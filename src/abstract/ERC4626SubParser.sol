// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {OPCODE_ERC4626_CONVERT_TO_ASSETS, OPCODE_ERC4626_CONVERT_TO_SHARES} from "./ERC4626Extern.sol";
import {OperandV2, BaseRainlangSubParser} from "rainlang-0.1.2/src/abstract/BaseRainlangSubParser.sol";
import {LibParseOperand} from "rainlang-0.1.2/src/lib/parse/LibParseOperand.sol";
import {
    SUB_PARSER_WORD_PARSERS_LENGTH,
    SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS,
    SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES
} from "../lib/parse/LibERC4626SubParser.sol";
import {LibConvert} from "rain-lib-typecast-0.1.0/src/LibConvert.sol";
import {LibSubParse} from "rainlang-0.1.2/src/lib/parse/LibSubParse.sol";
import {IInterpreterExternV4} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterExternV4.sol";
import {
    OPERAND_HANDLER_FUNCTION_POINTERS as SUB_PARSER_OPERAND_HANDLERS,
    PARSE_META as SUB_PARSER_PARSE_META,
    SUB_PARSER_WORD_PARSERS
} from "../generated/ERC4626Words.pointers.sol";

uint8 constant PARSE_META_BUILD_DEPTH = 1;

abstract contract ERC4626SubParser is BaseRainlangSubParser {
    // slither-disable-next-line dead-code
    function extern() internal view virtual returns (address) {
        return address(this);
    }

    /// @inheritdoc BaseRainlangSubParser
    function subParserParseMeta() internal pure override returns (bytes memory) {
        return SUB_PARSER_PARSE_META;
    }

    /// @inheritdoc BaseRainlangSubParser
    function subParserWordParsers() internal pure override returns (bytes memory) {
        return SUB_PARSER_WORD_PARSERS;
    }

    /// @inheritdoc BaseRainlangSubParser
    function subParserOperandHandlers() internal pure override returns (bytes memory) {
        return SUB_PARSER_OPERAND_HANDLERS;
    }

    function buildOperandHandlerFunctionPointers() external pure returns (bytes memory) {
        function(bytes32[] memory) internal pure returns (OperandV2)[] memory fs =
            new function(bytes32[] memory) internal pure returns (OperandV2)[](SUB_PARSER_WORD_PARSERS_LENGTH);
        fs[SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS] = LibParseOperand.handleOperandDisallowed;
        fs[SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES] = LibParseOperand.handleOperandDisallowed;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return "";
    }

    function buildSubParserWordParsers() external pure returns (bytes memory) {
        function(uint256, uint256, OperandV2) internal view returns (bool, bytes memory, bytes32[] memory)[] memory fs = new function(uint256, uint256, OperandV2)
        internal
        view returns (bool, bytes memory, bytes32[] memory)[](SUB_PARSER_WORD_PARSERS_LENGTH);
        fs[SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS] = erc4626ConvertToAssetsSubParser;
        fs[SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES] = erc4626ConvertToSharesSubParser;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    // slither-disable-next-line dead-code
    function erc4626ConvertToAssetsSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        internal
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        // slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV4(extern()), constantsHeight, ioByte, operand, OPCODE_ERC4626_CONVERT_TO_ASSETS
        );
    }

    // slither-disable-next-line dead-code
    function erc4626ConvertToSharesSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        internal
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        // slither-disable-next-line unused-return
        return LibSubParse.subParserExtern(
            IInterpreterExternV4(extern()), constantsHeight, ioByte, operand, OPCODE_ERC4626_CONVERT_TO_SHARES
        );
    }
}
