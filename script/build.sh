#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate all committed artifacts that rainix copy-artifacts diff-checks.
# Meta CBOR runs in the repo default devshell (needs `rain`); pointer
# constants and forge fmt run in the sol-shell (needs forge).
# Requires soldeer deps installed: nix develop github:rainlanguage/rainix#sol-shell -c forge soldeer install
set -euo pipefail
nix develop -c bash -euxo pipefail -c '
  mkdir -p meta
  forge script --silent ./script/BuildAuthoringMeta.sol
  rain meta build \
    -i <(cat ./meta/ERC4626SubParserAuthoringMeta.rain.meta) \
    -m authoring-meta-v2 \
    -t cbor \
    -e deflate \
    -l none \
    -o meta/ERC4626Words.rain.meta \
    ;
'
nix develop github:rainlanguage/rainix#sol-shell -c bash -euxo pipefail -c '
  forge script --silent ./script/BuildPointers.sol
  forge fmt
'
