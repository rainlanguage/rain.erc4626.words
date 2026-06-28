// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";
import {
    BYTECODE_HASH,
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    SUB_PARSER_WORD_PARSERS,
    OPERAND_HANDLER_FUNCTION_POINTERS
} from "../../../src/generated/ERC4626Words.pointers.sol";

/// @notice Asserts committed pointer constants equal freshly-built equivalents.
/// Covers HIGH issues: pointer/integrity dispatch tables can silently drift
/// when build functions and committed constants disagree.
contract ERC4626WordsPointersTest is Test {
    ERC4626Words internal words;

    function setUp() external {
        words = new ERC4626Words();
    }

    function testBytecodeHashMatchesDeployedCode() external view {
        assertEq(address(words).codehash, BYTECODE_HASH, "BYTECODE_HASH is stale");
    }

    function testOpcodeFunctionPointersMatchCommitted() external view {
        assertEq(
            words.buildOpcodeFunctionPointers(), OPCODE_FUNCTION_POINTERS, "opcode pointers drifted from committed"
        );
    }

    function testIntegrityFunctionPointersMatchCommitted() external view {
        assertEq(
            words.buildIntegrityFunctionPointers(),
            INTEGRITY_FUNCTION_POINTERS,
            "integrity pointers drifted from committed"
        );
    }

    function testSubParserWordParsersMatchCommitted() external view {
        assertEq(
            words.buildSubParserWordParsers(), SUB_PARSER_WORD_PARSERS, "sub-parser word parsers drifted from committed"
        );
    }

    function testOperandHandlerFunctionPointersMatchCommitted() external view {
        assertEq(
            words.buildOperandHandlerFunctionPointers(),
            OPERAND_HANDLER_FUNCTION_POINTERS,
            "operand handler pointers drifted from committed"
        );
    }

    function testOpcodeFunctionPointersLengthIsNonZero() external pure {
        assertTrue(OPCODE_FUNCTION_POINTERS.length > 0, "OPCODE_FUNCTION_POINTERS must not be empty");
    }

    function testIntegrityFunctionPointersLengthIsNonZero() external pure {
        assertTrue(INTEGRITY_FUNCTION_POINTERS.length > 0, "INTEGRITY_FUNCTION_POINTERS must not be empty");
    }

    function testOpcodeAndIntegrityPointerLengthsMatch() external pure {
        assertEq(
            OPCODE_FUNCTION_POINTERS.length,
            INTEGRITY_FUNCTION_POINTERS.length,
            "opcode and integrity pointer arrays must have equal length"
        );
    }

    function testSubParserAndOperandHandlerLengthsMatch() external pure {
        assertEq(
            SUB_PARSER_WORD_PARSERS.length,
            OPERAND_HANDLER_FUNCTION_POINTERS.length,
            "sub-parser word parsers and operand handler arrays must have equal length"
        );
    }
}
