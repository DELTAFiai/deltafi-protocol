# DELTAFi Litepaper

## 1. Abstract

DELTAFi is an AI-native systematic trading vault on Hyperliquid. It runs two strategy families -- Funding Rate Carry and BTC Dominance Long/Short -- with live track records of 6 to 18 months, producing annualized returns between 8% and 56% depending on variant and risk profile. All trading occurs on Hyperliquid's on-chain order book, making every order, fill, and position independently verifiable. The vault is an ERC-4626 contract on HyperEVM that bridges to HyperCore for combined spot and perpetual capability, enforcing fee calculations, NAV accounting, and permissionless withdrawals at the protocol level.

## 2. The Problem

### Opacity in Fund Management

The global hedge fund industry manages approximately $4.7 trillion. Investors in these funds accept a fundamental constraint: they cannot independently verify what is being done with their capital. They receive periodic reports, audited by third parties, summarizing positions and returns after the fact. The history of finance provides a catalog of what happens when verification is absent -- Madoff, Archegos, FTX, Three Arrows Capital. Each case involved prolonged periods where reported performance diverged from actual risk, and investors had no mechanism to detect the divergence until collapse.

This problem is not solved by moving to DeFi. Most on-chain vaults that claim active management are operationally identical to their off-chain counterparts: a manager trades on behalf of depositors, and depositors trust the manager's competence and honesty. The on-chain settlement layer provides custody guarantees but not transparency into strategy execution.

### The Passive DeFi Default

The vast majority of capital deployed in DeFi earns passive yields: liquidity provision, lending, staking. These activities are valuable infrastructure, but they do not generate alpha. They provide the market rate for capital deployment in a given protocol.

The few DeFi vaults that attempt active alpha generation tend to be opaque about their methodology, unverifiable in their execution, or both. The result is a gap: depositors who want active management with on-chain verifiability have almost no options.

## 3. The Convergence

Three conditions are now simultaneously true, creating a window that did not exist two years ago.

**AI inference costs have dropped enough to run trading systems at scale.** The cost of running inference for signal generation, risk monitoring, and execution optimization has fallen by orders of magnitude. What required dedicated GPU clusters in 2022 can run as a continuous service in 2025 at a fraction of the cost. This makes AI-driven systematic trading economically viable for on-chain vaults, not just for institutions with nine-figure AUM.

**Hyperliquid provides an on-chain central limit order book with real liquidity.** For the first time, a fully on-chain exchange offers the order book structure, execution speed, and depth required for systematic strategies. Hyperliquid processes orders with sub-second finality on its L1, and every order is recorded on-chain. This is not an AMM approximation -- it is a proper CLOB with the properties that systematic trading requires.

**Market depth is sufficient for systematic strategies.** Hyperliquid's perpetual markets have reached the liquidity thresholds where funding rate carry and relative-value strategies can operate without excessive market impact. The strategies described in this paper require the ability to enter and exit positions across multiple instruments without moving the market against themselves. That depth now exists.

These three conditions converge to make DELTAFi possible. The system is built to operate in this window.

## 4. The Solution: Glass Box, Not Black Box

DELTAFi's strategy logic is closed-source. This is deliberate -- publishing signal generation methodology would erode the alpha it produces. But the outputs of that logic are fully transparent.

Every order placed by the vault is submitted to Hyperliquid's on-chain order book. Every fill, cancellation, and funding payment is recorded on L1. Any observer can reconstruct the vault's complete trading history from on-chain data. Real-time exposure -- gross, net, by asset, by strategy -- is derivable from the same data. The vault's NAV is computed by querying L1 state directly through HyperEVM precompiles.

Fee calculations are enforced by the smart contract. Withdrawal rights are permissionless and encoded in the ERC-4626 standard. No administrator can prevent a depositor from redeeming their shares for the underlying assets.

This is the principle: **transparency of state, privacy of signal.** Depositors can verify exactly what the vault holds and what it has done. They cannot see why it made those decisions. This is the same information boundary that exists between a fund's investors and its portfolio -- but enforced by protocol rather than by trust.

## 5. Strategy Framework

