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

Converts vault shares to underlying assets.

|             |                                               |
| ----------- | --------------------------------------------- |
| **Input 0** | Vault contract address                        |
| **Input 1** | Share amount as a Float                       |
| **Output**  | Equivalent underlying asset amount as a Float |

```rain
assets: erc4626-convert-to-assets(0xVaultAddress 1e18);
```

### `erc4626-convert-to-shares`

Converts underlying assets to vault shares.

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

```sh
forge build
```

### Test

```sh
forge test
```

### Regenerate meta and pointer artifacts

Two separate steps must run in order: first regenerate the CBOR-encoded meta,
then regenerate the pointer constants (which read the meta):

```sh
./script/build.sh
nix develop github:rainlanguage/rainix#sol-shell -c forge script script/BuildPointers.sol
nix develop github:rainlanguage/rainix#sol-shell -c forge fmt
```

Equivalent via flake prelude + pointer script:

```sh
nix run .#erc4626-words-prelude
nix develop github:rainlanguage/rainix#sol-shell -c forge script script/BuildPointers.sol
```

The generated files `src/generated/ERC4626Words.pointers.sol` and
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

Required secrets: `PRIVATE_KEY`, `PRIVATE_KEY_DEV`, `CI_DEPLOY_RPC_URL`,
`EXPLORER_VERIFICATION_KEY`, `CI_DEPLOY_BASE_RPC_URL`,
`CI_DEPLOY_BASE_ETHERSCAN_API_KEY`.
