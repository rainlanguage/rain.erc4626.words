// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {LibDecimalFloat, Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";

/// @dev Minimal interface for any token that exposes decimal precision.
/// Shared by both the vault (for share decimals) and the underlying asset
/// (for asset decimals) to avoid declaring the identical decimals() selector twice.
interface IDecimalsMinimal {
    function decimals() external view returns (uint8);
}

/// @dev Minimal ERC-4626 interface covering only the conversion functions and
/// vault metadata needed by the Rain words.
interface IERC4626Minimal is IDecimalsMinimal {
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
}

/// @title LibERC4626
/// @notice Core library for interacting with ERC-4626 tokenised vaults on-chain.
/// Handles conversion between the float representation used by the Rain interpreter
/// and the fixed-point uint256 values expected by ERC-4626 contracts.
library LibERC4626 {
    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return The equivalent amount of underlying assets, as a Rain Float.
    function convertToAssets(Float vaultFloat, Float sharesFloat) internal view returns (Float) {
        address vault = address(uint160(LibDecimalFloat.toFixedDecimalLossless(vaultFloat, 0)));

        uint8 shareDecimals = IERC4626Minimal(vault).decimals();
        address assetToken = IERC4626Minimal(vault).asset();
        uint8 assetDecimals = IDecimalsMinimal(assetToken).decimals();

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, shareDecimals);
        uint256 assetsRaw = IERC4626Minimal(vault).convertToAssets(sharesRaw);

        return LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The vault address is passed as a Float encoding of the address integer.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    /// @param vaultFloat Float encoding of the ERC-4626 vault contract address.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return The equivalent number of vault shares, as a Rain Float.
    function convertToShares(Float vaultFloat, Float assetsFloat) internal view returns (Float) {
        address vault = address(uint160(LibDecimalFloat.toFixedDecimalLossless(vaultFloat, 0)));

        address assetToken = IERC4626Minimal(vault).asset();
        uint8 assetDecimals = IDecimalsMinimal(assetToken).decimals();
        uint8 shareDecimals = IERC4626Minimal(vault).decimals();

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, assetDecimals);
        uint256 sharesRaw = IERC4626Minimal(vault).convertToShares(assetsRaw);

        return LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
