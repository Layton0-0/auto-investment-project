# Ops 자동매매 준비 상태 위젯 — 기능 명세 (1페이지)

**작성일**: 2026-03-13  
**역할**: Planner (Outcomes over output, shippable scope)

---

## 1. 목표 (Goal)

**Outcome**: 운영자가 자동매매를 켜기 전에 **파이프라인 데이터 유무**를 Ops 화면에서 한눈에 확인할 수 있게 한다.

- 자동매매 가동 전 점검(09:10 등) 시, 전일(basDt) 일봉·시그널 건수가 충분한지 확인하는 단계를 **화면 한 곳**에서 수행 가능하게 함.
- 기존 `GET /api/v1/ops/auto-trading-readiness` API만 사용하며, **백엔드 신규 API는 없음**.

---

## 2. 요구사항 (Requirements)

| # | 요구사항 | 비고 |
|---|----------|------|
| R1 | Ops 페이지에 "자동매매 준비 상태" 대시보드 위젯(카드)을 노출한다. | 서브페이지(데이터/알림/설정 등)와 무관하게 Ops 진입 시 보이거나, 특정 탭 상단에 고정 |
| R2 | 위젯은 **4가지 지표**를 한 카드 안에 표시한다. | KR/US 일봉 건수, KR/US 시그널 건수 |
| R3 | 데이터 소스는 **기존 API** `GET /api/v1/ops/auto-trading-readiness` 단일 호출이다. | 프론트만 추가, 백엔드 변경 없음 |
| R4 | 기준일(basDt)을 표시하여 "어느 날짜 기준 데이터인지" 명확히 한다. | DTO의 `basDt` 사용 |
| R5 | 로딩·에러 상태를 처리한다. | 로딩 중/API 실패 시 사용자에게 명확한 표시 |
| R6 | ADMIN 전용 API이므로 Ops 페이지 접근 제어와 동일하게 둔다. | 이미 Ops는 권한 제어됨 |

**표시할 4가지 지표 (API 필드)**

- `dailyStockRowCountKr` — KR 일봉 건수 (TB_DAILY_STOCK)
- `dailyStockRowCountUs` — US 일봉 건수
- `signalScoreRowCountKr` — KR 시그널 건수 (TB_SIGNAL_SCORE)
- `signalScoreRowCountUs` — US 시그널 건수

(선택) 추가 노출: `basDt`, `autoTradingOnAccountCount`, `activeGovernanceHaltCount` — 카드 크기·가독성에 따라 최소 4지표 + basDt 우선.

---

## 3. 제약 (Constraints)

- **백엔드**: 신규 API·엔드포인트 추가 금지. 기존 `AutoTradingReadinessDto`·`GET /api/v1/ops/auto-trading-readiness` 만 사용.
- **프론트**: 기존 Ops 레이아웃·라우팅·권한 모델 유지. 위젯은 기존 UI 컴포넌트(Card, Badge 등) 스타일과 일치.
- **데이터 계약**: 백엔드 DTO에는 이미 `dailyStockRowCountKr`, `dailyStockRowCountUs`, `signalScoreRowCountKr`, `signalScoreRowCountUs` 포함. 프론트 `AutoTradingReadinessDto` 타입에 해당 필드가 없으면 **동기화** 필요.

---

## 4. 수용 기준 (Acceptance Criteria)

| # | 기준 | 검증 방법 |
|---|------|-----------|
| AC1 | Ops 페이지(어느 서브탭이든)에서 위젯이 노출된다. | Ops 진입 후 카드 노출 확인 |
| AC2 | 위젯에 KR/US 일봉 건수 2개, KR/US 시그널 건수 2개가 표시된다. | API 응답과 동일한 값 표시 |
| AC3 | 기준일(basDt)이 표시된다. | 예: 2026-03-12 |
| AC4 | API 호출 실패 시 에러 메시지 또는 안내가 표시된다. | 4xx/5xx 시 빈 카드가 아닌 에러 UI |
| AC5 | 로딩 중에는 로딩 표시가 보인다. | 스피너 또는 스켈레톤 |
| AC6 | 기존 E2E/QA 시나리오를 깨뜨리지 않는다. | run-api-qa.ps1·자동투자 E2E 체크리스트 유지 |

---

## 5. 비범위 (Out of Scope)

