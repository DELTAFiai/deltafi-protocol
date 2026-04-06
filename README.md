# DELTAFi Protocol

**Autonomous Strategies. On-Chain Proof.**

## Overview

DELTAFi Protocol is an ERC-4626 vault deployed on HyperEVM that bridges to Hyperliquid's L1 (HyperCore) to execute combined spot and perpetual positions.

Native Hyperliquid vaults are perps-only. This vault enables strategies that require both sides of the book -- for example, holding long spot while shorting the corresponding perpetual to capture funding rate carry. Without L1 bridge access, this is not possible from HyperEVM alone.

## Architecture

The vault interacts with HyperCore through two mechanisms:

**Reading L1 state** -- HyperEVM exposes precompile addresses that return real-time L1 data: spot balances, perp positions, mark prices, withdrawable amounts, and token metadata. The vault uses these to compute its total asset value (spot + perp) for accurate share pricing.

**Writing L1 actions** -- The CoreWriter system contract at `0x333...333` accepts encoded action payloads. The vault uses this to execute L1 operations: transferring spot tokens, moving USD between spot and perp accounts, and registering API wallets for automated trading.

### Flow

1. Authorized participant deposits ERC-20 tokens on HyperEVM
2. Vault mints ERC-4626 shares and bridges deposited tokens to L1 via the spot bridge
3. Portfolio manager allocates capital between spot and perp accounts on L1
4. `totalAssets()` queries L1 precompiles to compute real-time NAV across both accounts
5. On withdrawal, vault sends spot tokens from L1 back to the bridge for EVM settlement

## Contracts

```
contracts/
  DELTAFiVault.sol      -- ERC-4626 vault with L1 spot+perp bridge integration
  PriceOracle.sol        -- Redstone-compatible price feed aggregator
  lib/
    L1Read.sol           -- Reference: all HyperEVM L1 read precompiles
    CoreWriter.sol       -- Reference: HyperCore raw action writer
```

### DELTAFiVault.sol

The primary vault contract. Inherits ERC-4626 for standardized deposit/withdraw, with additional access control:

- **Owner** -- Sets fees, authorized participants, portfolio manager, pause state
- **Portfolio Manager** -- Moves USD between spot and perp accounts on L1
- **Authorized Participants** -- Whitelisted addresses that can deposit and withdraw
- **Management Fee** -- Annualized fee (in PPM) accrued as minted shares to the fee receiver
- **Redemption Fee** -- Deducted from withdrawal amounts (in PPM)
- **Pause** -- Owner can pause all deposits and withdrawals

### PriceOracle.sol

Maps Hyperliquid token IDs to Redstone price feed addresses. Returns prices in 8-decimal format. Falls back to 1e8 (i.e., $1.00) when no feed is configured.

### lib/

Reference contracts for the HyperEVM precompile and system contract interfaces. These are published for documentation purposes -- the vault inlines the subset of functionality it needs.

## DELTA Token

| Property | Value |
|----------|-------|
| Token | DELTA |
| Chain | HyperEVM (Chain ID 999) |
| Standard | ERC-20 |
| Contract | `0x6ce07066584109E5b6b77C3a93136a933741cFbC` |
| Buyback | Vault profits used for open market DELTA purchases |

## Links

- **Website:** [deltafinance.io](https://deltafinance.io)
- **Litepaper:** [deltafinance.io/litepaper](https://deltafinance.io/litepaper)
- **Token:** [deltafi-token](https://github.com/DELTAFiai/deltafi-token)

## License

MIT
