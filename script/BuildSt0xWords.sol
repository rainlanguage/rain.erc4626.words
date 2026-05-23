// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {St0xWords} from "src/concrete/St0xWords.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibGenParseMeta} from "rain.interpreter.interface/lib/codegen/LibGenParseMeta.sol";
import {LibERC4626SubParser} from "src/lib/parse/LibERC4626SubParser.sol";
import {PARSE_META_BUILD_DEPTH} from "src/abstract/ERC4626SubParser.sol";

contract BuildSt0xWords is Script {
    function buildSt0xWordsPointers() internal {
        St0xWords st0xWords = new St0xWords();

        string memory name = "St0xWords";

        LibFs.buildFileForContract(
            vm,
            address(st0xWords),
            name,
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibGenParseMeta.parseMetaConstantString(
                    vm, LibERC4626SubParser.authoringMetaV2(), PARSE_META_BUILD_DEPTH
                ),
                LibCodeGen.subParserWordParsersConstantString(vm, st0xWords),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, st0xWords),
                LibCodeGen.integrityFunctionPointersConstantString(vm, st0xWords),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, st0xWords)
            )
        );
    }

    function run() external {
        buildSt0xWordsPointers();
    }
}
