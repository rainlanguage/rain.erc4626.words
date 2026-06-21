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
    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    /// The returned Float is re-encoded at the underlying asset token's decimal precision,
    /// which may differ from the share token's decimal precision.
    /// Rounding follows ERC-4626 convertToAssets (rounds down, favors the vault).
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return assetsFloat The equivalent amount of underlying assets, as a Rain Float
    ///         re-encoded at the underlying asset token's decimal precision.
    function convertToAssets(Float vaultFloat, Float sharesFloat) internal view returns (Float assetsFloat) {
        address vault = address(uint160(LibDecimalFloat.toFixedDecimalLossless(vaultFloat, 0)));

        uint8 shareDecimals = IERC4626Minimal(vault).decimals();
        address assetToken = IERC4626Minimal(vault).asset();
        uint8 assetDecimals = IERC20MetadataMinimal(assetToken).decimals();

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, shareDecimals);
        uint256 assetsRaw = IERC4626Minimal(vault).convertToAssets(sharesRaw);

        assetsFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    /// The returned Float is re-encoded at the vault share token's decimal precision,
    /// which may differ from the underlying asset's decimal precision.
    /// Rounding follows ERC-4626 convertToShares (rounds down, favors the vault).
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return sharesFloat The equivalent number of vault shares, as a Rain Float
    ///         re-encoded at the vault share token's decimal precision.
    function convertToShares(Float vaultFloat, Float assetsFloat) internal view returns (Float sharesFloat) {
        address vault = address(uint160(LibDecimalFloat.toFixedDecimalLossless(vaultFloat, 0)));

        address assetToken = IERC4626Minimal(vault).asset();
        uint8 assetDecimals = IERC20MetadataMinimal(assetToken).decimals();
        uint8 shareDecimals = IERC4626Minimal(vault).decimals();

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, assetDecimals);
        uint256 sharesRaw = IERC4626Minimal(vault).convertToShares(assetsRaw);

        sharesFloat = LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
