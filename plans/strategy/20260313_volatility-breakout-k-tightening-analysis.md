# 변동성 돌파 k 파라미터 축소 영향 분석 (Strategy Analyst)

**일자**: 2026-03-13  
**역할**: Strategy Analyst (원칙 기반, 체계적, 문서화)  
**결정 검토**: 한국 단기 파이프라인 변동성 돌파 k 범위 [0.3, 0.7] → [0.35, 0.65] 축소

---

## 1. k 사용처 (백엔드)

### 1.1 수식

- **목표가**: `Target = Open + (Range × k)`, Range = 전일 고가 − 전일 저가  
- **동적 k (한국 KR)**: `k_dynamic = k_base × (평균변동폭 / 최근변동폭)`, 결과를 **[kMin, kMax]** 로 클램핑  
  - 평균변동폭: 최근 20일 시가 대비 고가−저가 변동폭의 평균  
  - 최근변동폭: 최근 5일 동일 변동폭 평균  

### 1.2 FactorCalculationService

| 항목 | 내용 |
|------|------|
| **설정 주입** | `@Value("${investment.factor.volatility-breakout-k-min:0.3}")` → `volatilityBreakoutKMin` |
| | `@Value("${investment.factor.volatility-breakout-k-max:0.7}")` → `volatilityBreakoutKMax` |
| **사용 위치** | `addVolatilityBreakout()`: KR이고 `volatility-breakout-k-dynamic=true` 이면 `calculateDynamicK()` 호출 |
| **클램핑** | `calculateDynamicK()` 내부: `adjustedK < kMin` → kMin, `adjustedK > kMax` → kMax 적용 (302~305행) |
| **저장** | TB_SIGNAL_SCORE에 `factorType=VOLATILITY_BREAKOUT`, `score=target`(목표가), `metadata`에 k 값 저장 |

동적 k 미사용 시(US 또는 k-dynamic=false)에는 `volatility-breakout-k`(기본 0.5)만 사용하며, k-min/k-max는 미적용.

### 1.3 Config 키 (application.yml)

| 키 | 기본값 | 비고 |
|----|--------|------|
| `investment.factor.volatility-breakout-k` | 0.5 | 고정 k (동적 비활성 시) |
| `investment.factor.volatility-breakout-k-dynamic` | true | 한국장 k 동적 조정 여부 |
| `investment.factor.volatility-breakout-k-min` | **0.3** | 동적 조정 하한 (변경 대상) |
| `investment.factor.volatility-breakout-k-max` | **0.7** | 동적 조정 상한 (변경 대상) |

환경 변수 오버라이드: `FACTOR_VOLATILITY_BREAKOUT_K_MIN`, `FACTOR_VOLATILITY_BREAKOUT_K_MAX`

### 1.4 연동 흐름

- **팩터 계산**: `FactorCalculationScheduler` / Batch → `FactorCalculationService.calculateAndSave(basDt, market)` → `addVolatilityBreakout()` → TB_SIGNAL_SCORE 적재  
- **장중 돌파**: `IntradayBreakoutService.getBreakoutCandidates()` → `FactorCalculationService.getVolatilityBreakoutK(symbol, market, today)` → 동일 k-min/k-max 클램핑된 k 사용  
- **백테스트**: `BacktestService.run()` → `PositionSizingService.getRecommendations(date)` → **TB_SIGNAL_SCORE 기반** 권장 생성. 즉 k 변경 효과를 보려면 **동일 기간에 대해 팩터 재계산 후** 백테스트 필요.

---

## 2. 변경 영향 (k [0.3, 0.7] → [0.35, 0.65])

- **의미**: 동적 k가 더 좁은 구간으로 제한됨.  
  - k가 낮을수록 목표가가 시가에 가깝게 설정되어 진입이 더 일찍·많이 발생할 수 있고, k가 높을수록 목표가가 멀어져 진입이 더 적고 보수적임.  
- **축소 효과**:  
  - 0.3 미만으로 내려가던 구간 → 0.35로 올라감 → 목표가 상향, **진입 빈도 감소·가짜 돌파 필터 강화** 가능.  
  - 0.7 이상으로 올라가던 구간 → 0.65로 내려감 → 목표가 하향, **진입 빈도 증가** 가능.  
- **정량적 영향**: 진입 횟수·승률·MDD·CAGR·Sharpe·Profit factor는 데이터와 기간에 따라 달라지므로 **동일 기간·동일 데이터로 백테스트 전후 비교**로만 판단 가능.

---

## 3. 백테스트 검증 항목 (Before / After)

변경 채택 전에 아래를 **동일 기간·동일 시드/설정**으로 두 번 실행해 비교한다.

