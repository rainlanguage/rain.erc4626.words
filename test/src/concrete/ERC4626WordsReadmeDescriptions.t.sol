// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {AuthoringMetaV2} from "rain-interpreter-interface-0.1.0/src/interface/ISubParserV4.sol";
import {LibERC4626SubParser} from "../../../src/lib/parse/LibERC4626SubParser.sol";

/// @notice README.md must contain the full canonical description of every word
/// declared by authoringMetaV2(), verbatim. The decoded authoring meta is the
/// oracle: the description strings are the single source of truth for each
/// word's input ordering, decimals handling, and rounding semantics, so any
/// change to a description in LibERC4626SubParser.authoringMetaV2() that is
/// not mirrored into the README fails this test. The README is compared after
/// newline normalisation so markdown hard-wrapping of the quoted description
/// does not defeat the containment check.
contract ERC4626WordsReadmeDescriptionsTest is Test {
    /// Replaces every LF and CR byte with a space so a description that the
    /// README hard-wraps across lines still matches the single-line canonical
    /// string from the authoring meta.
    function normalizeNewlines(bytes memory data) internal pure returns (bytes memory) {
        for (uint256 i = 0; i < data.length; i++) {
            if (data[i] == 0x0A || data[i] == 0x0D) {
                data[i] = 0x20;
            }
        }
        return data;
    }

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

    /// The containment helper must discriminate: a corrupted needle, or one
    /// longer than the haystack, must NOT match, while matches at any offset
    /// (including the very end of the haystack) must be found. A helper that
    /// drifted towards returning true unconditionally would make the README
    /// containment check vacuous, so these edges are pinned here.
    function testContainsBytesDiscriminates() external pure {
        assertTrue(containsBytes(bytes("readme text body"), bytes("body")), "match at end of haystack must be found");
        assertTrue(
            containsBytes(bytes("readme text body"), bytes("readme")), "match at start of haystack must be found"
        );
        assertTrue(containsBytes(bytes("readme text body"), bytes("text")), "match in middle of haystack must be found");
        assertTrue(containsBytes(bytes("readme"), bytes("")), "empty needle matches trivially");
        assertTrue(!containsBytes(bytes("readme text body"), bytes("bodz")), "corrupted needle must not match");
        assertTrue(
            !containsBytes(bytes("short"), bytes("much longer needle")), "needle longer than haystack must not match"
        );
    }

    /// Newline normalisation must map both LF and CR to single spaces and
    /// leave every other byte untouched.
    function testNormalizeNewlines() external pure {
        assertEq(string(normalizeNewlines(bytes("a\nb\r\nc"))), "a b  c", "LF and CR each become one space");
        assertEq(string(normalizeNewlines(bytes("no newlines"))), "no newlines", "other bytes untouched");
    }

    function testReadmeContainsEveryAuthoringMetaWordDescription() external view {
        bytes memory readme = normalizeNewlines(bytes(vm.readFile("README.md")));
        AuthoringMetaV2[] memory meta = abi.decode(LibERC4626SubParser.authoringMetaV2(), (AuthoringMetaV2[]));
        assertTrue(meta.length > 0, "authoring meta must declare at least one word");
        for (uint256 i = 0; i < meta.length; i++) {
            bytes memory description = bytes(meta[i].description);
            assertTrue(description.length > 0, "authoring meta description must not be empty");
            // A newline inside a canonical description would never survive the
            // README normalisation, so the containment check below could only
            // fail confusingly; reject it explicitly instead.
            for (uint256 j = 0; j < description.length; j++) {
                assertTrue(
                    description[j] != 0x0A && description[j] != 0x0D,
                    "authoring meta description must not contain newlines"
                );
            }
            assertTrue(
                containsBytes(readme, description),
                string.concat("README must contain the canonical description of word ", vm.toString(i))
            );
        }
    }
}
