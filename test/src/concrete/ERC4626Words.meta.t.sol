// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";

contract ERC4626WordsMetaTest is Test {
    ERC4626Words internal words;

    function setUp() external {
        words = new ERC4626Words();
    }

    /// @notice describedByMetaV1() must equal keccak256(meta/ERC4626Words.rain.meta).
    /// This pins the on-chain hash to the actual CBOR bytes so a stale DESCRIBED_BY_META_HASH
    /// or an out-of-sync meta file is caught immediately by CI.
    function testDescribedByMetaHashMatchesCBORFile() external view {
        bytes memory metaBytes = vm.readFileBinary("meta/ERC4626Words.rain.meta");
        bytes32 fileHash = keccak256(metaBytes);
        assertEq(words.describedByMetaV1(), fileHash, "on-chain hash must equal keccak256 of CBOR meta file");
    }
}
