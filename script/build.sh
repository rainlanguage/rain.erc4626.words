#!/usr/bin/env bash
# SPDX-License-Identifier: LicenseRef-DCL-1.0
# SPDX-FileCopyrightText: Copyright (c) 2020 Rain Open Source Software Ltd
# Regenerate committed meta artifacts that rainix copy-artifacts diff-checks.
# Runs in the repo default devshell because `rain` is not in rainix sol-shell.
set -euo pipefail
nix develop -c erc4626-words-prelude
