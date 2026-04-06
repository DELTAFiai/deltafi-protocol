# Funding Rate Carry

## Overview

Funding Rate Carry is a market-neutral strategy that collects the recurring funding payments embedded in perpetual futures contracts. In most market regimes, leveraged speculators pay a structural premium to hold perpetual positions, and this premium flows to the counterparty at regular settlement intervals. The strategy captures this premium by holding equal and opposite positions in spot and perpetual markets on the same asset, producing a yield-like return stream with near-zero directional exposure.

## How Assets Are Selected

Asset selection follows a two-step filter designed to identify instruments that generate consistent yield without exposing the portfolio to outsized drawdowns.

The first step ranks all eligible perpetual markets by their cumulative funding payments over a trailing lookback window. This isolates the subset of assets where leveraged demand is strongest and the funding premium is most persistent. Assets with low or negative cumulative funding are excluded regardless of other characteristics.

The second step filters the remaining candidates by historical maximum drawdown of the carry position. An asset may generate high funding, but if it does so while subjecting the hedged position to large interim losses -- from basis divergence, liquidation risk on the short leg, or extreme spot volatility -- it fails this filter. The result is a universe of assets that produce yield and do so with stability.

This two-step process is the core of the selection logic. It avoids the common failure mode in carry strategies: chasing the highest-yielding instruments, which are often the most volatile.

## Position Construction

For each selected asset, the strategy opens a long spot position and a short perpetual position of equal notional value. The spot leg appreciates when the asset rises and depreciates when it falls. The perp short does the opposite. The two legs cancel, leaving the combined position with approximately zero sensitivity to the underlying price.

This is a delta-neutral construction. Revenue comes from the hourly funding payments collected on the short perpetual leg, not from directional price movement.

The requirement for simultaneous spot and perpetual exposure is the reason DELTAFi built a custom ERC-4626 vault on HyperEVM with L1 bridge integration. Native Hyperliquid vaults are perps-only and cannot hold spot positions. Without spot capability, this strategy cannot be implemented as described -- it would require a perp-perp approximation that introduces basis risk between two derivative instruments rather than eliminating it through spot anchoring.

## Rebalancing

The portfolio is rebalanced monthly. At each rebalance, all eligible assets are re-ranked using the same two-step selection process.

A tiered retention system governs which positions are kept, added, or removed. Assets that rank in the top tier are held or added to the portfolio. Assets in a middle tier are retained if already held, but not added as new positions -- this reduces unnecessary turnover from minor rank fluctuations. Assets that fall below the retention threshold are replaced.

This system balances responsiveness to changing market conditions against the transaction costs and slippage incurred by frequent position changes. In funding rate carry, where individual position returns are modest, minimizing unnecessary trading friction is material to net performance.

## Risk Controls

Risk management for this strategy operates through the shared risk framework described in [risk-framework.md](risk-framework.md). Key constraints applied at the strategy level:

- **Position size limits.** No single asset's carry position exceeds a defined fraction of strategy capital. This prevents concentration in any one funding stream.
- **Aggregate exposure caps.** Total notional across all carry positions is bounded relative to vault NAV.
- **Drawdown circuit breakers.** If the strategy's cumulative drawdown reaches a predefined threshold, position sizes are reduced automatically. At a more severe threshold, the strategy is wound down entirely. These thresholds are enforced by the risk system independently of the strategy logic.

## Variants

**HYPE** -- Single-asset funding rate carry on HYPE, executed on Hyperliquid. Concentrated exposure to one asset's funding stream. Suitable when HYPE funding rates are elevated due to speculative demand for the native token.

**BTC** -- Single-asset funding rate carry on BTC, executed on Hyperliquid. BTC typically has lower but more consistent funding rates than smaller assets. Lower yield, lower variance.

**Multi-Asset** -- Diversified carry across a portfolio of selected assets. The two-step filter process described above applies to this variant. Diversification across multiple funding streams reduces dependence on any single asset's funding dynamics and smooths the return profile.

---

This document describes the methodology. It does not constitute a guarantee of future performance.
