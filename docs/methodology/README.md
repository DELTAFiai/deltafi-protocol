# Strategy Methodology

Documentation of DELTAFi's strategy logic, position construction, and risk management architecture. These documents describe the systematic processes used to generate and manage positions. Exact parameters are omitted.

---

1. **[Funding Rate Carry](funding-rate-carry.md)** -- Market-neutral delta-zero strategy that collects perpetual funding payments through paired spot and perpetual positions, with systematic asset selection filtering for yield and stability.

2. **[BTC Dominance Long/Short](btc-dominance.md)** -- Systematic long BTC / short altcoin strategy weighted by market capitalization, profiting from Bitcoin's outperformance relative to the broader crypto market.

3. **[Risk Framework](risk-framework.md)** -- Position-level, portfolio-level, and system-level risk controls that operate independently of strategy logic, including drawdown circuit breakers, correlation monitoring, and on-chain position verifiability.
