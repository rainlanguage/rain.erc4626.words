// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @dev Minimal mock of an ERC-20 token for use as the underlying asset in tests.
contract MockERC20 {
    uint8 public decimals;

    constructor(uint8 decimals_) {
        decimals = decimals_;
    }
}
