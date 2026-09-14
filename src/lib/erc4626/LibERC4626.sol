// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {LibDecimalFloat, Float} from "rain-math-float-0.2.1/src/lib/LibDecimalFloat.sol";

/// @dev Minimal ERC-20 metadata interface for reading a token's decimal
/// precision. Used for the underlying asset and, via IERC4626Minimal, for the
/// vault share token itself.
interface IERC20MetadataMinimal {
    function decimals() external view returns (uint8);
}

/// @dev Minimal ERC-4626 interface covering only the conversion functions and
/// metadata needed by the Rain words. Inherits decimals() from
/// IERC20MetadataMinimal, reflecting that every ERC-4626 vault is also an
/// ERC-20 token.
interface IERC4626Minimal is IERC20MetadataMinimal {
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
}

/// @title LibERC4626
/// @notice Core library for interacting with ERC-4626 tokenised vaults on-chain.
/// Takes the vault as a typed contract reference and handles conversion of the
/// AMOUNTS between the float representation used by the Rain interpreter and
/// the fixed-point uint256 values expected by ERC-4626 contracts.
library LibERC4626 {
    /// Reads the share and underlying-asset decimal scales from the vault:
    /// vault.decimals() then vault.asset() then assetToken.decimals(), giving
    /// both conversion functions a single, symmetric read path.
    /// @param vault The ERC-4626 vault contract.
    /// @return shareDecimals The decimal precision of the vault share token.
    /// @return assetDecimals The decimal precision of the underlying asset token.
    function _vaultScales(IERC4626Minimal vault) private view returns (uint8 shareDecimals, uint8 assetDecimals) {
        shareDecimals = vault.decimals();
        assetDecimals = IERC20MetadataMinimal(vault.asset()).decimals();
    }

    /// @notice Converts vault shares to underlying assets via ERC-4626 convertToAssets.
    /// The shares amount is passed as a Rain Float with the vault's share decimals.
    /// @dev ERC-4626 mandates that convertToAssets rounds DOWN (toward zero). The result
    /// is therefore the floor of the true share-to-asset conversion, not an exact equivalent.
    /// Callers must ensure that under-counting assets is safe for their use-site
    /// (i.e. the non-interactive party is not shorted by the floor rounding).
    /// @dev Reverts if `sharesFloat` cannot be losslessly represented at the vault's share
    /// decimal precision (e.g. a Float encoding 1e-19 with an 18-decimal vault).
    /// @param vault The ERC-4626 vault contract.
    /// @param sharesFloat The number of shares to convert, as a Rain Float.
    /// @return The equivalent amount of underlying assets, as a Rain Float
    /// re-encoded at the underlying asset token's decimals (not the share
    /// decimals the input was decoded at).
    function convertToAssets(IERC4626Minimal vault, Float sharesFloat) internal view returns (Float) {
        (uint8 shareDecimals, uint8 assetDecimals) = _vaultScales(vault);
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, shareDecimals);
        uint256 assetsRaw = vault.convertToAssets(sharesRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals);
    }

    /// @notice Converts underlying assets to vault shares via ERC-4626 convertToShares.
    /// The assets amount is passed as a Rain Float with the underlying asset's decimals.
    /// @dev ERC-4626 mandates that convertToShares rounds DOWN (toward zero). The result
    /// is therefore the floor of the true asset-to-share conversion, not an exact equivalent.
    /// Callers must ensure that under-counting shares is safe for their use-site
    /// (i.e. the non-interactive party is not shorted by the floor rounding).
    /// @dev Reverts if `assetsFloat` cannot be losslessly represented at the underlying
    /// asset's decimal precision (e.g. a Float encoding 1e-7 with a 6-decimal asset).
    /// @param vault The ERC-4626 vault contract.
    /// @param assetsFloat The amount of underlying assets to convert, as a Rain Float.
    /// @return The equivalent number of vault shares, as a Rain Float
    /// re-encoded at the vault share token's decimals (not the asset decimals
    /// the input was decoded at).
    function convertToShares(IERC4626Minimal vault, Float assetsFloat) internal view returns (Float) {
        (uint8 shareDecimals, uint8 assetDecimals) = _vaultScales(vault);
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, assetDecimals);
        uint256 sharesRaw = vault.convertToShares(assetsRaw);
        return LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals);
    }
}
