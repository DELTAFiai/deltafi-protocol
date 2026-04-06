# Risk Framework

## Philosophy

Risk management at DELTAFi is the core architecture, not an ancillary feature. The system that generates trading signals and the system that constrains those signals are structurally separated. Strategy logic cannot override risk limits. Risk enforcement operates at a higher privilege level than signal generation, and the two communicate through well-defined interfaces with hard boundaries.

This separation exists because the failure mode of systematic trading is rarely a bad signal -- it is a good signal that was sized incorrectly, held too long, or allowed to compound with correlated positions across strategies. The risk framework is designed to prevent these failures regardless of what any individual strategy is doing.

## Position-Level Controls

Every position opened by any strategy is subject to constraints enforced before execution.

**Maximum position size.** No single instrument position can exceed a defined fraction of total vault NAV. This prevents concentration risk even when a strategy's signal is strong. The limit applies to both legs of hedged positions independently.

**Stop-loss enforcement.** Each position carries a maximum acceptable loss threshold. If the position's unrealized loss reaches this threshold, it is reduced or closed regardless of the strategy's view. This is a hard constraint -- the strategy logic has no mechanism to delay or override it.

**Leverage limits.** Each strategy operates within a defined maximum leverage envelope. Funding Rate Carry, being delta-neutral, operates at low net leverage. BTC Dominance Long/Short, which carries directional relative-value exposure, operates within tighter gross leverage constraints. The limits are strategy-specific and reflect the risk characteristics of each approach.

## Portfolio-Level Controls

Individual positions can be well-sized and still create dangerous exposure when aggregated across strategies. Portfolio-level controls address this.

**Cross-strategy correlation monitoring.** The risk system tracks realized correlations between strategy returns on a rolling basis. When correlations between ostensibly uncorrelated strategies rise above predefined thresholds, aggregate position sizes are reduced. In crypto markets, correlations tend to spike during stress events -- precisely when diversification is most needed and least available. The system accounts for this by treating high-correlation regimes as a risk state that requires defensive positioning.

**Maximum aggregate exposure.** Total gross exposure across all strategies is bounded as a multiple of vault NAV. This prevents the portfolio from becoming over-levered even if each individual strategy is within its own limits.

**Drawdown circuit breakers.** The portfolio has tiered drawdown thresholds that trigger automatic responses. At the first threshold, all strategy allocations are reduced proportionally. At a more severe threshold, all new position-taking is halted and existing positions are wound down to a defensive state. These thresholds are calibrated to the vault's risk budget and are not adjustable by strategy logic.

## System-Level Controls

Beyond position and portfolio constraints, the system itself is monitored and bounded.

**Strategy performance monitoring.** Each strategy's realized performance is tracked against its expected risk-return profile. A strategy that is underperforming its risk budget -- drawing down more than expected relative to its allocation -- receives a reduced capital allocation. This is dynamic: allocations are adjusted based on observed behavior, not just forward-looking model assumptions. Strategies that consistently underperform their risk-adjusted targets are deprioritized in favor of strategies that are delivering.

**Kill switch.** The system maintains the capability to flatten all positions across all strategies simultaneously. This is a last-resort mechanism for exchange-level incidents, extreme counterparty events, or infrastructure failures. The kill switch operates at the execution layer, independent of all strategy logic.

**Separation of strategy and execution.** Strategy logic determines what to trade. The execution layer determines how and whether to trade it. A strategy can request a position, but the execution layer validates it against all risk constraints before submitting. If a trade would violate any limit at any level, it is rejected. This architecture ensures that the risk framework cannot be circumvented by parameter drift or edge cases in strategy logic.

## Monitoring

All positions are monitored continuously during market hours.

**Exposure tracking.** Real-time gross and net exposure by strategy, by asset, and in aggregate. Delta exposure, notional exposure, and leverage ratios are computed and logged at regular intervals.

**Risk metric computation.** Drawdown from peak, rolling volatility, realized Sharpe, and correlation matrices are updated continuously and compared against their expected ranges.

**On-chain verifiability.** All perpetual positions are executed on Hyperliquid's on-chain order book. Position sizes, entry prices, and funding payments are verifiable by any participant with access to the chain. Spot positions held through HyperEVM are visible on-chain. The vault's total asset computation queries L1 state directly through precompile reads. There is no opaque custody layer between the vault and its positions.

---

This document describes the risk management architecture. Risk controls reduce but do not eliminate the possibility of loss.