DELTAFi operates two systematic strategy families. Funding Rate Carry targets consistent, low-volatility returns through delta-neutral positions. BTC Dominance Long/Short captures the relative performance differential between Bitcoin and altcoins. The two families have near-zero cross-correlation by construction: one harvests a structural premium that exists regardless of market direction, while the other expresses a directional view on market composition. Capital allocation between strategies is dynamic, adjusted based on observed market conditions and strategy performance.

### 5.1 Funding Rate Carry

Funding Rate Carry captures the recurring funding payments embedded in perpetual futures contracts. In most market regimes, leveraged speculators pay a structural premium to hold perpetual positions. This premium flows to the counterparty at regular settlement intervals.

The strategy holds a long spot position and a short perpetual position of equal notional value on the same asset, creating a delta-neutral construction. Revenue comes from the hourly funding payments collected on the short perpetual leg, not from directional price movement.

**Asset selection** follows a two-step filter. The first step ranks all eligible perpetual markets by cumulative funding payments over a trailing lookback window, isolating instruments where leveraged demand is strongest. The second step filters the remaining candidates by historical maximum drawdown of the carry position. An asset may generate high funding, but if the hedged position experiences large interim losses from basis divergence or extreme spot volatility, it is excluded. This two-step process avoids the common failure mode in carry strategies: chasing the highest-yielding instruments, which are often the most volatile.

**Rebalancing** occurs monthly. A tiered retention system governs position changes: top-ranked assets are held or added, middle-ranked assets are retained if already held but not added, and assets below the retention threshold are replaced. This reduces unnecessary turnover from minor rank fluctuations.

**Variants.** HYPE runs single-asset carry on HYPE. BTC runs single-asset carry on BTC. Multi-Asset diversifies across a portfolio of selected assets using the full two-step filter process.

### 5.2 BTC Dominance Long/Short

BTC Dominance Long/Short goes long Bitcoin and short a market-cap-weighted basket of altcoins. It profits when Bitcoin outperforms the broader cryptocurrency market -- a condition that corresponds to rising BTC dominance.

**Core thesis.** Bitcoin dominance is a structural market signal with documented regime behavior. When dominance declines, speculative capital is rotating into altcoins -- a pattern associated with late-cycle euphoria. When dominance rises, capital consolidates back into Bitcoin as the highest-liquidity asset in the ecosystem. The strategy maintains a persistent structural position that benefits from the long-term tendency of BTC dominance to revert upward after periods of altcoin outperformance.

**Position construction.** The long leg holds a BTC perpetual position. The short leg distributes across top altcoins by market capitalization, with each altcoin's short size proportional to its share of the non-BTC market. The result is an approximately market-neutral portfolio that extracts returns only from the differential between BTC and altcoin performance.

**Rebalancing** is monthly. Market capitalizations are recalculated and short-leg weights updated to reflect current altcoin market composition. The same tiered retention system used in Funding Rate Carry prevents excessive turnover.

**Variants.** Balanced sizes the BTC long proportionally to Bitcoin's current dominance ratio, producing a more conservative risk profile. Max sizes the BTC long at 100% of strategy capital regardless of current dominance, amplifying returns and drawdowns proportionally.

### 5.3 Future Strategies

Additional strategy families -- including market making, trend following, and statistical arbitrage -- are in development. Each will be added to the vault only when it meets the same standard applied to the current strategies: a live track record of sufficient length to evaluate risk-adjusted performance under real market conditions. DELTAFi expands capability incrementally, not speculatively.

## 6. Performance

All figures below are from live operations on real capital. None are derived from backtests. Returns are net of trading costs.

### Strategy Comparison

| Strategy | Period | Total ROI | Ann. ROI | Max Drawdown | Sharpe | Risk Profile |
|---|---|---|---|---|---|---|
| FR Carry -- HYPE | 10 months | 10.67% | 14.18% | -0.20% | 13.60 | Very Low |
| FR Carry -- BTC | ~6 months | 4.14% | ~8.3% | ~-0.5% | -- | Very Low |
| FR Carry -- Multi-Asset | ~18 months | ~17% | ~11.3% | -- | -- | Low |
| BTCDOM Balanced | 13 months | 37.77% | 34.06% | -13.34% | 1.51 | Medium |
| BTCDOM Max | 13 months | 61.49% | ~56% | ~-22% | -- | High |

