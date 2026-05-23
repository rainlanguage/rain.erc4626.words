# st0x.words

Rain subparser and extern (`St0xWords`) for ST0x Rain words. Today this includes
[ERC-4626](https://eips.ethereum.org/EIPS/eip-4626) vault conversions; more
words may be added later.

## Usage

Provides two words that call conversion functions on any ERC-4626 vault
contract.

```rain
using-words-from <St0xWords address>

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

Enter the nix dev shell first — it provides `forge`, `rain`, and all other
tools:

```sh
nix develop
```

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Regenerate pointers

Run the prelude to produce the CBOR-encoded meta, then regenerate the pointer
constants:

```sh
nix run .#st0x-prelude
forge script script/BuildSt0xWords.sol
```

The generated file `src/generated/St0xWords.pointers.sol` must be committed. The
`git-clean` CI job enforces this by re-running both steps and checking
`git diff --exit-code`.

### Deploy

```sh
DEPLOYMENT_KEY=<private-key> forge script script/DeploySt0xWords.sol \
  --rpc-url <rpc-url> \
  --broadcast \
  --verify
```

Or trigger the **Manual sol artifacts** GitHub Actions workflow from the Actions
tab, selecting the target network.

## CI

| Workflow                 | Trigger         | What it does                                                                |
| ------------------------ | --------------- | --------------------------------------------------------------------------- |
| **Rainix CI**            | push            | Runs `rainix-sol-test`, `rainix-sol-static`, `rainix-sol-legal` in parallel |
| **Git is clean**         | push            | Regenerates meta + pointers + format, fails if anything changed             |
| **Manual sol artifacts** | manual dispatch | Deploys to chosen network via `rainix-sol-artifacts`                        |

Required secrets: `PRIVATE_KEY`, `PRIVATE_KEY_DEV`, `CI_DEPLOY_RPC_URL`,
`EXPLORER_VERIFICATION_KEY`, `CI_DEPLOY_BASE_RPC_URL`,
`CI_DEPLOY_BASE_ETHERSCAN_API_KEY`.
