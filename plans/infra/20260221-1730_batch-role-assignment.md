# 배치 Job 논리적 역할 분배 원칙

**작성일**: 2026-02-21  
**목적**: Backend에 집중된 20개 이상 배치 Job의 실행 주체를 명확히 하고, 데이터 수집·계산·오케스트레이션·실행 레이어별 분배 원칙을 정립한다.

---

## 1. 네 가지 논리적 레이어 정의

| 레이어 | 담당 컴포넌트 | 역할 |
|--------|----------------|------|
| **데이터 수집** | investment-data-collector (Python) | 원시 데이터 수집·정규화·외부 API 호출. US 일봉, DART/SEC 공시, 뉴스(RSS 등). |
| **계산/ML** | investment-backend (Java) / investment-prediction-service (Python) | 팩터·시그널 계산(DB/트랜잭션 결합) → Backend. 대량 ML 추론·학습 → prediction-service. |
| **오케스트레이션** | investment-backend (Java) | 스케줄 정의(cron), 트리거, 실행 순서·재시도·감사. **단일 스케줄러**로 통일. |
| **실행** | investment-backend (Java) | 주문·체결 확인·리스크 검사·PnL 기록. 계좌/DB/거래소 API 결합. |

- **결론**: “배치를 파이썬에서 나눠서 해야 하는가?” → **스케줄(오케스트레이션)은 Backend에 두고**, **실제 “수집” 작업만 선택적으로 Python data-collector로 이전**하는 것이 원칙에 부합한다. 팩터 계산·주문·리스크는 DB/트랜잭션/도메인과 밀접하므로 Backend 유지.

---

## 2. Job별 실행 주체 매트릭스 (현재)

| Job ID | 이름 | Cron (예) | 실행 주체 |
|--------|------|-----------|-----------|
| trading-portfolio-generator | 트레이딩 포트폴리오 생성 | 0 0 9 * * * | Backend 내부 |
| short-term-strategy-executor | 단기 전략 실행 | 0 0 * * * * | Backend 내부 |
| medium-term-strategy-executor | 중기 전략 실행 | 0 0 9 * * * | Backend 내부 |
| long-term-strategy-executor | 장기 전략 실행 | 0 0 9 * * MON | Backend 내부 |
| krx-daily-collector | KRX 일별 시세 수집 | 0 0 16 * * * | Backend 내부 (KrxCollectionService) |
| us-daily-collector | US 시장 일별 시세 수집 | 0 0 17 * * * | Backend → data-collector HTTP (UsMarketCollectionService) |
| krx-daily-backfill | KRX 일별 시세 백필 | (수동) | Backend 내부 (KrxCollectionService) |
| us-daily-backfill | US 일별 시세 백필 | (수동) | Backend → data-collector HTTP |
| factor-calculation | 팩터 계산 | 0 0 8 * * * | Backend 내부 (FactorCalculationService) |
| auto-buy | 자동매수(통합) | 0 10 9 * * * | Backend 내부 |
| pipeline-execution | 파이프라인 실행 | (수동) | Backend 내부 |
| pipeline-exit | 파이프라인 청산 평가 | 0 */5 9-15 * * MON-FRI | Backend 내부 |
| fill-confirmation | 체결 확인 후 포지션 등록 | 0 * * * * * | Backend 내부 |
| unfilled-order-check | 미체결 확인 | 0 * * * * * | Backend 내부 |
| risk-event-alert | 리스크 이벤트 알림 | 0 */10 9-15 * * MON-FRI | Backend 내부 |
| medium-term-rebalance | 중기 리밸런스 | 0 30 8 1 * * | Backend 내부 |
| daily-pnl | 일일 PnL 기록 | 0 5 16 * * MON-FRI | Backend 내부 |
| intraday-breakout | 장중 변동성 돌파 | 0 10,40 9 * * MON-FRI | Backend 내부 |
| robo-rebalance | 로보 리밸런싱 | (수동) | Backend 내부 |
| strategy-governance-check | 전략 거버넌스 검사 | 0 0 2 1 * * | Backend 내부 |

---

## 3. 스케줄 전략

- **권장: 단일 스케줄러(Backend)**  
  - 모든 cron은 `BatchJobScheduler`(Backend)에서만 관리.  
  - Backend가 필요 시 data-collector / prediction-service를 **HTTP로 호출**하는 구조 유지.  
  - 장점: 실행 순서·재시도·감사·Rollback이 한 곳에서 제어 가능.

- **data-collector의 APScheduler**  
  - **DART/SEC/뉴스 수집**만 사용 (환경변수 `SCHEDULE_DART_SEC=1`, `SCHEDULE_SPEED_BUZZ=1`).  
  - KRX/US **일봉 수집**은 Backend cron이 트리거하고, Backend가 data-collector URL을 호출하는 패턴으로 통일하는 것을 권장 (US는 이미 해당 패턴).

---

## 4. 이전 후보 (Python으로 옮길 수 있는 작업)

| 후보 | 현재 | 이전 방향 | 우선순위 |
|------|------|-----------|----------|
| **us-daily-collector** | Backend → data-collector HTTP | 이미 data-collector에서 실행. Backend는 트리거·저장 오케스트레이션만 담당. | 완료 |
| **krx-daily-collector** | Backend 내부 (KrxCollectionService) | (선택) 수집 로직만 data-collector로 이전, Backend는 POST /krx-daily 호출·DB 저장만 담당 | Phase 2 |
| **krx-daily-backfill / us-daily-backfill** | Backend 내부 / Backend→data-collector | 위와 동일 패턴으로 data-collector 엔드포인트 추가 가능 | Phase 2 |

- **Backend 유지 권장**:  
  trading-portfolio-generator, *-strategy-executor, factor-calculation, auto-buy, pipeline-*, fill-confirmation, unfilled-order-check, risk-event-alert, medium-term-rebalance, daily-pnl, intraday-breakout, strategy-governance-check, robo-rebalance  
  → 모두 DB/거래/리스크/도메인과 강하게 결합되어 있어 Backend에 두는 것이 적합.

---

## 5. Rollback 정책

- **Backend 설정으로 복귀 가능**하도록 설계한다.  
  - 예: KRX 일봉을 data-collector로 이전한 경우, `investment.data.krx.collector-url` 미설정 또는 플래그 비활성화 시 기존 **KrxCollectionService**를 다시 호출하도록 분기.  
- US 일봉은 이미 `investment.data.us.collector-url` 미설정 시 로컬 스크립트 또는 스텁으로 동작하므로 동일한 Rollback 패턴 적용 가능.

---

## 6. 참고 문서

- [SYSTEM_READINESS_REPORT.md](../../SYSTEM_READINESS_REPORT.md) — 시스템 구성 현황  
- [shrimp-rules.md](../../shrimp-rules.md) §2 — 프로젝트 아키텍처 및 Backend/Python 연동  
- [10-data-collection-api.md](../../investment-backend/docs/04-api/10-data-collection-api.md) — 데이터 수집 API 및 스케줄  
- [BatchJobRegistry.java](../../investment-backend/src/main/java/com/investment/batch/registry/BatchJobRegistry.java) — Job 정의 소스