### Highlights

**Funding Rate Carry -- HYPE** produced 10 consecutive positive months (December 2024 through September 2025) with a maximum drawdown of -0.20% and a Sharpe ratio of 13.60. 10 months live.. Monthly returns ranged from 0.22% to 2.09%. This is a near-zero-volatility return stream.

**Funding Rate Carry -- BTC** returned 4.14% over approximately 6 months with one marginal negative month (-0.02%). Lower yield than the HYPE variant, reflecting BTC's typically lower funding rates, but with similar consistency.

**Funding Rate Carry -- Multi-Asset** is the longest-running variant at approximately 18 months, returning ~17% with diversified exposure across multiple funding streams on Binance Coin-M Futures.

**BTCDOM Balanced** returned 37.77% over 13 months with a Sharpe ratio of 1.51 and maximum drawdown of -13.34%. Best month: +9.80% (April 2025). 3 negative months out of 14.

**BTCDOM Max** returned 61.49% over the same 13-month period. Highest absolute returns across all strategies, with the highest volatility. Best month: +19.91% (November 2024). Maximum drawdown approximately -22%.

Full monthly P&L breakdowns and CSV data are available in the [performance documentation](performance/) of this repository.

*Past performance is not indicative of future results. All figures denominated in USD.*

## 7. Vault Architecture

### Why a Custom Vault

Native Hyperliquid vaults are perpetuals-only. They cannot hold spot positions. Funding Rate Carry requires simultaneous long spot and short perpetual positions on the same asset. Without spot capability, the strategy would require a perp-perp approximation that introduces basis risk between two derivative instruments rather than eliminating it through spot anchoring. DELTAFi built a custom vault to solve this.

### ERC-4626 on HyperEVM

The vault is a standard ERC-4626 tokenized vault deployed on HyperEVM. Depositors receive shares proportional to their contribution. Shares are redeemable for the underlying assets at any time through the standard ERC-4626 withdrawal interface.

### L1 Bridge Integration