- 새 백엔드 API 또는 DTO 필드 추가 (이미 시장별 필드 존재).
- Ops 외 다른 페이지(예: 대시보드 메인)에 동일 위젯 복제.
- 알림/푸시·자동 새로고침(폴링) — 필요 시 추후 스토리로 분리.

---

## 7. 태스크 분해 (Epic → Feature → Task)

**Shrimp Task Manager**: 상위 목표는 `plan_task`로 등록 후, 아래 Task를 순서대로 실행(의존성 순).

### Epic
- **E1. Ops 자동매매 준비 상태 위젯**  
  운영자가 자동매매 가동 전 파이프라인 데이터 유무를 Ops에서 한눈에 확인할 수 있도록 위젯 제공.

### Feature
- **F1. 준비 상태 API 연동 및 카드 UI**  
  기존 `GET /api/v1/ops/auto-trading-readiness` 호출 후 4지표를 카드로 표시.

### Tasks (의존성 및 권장 순서)

| 순서 | Task ID | 설명 | 의존성 |
|------|---------|------|--------|
| 1 | T1 | **프론트 DTO 동기화**: `opsApi.ts`의 `AutoTradingReadinessDto`에 `dailyStockRowCountKr`, `dailyStockRowCountUs`, `signalScoreRowCountKr`, `signalScoreRowCountUs` 필드 추가. (백엔드에는 이미 존재) | 없음 |
| 2 | T2 | **AutoTradingReadinessCard 컴포넌트**: 4지표(KR/US 일봉·시그널 건수) + basDt 표시, 로딩/에러 상태 처리. `getAutoTradingReadiness()` 호출. | T1 |
| 3 | T3 | **Ops 레이아웃 배치**: `Ops.tsx`(또는 `OpsDashboard`) 상단에 `AutoTradingReadinessCard` 배치. 모든 Ops 서브탭에서 보이도록. | T2 |
| 4 | T4 | **문서·QA 반영**: 11-api-frontend-mapping.md Ops 절에 위젯·readiness 표시 명시. 필요 시 자동투자 E2E 체크리스트에 "Ops 준비상태 위젯 확인" 항목 추가. 02-development-status.md 완료 섹션에 본 기능 추가. | T3 |

**의존 관계**: T1 → T2 → T3 → T4 (순차 실행 권장).

---

## 8. 참조 (References)

- **설계서 (Architect)**: [plans/architecture/20260313-1500_ops-auto-trading-readiness-widget-design.md](../architecture/20260313-1500_ops-auto-trading-readiness-widget-design.md) — API 경계, 모듈 경계, 구현 가이드
- API: `investment-backend/docs/04-api/02-api-endpoints.md` — `GET /api/v1/ops/auto-trading-readiness`
- DTO: `AutoTradingReadinessDto` (backend), `opsApi.ts` `AutoTradingReadinessDto` (frontend)
- Ops UI: `investment-frontend/src/components/Ops.tsx`, `OpsDashboard`
- 점검 절차: `13-manual-operator-tasks.md` §1.11, `데이터_부재_점검_가이드.md`

---

## 9. 문서 정렬 및 제안 (Alignment & Doc Updates)

- **02-development-status.md**: 구현 완료 시 §1 완료(Completed)에 "Ops 자동매매 준비 상태 위젯" 항목 추가 — GET /api/v1/ops/auto-trading-readiness 기반 4지표 카드, 프론트 DTO 동기화·AutoTradingReadinessCard·Ops 레이아웃 배치. §5 변경 이력에 버전·일자 추가.
- **repo-status-and-next-tasks.md**: §2.1 "즉시 가능" 또는 §2.2 "선택·후속"에 "Ops 자동매매 준비 상태 위젯 (명세: plans/frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md)" 한 줄 추가해 다음 작업 후보로 노출.
- **PRD/roadmap**: 기능 추가가 기존 "실시간 모니터링·운영자 점검" 범위 내이므로 별도 Phase 수정 불필요. 필요 시 PRD §4 기능 요약에 "Ops 준비 상태 시각화" 문구 보강.
- **11-api-frontend-mapping.md**: Ops 절에 "자동매매 준비 상태 위젯: getAutoTradingReadiness, 4지표(KR/US 일봉·시그널) 카드" 설명 추가.
