# 저장소 상태 및 다음 작업 정리

**갱신일**: 2026-03-13  
**기준 문서**: [02-development-status.md](investment-backend/docs/09-planning/02-development-status.md), [00-strategy-registry.md](investment-backend/docs/02-architecture/00-strategy-registry.md)

**변경 (2026-03-13)**: `quant-trading-system` 서브트리 제거. 중복이 아닌 문서·AI 개발 전략은 메인 프로젝트 docs로 이전함.  
→ [docs/ai-quant-development/](../ai-quant-development/00-index.md) (Agent 워크플로우, AI 전략 발견 파이프라인, 반자동 개발), [18-kr-short-term-strategies-top10.md](../investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md) (한국 단타 전략 TOP 10).

---

## 1. 현재 Repo 상태 요약

### 1.1 investment-backend (Spring Boot)

| 구분 | 상태 |
|------|------|
| **4단계 파이프라인** | 완료. KR/US, 단기·중기·장기, 유니버스→시그널→자금관리→실행·청산. |
| **한국 시그널 개선** | 완료. Ops readiness 시장별 건수, `use-5d-avg-liquidity-kr`, `kr-symbols-override`. |
| **로보 어드바이저** | 완료. 동적 자산배분·듀얼 모멘텀(노트)·실행 전 백테스트·리밸런싱. |
| **전략 거버넌스** | 완료. 정기 검사·halt·Admin API·Pipeline 스킵 연동. |
| **백테스트** | 완료. Walk-Forward, 수수료·슬리피지, BacktestRunResult. 스트레스 결과 표는 **데이터 수집 후 기입** 대기. |
| **리스크·게이트** | 완료. 리스크 게이트, 일일 손실 한도, 시장 급락 게이트, Pre-Trade 컴플라이언스, Kill Switch. |
| **KIS API·WebSocket** | 완료. 주문·잔고·현재가·실시간 호가/체결, 재연결·하트비트. |
| **뉴스·공시** | 완료. DART/SEC 시그널, Speed/Buzz 수집기, 감정 점수·페이징. |
| **온보딩·퀵스타트** | 완료. 퀴즈→프로필·원클릭 자동투자 시작, E2E. |
| **진행중** | 별도 “진행중” 섹션 없음. 진행예정만 존재. |

### 1.2 기타 서비스

| 시스템 | 역할 | 비고 |
|--------|------|------|
| **investment-data-collector** | 뉴스·공시·KRX/US 수집. Backend가 호출. | Docker Compose 포함 (8001). |
| **investment-prediction-service** | AI 예측(LSTM 등). Backend가 호출. | Docker Compose 포함 (8000). |

**운영 백엔드는 Backend 단일.** 백테스트·주문·파이프라인·시그널은 모두 Backend에서 수행. `run-backtest.ps1`은 Backend `POST /api/v1/backtest` 호출.

### 1.3 프론트·인프라

- **프론트**: React, 대시보드·자동투자 현황·설정·Ops·리스크·백테스트 등 연동 완료. 후속: 실시간 차트·앱 내 알림·반응형·모바일(선택).
- **인프라**: Docker Compose 로컬/배포, CI/CD 문서화. 도메인 E2E 검증·성능 최적화(2차)는 진행예정.

---

## 2. 다음 작업 (우선순위)

### 2.1 즉시 가능 (데이터/문서)

| # | 작업 | 담당 | 참조 |
|---|------|------|------|
| 1 | **백테스트 스트레스 결과 기입** | Backend/QA | 스트레스 구간(2020-02~04, 2022-01~06) KR/US 데이터 백필 후 `POST /api/v1/backtest` 실행 → [backtest-stress-results.md](investment-backend/docs/02-architecture/backtest-stress-results.md) §3.1·§3.2 표 기입. |
| 2 | **메뉴별 백엔드 순차 점검** | Backend | [11-api-frontend-mapping.md](investment-backend/docs/04-api/11-api-frontend-mapping.md) §4·§5.2 기준으로 미구현·미연동 항목 있으면 1건씩 구현·문서 갱신. |
| 3 | **Ops 자동매매 준비 상태 위젯** | Frontend | GET /api/v1/ops/auto-trading-readiness 기반 KR/US 일봉·시그널 4지표 카드. 명세: [plans/frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md](../plans/frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md). |

### 2.2 선택·후속

