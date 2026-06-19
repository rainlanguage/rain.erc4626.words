// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {MockERC20} from "./MockERC20.sol";

/// @dev Minimal mock ERC-4626 vault for testing.
/// Exchange rate is expressed as assetsPerShare with assetDecimals precision,
/// i.e. assetsPerShare = (assets for 1 whole share) * 10**assetDecimals.
contract MockERC4626 {
    uint8 public decimals;
    address public asset;
    /// @dev Assets returned per 1 whole share (10**shareDecimals raw shares),
    /// expressed in raw asset units.
    uint256 public assetsPerShare;

    constructor(uint8 shareDecimals_, address asset_, uint256 assetsPerShare_) {
        decimals = shareDecimals_;
        asset = asset_;
        assetsPerShare = assetsPerShare_;
    }

    function convertToAssets(uint256 shares) external view returns (uint256) {
        return shares * assetsPerShare / (10 ** uint256(decimals));
    }

    function convertToShares(uint256 assets) external view returns (uint256) {
        return assets * (10 ** uint256(decimals)) / assetsPerShare;
    }
}
