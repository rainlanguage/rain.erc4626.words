// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626} from "../../erc4626/LibERC4626.sol";

library LibOpERC4626ConvertToShares {
    /// Extern integrity for erc4626-convert-to-shares.
    /// Always requires 2 inputs (vault address, assets) and produces 1 output (shares).
    /// The OperandV2 parameter is unused; this word takes no operand-encoded configuration.
    /// The declared-inputs and declared-outputs parameters are intentionally ignored; arity
    /// is fixed at 2-in/1-out and is enforced by the parser comparing these return values
    /// against the declared counts in the source expression.
    /// @return The number of inputs required: 2 (vault address as Float, assets as Float).
    /// @return The number of outputs produced: 1 (shares as Float).
    function integrity(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Runs the erc4626-convert-to-shares operation.
    /// Reads the vault address and asset amount from the stack, calls
    /// ERC-4626 convertToShares, and pushes the resulting share amount.
    /// Rounding follows ERC-4626 convertToShares (rounds down, favors the vault).
    /// The OperandV2 parameter is unused; this word takes no operand-encoded configuration.
    /// @param inputs [vault address as Float, assets as Float interpreted at the
    ///        underlying asset token's decimal precision].
    /// @return outputs A single-element array containing the converted shares amount as a
    ///         Rain Float, re-encoded at the vault share token's decimal precision.
    function run(OperandV2, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
        Float vaultFloat;
        Float assetsFloat;
        assembly ("memory-safe") {
            vaultFloat := mload(add(inputs, 0x20))
            assetsFloat := mload(add(inputs, 0x40))
        }

        Float sharesFloat = LibERC4626.convertToShares(vaultFloat, assetsFloat);

        StackItem[] memory outputs;
        assembly ("memory-safe") {
            outputs := mload(0x40)
            mstore(0x40, add(outputs, 0x40))
            mstore(outputs, 1)
            mstore(add(outputs, 0x20), sharesFloat)
        }
        return outputs;
    }
}
