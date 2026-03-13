# Ops 자동매매 준비 상태 위젯 — 시스템 설계

**역할**: Architect (Martin Fowler persona)  
**일자**: 2026-03-13  
**기준 명세**: [plans/frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md](../frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md)  
**목적**: Backend·Frontend 개발자가 구현에 사용할 API 경계, 모듈 경계, 정렬 사항을 명시. **코드 없음.**

---

## 1. 요약

- **Backend**: 변경 없음. 기존 `GET /api/v1/ops/auto-trading-readiness` 단일 API만 사용.
- **Frontend**: 기존 API 연동 + DTO 타입 동기화 + 신규 위젯 컴포넌트 + Ops 레이아웃 배치.
- **ADR**: 신규 아키텍처 결정 없음(기존 API·기존 Ops/Admin 패턴 재사용). ADR 제안 없음.

---

## 2. API 경계 (Contract)

### 2.1 사용 API (기존, 변경 없음)

| 항목 | 내용 |
|------|------|
| **Method** | `GET` |
| **Path** | `/api/v1/ops/auto-trading-readiness` |
| **Query** | 없음 |
| **Request body** | 없음 |
| **Response 200** | `AutoTradingReadinessDto` (아래 스키마) |
| **Status codes** | 200 OK, 401 Unauthorized, 403 Forbidden (ADMIN 아님) |
| **인가** | `hasRole('ADMIN')` |

### 2.2 Response Schema: AutoTradingReadinessDto

백엔드가 이미 제공하는 필드. 프론트는 이 계약에 맞춰 DTO 타입을 **동기화**해야 함.

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| basDt | string | O | 기준일 (yyyy-MM-dd). 파이프라인에서 사용하는 전일. |
| autoTradingOnAccountCount | number | O | 자동투자 ON인 계좌 수 |
| dailyStockRowCount | number | O | 기준일 TB_DAILY_STOCK 전체 건수 (KR+US) |
| dailyStockRowCountKr | number | - | 기준일 TB_DAILY_STOCK **KR** 건수 (위젯 4지표 중 1) |
| dailyStockRowCountUs | number | - | 기준일 TB_DAILY_STOCK **US** 건수 (위젯 4지표 중 1) |
| signalScoreRowCount | number | O | 기준일 TB_SIGNAL_SCORE 전체 건수 |
| signalScoreRowCountKr | number | - | 기준일 TB_SIGNAL_SCORE **KR** 건수 (위젯 4지표 중 1) |
| signalScoreRowCountUs | number | - | 기준일 TB_SIGNAL_SCORE **US** 건수 (위젯 4지표 중 1) |
| activeGovernanceHaltCount | number | O | 활성 거버넌스 halt 수 (선택 노출) |

**위젯 필수 표시**: `dailyStockRowCountKr`, `dailyStockRowCountUs`, `signalScoreRowCountKr`, `signalScoreRowCountUs` 4지표 + `basDt`.  
**선택 표시**: `autoTradingOnAccountCount`, `activeGovernanceHaltCount` (카드 크기·가독성에 따라).

### 2.3 에러 응답

- 401/403 시 프로젝트 표준 에러 body (code, message, details, traceId, timestamp).  
- 프론트: 로딩·에러·빈 상태를 구분하여 표시(AC4, AC5).

---

## 3. 모듈/패키지 경계 및 의존성

### 3.1 Backend

- **변경 없음.** 신규 컨트롤러·서비스·DTO 없음.
- 기존: `OpsController`(또는 해당 Ops 진입점) → `AutoTradingReadinessService` → `AutoTradingReadinessDto`.  
- 참고: `investment-backend/src/main/java/com/investment/ops/` (dto, service), 해당 컨트롤러에서 `GET /api/v1/ops/auto-trading-readiness` 노출.

### 3.2 Frontend

| 레이어 | 컴포넌트/모듈 | 역할 | 의존 방향 |
|--------|----------------|------|------------|
| Page/Layout | Ops (또는 OpsDashboard) | Ops 진입점; 위젯 배치 | → AutoTradingReadinessCard |
| Presentational | **AutoTradingReadinessCard** (신규) | 4지표 + basDt 카드, 로딩/에러/빈 상태 | → opsApi, 타입 |
| API | opsApi.ts | getAutoTradingReadiness() | → 백엔드 API, AutoTradingReadinessDto |
| Types | AutoTradingReadinessDto (opsApi.ts 내 interface) | API 응답 타입 | — |

**의존성 방향**: Ops Page → AutoTradingReadinessCard → opsApi.getAutoTradingReadiness().  
**데이터 흐름**: 마운트(또는 Ops 진입) 시 1회 GET 호출 → DTO 수신 → 카드에 4지표 + basDt 표시.

