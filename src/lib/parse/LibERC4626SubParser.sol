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
            "Converts ERC-4626 vault shares to underlying assets. Accepts 2 inputs: the vault contract address (as a Float-encoded integer) and the amount of shares as a float. Returns 1 output: the floor-rounded amount of underlying assets as a float. The conversion uses the vault's own convertToAssets function and respects the share and asset token decimals. Results are rounded down (floor) per the ERC-4626 convertToAssets specification, which favors the vault."
        );

        meta[SUB_PARSER_WORD_ERC4626_CONVERT_TO_SHARES] = AuthoringMetaV2(
            "erc4626-convert-to-shares",
            "Converts underlying assets to ERC-4626 vault shares. Accepts 2 inputs: the vault contract address (as a Float-encoded integer) and the amount of underlying assets as a float. Returns 1 output: the floor-rounded number of vault shares as a float. The conversion uses the vault's own convertToShares function and respects the asset and share token decimals. Results are rounded down (floor) per the ERC-4626 convertToShares specification, which favors the vault."
        );

        return abi.encode(meta);
    }
}
