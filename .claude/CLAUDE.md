# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Project Overview

**rain.erc4626.words** — Rain subparser and extern words for
[ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) tokenised vaults.

Provides `erc4626-convert-to-assets` and `erc4626-convert-to-shares`,
implemented via `ERC4626Words` (concrete) and libraries under `src/`. Depends on
`lib/rain.interpreter` (git submodule).

## Build & Test Commands

All commands require the Nix development shell: `nix develop` or
`nix develop -c <cmd>`.

| Task                   | Command                                                    |
| ---------------------- | ---------------------------------------------------------- |
| Build                  | `nix develop -c forge build`                               |
| Test                   | `nix develop -c forge test`                                |
| Regenerate meta + CBOR | `nix develop -c erc4626-words-prelude`                     |
| Regenerate pointers    | `nix develop -c forge script script/BuildERC4626Words.sol` |
| Format                 | `nix develop -c forge fmt`                                 |
| Solidity tests (CI)    | `nix develop -c rainix-sol-test`                           |
| Slither (CI)           | `nix develop -c rainix-sol-static`                         |
| REUSE license (CI)     | `nix develop -c rainix-sol-legal`                          |

Regenerate artifacts the way **Git is clean** CI does:

```sh
nix develop -c erc4626-words-prelude
nix develop -c forge script script/BuildERC4626Words.sol
nix develop -c forge fmt
git diff --exit-code
```

Commit `meta/ERC4626Words.rain.meta` and
`src/generated/ERC4626Words.pointers.sol` when they change.

Run a single test:

```sh
nix develop -c forge test --match-contract ERC4626Words
```

## Architecture

- `src/concrete/ERC4626Words.sol` — Words contract deployed on-chain
- `src/abstract/` — `ERC4626SubParser`, `ERC4626Extern`
- `src/lib/op/erc4626/` — Opcode implementations
- `src/generated/ERC4626Words.pointers.sol` — Generated; do not edit by hand
- `script/BuildAuthoringMeta.sol` — Emits authoring meta (prelude runs this +
  `rain meta build`)
- `script/BuildERC4626Words.sol` — Regenerates pointer constants
- `flake.nix` — Defines `erc4626-words-prelude` nix task

## Key Configuration

- **Solidity**: `foundry.toml` — solc 0.8.25, Cancun EVM, optimizer 1000 runs,
  `bytecode_hash = "none"`, `cbor_metadata = false`
- **Slither**: `slither.config.json` at repo root (required for
  `rainix-sol-static`)
- **Submodules**: `lib/rain.interpreter`, `lib/forge-std` — init with
  `git submodule update --init --recursive`

## Licensing

DecentraLicense 1.0 (DCL-1.0). REUSE 3.3 compliant — annotate new tracked files
in `REUSE.toml` or with SPDX headers.
