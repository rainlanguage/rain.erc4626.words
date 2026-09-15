# rain.erc4626.words

Rain subparser and extern words for
[ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) tokenised vaults.

## Usage

Provides two words that call conversion functions on any ERC-4626 vault
contract.

```rain
using-words-from <ERC4626Words address>

assets: erc4626-convert-to-assets(vault-address shares);
shares: erc4626-convert-to-shares(vault-address assets);
```

### `erc4626-convert-to-assets`

Converts ERC-4626 vault shares to underlying assets. Accepts 2 inputs: the vault
contract address and the amount of shares as a float. Returns 1 output: the
equivalent amount of underlying assets as a float. The conversion uses the
vault's own convertToAssets function and respects the share and asset token
decimals. Results are rounded down (floor) per the ERC-4626 convertToAssets
specification, which favors the vault.

|             |                                               |
| ----------- | --------------------------------------------- |
| **Input 0** | Vault contract address                        |
| **Input 1** | Share amount as a Float                       |
| **Output**  | Equivalent underlying asset amount as a Float |

```rain
assets: erc4626-convert-to-assets(0xVaultAddress 1e18);
```

### `erc4626-convert-to-shares`

Converts underlying assets to ERC-4626 vault shares. Accepts 2 inputs: the vault
contract address and the amount of underlying assets as a float. Returns 1
output: the equivalent number of vault shares as a float. The conversion uses
the vault's own convertToShares function and respects the asset and share token
decimals. Results are rounded down (floor) per the ERC-4626 convertToShares
specification, which favors the vault.

|             |                                          |
| ----------- | ---------------------------------------- |
| **Input 0** | Vault contract address                   |
| **Input 1** | Asset amount as a Float                  |
| **Output**  | Equivalent vault share amount as a Float |

```rain
shares: erc4626-convert-to-shares(0xVaultAddress 1e18);
```

Both words read `decimals()` from the vault share token and `decimals()` from
the underlying asset token to handle correct float conversion for any decimal
combination (e.g. an 18-decimal share token backed by 6-decimal USDC).

## Development

Enter the nix dev shell first — it provides `forge`, `rain`,
`erc4626-words-prelude`, and all other tools:

```sh
nix develop
```

Install Solidity dependencies (soldeer) after cloning or when `soldeer.lock`
changes:

```sh
nix develop github:rainlanguage/rainix#sol-shell -c forge soldeer install
```

### Build

Requires soldeer dependencies to be installed first (see above).

```sh
forge build
```

### Test

Requires soldeer dependencies to be installed first (see above).

```sh
forge test
```

### Regenerate meta and pointer artifacts

Two separate steps must run in order: first regenerate the CBOR-encoded meta,
then regenerate the pointer constants (which read the meta):

```sh
./script/build.sh
nix develop github:rainlanguage/rainix#sol-shell -c forge script script/Build.sol
nix develop github:rainlanguage/rainix#sol-shell -c forge fmt
```

Equivalent via flake prelude + pointer script:

```sh
nix run .#erc4626-words-prelude
nix develop github:rainlanguage/rainix#sol-shell -c forge script script/Build.sol
```

The generated files `src/generated/ERC4626WordsPointers.sol` and
`meta/ERC4626Words.rain.meta` must be committed. The **Git is clean** CI job
calls the reusable `rainix-copy-artifacts` workflow, which re-runs these steps
and fails with `git diff --exit-code` if any committed file has drifted.

### Deploy

```sh
DEPLOYMENT_KEY=<private-key> forge script script/Deploy.sol \
  --rpc-url <rpc-url> \
  --broadcast \
  --verify
```

Or trigger the **Manual sol artifacts** GitHub Actions workflow from the Actions
tab, selecting the target network.

## CI

| Workflow                 | Trigger         | What it does                                                             |
| ------------------------ | --------------- | ------------------------------------------------------------------------ |
| **rainix-sol**           | push            | Reusable Rainix workflow: test, static analysis, REUSE (`rainix-sol`)    |
| **Git is clean**         | push            | Reusable `rainix-copy-artifacts`: meta, pointers, format, fails if dirty |
| **Manual sol artifacts** | manual dispatch | Deploys to chosen network via `rainix-sol-artifacts`                     |

Required secrets (for the Manual sol artifacts deploy workflow, network=base):
`PRIVATE_KEY`, `CI_DEPLOY_BASE_RPC_URL`, `CI_DEPLOY_BASE_ETHERSCAN_API_KEY`,
`CI_DEPLOY_BASE_VERIFY`, `CI_DEPLOY_BASE_VERIFIER`,
`CI_DEPLOY_BASE_VERIFIER_URL`. For other networks substitute `BASE` with the
network name in uppercase. The CI workflows also use `CACHIX_AUTH_TOKEN`
(org-level, passed via `secrets: inherit`).
