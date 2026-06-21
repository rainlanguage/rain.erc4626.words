// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";

contract ERC4626WordsReadmeTest is Test {
    function containsBytes(bytes memory haystack, bytes memory needle) internal pure returns (bool) {
        if (needle.length == 0) return true;
        if (haystack.length < needle.length) return false;
        for (uint256 i = 0; i <= haystack.length - needle.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < needle.length; j++) {
                if (haystack[i + j] != needle[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return true;
        }
        return false;
    }

    function testReadmeContainsConvertToAssetsWordName() external view {
        bytes memory readme = bytes(vm.readFile("README.md"));
        assertTrue(
            containsBytes(readme, bytes("erc4626-convert-to-assets")),
            "README must document erc4626-convert-to-assets word name"
        );
    }

    function testReadmeContainsConvertToSharesWordName() external view {
        bytes memory readme = bytes(vm.readFile("README.md"));
        assertTrue(
            containsBytes(readme, bytes("erc4626-convert-to-shares")),
            "README must document erc4626-convert-to-shares word name"
        );
    }
}
