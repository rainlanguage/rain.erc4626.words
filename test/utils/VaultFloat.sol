// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";

/// @notice Canonical encoder/decoder for the address-as-Float convention used
/// by the ERC-4626 words. An address is packed as a whole-number Float at
/// exponent 0, matching the `toFixedDecimalLossless(vaultFloat, 0)` decode in
/// LibERC4626. Centralises the encoding so tests stay in sync with production.
library VaultFloat {
    /// Pack an ERC-4626 vault address as a Rain Float (exponent 0, whole number).
    /// @param vault The vault contract address.
    /// @return The Float encoding of the address integer.
    function pack(address vault) internal pure returns (Float) {
        return LibDecimalFloat.packLossless(int256(uint256(uint160(vault))), 0);
    }

    /// Pack a vault address as a StackItem for use in extern inputs arrays.
    /// @param vault The vault contract address.
    /// @return The StackItem wrapping the Float-encoded address.
    function packStackItem(address vault) internal pure returns (StackItem) {
        return StackItem.wrap(Float.unwrap(pack(vault)));
    }
}