| # | 작업 | 비고 |
|---|------|------|
| 3 | 연말 손실 한도 정책 보강 | VaR/CVaR·역사적 VaR 등, 필요 시. |
| 4 | 연말 세금·리포트 고도화 | Hometax·배당·2.5M 공제 등. |
| 5 | 대시보드 실시간 차트·앱 알림·모바일 | 프론트 후속. |
| 6 | 도메인 E2E 검증 | 12-domain-e2e-readiness.md 체크리스트. |
| 7 | KIS 실서버 연동 검증·미국 기간별 시세 | 실행·게이트웨이 후속. |

---

## 3. 개발 순서 권장

- **운영은 Backend 단일** — 백테스트·주문·파이프라인은 Backend만 사용. `run-backtest.ps1`·프론트·배치는 Backend API만 호출.
- **퀀트·AI 전략 개발** 시 Agent 순서: [docs/ai-quant-development/01-agent-workflow-quant.md](../ai-quant-development/01-agent-workflow-quant.md) (strategist → architect → dev → backtest → auto).
- 전략·백테스트 계약은 `00-strategy-registry.md`·`backtest-stress-results.md`를 단일 소스로 참조.

---

## 4. 전략 레지스트리·아키텍처 대비 갭 (상위 5건)

| # | 갭 | 파일/모듈 | 비고 |
|---|-----|-----------|------|
| 1 | **ReconciliationService** | 미구현 | §2.9.1: 브로커-DB 정합성(TB_STRATEGY_POSITION vs 실잔고), Batch `reconcile`(08:00·16:10), 불일치 시 Discord, GET `/api/v1/ops/reconcile`(ADMIN). application.yml 주석만 존재. |
| 2 | **RegimeDetectionService** | 미확인 | v2.0: SPY 50/200일선+VIX 규칙 BULL/BEAR/NEUTRAL, Redis 캐시. MacroDashboardService에 레짐 판정 있을 수 있으나 별도 서비스명·캐시 역할 문서화 부족. |
| 3 | **FactorDecayMonitorService** | 미구현 | v2.0: 팩터별 Sharpe 열화 시 Discord 알림. |
| 4 | **파이프라인/백테스트 correlation id** | PipelineExecutionScheduler, PipelineExecutor, BacktestService | 실행 단위 추적용 pipelineRunId/backtestRunId 미부여. 구조화 로그·추적 보강 필요. |
| 5 | **InverseVolatilityPortfolioService** | 미확인 | v2.0: 역변동성 포트폴리오 서비스(StubPortfolioComponents 대체 옵션). Stub은 존재하나 전용 서비스 미확인. |

---

## 5. 아키텍처 개선 제안 (경계·순환만, 대규모 개편 없음)

- **PipelineExecutor ↔ OrderService**: 주문 실행은 이미 OrderService에 위임되어 있어 경계는 명확함. PipelineExecutor가 `executeOrderForPipeline`만 호출하므로, 주문 정책(재시도·컴플라이언스)은 OrderService 쪽에 두고 PipelineExecutor는 “권장 목록 → 주문 요청”만 담당하도록 유지하면 됨.
- **BacktestService ↔ PositionSizingService**: BacktestService가 일자별로 `getRecommendations(date, ...)`를 호출하는 구조는 적절함. **성능 제안**: BacktestService 내부에서 `getClose`/`getHigh`/`getLow`가 일자·종목마다 개별 호출되어 N+1에 가깝게 동작하므로, 일자별 해당 date의 모든 종목 일봉을 한 번에 조회하는 배치 쿼리(예: `DailyStockRepository.findByMarketAndBasDt`)로 바꾸면 호출 수를 크게 줄일 수 있음.
- **Governance·Risk 게이트**: PipelineExecutionScheduler가 RiskGateService, DailyLossLimitService, MarketCrashGateService, GovernanceHaltService를 순차 호출하는 구조는 단방향 의존이라 순환 없음. 각 게이트를 독립 서비스로 유지하면 테스트·스텁 대체가 쉬움.

---

## 6. 참조 문서

| 문서 | 용도 |
|------|------|
| [02-development-status.md](investment-backend/docs/09-planning/02-development-status.md) | 완료/진행예정 상세, 갱신 원칙 |
| [00-strategy-registry.md](investment-backend/docs/02-architecture/00-strategy-registry.md) | 전략·수식·버전 스택 |
| [backtest-stress-results.md](investment-backend/docs/02-architecture/backtest-stress-results.md) | 스트레스 시나리오·결과 표 |
| [18-kr-short-term-strategies-top10.md](investment-backend/docs/02-architecture/18-kr-short-term-strategies-top10.md) | 한국 단타 전략 TOP 10 |
| [docs/ai-quant-development/00-index.md](../ai-quant-development/00-index.md) | AI·퀀트 개발 가이드 (Agent 워크플로우, AI 전략 발견 파이프라인, 반자동 개발) |
