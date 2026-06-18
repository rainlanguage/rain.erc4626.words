// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

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
    /// @notice Returns the address of the extern contract that handles ERC-4626
    /// word dispatch at eval time. Defaults to address(this) so a single deployed
    /// ERC4626Words contract can act as both sub-parser and extern. Override to
    /// point at a separately deployed extern.
    /// @return The extern contract address encoded in ExternDispatchV2 constants.
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

    /// @notice Builds the packed bytes of operand handler function pointers for
    /// the sub-parser. Both ERC-4626 words disallow operands; every slot maps to
    /// `handleOperandDisallowed`.
    /// @return Packed bytes of 16-bit operand handler function pointers.
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

    /// @notice Returns an empty literal parser table. ERC-4626 words introduce no
    /// new literal types; all literal parsing is delegated to the host parser.
    /// @return Empty bytes — no literal parsers are registered.
    function buildLiteralParserFunctionPointers() external pure returns (bytes memory) {
        return "";
    }

    /// @notice Builds the packed bytes of sub-parser word function pointers. Each
    /// 16-bit slot maps a word index to the sub-parser function that encodes the
    /// ExternDispatchV2 constant for that word.
    /// @return Packed bytes of 16-bit sub-parser word function pointers.
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

    /// @notice Sub-parser word handler for `erc4626-convert-to-assets`. Called by
    /// the host parser when it encounters this word; encodes an ExternDispatchV2
    /// constant that routes eval-time dispatch to the assets opcode of the extern
    /// returned by `extern()`.
    /// @param constantsHeight The constants stack height at this word's parse position.
    /// @param ioByte IO byte encoding the declared input/output arity for this word.
    /// @param operand Parsed operand value; must be zero (operands are disallowed).
    /// @return Always true — this sub-parser always handles the word.
    /// @return ABI-encoded bytecode fragment for the extern dispatch instruction.
    /// @return Single-element constants array containing the ExternDispatchV2 value.
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

    /// @notice Sub-parser word handler for `erc4626-convert-to-shares`. Called by
    /// the host parser when it encounters this word; encodes an ExternDispatchV2
    /// constant that routes eval-time dispatch to the shares opcode of the extern
    /// returned by `extern()`.
    /// @param constantsHeight The constants stack height at this word's parse position.
    /// @param ioByte IO byte encoding the declared input/output arity for this word.
    /// @param operand Parsed operand value; must be zero (operands are disallowed).
    /// @return Always true — this sub-parser always handles the word.
    /// @return ABI-encoded bytecode fragment for the extern dispatch instruction.
    /// @return Single-element constants array containing the ExternDispatchV2 value.
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