| 항목 | 설명 | 목표(참고) |
|------|------|------------|
| **거래 수 (trade count)** | 매수→청산 완료 건수 | 축소 시 감소 가능; 과도한 감소 시 기회 상실 검토 |
| **시그널 수** | VOLATILITY_BREAKOUT 시그널 건수 (또는 getRecommendations 호출 시 권장 건수) | 진입 기회 지표 |
| **승률 (win rate)** | 승리 거래 수 / 전체 거래 수 | 00-strategy-registry §2.2 Half-Kelly: 60% 이상 권장 |
| **MDD (max drawdown)** | 최대 낙폭 % | -15% 이내 통제 (공통 목표) |
| **CAGR** | 연평균 복합 수익률 | 목표 30% 이상 (공통) |
| **Sharpe ratio** | (일수익 평균/표준편차)×√252 | Walk-Forward 목표 예: ≥1.0 |
| **Profit factor** | 총 이익 / \|총 손실\| | 백테스트 보고 필수 5종 |

**Before**: k-min=0.3, k-max=0.7 유지 → 해당 기간 팩터 계산 이미 되어 있으면 그대로 백테스트 1회 실행.  
**After**: k-min=0.35, k-max=0.65 적용 → **동일 기간에 대해 팩터 재계산** 실행 후 백테스트 1회 실행.

비교 시 동일 수수료·슬리피지·초기자본·시장(KR)·전략 타입(SHORT_TERM) 사용.

---

## 4. 백테스트 실행 방법 (직접 실행, 에이전트 미실행)

- **API**: `POST /api/v1/backtest`  
  - Body: `{ "startDate": "yyyy-MM-dd", "endDate": "yyyy-MM-dd", "market": "KR", "strategyType": "SHORT_TERM", "initialCapital": 100000000 }`  
- **스크립트**: `.\scripts\run-backtest.ps1`  
  - 예: `.\scripts\run-backtest.ps1 -StartDate "2024-01-01" -EndDate "2024-12-31" -Market "KR" -StrategyType "SHORT_TERM" -InitialCapital 100000000 -BaseUrl "http://localhost:8080"`  
- **두 파라미터 세트 비교 절차**  
  1. **현행 (0.3, 0.7)**  
     - Backend 기동 시 기본값 또는 `FACTOR_VOLATILITY_BREAKOUT_K_MIN=0.3`, `FACTOR_VOLATILITY_BREAKOUT_K_MAX=0.7`  
     - 검증 기간에 대해 팩터 계산이 이미 반영되어 있으면 생략, 아니면 해당 기간 KR 팩터 계산 실행  
     - `POST /api/v1/backtest` 1회 호출 (또는 run-backtest.ps1) → 결과 저장 (tradeCount, winRate, mddPct, cagr, sharpeRatio, profitFactor)  
  2. **변경안 (0.35, 0.65)**  
     - Backend 재기동 또는 설정 변경: `FACTOR_VOLATILITY_BREAKOUT_K_MIN=0.35`, `FACTOR_VOLATILITY_BREAKOUT_K_MAX=0.65`  
     - **동일 기간**에 대해 KR 팩터 계산 재실행 (Batch 또는 FactorCalculationService 호출) → TB_SIGNAL_SCORE 갱신  
     - `POST /api/v1/backtest` 동일 Body로 1회 호출 (또는 run-backtest.ps1) → 결과 저장  
  3. 위 메트릭 Before/After 비교 후, MDD·승률·CAGR·Sharpe·거래 수가 정책 목표와 리스크 선호에 부합하는지로 채택 여부 결정.

백테스트는 에이전트가 직접 실행하지 않으며, 운영자가 위 절차로 실행한다.

---

## 5. 전략 레지스트리 버전 스택 초안 (채택 시)

채택 시 [00-strategy-registry.md](../investment-backend/docs/02-architecture/00-strategy-registry.md) §7 버전 스택에 추가할 한 줄 초안:

| 버전 | 일자 | 적용 시장(나라) | 적용 분야/기간 | 변경 요약 | 결과 | 교훈·비고 |
|------|------|-----------------|----------------|-----------|------|-----------|
| v2.2 | 2026-03-13 | KR | 단기·변동성 돌파 | volatility-breakout k 동적 범위 [0.3, 0.7] → [0.35, 0.65] (k-min/k-max) | (백테스트 후 기입) | 가짜 돌파 완화·진입 품질 개선 목적; 18-kr-short-term-strategies-top10 §1 반영 |

결과란은 백테스트 실행 후 메트릭(거래 수, 승률, MDD, CAGR, Sharpe, profit factor) 요약으로 기입하고, 교훈·비고는 필요 시 보완한다.

---

## 6. 참조 문서

- [00-strategy-registry.md](../investment-backend/docs/02-architecture/00-strategy-registry.md) §2.3 변동성 돌파, §2.8 백테스트 메트릭, §6 계산 수식·파라미터 일람, §7 버전 스택  
- [18-kr-short-term-strategies-top10.md](../investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md) §1 변동성 돌파 (k ∈ [0.3, 0.7])  
- [backtest-stress-results.md](../investment-backend/docs/02-architecture/backtest-stress-results.md) 스트레스 구간·실행 방법  
- [.cursor/rules/backtest-quant-research-standards.mdc](../.cursor/rules/backtest-quant-research-standards.mdc) 필수 5종 메트릭·재현 가능 연구
