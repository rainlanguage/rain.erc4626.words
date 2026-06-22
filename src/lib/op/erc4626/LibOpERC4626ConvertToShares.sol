// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {LibERC4626} from "../../erc4626/LibERC4626.sol";

library LibOpERC4626ConvertToShares {
    /// Extern integrity for erc4626-convert-to-shares.
    /// Always requires 2 inputs (vault address, assets) and produces 1 output (shares).
    function integrity(OperandV2, uint256, uint256) internal pure returns (uint256, uint256) {
        return (2, 1);
    }

    /// Runs the erc4626-convert-to-shares operation.
    /// Reads the vault address and asset amount from the stack, calls
    /// ERC-4626 convertToShares, and pushes the resulting share amount.
    /// @param inputs the inputs to the extern: [vault address as Float, assets as Float].
    function run(OperandV2, StackItem[] memory inputs) internal view returns (StackItem[] memory) {
        Float vaultFloat = Float.wrap(StackItem.unwrap(inputs[0]));
        Float assetsFloat = Float.wrap(StackItem.unwrap(inputs[1]));

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
