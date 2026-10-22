// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {allForkVaults} from "./LibFork.sol";

contract LibForkTest is Test {
    /// `allForkVaults()` is the single registry of fork-tested vault
    /// addresses, so its enumeration must be well formed on its own terms:
    /// non-empty, no zero entries, and no duplicate addresses. Every
    /// consumer derives its vault set, count and labels from this registry,
    /// so these invariants hold for every fork test without any parallel
    /// hand-maintained list.
    function testAllForkVaultsEnumeration() external pure {
        address[] memory vaults = allForkVaults();
        assertTrue(vaults.length > 0, "vault registry is empty");
        for (uint256 i = 0; i < vaults.length; i++) {
            assertTrue(vaults[i] != address(0), "zero address in vault registry");
            for (uint256 j = i + 1; j < vaults.length; j++) {
                assertTrue(vaults[i] != vaults[j], "duplicate address in vault registry");
            }
        }
    }
}
