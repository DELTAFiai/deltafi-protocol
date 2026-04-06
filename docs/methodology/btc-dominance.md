# BTC Dominance Long/Short

## Overview

BTC Dominance Long/Short is a systematic strategy that goes long Bitcoin and short a basket of altcoins, weighted by market capitalization. It profits when Bitcoin outperforms the broader cryptocurrency market -- a condition that corresponds to rising BTC dominance. The strategy is hedged: both legs are sized such that the portfolio has limited net market exposure, isolating the relative performance differential between BTC and altcoins.

## Core Thesis

Bitcoin dominance -- its share of total cryptocurrency market capitalization -- is a structural market signal with documented regime behavior. When dominance declines, it typically indicates that speculative capital is rotating into altcoins, a pattern associated with late-cycle euphoria and elevated risk. When dominance rises, capital consolidates back into Bitcoin as the highest-liquidity, lowest-risk asset in the crypto ecosystem.

This is not a timing signal. The strategy does not attempt to predict when dominance will rise or fall. It maintains a persistent structural position that benefits from the long-term tendency of BTC dominance to revert upward after periods of altcoin outperformance. The position is profitable in risk-off environments, during leverage unwinds, and in periods where institutional flows concentrate in Bitcoin -- conditions that occur frequently and persistently across market cycles.

## Position Construction

The long leg holds a BTC perpetual position. The short leg distributes across the top altcoins by market capitalization, with each altcoin's short size proportional to its share of the non-BTC market. A larger altcoin receives a proportionally larger short position; a smaller altcoin receives a smaller one. This market-cap weighting means the short basket naturally reflects the composition of the altcoin market rather than making equal bets against each constituent.

The result is a portfolio that is approximately market-neutral in aggregate. If the entire crypto market moves up or down uniformly, the long and short legs offset. The strategy extracts returns only from the differential: BTC outperforming altcoins (profit) or altcoins outperforming BTC (loss).

## Rebalancing

The portfolio is rebalanced monthly. At each rebalance, market capitalizations are recalculated and short-leg weights are updated to reflect the current composition of the altcoin market. Assets that have grown in market share receive larger short allocations; assets that have shrunk receive smaller ones.

Constituent selection uses the same tiered retention system as the Funding Rate Carry strategy. Top-ranked altcoins by market cap are included or retained. Middle-ranked altcoins are kept if already in the portfolio but not added as new positions. Altcoins that fall below the retention threshold are replaced. This prevents excessive turnover from minor shifts in market cap rankings between rebalance dates.

## Risk Controls

This strategy operates under the same shared risk framework described in [risk-framework.md](risk-framework.md). Specific constraints:

- **Drawdown limits.** The strategy has predefined drawdown thresholds that trigger automatic position reduction and, at more severe levels, full wind-down. BTC Dominance carries higher drawdown risk than Funding Rate Carry by construction, and the risk framework accounts for this with strategy-specific thresholds.
- **Correlation monitoring.** The hedged structure assumes that BTC and altcoins do not move in perfect lockstep. During market stress, correlations across crypto assets can spike toward 1.0, temporarily degrading the hedge. The risk system monitors realized correlation and can reduce position sizes when diversification benefits deteriorate.
- **Position size caps.** Individual short positions are bounded to prevent excessive concentration in any single altcoin. The BTC long position is bounded relative to total vault NAV.

## Variants

**Balanced** -- The BTC long position is sized proportionally to Bitcoin's current dominance ratio. If BTC dominance is 55%, the long leg represents 55% of strategy capital. This produces a more conservative risk profile: lower returns, lower drawdowns. The position naturally scales down when BTC dominance is low (and the thesis is under pressure) and scales up when dominance is high (and the thesis is performing).

**Max** -- The BTC long position is sized at 100% of strategy capital regardless of the current dominance ratio. This is a more aggressive expression of the same thesis. Returns are amplified in both directions. The Max variant outperforms Balanced significantly during periods of rising dominance but experiences proportionally larger drawdowns during altcoin rallies.

The choice between variants reflects risk appetite. Balanced is appropriate for capital that prioritizes drawdown control. Max is appropriate for capital that accepts higher interim volatility in exchange for higher expected returns over a full market cycle.

---

This document describes the methodology. It does not constitute a guarantee of future performance.
