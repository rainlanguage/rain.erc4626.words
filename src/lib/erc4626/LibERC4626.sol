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

/// @title LibERC4626
/// @notice Core library for interacting with ERC-4626 tokenised vaults on-chain.
/// Handles conversion between the float representation used by the Rain interpreter
/// and the fixed-point uint256 values expected by ERC-4626 contracts.
library LibERC4626 {
    /// Decodes a vault Float into its address and both decimal scales.
    /// Reads vault.decimals() then vault.asset() then assetToken.decimals(),
    /// giving both conversion functions a single, symmetric read path.
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
        assetDecimals = IERC20MetadataMinimal(vault.asset()).decimals();
    }

    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    /// Share amounts with sub-decimal precision are truncated toward zero (floor) before
    /// being forwarded to the vault, matching ERC-4626's documented floor-rounding convention.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return The equivalent amount of underlying assets, as a Rain Float.
    function convertToAssets(Float vaultFloat, Float sharesFloat) internal view returns (Float) {
        (IERC4626Minimal vault, uint8 shareDecimals, uint8 assetDecimals) = _decode(vaultFloat);
        // slither-disable-next-line unused-return
        (uint256 sharesRaw,) = LibDecimalFloat.toFixedDecimalLossy(sharesFloat, shareDecimals);
        uint256 assetsRaw = vault.convertToAssets(sharesRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    /// Asset amounts with sub-decimal precision are truncated toward zero (floor) before
    /// being forwarded to the vault, matching ERC-4626's documented floor-rounding convention.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return The equivalent number of vault shares, as a Rain Float.
    function convertToShares(Float vaultFloat, Float assetsFloat) internal view returns (Float) {
        (IERC4626Minimal vault, uint8 shareDecimals, uint8 assetDecimals) = _decode(vaultFloat);
        // slither-disable-next-line unused-return
        (uint256 assetsRaw,) = LibDecimalFloat.toFixedDecimalLossy(assetsFloat, assetDecimals);
        uint256 sharesRaw = vault.convertToShares(assetsRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
