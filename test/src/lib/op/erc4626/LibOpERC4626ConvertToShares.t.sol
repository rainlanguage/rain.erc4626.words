// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {MockERC4626} from "test/utils/MockERC4626.sol";
import {MockERC20} from "test/utils/MockERC20.sol";
import {UnexpectedInputs} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";

contract LibOpERC4626ConvertToSharesTest is Test {
    MockERC20 internal asset;
    MockERC4626 internal vault;

    function setUp() external {
        asset = new MockERC20(18);
        vault = new MockERC4626(18, address(asset), 1e18);
    }

    function testIntegrity(OperandV2 operand, uint256 inputs, uint256 outputs) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC4626ConvertToShares.integrity(operand, inputs, outputs);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testRunOneToOne() external view {
        StackItem[] memory inputs = new StackItem[](2);
        // vault address encoded as Float
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 1.0 asset
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1, "should produce 1 output");

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(sharesRaw, 1e18, "1 asset should convert to 1 share in a 1:1 vault");
    }

    function testRunTwoAssets() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 2.0 assets
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(2, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1);

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(sharesRaw, 2e18, "2 assets should convert to 2 shares in a 1:1 vault");
    }

    function testRunTwoToOneVault() external {
        // 1 share = 2 assets → 1 asset = 0.5 shares
        MockERC4626 vault2 = new MockERC4626(18, address(asset), 2e18);

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault2)))), 0)));
        // 2.0 assets
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(2, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1);

        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(sharesRaw, 1e18, "2 assets should convert to 1 share in a 2:1 vault");
    }

    function testRunOutputIsNonZeroForNonZeroInput() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        assertTrue(StackItem.unwrap(outputs[0]) != bytes32(0), "output should be non-zero for non-zero input");
    }

    function _callRunShares(StackItem[] memory inputs) external view returns (StackItem[] memory) {
        return LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);
    }

    function testRunRevertsOnOneInput() external {
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        vm.expectRevert(abi.encodeWithSelector(UnexpectedInputs.selector, uint256(2), uint256(1)));
        this._callRunShares(inputs);
    }

    function testRunRevertsOnZeroInputs() external {
        StackItem[] memory inputs = new StackItem[](0);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedInputs.selector, uint256(2), uint256(0)));
        this._callRunShares(inputs);
    }
}
