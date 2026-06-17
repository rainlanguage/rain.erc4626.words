// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibERC4626} from "src/lib/erc4626/LibERC4626.sol";
import {LibDecimalFloat, Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {MockERC4626, MockERC20} from "test/utils/MockERC4626.sol";

contract LibERC4626Test is Test {
    MockERC20 internal asset;
    MockERC4626 internal vault;

    /// @dev Set up a 1:1 vault with 18-decimal shares and 18-decimal assets.
    function setUp() external {
        asset = new MockERC20(18);
        // assetsPerShare = 1e18 means 1 share = 1 asset
        vault = new MockERC4626(18, address(asset), 1e18);
    }

    function testConvertToAssetsOneToOne() external view {
        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0);
        // 1.0 share
        Float sharesFloat = LibDecimalFloat.packLossless(1, 0);

        Float assetsFloat = LibERC4626.convertToAssets(vaultFloat, sharesFloat);

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, 18);
        assertEq(assetsRaw, 1e18, "1 share should be 1 asset in a 1:1 vault");
    }

    function testConvertToSharesOneToOne() external view {
        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0);
        // 1.0 asset
        Float assetsFloat = LibDecimalFloat.packLossless(1, 0);

        Float sharesFloat = LibERC4626.convertToShares(vaultFloat, assetsFloat);

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, 18);
        assertEq(sharesRaw, 1e18, "1 asset should be 1 share in a 1:1 vault");
    }

    function testConvertToAssetsTwoToOne() external {
        // 1 share = 2 assets
        MockERC4626 vault2 = new MockERC4626(18, address(asset), 2e18);

        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault2)))), 0);
        // 1.0 share
        Float sharesFloat = LibDecimalFloat.packLossless(1, 0);

        Float assetsFloat = LibERC4626.convertToAssets(vaultFloat, sharesFloat);

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, 18);
        assertEq(assetsRaw, 2e18, "1 share should be 2 assets in a 2:1 vault");
    }

    function testConvertToSharesHalfRate() external {
        // 1 share = 2 assets → 1 asset = 0.5 shares
        MockERC4626 vault2 = new MockERC4626(18, address(asset), 2e18);

        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault2)))), 0);
        // 2.0 assets
        Float assetsFloat = LibDecimalFloat.packLossless(2, 0);

        Float sharesFloat = LibERC4626.convertToShares(vaultFloat, assetsFloat);

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, 18);
        assertEq(sharesRaw, 1e18, "2 assets should be 1 share in a 2:1 vault");
    }

    function testConvertToAssetsWithSixDecimalAsset() external {
        // Simulate a vault backed by USDC (6 decimals) with 18-decimal shares
        MockERC20 usdc = new MockERC20(6);
        // 1 share = 1 USDC = 1e6 raw asset units
        MockERC4626 usdcVault = new MockERC4626(18, address(usdc), 1e6);

        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(usdcVault)))), 0);
        // 1.0 share
        Float sharesFloat = LibDecimalFloat.packLossless(1, 0);

        Float assetsFloat = LibERC4626.convertToAssets(vaultFloat, sharesFloat);

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, 6);
        assertEq(assetsRaw, 1e6, "1 share should be 1 USDC (1e6 raw) in a 1:1 USDC vault");
    }

    function testConvertToSharesWithSixDecimalAsset() external {
        MockERC20 usdc = new MockERC20(6);
        // 1 share = 1 USDC
        MockERC4626 usdcVault = new MockERC4626(18, address(usdc), 1e6);

        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(usdcVault)))), 0);
        // 1.0 USDC (represented as float)
        Float assetsFloat = LibDecimalFloat.packLossless(1, 0);

        Float sharesFloat = LibERC4626.convertToShares(vaultFloat, assetsFloat);

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, 18);
        assertEq(sharesRaw, 1e18, "1 USDC should be 1 share in a 1:1 USDC vault");
    }

    function testConvertToAssetsRoundsDownWithFractionalShares() external {
        // assetsPerShare=1 raw unit: 1 whole share (1e18 raw) gives 1 raw asset.
        // 0.5 shares (5e17 raw) → 5e17 * 1 / 1e18 = 0 (Solidity floor division).
        MockERC4626 v = new MockERC4626(18, address(asset), 1);
        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(v)))), 0);
        Float sharesFloat = LibDecimalFloat.packLossless(5, -1);
        Float assetsFloat = LibERC4626.convertToAssets(vaultFloat, sharesFloat);
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(assetsFloat, 18);
        assertEq(assetsRaw, 0, "fractional shares must round DOWN to 0 assets, never up");
    }

    function testConvertToSharesRoundsDownWithNonDivisibleRate() external {
        // 1 share = 3 assets: 1 asset → assets*1e18/assetsPerShare = 1e18*1e18/3e18 = 333333333333333333 (floor).
        MockERC4626 v3 = new MockERC4626(18, address(asset), 3e18);
        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(v3)))), 0);
        Float assetsFloat = LibDecimalFloat.packLossless(1, 0);
        Float sharesFloat = LibERC4626.convertToShares(vaultFloat, assetsFloat);
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(sharesFloat, 18);
        assertEq(sharesRaw, 333333333333333333, "convertToShares must round DOWN (favor protocol, not caller)");
        assertTrue(sharesRaw < 333333333333333334, "must not round up toward the interactive caller");
    }
}
