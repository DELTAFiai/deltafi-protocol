# Hyperliquid Ecosystem Overview

Hyperliquid has emerged as the leading purpose-built L1 for on-chain trading, combining a fully on-chain central limit order book with EVM compatibility under a single consensus mechanism. This overview maps the protocol's architecture, ecosystem participants, developer tooling, and structural gaps as of early 2026 -- providing the foundation for evaluating strategy deployment on the platform.

---

## Core Protocol

Hyperliquid is a purpose-built L1 blockchain optimized for on-chain trading, with two execution layers under a single consensus (HyperBFT):

- **HyperCore** -- Rust-based VM running a fully on-chain central limit order book (CLOB). 200k orders/sec, sub-second finality.
- **HyperEVM** -- EVM-compatible layer (Chain ID 999). Solidity contracts can read order book prices via read precompiles.
- **Products**: 229 perp markets (BTC up to 40x), spot trading with native token deployments, vault system.

Key primitives: read precompiles, write system contracts (rolling out), builder codes (0.1% fee per routed trade), native vault creation, HIP token standards.

## Ecosystem dApps (~175+ teams, ~$3.3B TVL)

### DeFi -- Lending and CDPs
- HyperLend ($380M TVL) -- lending/borrowing/flash loans
- Felix Protocol ($401M TVL) -- CDP minting feUSD
- Hyperdrive -- lending + liquid staking
- Timeswap, Summer.fi

### DEXs and Liquidity
- Valantis Labs -- embedded liquidity DEX (acquired stakedhype)
- Hyperpie -- ve(3,3) DEX + launchpad
- Rage Trade, Pear Protocol

### Liquid Staking
- Kinetiq ($740M TVL) -- dominant stHYPE provider
- Thunderhead

### Yield and Vaults
- HLP -- protocol vault (market making, liquidations, fee accrual, 4-day lockup, no fee)
- User Vaults -- anyone can create, 10% profit share
- Liminal -- delta-neutral funding rate yield

### Trading Tools
- Insilico Terminal
- HypurrDash -- analytics + whale tracking
- goodcryptoX -- grid/DCA bots
- Hummingbot, WunderTrading (copy trading)
- TradeStream, Vegas, GUESS

### Infrastructure
- Oracles: Pyth, RedStone, Stork, native Chainlink-compatible
- Bridges: deBridge, LayerZero, Unit
- RPC: QuickNode, Alchemy, Chainstack, Dwellir
- Explorer: HypurrScan
- Analytics: Nansen, DefiLlama, DappRadar
- Data pipelines: ChainSight

### Launchpads and Social
- HypurrFun -- memecoin launchpad
- fan.fun
- Buffer Finance -- binary options
- Spectral -- on-chain credit/AI

## Developer Ecosystem

- **Official SDKs**: Python (`hyperliquid-python-sdk`), Rust (`hyperliquid-rust-sdk`)
- **Community SDKs**: TypeScript by nktkas and nomeida, CCXT integration
- **HyperEVM**: Two RPC paths (`/evm` standard, `/nanoreth` with tracing). Testnet available.
- **Docs**: GitBook at `hyperliquid.gitbook.io`
- **Resources**: `HyperDevCommunity/AwesomeHyperEVM` on GitHub

## Structural Gaps vs. Mature Ecosystems

- No robust options protocols
- No advanced portfolio management tools
- Limited mobile experience
- No governance tooling
- Young prediction market ecosystem (HIP-4 launched Feb 2026)
- No sophisticated risk management tools
- Write system contracts not fully live (limits EVM-to-order-book composability)
- Validator centralization concerns
- UI not customizable, no official mobile app

## Unique Features

- **Fully on-chain CLOB** -- no off-chain matching
- **HIP-1**: Tokens deploy with instant order book + spot trading + staking
- **HIP-2 (Hyperliquidity)**: Market-making logic embedded in block transitions. 0.3% spread every 3 seconds, zero maintenance.
- **HIP-3**: Permissionless perpetual market creation
- **HIP-4** (Feb 2026): Native prediction markets / outcome trading
- **Builder Codes**: On-chain fee-sharing per trade
- **Vault System**: On-chain hedge fund infrastructure (HLP + user vaults)
- **Dual-VM Architecture**: HyperCore (Rust) + HyperEVM (Solidity) under one consensus

## 2025-2026 Metrics

- ~$2.95T cumulative volume
- ~$843M revenue
- $8.34B average daily volume
- $5.6B peak open interest

## Sources

- Hyperliquid Official Docs
- DWF Labs Ecosystem Summary
- DefiLlama -- Hyperliquid L1
- HypeWatch Complete Guide 2026
- AwesomeHyperEVM (GitHub)
- CryptoAdventure 2025 Annual Report
