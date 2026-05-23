// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std/Test.sol";
import {St0xWords} from "src/concrete/St0xWords.sol";
import {LibOpERC4626ConvertToAssets} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain.interpreter.interface/interface/unstable/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain.math.float/lib/LibDecimalFloat.sol";
import {MockERC4626, MockERC20} from "test/utils/MockERC4626.sol";

/// @notice Tests St0xWords ERC-4626 extern dispatch directly (bypassing the parser).
contract St0xWordsConversionsTest is Test {
    MockERC20 internal asset;
    MockERC4626 internal vault;
    St0xWords internal st0xWords;

    function setUp() external {
        asset = new MockERC20(18);
        vault = new MockERC4626(18, address(asset), 1e18);
        st0xWords = new St0xWords();
    }

    function testConvertToAssetsDispatch() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 1.0 share
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1, "convertToAssets should produce 1 output");
        assertTrue(StackItem.unwrap(outputs[0]) != bytes32(0), "output should be non-zero");

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(assetsRaw, 1e18, "1 share should be 1 asset");
    }

    function testConvertToSharesDispatch() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 1.0 asset
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1, "convertToShares should produce 1 output");
        assertTrue(StackItem.unwrap(outputs[0]) != bytes32(0), "output should be non-zero");

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(sharesRaw, 1e18, "1 asset should be 1 share");
    }

    function testSt0xWordsDeploysSuccessfully() external view {
        assertTrue(address(st0xWords) != address(0), "St0xWords should deploy");
    }

    function testConvertToAssetsAndSharesRoundTrip() external view {
        Float vaultFloat = LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0);
        // Start with 3.5 shares
        Float sharesIn = LibDecimalFloat.packLossless(35, -1);

        StackItem[] memory assetsInputs = new StackItem[](2);
        assetsInputs[0] = StackItem.wrap(Float.unwrap(vaultFloat));
        assetsInputs[1] = StackItem.wrap(Float.unwrap(sharesIn));

        StackItem[] memory assetsOutputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), assetsInputs);

        // Convert back to shares
        StackItem[] memory sharesInputs = new StackItem[](2);
        sharesInputs[0] = StackItem.wrap(Float.unwrap(vaultFloat));
        sharesInputs[1] = assetsOutputs[0];

        StackItem[] memory sharesOutputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), sharesInputs);

        // In a 1:1 vault, shares_out should equal shares_in (within rounding)
        uint256 sharesOutRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(sharesOutputs[0])), 18);
        uint256 sharesInRaw = LibDecimalFloat.toFixedDecimalLossless(sharesIn, 18);
        assertEq(sharesOutRaw, sharesInRaw, "round-trip should return original share amount in 1:1 vault");
    }
}
