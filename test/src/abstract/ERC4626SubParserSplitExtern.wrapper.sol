// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626SubParserWordParsersWrapper} from "test/src/abstract/ERC4626SubParser.wordParsers.wrapper.sol";

/// @dev Overrides extern() to a separate address to verify the sub-parser
/// respects the virtual override rather than hardcoding address(this).
contract ERC4626SubParserSplitExternWrapper is ERC4626SubParserWordParsersWrapper {
    address private immutable _ext;

    constructor(address ext) {
        _ext = ext;
    }

    function extern() internal view override returns (address) {
        return _ext;
    }
}
