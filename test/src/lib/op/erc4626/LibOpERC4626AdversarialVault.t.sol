// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {LibOpERC4626ConvertToAssets} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LossyConversionToFloat} from "rain-math-float-0.1.1/src/error/ErrDecimalFloat.sol";
import {MockERC20} from "test/utils/MockERC20.sol";
import {MaliciousERC4626} from "test/utils/MaliciousERC4626.sol";
import {VaultFloat} from "test/utils/VaultFloat.sol";

/// @notice Tests that an adversarial vault returning type(uint256).max causes a
/// revert with LossyConversionToFloat rather than silent data corruption.
/// Covers issues #88 (adversarial convertToAssets), #107 (adversarial
/// convertToShares), and #153 (MockERC4626 cannot model adversarial scenarios).
contract LibOpERC4626AdversarialVaultTest is Test {
    MockERC20 internal asset;
    MaliciousERC4626 internal malVault;

    function setUp() external {
        asset = new MockERC20(18);
        malVault = new MaliciousERC4626(18, address(asset));
    }

    /// External wrapper so vm.expectRevert crosses a call boundary.
    function runConvertToAssets(StackItem[] calldata inputs) external view returns (StackItem[] memory) {
        StackItem[] memory memInputs = new StackItem[](inputs.length);
        for (uint256 i = 0; i < inputs.length; i++) {
            memInputs[i] = inputs[i];
        }
        return LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), memInputs);
    }

    /// External wrapper so vm.expectRevert crosses a call boundary.
    function runConvertToShares(StackItem[] calldata inputs) external view returns (StackItem[] memory) {
        StackItem[] memory memInputs = new StackItem[](inputs.length);
        for (uint256 i = 0; i < inputs.length; i++) {
            memInputs[i] = inputs[i];
        }
        return LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), memInputs);
    }

    /// An adversarial vault returning type(uint256).max from convertToAssets
    /// must revert with LossyConversionToFloat, not silently corrupt the result.
    function testAdversarialConvertToAssetsReverts() external {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = VaultFloat.packStackItem(address(malVault));
        inputs[1] = VaultFloat.floatStackItem(1, 0);

        // type(uint256).max / 10 fits in int256; exponent shifts by +1 because the
        // value exceeded int256 max and was divided by 10 inside fromFixedDecimalLossy.
        vm.expectRevert(
            abi.encodeWithSelector(LossyConversionToFloat.selector, int256(type(uint256).max / 10), int256(-17))
        );
        this.runConvertToAssets(inputs);
    }

    /// An adversarial vault returning type(uint256).max from convertToShares
    /// must revert with LossyConversionToFloat, not silently corrupt the result.
    function testAdversarialConvertToSharesReverts() external {
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = VaultFloat.packStackItem(address(malVault));
        inputs[1] = VaultFloat.floatStackItem(1, 0);

        vm.expectRevert(
            abi.encodeWithSelector(LossyConversionToFloat.selector, int256(type(uint256).max / 10), int256(-17))
        );
        this.runConvertToShares(inputs);
    }
}
