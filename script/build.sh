#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate committed meta artifacts that rainix copy-artifacts diff-checks.
# Delegates to the erc4626-words-prelude nix task, which is the single source
# of truth for the meta build commands (avoids duplication with flake.nix).
set -euo pipefail
nix run .#erc4626-words-prelude
