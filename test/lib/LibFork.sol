// SPDX-License-Identifier: LicenseRef-DCL-1.0
// SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
pragma solidity =0.8.25;

string constant FORK_RPC_URL_BASE = "https://base.gateway.tenderly.co";

uint256 constant FORK_BLOCK_BASE = 46360198;

/// The single canonical registry of ERC4626 vault addresses exercised by fork
/// tests. Each address lives only here: consumers derive the vault count from
/// `.length` and per-vault labels from the addresses themselves, so every
/// entry is exercised by every consuming loop and there is no parallel list
/// that can drift out of sync.
function allForkVaults() pure returns (address[] memory vaults_) {
    vaults_ = new address[](15);
    vaults_[0] = 0xFb5B41acdbA20a3230F84BE995173CFb98b8D6E7; // NVDA
    vaults_[1] = 0x997baE3EC193a249596d3708C3fAB7C501Bb8a53; // AMZN
    vaults_[2] = 0x219A8d384a10BF19b9f24cB5cC53F79Dd0e5A03D; // TSLA
    vaults_[3] = 0xFF05E1bD696900dc6A52CA35Ca61Bb1024eDa8e2; // MSTR
    vaults_[4] = 0x1E46d7eFef64A833AFB1CD49299a7AD5B439f4d8; // IAU
    vaults_[5] = 0x5cDa0E1CA4ce2af96315f7F8963C85399c172204; // COIN
    vaults_[6] = 0x31C2C14134e6E3B7ef9478297F199331133Fc2d8; // SPYM
    vaults_[7] = 0xEB7F3E4093C9d68253b6104FbbfF561F3eC0442F; // SIVR
    vaults_[8] = 0x8AFba81DEc38DE0A18E2Df5E1967a7493651eebf; // CRCL
    vaults_[9] = 0x2512EC661f0bA089c275EA105E31bAD6FcFcf319; // BMNR
    vaults_[10] = 0x82f5BAEE1076334357a34A19E04f7c282D51cE47; // PPLT
    vaults_[11] = 0x823FF7Bbde2869aAe73A6CD53e7f614442836757; // QQQM
    vaults_[12] = 0x23ec6886b49D7ab123E9ee8e474D2fa7AB6Cbc2d; // VWO
    vaults_[13] = 0x9FfF48B4535AF3765Ac9E1b164720EDc01DF8EE7; // ARKK
    vaults_[14] = 0x78c31580c97101694C70022c83D570150c11e935; // SGOV
}
