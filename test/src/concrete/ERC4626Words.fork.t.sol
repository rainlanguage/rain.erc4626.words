// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {FORK_RPC_URL_BASE, FORK_BLOCK_BASE} from "test/lib/LibFork.sol";
import {LibOpERC4626ConvertToAssets} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";

address constant VAULT_BASE = 0x78c31580c97101694C70022c83D570150c11e935;

interface IERC4626Fork {
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
}

interface IERC20Fork {
    function decimals() external view returns (uint8);
}

contract ERC4626WordsForkTest is Test {
    IERC4626Fork internal vault;
    uint8 internal shareDecimals;
    uint8 internal assetDecimals;

    function setUp() external {
        vm.createSelectFork(FORK_RPC_URL_BASE, FORK_BLOCK_BASE);
        vault = IERC4626Fork(VAULT_BASE);
        shareDecimals = vault.decimals();
        assetDecimals = IERC20Fork(vault.asset()).decimals();
    }

    /// Verify convertToShares matches the vault's actual on-chain rate at the fork block.
    /// At block 46360198: convertToShares(1e18 assets) = 99730647641058807 shares (≈0.997 per asset).
    function testForkConvertToSharesMatchesVault() external view {
        uint256 assetsRaw = 10 ** assetDecimals;
        uint256 expectedSharesRaw = vault.convertToShares(assetsRaw);

        console2.log("assetsRaw (input to vault)", assetsRaw);
        console2.log("expectedSharesRaw (vault.convertToShares output)", expectedSharesRaw);

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(VAULT_BASE))), 0)));
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        console2.log(
            "actualShares (fixed decimal)",
            LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), shareDecimals)
        );

        Float expectedShares = LibDecimalFloat.fromFixedDecimalLosslessPacked(expectedSharesRaw, shareDecimals);
        assertEq(
            StackItem.unwrap(outputs[0]), Float.unwrap(expectedShares), "shares must match vault.convertToShares(1e18)"
        );
    }

    /// Verify convertToAssets matches the vault's actual on-chain rate at the fork block.
    /// At block 46360198: convertToAssets(1e18 shares) = 100270062609660912 assets (≈1.003 per share).
    function testForkConvertToAssetsMatchesVault() external view {
        uint256 sharesRaw = 10 ** shareDecimals;
        uint256 expectedAssetsRaw = vault.convertToAssets(sharesRaw);

        console2.log("sharesRaw (input to vault)", sharesRaw);
        console2.log("expectedAssetsRaw (vault.convertToAssets output)", expectedAssetsRaw);

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(VAULT_BASE))), 0)));
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        console2.log(
            "actualAssets (fixed decimal)",
            LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), assetDecimals)
        );

        Float expectedAssets = LibDecimalFloat.fromFixedDecimalLosslessPacked(expectedAssetsRaw, assetDecimals);
        assertEq(
            StackItem.unwrap(outputs[0]), Float.unwrap(expectedAssets), "assets must match vault.convertToAssets(1e18)"
        );
    }
}
