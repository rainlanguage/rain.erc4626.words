// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainlangExpressionDeployerDeploymentTest
} from "rainlang-0.1.2/test/abstract/RainlangExpressionDeployerDeploymentTest.sol";
import {UnexpectedOperand} from "rainlang-0.1.2/src/error/ErrParse.sol";
import {Strings} from "@openzeppelin-contracts-5.6.1/utils/Strings.sol";
import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";

/// @notice Tests that erc4626-convert-to-assets and erc4626-convert-to-shares
/// reject any operand value at parse time. Both words are wired to
/// LibParseOperand.handleOperandDisallowed in buildOperandHandlerFunctionPointers.
/// A mutant swapping that handler for a permissive one would allow operands
/// through, causing these tests to fail.
contract ERC4626SubParserOperandHandlerTest is RainlangExpressionDeployerDeploymentTest {
    ERC4626Words internal words;

    function setUp() external {
        words = new ERC4626Words();
    }

    function testConvertToAssetsRevertsOnOperand() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-assets<0>(",
                    Strings.toHexString(address(0)),
                    " 1);"
                )
            )
        );
    }

    function testConvertToSharesRevertsOnOperand() external {
        vm.expectRevert(abi.encodeWithSelector(UnexpectedOperand.selector));
        I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-shares<0>(",
                    Strings.toHexString(address(0)),
                    " 1);"
                )
            )
        );
    }
}
