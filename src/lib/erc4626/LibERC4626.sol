// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {LibDecimalFloat, Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";

/// @dev Minimal ERC-4626 interface covering only the conversion functions and
/// metadata needed by the Rain words.
interface IERC4626Minimal {
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
}

/// @dev Minimal ERC-20 metadata interface for reading the underlying asset's
/// decimal precision.
interface IERC20MetadataMinimal {
    function decimals() external view returns (uint8);
}

/// @dev Upper bound on decimals accepted from vault and asset contracts. Values
/// above this would cause toFixedDecimalLossless to overflow uint256 for any
/// non-trivial Float, enabling denial-of-service by a malicious vault.
uint8 constant MAX_DECIMALS = 36;

/// Thrown when a vault or asset reports more decimals than MAX_DECIMALS.
/// @param token The vault or asset address that reported the excessive decimals.
/// @param decimals The reported decimals value.
error UnsupportedDecimals(address token, uint8 decimals);

/// @title LibERC4626
/// @notice Core library for interacting with ERC-4626 tokenised vaults on-chain.
/// Handles conversion between the float representation used by the Rain interpreter
/// and the fixed-point uint256 values expected by ERC-4626 contracts.
library LibERC4626 {
    /// Decodes a vault Float into its address and both decimal scales.
    /// Reads vault.decimals() then vault.asset() then assetToken.decimals(),
    /// giving both conversion functions a single, symmetric read path.
    /// Reverts with UnsupportedDecimals if either reported value exceeds MAX_DECIMALS.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @return vault The ERC-4626 vault contract.
    /// @return shareDecimals The decimal precision of the vault share token.
    /// @return assetDecimals The decimal precision of the underlying asset token.
    function _decode(Float vaultFloat)
        private
        view
        returns (IERC4626Minimal vault, uint8 shareDecimals, uint8 assetDecimals)
    {
        vault = IERC4626Minimal(address(uint160(LibDecimalFloat.toFixedDecimalLossless(vaultFloat, 0))));
        shareDecimals = vault.decimals();
        if (shareDecimals > MAX_DECIMALS) revert UnsupportedDecimals(address(vault), shareDecimals);
        address assetAddr = vault.asset();
        assetDecimals = IERC20MetadataMinimal(assetAddr).decimals();
        if (assetDecimals > MAX_DECIMALS) revert UnsupportedDecimals(assetAddr, assetDecimals);
    }

    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return The equivalent amount of underlying assets, as a Rain Float.
    function convertToAssets(Float vaultFloat, Float sharesFloat) internal view returns (Float) {
        (IERC4626Minimal vault, uint8 shareDecimals, uint8 assetDecimals) = _decode(vaultFloat);
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, shareDecimals);
        uint256 assetsRaw = vault.convertToAssets(sharesRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return The equivalent number of vault shares, as a Rain Float.
    function convertToShares(Float vaultFloat, Float assetsFloat) internal view returns (Float) {
        (IERC4626Minimal vault, uint8 shareDecimals, uint8 assetDecimals) = _decode(vaultFloat);
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, assetDecimals);
        uint256 sharesRaw = vault.convertToShares(assetsRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