### 3.3 신규/변경 컴포넌트

| 구분 | 항목 | 비고 |
|------|------|------|
| Backend | 없음 | 기존 API만 사용 |
| Frontend 신규 | **AutoTradingReadinessCard** | 4지표(KR/US 일봉·시그널) + basDt, 로딩/에러 처리 |
| Frontend 변경 | **AutoTradingReadinessDto** (opsApi.ts) | `dailyStockRowCountKr`, `dailyStockRowCountUs`, `signalScoreRowCountKr`, `signalScoreRowCountUs` 필드 추가 (백엔드와 동기화) |
| Frontend 변경 | **Ops 레이아웃** | 상단에 AutoTradingReadinessCard 배치 (모든 Ops 서브탭에서 노출) |

---

## 4. 아키텍처·결정사항과의 정렬

### 4.1 [investment-backend/docs/02-architecture/01-system-architecture.md](investment-backend/docs/02-architecture/01-system-architecture.md)

- Ops·Admin 전용 API는 기존 Kill Switch·Governance API와 동일한 패턴(ADMIN 전용).  
- 본 기능은 **기존 Ops API 재사용**이므로 레이어·패키지 구조 변경 없음.

### 4.2 [investment-backend/docs/decisions.md](investment-backend/docs/decisions.md)

- **ADR 9**: REST, `/api/v1`, DTO — 기존 API가 이미 준수.  
- **ADR 17**: Admin 전용 — `GET /api/v1/ops/auto-trading-readiness` 이미 `hasRole('ADMIN')`.  
- **ADR 제안**: 없음. 신규 API·신규 아키텍처 결정이 없음.

### 4.3 [investment-backend/docs/04-api/11-api-frontend-mapping.md](investment-backend/docs/04-api/11-api-frontend-mapping.md)

- Ops 절에 **자동매매 준비 상태 위젯** 연동 명시: `getAutoTradingReadiness`, 4지표(KR/US 일봉·시그널) 카드, basDt.  
- 구현 완료 후 해당 문서 §4·§5.2(메뉴별 매핑)에 위젯·readiness 표시 반영.

---

## 5. 구현 가이드 (Backend / Frontend)

### 5.1 Backend Developer

- **할 일 없음.** 기존 API·DTO가 명세·설계 계약을 이미 만족함.  
- (선택) 02-api-endpoints.md §12.4에 응답 필드 `dailyStockRowCountKr/Us`, `signalScoreRowCountKr/Us`가 이미 기입되어 있는지 확인하고, 누락 시 보완.

### 5.2 Frontend Developer

1. **T1 — DTO 동기화**  
   `investment-frontend/src/api/opsApi.ts`의 `AutoTradingReadinessDto`에 다음 필드 추가:  
   `dailyStockRowCountKr?: number;`  
   `dailyStockRowCountUs?: number;`  
   `signalScoreRowCountKr?: number;`  
   `signalScoreRowCountUs?: number;`  
   (백엔드에는 이미 존재하므로 타입만 맞추면 됨.)

2. **T2 — AutoTradingReadinessCard**  
   - `getAutoTradingReadiness()` 호출.  
   - 4지표(dailyStockRowCountKr/Us, signalScoreRowCountKr/Us) + basDt 표시.  
   - 로딩 중: 스피너 또는 스켈레톤.  
   - 에러 시: 에러 메시지 또는 안내(빈 카드 대신).  
   - 단일 책임: “준비 상태 한 카드”만 담당.

3. **T3 — Ops 레이아웃**  
   - Ops 페이지(또는 OpsDashboard) 상단에 `AutoTradingReadinessCard` 배치.  
   - 모든 Ops 서브탭(데이터/알림/설정 등)에서 보이도록 배치 위치 결정.

4. **T4 — 문서·QA**  
   - 11-api-frontend-mapping.md Ops 절에 위젯·readiness 4지표 명시.  
   - 필요 시 자동투자 E2E 체크리스트에 “Ops 준비상태 위젯 확인” 항목 추가.  
   - 02-development-status.md 완료 섹션에 “Ops 자동매매 준비 상태 위젯” 추가.

---

## 6. 문서 갱신 체크리스트

- [x] API 경계·스키마·상태 코드: §2
- [x] 모듈/패키지 경계·의존성: §3
- [x] 아키텍처·decisions 정렬: §4
- [x] ADR: 불필요(기존 API 재사용)
- [ ] 구현 후: 11-api-frontend-mapping, 02-development-status, (선택) 02-api-endpoints 필드 확인

---

**문서 버전**: 1.0  
**기준 명세**: plans/frontend/20260313-1200_ops-auto-trading-readiness-widget-spec.md
