# BTC Dominance Long/Short

## Strategy Description

BTC Dominance Long/Short takes positions based on Bitcoin's share of total cryptocurrency market capitalization (BTC.D). The core thesis is that Bitcoin dominance tends to rise during risk-off periods and fall during altcoin-driven rallies, creating a persistent and exploitable signal. The strategy goes long BTC and short a basket of altcoins when dominance is rising, and reduces or reverses exposure when dominance declines.

The two variants differ in how aggressively they size the BTC long leg. The Balanced variant scales BTC long weight proportionally to the dominance ratio, producing moderate returns with controlled drawdowns. The Max variant maintains a 100% BTC long weight at all times, amplifying both gains and losses.

---

## Balanced Variant

**Inception:** August 2024
**Last data point:** September 2025
**Exchange:** Binance / Hyperliquid

### Key Metrics

| Metric | Value |
|---|---|
| Period | 13 months |
| Total ROI | 37.77% |
| Annualized ROI | 34.06% |
| Max Drawdown | -13.34% |
| Sharpe Ratio | 1.51 |

### Monthly P&L

| Month | PnL | Cumulative |
|---|---|---|
| Aug 2024 | -0.55% | -0.55% |
| Sep 2024 | 3.82% | 3.25% |
| Oct 2024 | 8.77% | 12.31% |
| Nov 2024 | 9.61% | 23.10% |
| Dec 2024 | 1.31% | 24.71% |
| Jan 2025 | 5.01% | 30.95% |
| Feb 2025 | -5.03% | 24.36% |
| Mar 2025 | 1.21% | 25.87% |
| Apr 2025 | 9.80% | 38.20% |
| May 2025 | 3.98% | 43.70% |
| Jun 2025 | 2.40% | 47.15% |
| Jul 2025 | -2.35% | 43.68% |
| Aug 2025 | -7.45% | 32.98% |
| Sep 2025 | 3.61% | 37.77% |

3 negative months out of 14. Largest single-month loss: -7.45% (August 2025). Best month: +9.80% (April 2025).

---

## Max Variant

**Inception:** August 2024
**Last data point:** September 2025
**Exchange:** Binance / Hyperliquid

### Key Metrics

| Metric | Value |
|---|---|
| Period | 13 months |
| Total ROI | 61.49% |
| Annualized ROI | ~56% |
| Max Drawdown | ~-22% |

Sharpe Ratio not calculated for this variant.

### Monthly P&L

| Month | PnL | Cumulative |
|---|---|---|
| Aug 2024 | -1.65% | -1.65% |
| Sep 2024 | 6.75% | 4.99% |
| Oct 2024 | 11.91% | 17.49% |
| Nov 2024 | 19.91% | 40.88% |
| Dec 2024 | 0.30% | 41.30% |
| Jan 2025 | 7.71% | 52.20% |
| Feb 2025 | -11.25% | 35.07% |
| Mar 2025 | 0.59% | 35.86% |
| Apr 2025 | 13.21% | 53.82% |
| May 2025 | 6.58% | 63.94% |
| Jun 2025 | 3.01% | 68.87% |
| Jul 2025 | -0.36% | 68.25% |
| Aug 2025 | -8.89% | 53.30% |
| Sep 2025 | 5.34% | 61.49% |

Highest absolute returns across all strategies but also the highest volatility. 3 negative months out of 14. Worst month: -11.25% (February 2025). Best month: +19.91% (November 2024).

---

Past performance is not indicative of future results. All figures denominated in USD.
