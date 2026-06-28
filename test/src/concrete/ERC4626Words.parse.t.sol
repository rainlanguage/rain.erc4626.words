// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {
    RainlangExpressionDeployerDeploymentTest
} from "rainlang-0.1.2/test/abstract/RainlangExpressionDeployerDeploymentTest.sol";
import {
    EvalV4,
    SourceIndexV2,
    FullyQualifiedNamespace,
    StackItem
} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";
import {LibContext} from "rain-interpreter-interface-0.1.0/src/lib/caller/LibContext.sol";
import {SignedContextV1} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterCallerV4.sol";
import {Float, LibDecimalFloat} from "rain-math-float-0.1.1/src/lib/LibDecimalFloat.sol";
import {Strings} from "@openzeppelin-contracts-5.6.1/utils/Strings.sol";
import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";
import {MockERC4626, MockERC20} from "../../utils/MockERC4626.sol";

/// @notice Parse+eval tests for the ERC4626 subparser words.
/// These tests exercise the full name → PARSE_META → opcode → extern dispatch chain,
/// catching any transposition in word name–to–opcode index mapping that unit tests
/// calling LibOp*.run() directly would not detect.
contract ERC4626WordsParseTest is RainlangExpressionDeployerDeploymentTest {
    ERC4626Words internal words;
    MockERC20 internal asset;
    MockERC4626 internal vault;

    /// @dev 1 share (18-decimal) = 2 USDC (6-decimal).
    uint256 internal constant ASSETS_PER_SHARE = 2e6;

    function setUp() external {
        words = new ERC4626Words();
        asset = new MockERC20(6);
        vault = new MockERC4626(18, address(asset), ASSETS_PER_SHARE);
    }

    function evalBytecode(bytes memory bytecode) internal view returns (StackItem[] memory stack) {
        (stack,) = I_INTERPRETER.eval4(
            EvalV4({
                store: I_STORE,
                namespace: FullyQualifiedNamespace.wrap(0),
                bytecode: bytecode,
                sourceIndex: SourceIndexV2.wrap(0),
                context: LibContext.build(new bytes32[][](0), new SignedContextV1[](0)),
                inputs: new StackItem[](0),
                stateOverlay: new bytes32[](0)
            })
        );
    }

    /// @dev Parses and evaluates erc4626-convert-to-assets via the real subparser+PARSE_META path.
    /// 1 share in a 2:1 vault (1 share = 2 USDC) must evaluate to Float(2.0).
    function testParseEvalConvertToAssets() external view {
        bytes memory bytecode = I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-assets(",
                    Strings.toHexString(address(vault)),
                    " 1);"
                )
            )
        );

        StackItem[] memory stack = evalBytecode(bytecode);
        assertEq(stack.length, 1, "convertToAssets must produce 1 output");
        uint256 assetsRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(stack[0])), 6);
        assertEq(assetsRaw, 2e6, "erc4626-convert-to-assets: 1 share must yield 2 USDC");
    }

    /// @dev Parses and evaluates erc4626-convert-to-shares via the real subparser+PARSE_META path.
    /// 2 USDC in a 2:1 vault must evaluate to Float(1.0) == 1 share.
    function testParseEvalConvertToShares() external view {
        bytes memory bytecode = I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-shares(",
                    Strings.toHexString(address(vault)),
                    " 2);"
                )
            )
        );

        StackItem[] memory stack = evalBytecode(bytecode);
        assertEq(stack.length, 1, "convertToShares must produce 1 output");
        uint256 sharesRaw = LibDecimalFloat.toFixedDecimalLossless(Float.wrap(StackItem.unwrap(stack[0])), 18);
        assertEq(sharesRaw, 1e18, "erc4626-convert-to-shares: 2 USDC must yield 1 share");
    }

    /// @dev With the same Float(1.0) amount argument, erc4626-convert-to-assets and
    /// erc4626-convert-to-shares must produce different results.
    /// - assets word: 1 share → 2 USDC  (Float 2.0)
    /// - shares word: 1 USDC → 0.5 shares (Float 0.5)
    /// A transposition in the PARSE_META word→opcode mapping would make them swap,
    /// making the test fail in exactly the scenario issue #134 describes.
    function testWordNamesMustMapToDistinctOpcodes() external view {
        bytes memory bytecodeAssets = I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-assets(",
                    Strings.toHexString(address(vault)),
                    " 1);"
                )
            )
        );
        bytes memory bytecodeShares = I_DEPLOYER.parse2(
            bytes(
                string.concat(
                    "using-words-from ",
                    Strings.toHexString(address(words)),
                    " _: erc4626-convert-to-shares(",
                    Strings.toHexString(address(vault)),
                    " 1);"
                )
            )
        );

        StackItem[] memory stackAssets = evalBytecode(bytecodeAssets);
        StackItem[] memory stackShares = evalBytecode(bytecodeShares);

        assertTrue(
            StackItem.unwrap(stackAssets[0]) != StackItem.unwrap(stackShares[0]),
            "erc4626-convert-to-assets and erc4626-convert-to-shares must parse to distinct opcodes"
        );
    }
}
