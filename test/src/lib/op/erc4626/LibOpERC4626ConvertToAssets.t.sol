// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibOpERC4626ConvertToAssets} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LossyConversionFromFloat} from "rain-math-float-0.1.1/src/error/ErrDecimalFloat.sol";
import {MockERC4626, MockERC20} from "test/utils/MockERC4626.sol";
import {UnexpectedInputs} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";

contract LibOpERC4626ConvertToAssetsTest is Test {
    MockERC20 internal asset;
    MockERC4626 internal vault;

    function setUp() external {
        asset = new MockERC20(18);
        vault = new MockERC4626(18, address(asset), 1e18);
    }

    function testIntegrity(OperandV2 operand, uint256 inputs, uint256 outputs) external pure {
        (uint256 calcInputs, uint256 calcOutputs) = LibOpERC4626ConvertToAssets.integrity(operand, inputs, outputs);
        assertEq(calcInputs, 2);
        assertEq(calcOutputs, 1);
    }

    function testRunOneToOne() external view {
        StackItem[] memory inputs = new StackItem[](2);
        // vault address encoded as Float (address as integer with exponent 0)
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 1.0 share
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1, "should produce 1 output");

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(assetsRaw, 1e18, "1 share should convert to 1 asset in a 1:1 vault");
    }

    function testRunTwoShares() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 2.0 shares
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(2, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1);

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(assetsRaw, 2e18, "2 shares should convert to 2 assets in a 1:1 vault");
    }

    function testRunTwoToOneVault() external {
        // 1 share = 2 assets
        MockERC4626 vault2 = new MockERC4626(18, address(asset), 2e18);

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault2)))), 0)));
        // 1.0 share
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        assertEq(outputs.length, 1);

        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(assetsRaw, 2e18, "1 share should convert to 2 assets in a 2:1 vault");
    }

    function testRunOutputIsNonZeroForNonZeroInput() external view {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);

        assertTrue(StackItem.unwrap(outputs[0]) != bytes32(0), "output should be non-zero for non-zero input");
    }

    function _callRunAssets(StackItem[] memory inputs) external view returns (StackItem[] memory) {
        return LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);
    }

    function testRunRevertsOnOneInput() external {
        StackItem[] memory inputs = new StackItem[](1);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        vm.expectRevert(abi.encodeWithSelector(UnexpectedInputs.selector, uint256(2), uint256(1)));
        this._callRunAssets(inputs);
    }

    function testRunRevertsOnZeroInputs() external {
        StackItem[] memory inputs = new StackItem[](0);
        vm.expectRevert(abi.encodeWithSelector(UnexpectedInputs.selector, uint256(2), uint256(0)));
        this._callRunAssets(inputs);
    }

    function runExternal(StackItem[] memory inputs) external view returns (StackItem[] memory) {
        return LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);
    }

    function testRunRevertsOnLossyShareInput() external {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
        // 1e-19 shares: finer than the vault's 18 decimals, cannot be converted losslessly to uint256
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, -19)));
        vm.expectRevert(abi.encodeWithSelector(LossyConversionFromFloat.selector, int256(1), int256(-19)));
        this.runExternal(inputs);
    }

    function testRunRoundsDownOnPrecisionLoss() external {
        // assetsPerShare = 1e18/3 = 333333333333333333; 1 share rounds down to 333333333333333333 assets
        MockERC4626 vault3 = new MockERC4626(18, address(asset), uint256(1e18) / 3);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault3)))), 0)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(assetsRaw, 333333333333333333, "convertToAssets must round DOWN (floor)");
        assertLt(assetsRaw, uint256(1e18) / 3 + 1, "must not round up");
    }
}
