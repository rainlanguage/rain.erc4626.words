// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626} from "../../erc4626/LibERC4626.sol";

library LibOpERC4626ConvertToAssets {
    /// @notice Extern integrity for erc4626-convert-to-assets.
    /// Always requires 2 inputs (vault address, shares) and produces 1 output (assets).
    /// @param operand Not used; erc4626-convert-to-assets takes no operand.
    /// @param stackInputs Not used; arity is fixed regardless of declared stack state.
    /// @param stackOutputs Not used; arity is fixed regardless of declared stack state.
    /// @return Always 2 (vault address, shares).
    /// @return Always 1 (assets).
    function integrity(OperandV2 operand, uint256 stackInputs, uint256 stackOutputs)
        internal
        pure
        returns (uint256, uint256)
    {
        return (2, 1);
    }

    /// @notice Runs the erc4626-convert-to-assets operation.
    /// Reads the vault address and share amount from the stack, calls
    /// ERC-4626 `convertToAssets`, and pushes the resulting asset amount.
    /// Conversion rounds down (floor) per ERC-4626 spec. The share amount
    /// must be exactly representable in the vault's share decimals; reverts
    /// on precision loss.
    /// @param operand Not used; no operand is accepted for this word.
    /// @param inputs Stack items: [0] vault address as Float (packed integer),
    /// [1] shares as Float.
    /// @return 1-element array: [assets as Float].
    /// @dev Assembly reads at `inputs[0]` (`add(inputs, 0x20)`) and `inputs[1]`
    /// (`add(inputs, 0x40)`) are safe: `integrity()` enforces `inputs.length == 2`
    /// before the interpreter dispatches `run()`.
    function run(OperandV2 operand, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
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
