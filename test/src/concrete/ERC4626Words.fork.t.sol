// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {
    FORK_RPC_URL_BASE,
    FORK_BLOCK_BASE,
    WT_NVDA,
    WT_AMZN,
    WT_TSLA,
    WT_MSTR,
    WT_IAU,
    WT_COIN,
    WT_SPYM,
    WT_SIVR,
    WT_CRCL,
    WT_BMNR,
    WT_PPLT,
    WT_QQQM,
    WT_VWO,
    WT_ARKK,
    WT_SGOV
} from "test/lib/LibFork.sol";
import {LibOpERC4626ConvertToAssets} from "src/lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {LibOpERC4626ConvertToShares} from "src/lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {OperandV2, StackItem} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {VaultFloat} from "test/utils/VaultFloat.sol";

interface IERC4626Fork {
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
    function convertToAssets(uint256 shares) external view returns (uint256 assets);
    function convertToShares(uint256 assets) external view returns (uint256 shares);
}

interface IERC20Fork {
    function decimals() external view returns (uint8);
}

contract ERC4626WordsForkTest is Test {
    function setUp() external {
        vm.createSelectFork(vm.envOr("FORK_RPC_URL_BASE", FORK_RPC_URL_BASE), FORK_BLOCK_BASE);
    }

    /// @dev Encode assets (raw) as a Float and run convertToShares, returning raw shares.
    function assetsToShares(address vaultAddress, uint256 assetsRaw) internal view returns (uint256 sharesRaw) {
        IERC4626Fork vault_ = IERC4626Fork(vaultAddress);
        uint8 shareDecimals_ = vault_.decimals();
        uint8 assetDecimals_ = IERC20Fork(vault_.asset()).decimals();

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = VaultFloat.packStackItem(vaultAddress);
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals_)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);
        sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), shareDecimals_);
    }

    /// @dev Encode shares (raw) as a Float and run convertToAssets, returning raw assets.
    function sharesToAssets(address vaultAddress, uint256 sharesRaw) internal view returns (uint256 assetsRaw) {
        IERC4626Fork vault_ = IERC4626Fork(vaultAddress);
        uint8 shareDecimals_ = vault_.decimals();
        uint8 assetDecimals_ = IERC20Fork(vault_.asset()).decimals();

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] = VaultFloat.packStackItem(vaultAddress);
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals_)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);
        assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), assetDecimals_);
    }

    /// @dev Assert both ERC4626 word directions match the vault's own functions at the fork block.
    ///      Uses one whole share / one whole asset unit as input so the float round-trip is lossless.
    ///      Expected values come from the vault directly, so non-1:1 exchange rates are tested correctly
    ///      and an assets/shares transposition in the word dispatch would be detected.
    function checkVault(address vaultAddr, string memory label) internal view {
        IERC4626Fork vault_ = IERC4626Fork(vaultAddr);
        uint8 shareDecimals_ = vault_.decimals();
        uint8 assetDecimals_ = IERC20Fork(vault_.asset()).decimals();

        uint256 oneShareRaw = 10 ** uint256(shareDecimals_);
        uint256 oneAssetRaw = 10 ** uint256(assetDecimals_);

        uint256 expectedAssets = vault_.convertToAssets(oneShareRaw);
        uint256 actualAssets = sharesToAssets(vaultAddr, oneShareRaw);
        assertEq(actualAssets, expectedAssets, string.concat(label, ": sharesToAssets mismatch"));

        uint256 expectedShares = vault_.convertToShares(oneAssetRaw);
        uint256 actualShares = assetsToShares(vaultAddr, oneAssetRaw);
        assertEq(actualShares, expectedShares, string.concat(label, ": assetsToShares mismatch"));
    }

    function testForkVaults() external view {
        address[] memory addrs = new address[](15);
        string[] memory labels = new string[](15);
        addrs[0] = WT_NVDA;
        labels[0] = "NVDA";
        addrs[1] = WT_AMZN;
        labels[1] = "AMZN";
        addrs[2] = WT_TSLA;
        labels[2] = "TSLA";
        addrs[3] = WT_MSTR;
        labels[3] = "MSTR";
        addrs[4] = WT_IAU;
        labels[4] = "IAU";
        addrs[5] = WT_COIN;
        labels[5] = "COIN";
        addrs[6] = WT_SPYM;
        labels[6] = "SPYM";
        addrs[7] = WT_SIVR;
        labels[7] = "SIVR";
        addrs[8] = WT_CRCL;
        labels[8] = "CRCL";
        addrs[9] = WT_BMNR;
        labels[9] = "BMNR";
        addrs[10] = WT_PPLT;
        labels[10] = "PPLT";
        addrs[11] = WT_QQQM;
        labels[11] = "QQQM";
        addrs[12] = WT_VWO;
        labels[12] = "VWO";
        addrs[13] = WT_ARKK;
        labels[13] = "ARKK";
        addrs[14] = WT_SGOV;
        labels[14] = "SGOV";
        for (uint256 i = 0; i < addrs.length; i++) {
            checkVault(addrs[i], labels[i]);
        }
    }
}
