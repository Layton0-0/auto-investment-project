# AI 전략 자동 생성·백테스트·저장 파이프라인

**목적**: "AI가 전략을 자동으로 발견하는 구조" — 전략 후보 생성 → 자동 백테스트 → 수익률·리스크 기준 통과 시에만 저장하여 퀀트 연구 자동화를 달성한다.  
(설계 문서. 구현은 Backend 배치·API 또는 별도 Python 스크립트로 진행할 수 있다.)

---

## 1. 파이프라인 개요

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Strategy        │     │  Backtest         │     │  Criteria        │
│  Generator       │ ──► │  Engine           │ ──► │  Filter          │
│  (후보 생성)      │     │  (역사 시뮬)       │     │  (CAGR/Sharpe/MDD)│
└──────────────────┘     └──────────────────┘     └──────────────────┘
        │                          │                         │
        │                          │                         │
        ▼                          ▼                         ▼
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────┐
│  Parameter       │     │  OHLCV Data      │     │  Strategy         │
│  Space / Pool    │     │  (PIT, 수정주가)  │     │  Store            │
│  (TOP 10 등)     │     │  TB_DAILY_STOCK  │     │  (통과 전략만)     │
└──────────────────┘     └──────────────────┘     └──────────────────┘
```

---

## 2. 단계별 명세

### 2.1 Strategy Generator (전략 후보 생성)

- **입력**: 전략 풀(예: [한국 단타 TOP 10](../../investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md)), 파라미터 공간(k, lookback, threshold 등).
- **출력**: (strategy_id, params) 리스트. 옵션: 그리드 서치·랜덤 샘플·LLM/GA 기반 제안.

### 2.2 Backtest Engine (기존 활용)

- **입력**: (strategy, OHLCV, 기간, 초기자본, 수수료/슬리피지).
- **출력**: BacktestRunResult (CAGR, Sharpe, MDD, win rate, profit factor, trades).
- **구현**: Backend `BacktestService`, `POST /api/v1/backtest`. PIT·수정주가·비용 반영 ([00-strategy-registry.md](../../investment-backend/docs/02-architecture/00-strategy-registry.md) §1.1).

### 2.3 Criteria Filter (통과 기준)

- **입력**: BacktestRunResult.
- **조건 예**: CAGR ≥ cagr_min, Sharpe ≥ sharpe_min, MDD ≥ mdd_min(낙폭 한도 이내), win_rate ≥ win_rate_min.
- **출력**: 통과 여부 + 메트릭 요약.

### 2.4 Strategy Store (통과 전략만 저장)

- **입력**: (strategy_id, params, BacktestRunResult, run_id, as_of_date).
- **저장**: DB 테이블(예: strategy_candidates, ai_discovered_strategies) 또는 로컬 파일(JSON/Parquet). append-only, 버전·중복 방지.

---

## 3. 데이터 흐름 (전체)

1. **Generator**가 전략 후보 리스트 생성 (한국 단타 TOP 10 기반 + 파라미터 그리드).
2. **Runner**가 각 후보에 대해:
   - Backend TB_DAILY_STOCK·TB_SIGNAL_SCORE 기반으로 백테스트 실행 (`POST /api/v1/backtest` 또는 내부 BacktestService 호출).
   - CriteriaFilter.passes(result) → True면 Store.save(...).
3. **로그**: 후보 수, 통과 수, 실패 사유(메트릭 미달), 소요 시간.
4. **산출물**: 통과 전략 목록 — Backend 전략 거버넌스·설정 반영에 사용.

---

## 4. 설정 예시

```yaml
# discovery (예: application.yml 또는 별도 설정)
discovery:
  cagr_min: 0.20        # 20% 이상
  sharpe_min: 1.0
  mdd_min: -0.15        # MDD -15% 이내
  win_rate_min: 0.50
  profit_factor_min: 1.2
  output_path: "output/discovered_strategies"
  # 또는 db_url으로 DB 저장
```

---

## 5. 실행 방식

- **수동 1회**: Backend 배치 Job 또는 스크립트로 Runner 실행 (기간·시장 지정).
- **API**: Backend `POST /api/v1/trigger/strategy-discovery` (옵션) → 비동기 Job으로 Runner 실행.
- **배치**: cron 또는 Backend 배치에서 주기적으로 Runner 호출 (예: 주 1회).

---

## 6. 확장

- **LLM/GA**: Generator를 LLM 프롬프트 또는 유전 알고리즘으로 파라미터 제안으로 교체.
- **Walk-Forward**: 기간을 train/test로 나누고, test 구간만 메트릭으로 통과 판단. Backend `POST /api/v1/backtest/walk-forward` 활용.
- **거버넌스 연동**: 저장된 전략을 Backend의 전략 거버넌스(정기 백테스트·halt)와 연동.

이 파이프라인을 구현하면 **퀀트 연구 자동화**가 되며, 소형 헤지펀드 수준의 전략 발견 루프로 확장할 수 있다.
