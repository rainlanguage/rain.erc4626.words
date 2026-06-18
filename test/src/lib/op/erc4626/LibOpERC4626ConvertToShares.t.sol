// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LossyConversionFromFloat} from "rain-math-float-0.1.1/src/error/ErrDecimalFloat.sol";
import {MockERC4626, MockERC20} from "test/utils/MockERC4626.sol";

contract LibOpERC4626ConvertToSharesTest is Test {
    MockERC20 internal asset;
    MockERC4626 internal vault;

    function setUp() external {
        asset = new MockERC20(18);
        vault = new MockERC4626(18, address(asset), 1e18);
    }

    function _callRunShares(StackItem[] memory inputs) external view returns (StackItem[] memory) {
        return LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);
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

    function testRunRoundsSharesDown() external {
        // vault: 1 share = 3 assets. convertToShares(1 asset) = floor(1/3) shares = 0.333...
        MockERC4626 vault3 = new MockERC4626(18, address(asset), 3e18);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault3)))), 0)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);

        // vault.convertToShares(1e18) = floor(1e18 * 1e18 / 3e18) = 333333333333333333
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), 18);
        assertEq(sharesRaw, 333333333333333333, "shares must floor down (favor vault)");
        assertLt(sharesRaw, 333333333333333334, "shares must not round up");
    }

    function testRunRevertsOnNonIntegerVaultFloat() external {
        StackItem[] memory inputs = new StackItem[](2);
        // vaultFloat = 0.5 — not representable as a uint160 address integer
        inputs[0] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(5, -1)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(1, 0)));
        vm.expectRevert(abi.encodeWithSelector(LossyConversionFromFloat.selector, int256(5), int256(-1)));
        this._callRunShares(inputs);
    }

    function testRunRevertsOnLossyAssetsInput() external {
        // vault with 0 asset decimals; 0.5 assets cannot be represented losslessly at 0 decimals
        MockERC20 asset0 = new MockERC20(0);
        MockERC4626 vault0 = new MockERC4626(0, address(asset0), 1);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault0)))), 0)));
        inputs[1] = StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(5, -1)));
        vm.expectRevert(abi.encodeWithSelector(LossyConversionFromFloat.selector, int256(5), int256(-1)));
        this._callRunShares(inputs);
    }
}
