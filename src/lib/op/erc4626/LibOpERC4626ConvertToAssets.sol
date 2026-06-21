// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626} from "../../erc4626/LibERC4626.sol";

library LibOpERC4626ConvertToAssets {
    /// Extern integrity for erc4626-convert-to-assets.
    /// Always requires 2 inputs (vault address, shares) and produces 1 output (assets).
    /// The OperandV2 parameter is unused; this word takes no operand-encoded configuration.
    /// The declared-inputs and declared-outputs counts are ignored; the fixed 2-in/1-out
    /// requirement is enforced here, not by the caller.
    /// @return The number of inputs required: 2 (vault address as Float, shares as Float).
    /// @return The number of outputs produced: 1 (assets as Float).
    function integrity(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Runs the erc4626-convert-to-assets operation.
    /// Reads the vault address and share amount from the stack, calls
    /// ERC-4626 convertToAssets, and pushes the resulting asset amount.
    /// Rounding follows ERC-4626 convertToAssets (rounds down, favors the vault).
    /// The OperandV2 parameter is unused; this word takes no operand-encoded configuration.
    /// @param inputs the inputs to the extern: [vault address as Float, shares as Float].
    /// @return outputs A single-element array containing the converted assets amount as a
    ///         Rain Float, re-encoded at the underlying asset token's decimal precision.
    function run(OperandV2, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
        Float vaultFloat;
        Float sharesFloat;
        assembly ("memory-safe") {
            vaultFloat := mload(add(inputs, 0x20))
            sharesFloat := mload(add(inputs, 0x40))
        }

        Float assetsFloat = LibERC4626.convertToAssets(vaultFloat, sharesFloat);

        StackItem[] memory outputs;
        assembly ("memory-safe") {
            outputs := mload(0x40)
            mstore(0x40, add(outputs, 0x40))
            mstore(outputs, 1)
            mstore(add(outputs, 0x20), assetsFloat)
        }
        return outputs;
    }
}
