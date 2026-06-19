// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {
    OPCODE_FUNCTION_POINTERS,
    INTEGRITY_FUNCTION_POINTERS,
    SUB_PARSER_WORD_PARSERS,
    OPERAND_HANDLER_FUNCTION_POINTERS
} from "src/generated/ERC4626Words.pointers.sol";

contract ERC4626WordsExternPointersTest is Test {
    ERC4626Words internal words;

    function setUp() external {
        words = new ERC4626Words();
    }

    function testOpcodePointersMatchCommitted() external {
        assertEq(
            words.buildOpcodeFunctionPointers(),
            OPCODE_FUNCTION_POINTERS,
            "committed OPCODE_FUNCTION_POINTERS drifted from freshly-built table"
        );
    }

    function testIntegrityPointersMatchCommitted() external {
        assertEq(
            words.buildIntegrityFunctionPointers(),
            INTEGRITY_FUNCTION_POINTERS,
            "committed INTEGRITY_FUNCTION_POINTERS drifted from freshly-built table"
        );
    }

    function testSubParserWordParsersMatchCommitted() external {
        assertEq(
            words.buildSubParserWordParsers(),
            SUB_PARSER_WORD_PARSERS,
            "committed SUB_PARSER_WORD_PARSERS drifted from freshly-built table"
        );
    }

    function testOperandHandlerPointersMatchCommitted() external {
        assertEq(
            words.buildOperandHandlerFunctionPointers(),
            OPERAND_HANDLER_FUNCTION_POINTERS,
            "committed OPERAND_HANDLER_FUNCTION_POINTERS drifted from freshly-built table"
        );
    }
}
