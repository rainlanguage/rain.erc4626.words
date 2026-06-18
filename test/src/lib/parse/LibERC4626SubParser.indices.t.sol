// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {AuthoringMetaV2} from "rain-interpreter-interface-0.1.0/src/interface/deprecated/v1/IParserV1.sol";
import {
    SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS,
    SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES,
    SUB_PARSER_WORD_PARSERS_LENGTH,
    LibERC4626SubParser
} from "src/lib/parse/LibERC4626SubParser.sol";
import {
    OPCODE_ERC4626_CONVERT_TO_ASSETS,
    OPCODE_ERC4626_CONVERT_TO_SHARES,
    OPCODE_FUNCTION_POINTERS_LENGTH
} from "src/abstract/ERC4626Extern.sol";

/// @notice Asserts that the parallel index constants in ERC4626Extern and
/// LibERC4626SubParser agree, and that the authoring-meta array is indexed by
/// those same constants. Any transposition or length mismatch in the five
/// hand-maintained index tables fails these tests.
/// Covers issues #31, #123, #128, #131.
contract LibERC4626SubParserIndicesTest is Test {
    function testLengthsAgree() external pure {
        assertEq(
            OPCODE_FUNCTION_POINTERS_LENGTH,
            SUB_PARSER_WORD_PARSERS_LENGTH,
            "extern and subparser length constants must agree"
        );
    }

    function testConvertToAssetsIndexAgrees() external pure {
        assertEq(
            OPCODE_ERC4626_CONVERT_TO_ASSETS,
            SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS,
            "convert-to-assets opcode and subparser word index must agree"
        );
    }

    function testConvertToSharesIndexAgrees() external pure {
        assertEq(
            OPCODE_ERC4626_CONVERT_TO_SHARES,
            SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES,
            "convert-to-shares opcode and subparser word index must agree"
        );
    }

    function testAuthoringMetaLengthMatchesParsersLength() external pure {
        AuthoringMetaV2[] memory meta = abi.decode(LibERC4626SubParser.authoringMetaV2(), (AuthoringMetaV2[]));
        assertEq(
            meta.length,
            SUB_PARSER_WORD_PARSERS_LENGTH,
            "authoring-meta array length must match SUB_PARSER_WORD_PARSERS_LENGTH"
        );
    }

    function testAuthoringMetaConvertToAssetsAtCorrectIndex() external pure {
        AuthoringMetaV2[] memory meta = abi.decode(LibERC4626SubParser.authoringMetaV2(), (AuthoringMetaV2[]));
        assertEq(
            meta[SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS].word,
            "erc4626-convert-to-assets",
            "authoring-meta index 0 must be erc4626-convert-to-assets"
        );
    }

    function testAuthoringMetaConvertToSharesAtCorrectIndex() external pure {
        AuthoringMetaV2[] memory meta = abi.decode(LibERC4626SubParser.authoringMetaV2(), (AuthoringMetaV2[]));
        assertEq(
            meta[SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES].word,
            "erc4626-convert-to-shares",
            "authoring-meta index 1 must be erc4626-convert-to-shares"
        );
    }
}
