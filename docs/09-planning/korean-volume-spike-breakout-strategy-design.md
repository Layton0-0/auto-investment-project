# Korean Short-Term "Volume Spike + Breakout" Strategy — Design (Boundaries & Contracts)

**역할**: Quant-architect. Martin Fowler clarity, boundaries and contracts only.  
**전략**: 한국 단기 "거래량 스파이크 + 돌파" — 유니버스는 거래량 비율·가격 돌파로 필터, 기존 포지션 사이징·청산 규칙 적용.  
**날짜**: 2026-03-13.

---

## 1. Strategy Summary

- **Filter**: Symbols by **volume ratio** (e.g. current volume / N-day average ≥ threshold) and **price breakout** (existing volatility breakout: Target = Open + Range×k).
- **Downstream**: Existing position sizing (Half-Kelly, ATR, risk-based cap) and exit rules (KR: -5% stop, prior-low stop, RSI≥70, -3% trailing; Time-Cut).
- **Scope**: KR market, SHORT_TERM. Fits into the existing 4-stage pipeline without replacing it.

---

## 2. Pipeline Placement (4-Stage)

| Stage | Component | Change |
|-------|-----------|--------|
| **1. Universe** | `UniverseFilterService` | **New**: Volume-spike filter for KR (config-driven). |
| **2. Signal** | `FactorCalculationService` | No new factor. Use existing `VOLATILITY_BREAKOUT`. |
| **2. Signal** | `PositionSizingService.filterSymbolsByStrategyType` / `filterSymbolsKrShortTerm` | **New**: When “volume spike + breakout” variant is on, restrict to symbols that have `VOLATILITY_BREAKOUT` signal (in addition to existing Case A/B). |
| **3. Sizing** | `PositionSizingService.getRecommendations` | No change. |
| **4. Execution / Exit** | `ExitRuleEvaluator`, `PipelineExecutor` | No change. |

**Contract**: Universe supplies only symbols that pass liquidity + (optional) volume spike. Signal stage supplies breakout via existing factor; sizing and execution use existing logic.

---

## 3. Stage 1 — Universe: New Logic

- **Where**: `UniverseFilterService.run(basDt, market)`.
- **New step**: For `market == "KR"`, after liquidity (and optional Sector RS / volume-rank), apply **volume-spike filter** when enabled.
  - **Input**: List of symbols (or `DailyStock` rows) that passed prior universe steps.
  - **Logic**: For each symbol, PIT: `volume(basDt)` and `avg volume(basDt - lookbackDays .. basDt - 1)`. Ratio = `volume(basDt) / avg_volume`. Keep symbols where `ratio >= minVolumeRatio`.
  - **Data**: `DailyStockRepository.findByMarketAndBasDtBetween(market, fromDt, basDt)`; volume from `DailyStock` (column/field as in schema). Average over past N days excluding basDt (PIT).
- **Ownership**: `UniverseFilterService` only. No new service; one new private method (e.g. `filterByVolumeSpike`) and one new config block.

---

## 4. Stage 2 — Signal: Changed / New Logic

- **FactorCalculationService**: No change. `VOLATILITY_BREAKOUT` already computed and stored in `TB_SIGNAL_SCORE`.
- **PositionSizingService**: When “volume spike + breakout” variant is active for KR SHORT_TERM:
  - After existing Case A (momentum) ∪ Case B (contrarian) in `filterSymbolsKrShortTerm`, **intersect** with symbols that have at least one `TB_SIGNAL_SCORE` row for `basDt` with `factorType == VOLATILITY_BREAKOUT` (and optionally score indicating “breakout hit” if stored).
  - Contract: Same inputs (`List<SignalScore> signals`, `basDt`, `market`); output is a subset of current KR short-term set, restricted to breakout symbols.

No new factor type; reuse existing `FactorCalculationService.FACTOR_VOLATILITY_BREAKOUT` and `SignalScoreRepository` queries.

---

## 5. New Config Keys and Types

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `investment.factor.volume-spike-enabled` | `boolean` | `false` | If true, KR universe applies volume-spike filter. |
| `investment.factor.volume-spike-min-ratio` | `double` | `1.5` | Min ratio: current volume / N-day average volume. |
| `investment.factor.volume-spike-lookback-days` | `int` | `20` | N for average volume (PIT: past N trading days up to basDt - 1). |
| `investment.factor.kr-short-term-breakout-required` | `boolean` | `false` | If true, KR SHORT_TERM signal filter requires VOLATILITY_BREAKOUT (volume-spike + breakout variant). |

All under existing `investment.factor` prefix. Bind via `@Value` or a small `VolumeSpikeFilterProperties` (optional).

---

## 6. API Contract (Backtest)

- **No new endpoint.** Use existing `POST /api/v1/backtest` with `market=KR`, `strategyType=SHORT_TERM`. When server config has `volume-spike-enabled=true` and `kr-short-term-breakout-required=true`, the run implicitly uses the “volume spike + breakout” strategy.
- **Optional extension (for A/B testing without restart):** Add to `BacktestRunRequest`:
  - `volumeSpikeFilterEnabled` (Boolean, optional): override for this run only; if present, overrides `investment.factor.volume-spike-enabled` for the backtest universe resolution.
  - `breakoutRequired` (Boolean, optional): override for this run only; if present, overrides `investment.factor.kr-short-term-breakout-required` for the signal filter in that run.
- **Response**: Unchanged. `BacktestRunResult` as today: `cagr`, `sharpeRatio`, `mddPct`, `winRate`, `profitFactor`, `tradeCount`, `equityCurve`, `trades`, etc. No new fields required.

---

## 7. Alignment with BacktestRunResult

- **cagr, sharpeRatio, mddPct, winRate, profitFactor, tradesCount**: No change. Backtest still uses `PositionSizingService.getRecommendations` and `ExitRuleEvaluator`; only the **set of symbols** (universe + signal filter) changes. Metrics are computed the same way from equity curve and trades.
- **Governance / reporting**: Existing `BacktestRunResult` and any governance checks (e.g. MDD/Sharpe thresholds) remain valid; strategy is still `SHORT_TERM`, market `KR`.

---

## 8. Data and PIT

- **Volume ratio**: Uses only `basDt` and earlier; average volume uses `basDt - 1` back for `lookbackDays` (trading days). No look-ahead.
- **Breakout**: Already PIT in `FactorCalculationService` (당일 고가/시가/전일 범위만 사용).

---

## 9. Document and Registry Update

- On implementation: add a short subsection to `docs/02-architecture/00-strategy-registry.md` under §3.1 (Universe) and §3.2 (Signal) for “Korean short-term volume spike + breakout”, and add the new config keys to §6 (수식·파라미터 일람). Bump strategy registry version and add a version-stack row.

---

**Summary**

- **Stage 1**: `UniverseFilterService` — new volume-spike filter (config: `volume-spike-enabled`, `volume-spike-min-ratio`, `volume-spike-lookback-days`).
- **Stage 2**: `PositionSizingService` — when `kr-short-term-breakout-required=true`, restrict KR SHORT_TERM to symbols with `VOLATILITY_BREAKOUT`; no new factor.
- **Stage 3–4**: Reuse existing sizing and exit rules.
- **API**: Existing `POST /api/v1/backtest`; optional request overrides for backtest-only A/B.
- **BacktestRunResult**: Unchanged; full alignment with cagr, sharpeRatio, mddPct, winRate, profitFactor, tradesCount.
