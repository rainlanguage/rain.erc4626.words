// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {
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

interface IERC4626Fork {
    function decimals() external view returns (uint8);
    function asset() external view returns (address);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
}

interface IERC20Fork {
    function decimals() external view returns (uint8);
}

contract ERC4626WordsForkTest is Test {
    function setUp() external {
        vm.createSelectFork("base", FORK_BLOCK_BASE);
    }

    function assetsToShares(address vaultAddress, uint256 assetsRaw) internal view returns (uint256 sharesRaw) {
        IERC4626Fork vault_ = IERC4626Fork(vaultAddress);
        uint8 shareDecimals_ = vault_.decimals();
        uint8 assetDecimals_ = IERC20Fork(vault_.asset()).decimals();

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(vaultAddress))), 0)));
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(assetsRaw, assetDecimals_)));

        StackItem[] memory outputs = LibOpERC4626ConvertToShares.run(OperandV2.wrap(0), inputs);
        sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), shareDecimals_);
    }

    function sharesToAssets(address vaultAddress, uint256 sharesRaw) internal view returns (uint256 assetsRaw) {
        IERC4626Fork vault_ = IERC4626Fork(vaultAddress);
        uint8 shareDecimals_ = vault_.decimals();
        uint8 assetDecimals_ = IERC20Fork(vault_.asset()).decimals();

        StackItem[] memory inputs = new StackItem[](2);
        inputs[0] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.packLossless(int256(uint256(uint160(vaultAddress))), 0)));
        inputs[1] =
            StackItem.wrap(Float.unwrap(LibDecimalFloat.fromFixedDecimalLosslessPacked(sharesRaw, shareDecimals_)));

        StackItem[] memory outputs = LibOpERC4626ConvertToAssets.run(OperandV2.wrap(0), inputs);
        assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(outputs[0])), assetDecimals_);
    }

    function testNVDA() external view {
        uint256 actualSharesRaw = assetsToShares(WT_NVDA, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_NVDA).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_NVDA, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_NVDA).convertToAssets(1e18));
    }

    function testAMZN() external view {
        uint256 actualSharesRaw = assetsToShares(WT_AMZN, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_AMZN).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_AMZN, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_AMZN).convertToAssets(1e18));
    }

    function testTSLA() external view {
        uint256 actualSharesRaw = assetsToShares(WT_TSLA, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_TSLA).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_TSLA, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_TSLA).convertToAssets(1e18));
    }

    function testMSTR() external view {
        uint256 actualSharesRaw = assetsToShares(WT_MSTR, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_MSTR).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_MSTR, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_MSTR).convertToAssets(1e18));
    }

    function testIAU() external view {
        uint256 actualSharesRaw = assetsToShares(WT_IAU, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_IAU).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_IAU, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_IAU).convertToAssets(1e18));
    }

    function testCOIN() external view {
        uint256 actualSharesRaw = assetsToShares(WT_COIN, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_COIN).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_COIN, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_COIN).convertToAssets(1e18));
    }

    function testSPYM() external view {
        uint256 actualSharesRaw = assetsToShares(WT_SPYM, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_SPYM).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_SPYM, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_SPYM).convertToAssets(1e18));
    }

    function testSIVR() external view {
        uint256 actualSharesRaw = assetsToShares(WT_SIVR, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_SIVR).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_SIVR, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_SIVR).convertToAssets(1e18));
    }

    function testCRCL() external view {
        uint256 actualSharesRaw = assetsToShares(WT_CRCL, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_CRCL).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_CRCL, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_CRCL).convertToAssets(1e18));
    }

    function testBMNR() external view {
        uint256 actualSharesRaw = assetsToShares(WT_BMNR, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_BMNR).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_BMNR, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_BMNR).convertToAssets(1e18));
    }

    function testPPLT() external view {
        uint256 actualSharesRaw = assetsToShares(WT_PPLT, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_PPLT).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_PPLT, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_PPLT).convertToAssets(1e18));
    }

    function testQQQM() external view {
        uint256 actualSharesRaw = assetsToShares(WT_QQQM, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_QQQM).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_QQQM, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_QQQM).convertToAssets(1e18));
    }

    function testVWO() external view {
        uint256 actualSharesRaw = assetsToShares(WT_VWO, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_VWO).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_VWO, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_VWO).convertToAssets(1e18));
    }

    function testARKK() external view {
        uint256 actualSharesRaw = assetsToShares(WT_ARKK, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_ARKK).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_ARKK, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_ARKK).convertToAssets(1e18));
    }

    function testSGOV() external view {
        uint256 actualSharesRaw = assetsToShares(WT_SGOV, 1e18);
        assertEq(actualSharesRaw, IERC4626Fork(WT_SGOV).convertToShares(1e18));

        uint256 actualAssetsRaw = sharesToAssets(WT_SGOV, 1e18);
        assertEq(actualAssetsRaw, IERC4626Fork(WT_SGOV).convertToAssets(1e18));
    }
}
