// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {BYTECODE_HASH} from "src/generated/ERC4626Words.pointers.sol";

contract ERC4626WordsPointersTest is Test {
    function testBytecodeHashMatchesDeployedCode() external {
        ERC4626Words words = new ERC4626Words();
        assertEq(address(words).codehash, BYTECODE_HASH, "BYTECODE_HASH is stale");
    }
}
