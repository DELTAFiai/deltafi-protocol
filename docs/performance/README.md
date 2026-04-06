# Strategy Performance

Strategy performance data from live operations. All returns are net of trading costs.

## Overview

DELTAFi operates two strategy families with distinct risk/return profiles. Funding Rate Carry strategies target consistent, low-volatility returns by harvesting perpetual funding rates. BTC Dominance strategies take directional positions based on Bitcoin's share of total crypto market capitalization, producing higher returns with correspondingly higher drawdowns.

All strategies below have been running on live capital for 6 to 18 months. None of the figures are derived from backtests.

## Strategy Comparison

| Strategy | Period | Total ROI | Ann. ROI | Max Drawdown | Sharpe | Risk Profile |
|---|---|---|---|---|---|---|
| [FR Carry -- HYPE](funding-rate-carry.md#hype-variant) | 10 months | 10.67% | 14.18% | -0.20% | 13.60 | Very Low |
| [FR Carry -- BTC](funding-rate-carry.md#btc-variant) | ~6 months | 4.14% | ~8.3% | ~-0.5% | -- | Very Low |
| [FR Carry -- Multi-Asset](funding-rate-carry.md#multi-asset-variant) | ~18 months | ~17% | ~11.3% | -- | -- | Low |
| [BTCDOM Balanced](btc-dominance.md#balanced-variant) | 13 months | 37.77% | 34.06% | -13.34% | 1.51 | Medium |
| [BTCDOM Max](btc-dominance.md#max-variant) | 13 months | 61.49% | ~56% | ~-22% | -- | High |

## Detail Pages

- [Funding Rate Carry](funding-rate-carry.md) -- HYPE, BTC, and Multi-Asset variants
- [BTC Dominance](btc-dominance.md) -- Balanced and Max variants

## Data

Monthly P&L data is available in CSV format under [data/](data/).

- [funding-rate-carry-hype.csv](data/funding-rate-carry-hype.csv)
- [funding-rate-carry-btc.csv](data/funding-rate-carry-btc.csv)
- [btcdom-balanced.csv](data/btcdom-balanced.csv)
- [btcdom-max.csv](data/btcdom-max.csv)

---

Past performance is not indicative of future results. All figures denominated in USD.
