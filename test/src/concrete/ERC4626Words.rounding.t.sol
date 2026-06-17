// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {OPCODE_ERC4626_CONVERT_TO_ASSETS, OPCODE_ERC4626_CONVERT_TO_SHARES} from "src/abstract/ERC4626Extern.sol";
import {ExternDispatchV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterExternV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {MockERC4626} from "test/utils/MockERC4626.sol";
import {MockERC20} from "test/utils/MockERC20.sol";

/// @notice Fuzz tests asserting that sub-decimal inputs never revert.
/// A vault with 18-decimal shares and a 6-decimal asset at a non-unity rate
/// produces fractional raw amounts when given arbitrary Float inputs.
/// The words must truncate (floor) rather than revert.
contract ERC4626WordsRoundingTest is Test {
    ERC4626Words internal words;
    MockERC20 internal asset;
    MockERC4626 internal vault;

    /// @dev 1 share = 1.123456 USDC (non-unity rate, 18-decimal shares, 6-decimal asset).
    uint256 internal constant ASSETS_PER_SHARE = 1123456;

    function setUp() external {
        words = new ERC4626Words();
        asset = new MockERC20(6);
        vault = new MockERC4626(18, address(asset), ASSETS_PER_SHARE);
    }

    function makeDispatch(uint256 opcode) internal pure returns (ExternDispatchV2) {
        return ExternDispatchV2.wrap(bytes32(uint256(opcode) << 16));
    }

    function vaultItem() internal view returns (StackItem) {
        // forge-lint: disable-next-line(unsafe-typecast)
        return StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(address(vault)))), 0)));
    }

    /// @notice An asset amount with 7 decimal places passed to convertToShares must
    /// not revert even though the vault only has 6-decimal precision. The 7th decimal
    /// digit is truncated (floor) before forwarding to the vault.
    function testFuzzConvertToSharesSubDecimalNeverReverts(int56 significand) external view {
        vm.assume(significand > 0);
        // 7 decimal places, but asset only has 6 — would revert with the old lossless conversion.
        Float assetsFloat = LibDecimalFloat.packLossless(int256(significand), -7);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = vaultItem();
        inputs[1] = StackItem.wrap(Float.unwrap(assetsFloat));
        words.extern(makeDispatch(OPCODE_ERC4626_CONVERT_TO_SHARES), inputs);
    }

    /// @notice A share amount with 19 decimal places passed to convertToAssets must
    /// not revert even though the vault only has 18-decimal precision. The excess digit
    /// is truncated (floor) before forwarding to the vault.
    function testFuzzConvertToAssetsSubDecimalNeverReverts(int56 significand) external view {
        vm.assume(significand > 0);
        // 19 decimal places, but shares have 18 — would revert with the old lossless conversion.
        Float sharesFloat = LibDecimalFloat.packLossless(int256(significand), -19);
        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = vaultItem();
        inputs[1] = StackItem.wrap(Float.unwrap(sharesFloat));
        words.extern(makeDispatch(OPCODE_ERC4626_CONVERT_TO_ASSETS), inputs);
    }
}
