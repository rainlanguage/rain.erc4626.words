// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";
import {OperandV2} from "rainlang-interface-0.2.9/src/interface/IInterpreterV4.sol";

/// @notice Derived contract that overrides the extern() seam to point at a
/// separately specified extern address, exposing both sub-parser word
/// functions so the emitted dispatch constants can be inspected.
contract OverriddenExternWords is ERC4626Words {
    address internal immutable sOverrideExtern;

    constructor(address overrideExtern) {
        sOverrideExtern = overrideExtern;
    }

    function extern() internal view override returns (address) {
        return sOverrideExtern;
    }

    function convertToAssetsSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToAssetsSubParser(constantsHeight, ioByte, operand);
    }

    function convertToSharesSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToSharesSubParser(constantsHeight, ioByte, operand);
    }
}
