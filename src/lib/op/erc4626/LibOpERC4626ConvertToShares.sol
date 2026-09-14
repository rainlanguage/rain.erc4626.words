// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rainlang-interface-0.2.9/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.2.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626, IERC4626Minimal} from "../../erc4626/LibERC4626.sol";
import {NotAnAddress} from "rainlang-0.2.6/src/error/ErrRainType.sol";

error UnexpectedInputs(uint256 expected, uint256 actual);

library LibOpERC4626ConvertToShares {
    /// Extern integrity for erc4626-convert-to-shares.
    /// Always requires 2 inputs (vault address, assets) and produces 1 output (shares).
    /// The OperandV2 parameter is unused; this word takes no operand-encoded configuration.
    /// The declared-inputs and declared-outputs parameters are intentionally ignored; arity
    /// is fixed at 2-in/1-out and is enforced by the parser comparing these return values
    /// against the declared counts in the source expression.
    /// @return The number of inputs required: 2 (vault address as raw stack bits, assets as Float).
    /// @return The number of outputs produced: 1 (shares as Float).
    function integrity(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Runs the erc4626-convert-to-shares operation.
    /// Reads the vault address (raw stack bits) and asset amount from the
    /// stack, calls ERC-4626 convertToShares, and pushes the resulting share
    /// amount. Rounding follows the vault's convertToShares: per EIP-4626
    /// this rounds DOWN (toward zero), favouring the vault; the caller
    /// receives fewer shares than the exact mathematical result.
    /// @dev This word performs no validation of the vault or its returned
    /// values beyond Float packing; the result carries whatever trust the
    /// expression places in the vault it names.
    /// @param operand Unused operand for this extern word.
    /// @param inputs [vault address as raw stack bits, assets as Float
    /// interpreted at the underlying asset token's decimals].
    /// @return outputs a single-element stack: [shares as Float at the vault's
    /// share decimals, rounded down per the vault's convertToShares].
    function run(OperandV2 operand, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
        if (inputs.length < 2) revert UnexpectedInputs(2, inputs.length);
        bytes32 vault;
        Float assetsFloat;
        assembly ("memory-safe") {
            vault := mload(add(inputs, 0x20))
            assetsFloat := mload(add(inputs, 0x40))
        }

        // It is the rainlang author's responsibility to ensure the correctness
        // of vault as an address.
        // Casting to `uint160` is intentional to detect non-address values.
        //forge-lint: disable-next-line(unsafe-typecast)
        if (uint256(vault) != uint256(uint160(uint256(vault)))) revert NotAnAddress(vault);

        // Casting to `uint160` is safe because `NotAnAddress` above
        // ensures the value fits in 160 bits.
        //forge-lint: disable-next-line(unsafe-typecast)
        Float sharesFloat = LibERC4626.convertToShares(IERC4626Minimal(address(uint160(uint256(vault)))), assetsFloat);

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
