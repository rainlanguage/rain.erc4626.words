// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

/// @dev Adversarial ERC-4626 vault that always returns type(uint256).max from
/// both convertToAssets and convertToShares, simulating a malicious or broken
/// vault that produces values too large to represent as a Rain Float.
contract MaliciousERC4626 {
    uint8 public decimals;
    address public asset;

    constructor(uint8 decimals_, address asset_) {
        decimals = decimals_;
        asset = asset_;
    }

    function convertToAssets(uint256) external pure returns (uint256) {
        return type(uint256).max;
    }

    function convertToShares(uint256) external pure returns (uint256) {
        return type(uint256).max;
    }
}