The vault bridges deposited assets from HyperEVM to HyperCore (Hyperliquid's L1) where trading occurs. Two mechanisms enable this:

- **Reading L1 state.** HyperEVM exposes precompile addresses that return real-time L1 data: spot balances, perpetual positions, mark prices, and withdrawable amounts. The vault uses these to compute total asset value across both spot and perp accounts.
- **Writing L1 actions.** The CoreWriter system contract accepts encoded action payloads for L1 operations: transferring spot tokens, moving USD between spot and perp accounts, and registering API wallets for automated trading.

### NAV Calculation

`totalAssets()` queries L1 precompiles to aggregate spot balances and perpetual position values, producing a real-time NAV that reflects actual holdings across both accounts. Share pricing is derived from this computation.

### Role Separation

- **Owner** -- Sets fees, authorized participants, portfolio manager, and pause state.
- **Portfolio Manager** -- Moves capital between spot and perp accounts on L1. Cannot withdraw funds.
- **Authorized Participants** -- Whitelisted addresses permitted to deposit and withdraw.

Management and redemption fees are enforced by the contract in parts-per-million precision. The owner can pause deposits and withdrawals in emergency conditions.

The vault contract code is open-source and available in this repository.

## 8. Risk Architecture

Risk management at DELTAFi is structurally separated from strategy logic. The system that generates trading signals and the system that constrains those signals operate independently. Strategy logic cannot override risk limits. Risk enforcement runs at a higher privilege level than signal generation.

### Position-Level Controls

- **Maximum position size.** No single instrument position can exceed a defined fraction of total vault NAV.
- **Stop-loss enforcement.** Each position carries a maximum acceptable loss threshold, enforced as a hard constraint that strategy logic cannot delay or override.
- **Leverage limits.** Each strategy operates within a defined maximum leverage envelope calibrated to its risk characteristics.

### Portfolio-Level Controls

- **Cross-strategy correlation monitoring.** Realized correlations between strategy returns are tracked on a rolling basis. When correlations spike -- as they tend to during market stress -- aggregate position sizes are reduced automatically.
- **Maximum aggregate exposure.** Total gross exposure across all strategies is bounded as a multiple of vault NAV.
- **Drawdown circuit breakers.** Tiered thresholds trigger automatic responses: proportional allocation reduction at the first threshold, full position wind-down at a more severe threshold. These are not adjustable by strategy logic.

### System-Level Controls

- **Strategy performance monitoring.** Each strategy's realized performance is tracked against its expected risk-return profile. Strategies that underperform their risk budget receive reduced capital allocation dynamically.
- **Kill switch.** The system can flatten all positions across all strategies simultaneously in response to exchange-level incidents, counterparty events, or infrastructure failures.
- **Separation of strategy and execution.** Strategy logic determines what to trade. The execution layer validates every trade against all risk constraints before submitting. If a trade would violate any limit at any level, it is rejected.

## 9. DELTA Token

| Property | Value |
|---|---|
| Standard | ERC-20 |
| Chain | HyperEVM (Chain ID 999) |
| Contract | `0x6ce07066584109E5b6b77C3a93136a933741cFbC` |

The DELTA token is connected to vault performance through a buyback mechanism. A portion of vault trading profits is used to purchase DELTA on the open market. This creates a verifiable, on-chain link between the vault's performance and demand for the token. Buyback transactions are executed on Hyperliquid and are independently verifiable like all other vault activity.

## 10. Why Hyperliquid

DELTAFi is built on Hyperliquid for specific technical reasons:

- **Fully on-chain CLOB.** Every order is recorded on the L1 chain. This provides the verifiability foundation that the entire system depends on. There is no off-chain matching engine.
- **Sub-second finality.** Fast enough for systematic strategies that require responsive execution and position management.
- **HyperEVM for custom smart contracts.** The vault requires custom ERC-4626 logic with L1 bridge integration. HyperEVM provides the smart contract environment; HyperCore provides the trading infrastructure. The two are connected through precompiles and system contracts.
- **Native spot and perpetual markets.** Both instrument types are available on the same L1, enabling the combined spot+perp positions that Funding Rate Carry requires.
- **Programmatic access.** Python and Rust SDKs enable the automated execution that systematic strategies require.

## 11. How It Works

1. **Deposit.** An authorized participant deposits USDC into the vault on HyperEVM. The vault mints ERC-4626 shares proportional to the depositor's contribution relative to current NAV. Deposited capital is bridged to HyperCore.

2. **Trade.** The AI trading system operates autonomously on HyperCore, executing Funding Rate Carry and BTC Dominance strategies within the constraints of the risk framework. All orders are placed on Hyperliquid's on-chain order book.

3. **Earn.** Returns accrue to the vault's NAV. Each share represents a proportional claim on the vault's total assets, which are computed in real time from L1 state. As the vault's trading generates returns, share value increases proportionally.

4. **Buyback.** A portion of trading profits is used to purchase DELTA tokens on the open market. This creates a direct, verifiable mechanism connecting vault performance to token demand.

## 12. Disclaimer

This document is for informational purposes only and does not constitute investment advice, a solicitation, or an offer to purchase any security or financial instrument.

Past performance is not indicative of future results. The performance data presented reflects historical results from live trading operations. Future returns may differ materially due to changes in market conditions, liquidity, funding rate dynamics, regulatory environment, or other factors.

Depositing assets into smart contracts carries inherent risks, including but not limited to: smart contract vulnerabilities, bridge failures, exchange counterparty risk, and loss of deposited capital. The vault's risk framework reduces but does not eliminate the possibility of loss.

Cryptocurrency markets are volatile and subject to regulatory uncertainty across jurisdictions. Participants are responsible for understanding the legal and tax implications of their activities.

The DELTA token is a utility token. Nothing in this document should be construed as a guarantee of token value appreciation.

---

*DELTAFi Protocol -- [github.com/DELTAFiai](https://github.com/DELTAFiai)*
