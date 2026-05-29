// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {LibFs} from "rain.sol.codegen/lib/LibFs.sol";
import {LibCodeGen} from "rain.sol.codegen/lib/LibCodeGen.sol";
import {LibGenParseMeta} from "rain.interpreter.interface/lib/codegen/LibGenParseMeta.sol";
import {LibERC4626SubParser} from "src/lib/parse/LibERC4626SubParser.sol";
import {PARSE_META_BUILD_DEPTH} from "src/abstract/ERC4626SubParser.sol";

contract BuildERC4626Words is Script {
    function buildERC4626WordsPointers() internal {
        ERC4626Words erc4626Words = new ERC4626Words();

        string memory name = "ERC4626Words";

        LibFs.buildFileForContract(
            vm,
            address(erc4626Words),
            name,
            string.concat(
                LibCodeGen.describedByMetaHashConstantString(vm, name),
                LibGenParseMeta.parseMetaConstantString(
                    vm, LibERC4626SubParser.authoringMetaV2(), PARSE_META_BUILD_DEPTH
                ),
                LibCodeGen.subParserWordParsersConstantString(vm, erc4626Words),
                LibCodeGen.operandHandlerFunctionPointersConstantString(vm, erc4626Words),
                LibCodeGen.integrityFunctionPointersConstantString(vm, erc4626Words),
                LibCodeGen.opcodeFunctionPointersConstantString(vm, erc4626Words)
            )
        );
    }

    function run() external {
        buildERC4626WordsPointers();
    }
}
