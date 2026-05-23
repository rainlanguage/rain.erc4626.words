// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626Extern, BaseRainterpreterExternNPE2} from "../abstract/ERC4626Extern.sol";
import {ERC4626SubParser, BaseRainterpreterSubParserNPE2} from "../abstract/ERC4626SubParser.sol";
import {IDescribedByMetaV1} from "rain.metadata/interface/IDescribedByMetaV1.sol";
import {DESCRIBED_BY_META_HASH} from "../generated/St0xWords.pointers.sol";

/// @title St0xWords
/// @notice Rain subparser and extern for ST0x words (ERC-4626 conversions today; more words later).
contract St0xWords is ERC4626Extern, ERC4626SubParser {
    /// @inheritdoc IDescribedByMetaV1
    function describedByMetaV1() external pure returns (bytes32) {
        return DESCRIBED_BY_META_HASH;
    }

    /// This is only needed because the parser and extern base contracts both
    /// implement IERC165, and the compiler needs to be told how to resolve the
    /// ambiguity.
    /// @inheritdoc BaseRainterpreterSubParserNPE2
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(BaseRainterpreterSubParserNPE2, BaseRainterpreterExternNPE2)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
