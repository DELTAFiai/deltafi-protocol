# DELTA Token

ERC-20 token on HyperEVM — the native asset of the DELTAFi ecosystem.

## Token Details

| Property | Value |
|----------|-------|
| Name | DELTA |
| Symbol | DELTA |
| Chain | HyperEVM |
| Chain ID | 999 |
| Standard | ERC-20 |
| Decimals | 18 |
| Contract | `0x6ce07066584109E5b6b77C3a93136a933741cFbC` |

## Network Configuration

To add HyperEVM to your wallet (e.g., MetaMask):

| Parameter | Value |
|-----------|-------|
| Network Name | HyperEVM |
| RPC URL | `https://rpc.hyperliquid.xyz/evm` |
| Chain ID | 999 |
| Currency Symbol | HYPE |
| Block Explorer | `https://hyperevmscan.io/` |

## Adding DELTA to Your Wallet

Import the token manually using:
- **Contract Address:** `0x6ce07066584109E5b6b77C3a93136a933741cFbC`
- **Token Symbol:** DELTA
- **Decimals:** 18

## Brand Assets

Token logos are available in the [`assets/`](./assets) directory:

- `delta-logo.svg` — SVG source
- `delta-logo-256.png` — 256x256 PNG
- `delta-logo-64.png` — 64x64 PNG
- `delta-logo-32.png` — 32x32 PNG

## Token List Entry

```json
{
  "chainId": 999,
  "address": "0x6ce07066584109E5b6b77C3a93136a933741cFbC",
  "name": "DELTA",
  "symbol": "DELTA",
  "decimals": 18
}
```

## Contract Source

[`contracts/DELTAToken.sol`](../contracts/DELTAToken.sol) -- Standard ERC-20 built on OpenZeppelin (ERC20, Ownable). All tokens minted to deployer at construction. Fixed supply, no additional mint function.

## Links

- **Website:** [deltafinance.io](https://deltafinance.io)
- **Block Explorer:** [View on HyperEVM](https://hyperevmscan.io/token/0x6ce07066584109E5b6b77C3a93136a933741cFbC)
