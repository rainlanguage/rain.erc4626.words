// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

import {ERC4626Words} from "../../../src/concrete/ERC4626Words.sol";
import {OperandV2} from "rainlang-interface-0.2.9/src/interface/IInterpreterV4.sol";

/// @notice Same harness on the unmodified contract for the default seam.
contract DefaultExternWords is ERC4626Words {
    function convertToAssetsSubParser(uint256 constantsHeight, uint256 ioByte, OperandV2 operand)
        external
        view
        returns (bool, bytes memory, bytes32[] memory)
    {
        return erc4626ConvertToAssetsSubParser(constantsHeight, ioByte, operand);
    }
}
