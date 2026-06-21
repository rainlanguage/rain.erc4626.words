// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {BaseRainlangExtern, OperandV2, StackItem} from "rainlang-0.1.2/src/abstract/BaseRainlangExtern.sol";
import {LibOpERC4626ConvertToAssets} from "../lib/op/erc4626/LibOpERC4626ConvertToAssets.sol";
import {LibOpERC4626ConvertToShares} from "../lib/op/erc4626/LibOpERC4626ConvertToShares.sol";
import {LibConvert} from "rain-lib-typecast-0.1.0/src/LibConvert.sol";
import {OPCODE_FUNCTION_POINTERS, INTEGRITY_FUNCTION_POINTERS} from "../generated/ERC4626Words.pointers.sol";

uint256 constant OPCODE_ERC4626_CONVERT_TO_ASSETS = 0;
uint256 constant OPCODE_ERC4626_CONVERT_TO_SHARES = 1;

uint256 constant OPCODE_FUNCTION_POINTERS_LENGTH = 2;

abstract contract ERC4626Extern is BaseRainlangExtern {
    function opcodeFunctionPointers() internal pure override returns (bytes memory) {
        return OPCODE_FUNCTION_POINTERS;
    }

    function integrityFunctionPointers() internal pure override returns (bytes memory) {
        return INTEGRITY_FUNCTION_POINTERS;
    }

    /// @notice Builds the packed bytes of opcode run() function pointers used
    /// by the extern dispatch table. Each 16-bit slot maps an opcode index to
    /// the corresponding library run() function pointer.
    /// @return Packed bytes of 16-bit run() function pointers, one per opcode.
    function buildOpcodeFunctionPointers() external pure returns (bytes memory) {
        function(OperandV2, StackItem[] memory) internal view returns (StackItem[] memory)[] memory fs = new function(OperandV2, StackItem[] memory)
        internal
        view returns (StackItem[] memory)[](OPCODE_FUNCTION_POINTERS_LENGTH);
        fs[OPCODE_ERC4626_CONVERT_TO_ASSETS] = LibOpERC4626ConvertToAssets.run;
        fs[OPCODE_ERC4626_CONVERT_TO_SHARES] = LibOpERC4626ConvertToShares.run;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }

    /// @notice Builds the packed bytes of integrity function pointers used by
    /// the extern for parse-time stack arity checking. Each 16-bit slot maps an
    /// opcode index to the corresponding library integrity() function pointer.
    /// @return Packed bytes of 16-bit integrity() function pointers, one per opcode.
    function buildIntegrityFunctionPointers() external pure returns (bytes memory) {
        function(OperandV2, uint256, uint256) internal pure returns (uint256, uint256)[] memory fs = new function(OperandV2, uint256, uint256)
        internal
        pure returns (uint256, uint256)[](OPCODE_FUNCTION_POINTERS_LENGTH);
        fs[OPCODE_ERC4626_CONVERT_TO_ASSETS] = LibOpERC4626ConvertToAssets.integrity;
        fs[OPCODE_ERC4626_CONVERT_TO_SHARES] = LibOpERC4626ConvertToShares.integrity;

        uint256[] memory pointers;
        assembly ("memory-safe") {
            pointers := fs
        }
        return LibConvert.unsafeTo16BitBytes(pointers);
    }
}
