// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity ^0.8.25;

import {AuthoringMetaV2} from "rain-interpreter-interface-0.1.0/src/interface/deprecated/v1/IParserV1.sol";

uint256 constant SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS = 0;
uint256 constant SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES = 1;

uint256 constant SUB_PARSER_WORD_PARSERS_LENGTH = 2;

library LibERC4626SubParser {
    function authoringMetaV2() internal pure returns (bytes memory) {
        AuthoringMetaV2[] memory meta = new AuthoringMetaV2[](SUB_PARSER_WORD_PARSERS_LENGTH);

        meta[SUB_PARSER_WORD_ERC4626_CONVERT_TO_ASSETS] = AuthoringMetaV2(
            "erc4626-convert-to-assets",
            "Converts ERC-4626 vault shares to underlying assets. Accepts 2 inputs: the vault contract address and the amount of shares as a float. The shares amount must be exactly representable in the vault's share decimals (reverts on precision loss). Returns 1 output: the equivalent amount of underlying assets as a float. The conversion uses the vault's own convertToAssets function and respects the share and asset token decimals."
        );

        meta[SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES] = AuthoringMetaV2(
            "erc4626-convert-to-shares",
            "Converts underlying assets to ERC-4626 vault shares. Accepts 2 inputs: the vault contract address and the amount of underlying assets as a float. The assets amount must be exactly representable in the vault's asset decimals (reverts on precision loss). Returns 1 output: the equivalent number of vault shares as a float. The conversion uses the vault's own convertToShares function and respects the asset and share token decimals."
        );

        return abi.encode(meta);
    }
}
