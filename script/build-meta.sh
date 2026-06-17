#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate committed meta artifacts. rainix copy-artifacts runs this BEFORE
# script/BuildPointers.sol so that pointers are always built from fresh meta.
# Delegates to the erc4626-words-prelude nix task (single source of truth).
set -euo pipefail
nix run .#erc4626-words-prelude
