// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626Words} from "src/concrete/ERC4626Words.sol";
import {OperandV2} from "rain-interpreter-interface-0.1.0/src/interface/IInterpreterV4.sol";

contract ERC4626SubParserWordParsersWrapper is ERC4626Words {
    function convertToAssetsSubParserPublic(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToAssetsSubParser(constantsHeight, ioByte, operand);
    }

    function convertToSharesSubParserPublic(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToSharesSubParser(constantsHeight, ioByte, operand);
    }
}

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
