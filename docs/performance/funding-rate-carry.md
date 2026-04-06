# Funding Rate Carry

## Strategy Description

Funding Rate Carry captures the recurring funding payments embedded in perpetual futures contracts. In most market regimes, perpetual futures trade at a premium to spot, causing long holders to pay a funding fee to short holders at regular intervals. This strategy holds a spot long position while simultaneously shorting the equivalent perpetual future, creating a delta-neutral position that collects the funding rate differential as income.

The result is a yield-like return stream with minimal exposure to the direction of the underlying asset. Variants differ by which assets are traded and on which exchange, but the core mechanism is the same across all three.

---

## HYPE Variant

Single-asset funding rate carry on HYPE, executed on Hyperliquid.

**Inception:** December 2024
**Last data point:** September 2025
**Exchange:** Hyperliquid

### Key Metrics

| Metric | Value |
|---|---|
| Period | 10 months |
| Total ROI | 10.67% |
| Annualized ROI | 14.18% |
| Max Drawdown | -0.20% |
| Sharpe Ratio | 13.60 |

### Monthly P&L

| Month | PnL | Cumulative |
|---|---|---|
| Dec 2024 | 0.22% | 0.22% |
| Jan 2025 | 2.09% | 2.31% |
| Feb 2025 | 0.91% | 3.24% |
| Mar 2025 | 0.72% | 3.98% |
| Apr 2025 | 0.42% | 4.43% |
| May 2025 | 1.66% | 6.16% |
| Jun 2025 | 0.85% | 7.06% |
| Jul 2025 | 1.60% | 8.77% |
| Aug 2025 | 0.82% | 9.66% |
| Sep 2025 | 0.92% | 10.67% |

Every month positive. Consistent monthly returns ranging from 0.22% to 2.09%.

---

## BTC Variant

Single-asset funding rate carry on BTC, executed on Hyperliquid.

**Inception:** April 2025
**Last data point:** September 2025
**Exchange:** Hyperliquid

### Key Metrics

| Metric | Value |
|---|---|
| Period | ~6 months |
| Total ROI | 4.14% |
| Annualized ROI | ~8.3% |
| Max Drawdown | ~-0.5% |

Sharpe Ratio not calculated due to short track record.

### Monthly P&L

| Month | PnL | Cumulative |
|---|---|---|
| Apr 2025 | -0.02% | -0.02% |
| May 2025 | 0.93% | 0.92% |
| Jun 2025 | 0.44% | 1.36% |
| Jul 2025 | 1.24% | 2.62% |
| Aug 2025 | 0.79% | 3.43% |
| Sep 2025 | 0.69% | 4.14% |

Lower returns than the HYPE variant, reflecting BTC's typically lower funding rates. One marginal negative month (-0.02% in April 2025).

---

## Multi-Asset Variant

Diversified funding rate carry across multiple assets, executed on Binance Coin-M Futures.

**Inception:** April 2024
**Last data point:** September 2025
**Exchange:** Binance Coin-M Futures

### Key Metrics

| Metric | Value |
|---|---|
| Period | ~18 months |
| Total ROI | ~17% |
| Annualized ROI | ~11.3% |

Max Drawdown and Sharpe Ratio not available for this variant.

### Asset Selection Methodology

1. Start with top 50 coins by market cap on Binance Coin-M
2. Rank by cumulative 1-year funding fees, take top 20
3. Filter to top 10 by lowest Maximum Drawdown (MDD)
4. Monthly rebalance with tiered retention (Tier 1: ranks 1-10, Tier 2: ranks 11-20, below threshold = replace)

### Notes

This is the longest-running variant at approximately 18 months. Exact monthly P&L breakdowns are not provided as available data is chart-derived approximation. The equity curve demonstrates consistent performance across multiple assets and varying market conditions over the full period.

---

Past performance is not indicative of future results. All figures denominated in USD.
