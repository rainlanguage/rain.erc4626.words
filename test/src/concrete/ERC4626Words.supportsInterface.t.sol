// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {Test} from "forge-std-1.16.1/src/Test.sol";
import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {IERC165} from "@openzeppelin-contracts-5.6.1/utils/introspection/IERC165.sol";
import {ISubParserV4} from "rain-interpreter-interface-0.1.0/src/interface/ISubParserV4.sol";
import {IInterpreterExternV4} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterExternV4.sol";
import {IDescribedByMetaV1} from "rain-metadata-0.1.0/src/interface/IDescribedByMetaV1.sol";
import {IIntegrityToolingV1} from "rain-sol-codegen-0.1.0/src/interface/IIntegrityToolingV1.sol";
import {IOpcodeToolingV1} from "rain-sol-codegen-0.1.0/src/interface/IOpcodeToolingV1.sol";
import {IParserToolingV1} from "rain-sol-codegen-0.1.0/src/interface/IParserToolingV1.sol";
import {ISubParserToolingV1} from "rain-sol-codegen-0.1.0/src/interface/ISubParserToolingV1.sol";

/// @notice Tests that ERC4626Words.supportsInterface resolves the IERC165 diamond
/// ambiguity correctly — both the SubParser and the Extern inheritance branches
/// must be reachable via C3 linearization.
contract ERC4626WordsSupportsInterfaceTest is Test {
    ERC4626Words internal words;

    function setUp() external {
        words = new ERC4626Words();
    }

    /// SubParser branch: ISubParserV4 must be reported as supported.
    function testSupportsISubParserV4() external view {
        assertTrue(words.supportsInterface(type(ISubParserV4).interfaceId), "must support ISubParserV4");
    }

    /// SubParser branch: IDescribedByMetaV1 must be reported as supported.
    function testSupportsIDescribedByMetaV1() external view {
        assertTrue(words.supportsInterface(type(IDescribedByMetaV1).interfaceId), "must support IDescribedByMetaV1");
    }

    /// SubParser branch: IParserToolingV1 must be reported as supported.
    function testSupportsIParserToolingV1() external view {
        assertTrue(words.supportsInterface(type(IParserToolingV1).interfaceId), "must support IParserToolingV1");
    }

    /// SubParser branch: ISubParserToolingV1 must be reported as supported.
    function testSupportsISubParserToolingV1() external view {
        assertTrue(words.supportsInterface(type(ISubParserToolingV1).interfaceId), "must support ISubParserToolingV1");
    }

    /// Extern branch: IInterpreterExternV4 must be reported as supported.
    function testSupportsIInterpreterExternV4() external view {
        assertTrue(words.supportsInterface(type(IInterpreterExternV4).interfaceId), "must support IInterpreterExternV4");
    }

    /// Extern branch: IIntegrityToolingV1 must be reported as supported.
    function testSupportsIIntegrityToolingV1() external view {
        assertTrue(words.supportsInterface(type(IIntegrityToolingV1).interfaceId), "must support IIntegrityToolingV1");
    }

    /// Extern branch: IOpcodeToolingV1 must be reported as supported.
    function testSupportsIOpcodeToolingV1() external view {
        assertTrue(words.supportsInterface(type(IOpcodeToolingV1).interfaceId), "must support IOpcodeToolingV1");
    }

    /// IERC165 itself must be reported (inherited by both bases via ERC165).
    function testSupportsIERC165() external view {
        assertTrue(words.supportsInterface(type(IERC165).interfaceId), "must support IERC165");
    }

    /// A random interface id must not be reported as supported.
    function testRejectsUnknownInterface() external view {
        assertFalse(words.supportsInterface(bytes4(0xdeadbeef)), "must reject unknown interface");
    }
}
