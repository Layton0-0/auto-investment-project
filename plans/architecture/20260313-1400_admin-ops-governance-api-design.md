# Admin Ops 거버넌스 API 설계

**역할**: Architect (Martin Fowler persona)  
**일자**: 2026-03-13  
**목적**: Ops 전략 거버넌스 탭용 Admin 전용 API의 경계·계약·모듈 구조를 명시하고, 기존 아키텍처·결정사항과 정렬한다.  
**범위**: 설계·문서만. 코드 구현은 이미 존재함(본 설계는 계약 정리 및 문서화).

---

## 1. 요구사항 요약

- **기능**: Admin만 사용하는 API로 (1) 최근 N건의 전략 거버넌스 검사 결과, (2) 활성 halt 목록(market + strategyType)을 조회하고, (3) halt를 원클릭으로 해제할 수 있어야 한다.
- **기존 구현**: `GovernanceCheckResult`·`GovernanceHalt` 엔티티 및 `GovernanceHaltService`가 있으며, `OpsGovernanceController`가 REST API를 노출한다. 본 설계는 **계약을 명시**하고 **프론트 Ops 거버넌스 탭**과의 연동을 명확히 한다.

---

## 2. API 경계 (Contract)

**Base path**: `/api/v1/ops/governance`  
**인가**: 모든 엔드포인트 `hasRole('ADMIN')`. 미인증/비관리자 요청은 401/403.

### 2.1 거버넌스 검사 활성 여부

| 항목 | 내용 |
|------|------|
| **Method** | `GET` |
| **Path** | `/api/v1/ops/governance/status` |
| **Query** | 없음 |
| **Request body** | 없음 |
| **Response 200** | `GovernanceStatusDto`: `{ "governanceEnabled": boolean }` |
| **Status codes** | 200 OK, 401 Unauthorized, 403 Forbidden |

- `governanceEnabled`: 시스템 설정 `governance.enabled` 값. `false`면 검사 Job 실행 시 결과가 저장되지 않음.

---

### 2.2 최근 검사 결과 (Last N)

| 항목 | 내용 |
|------|------|
| **Method** | `GET` |
| **Path** | `/api/v1/ops/governance/results` |
| **Query** | `limit` (optional, integer, default 20). 유효 범위 1~500. 초과 시 500으로 캡. |
| **Request body** | 없음 |
| **Response 200** | `GovernanceCheckResultDto[]` (RUN_AT 내림차순) |
| **Status codes** | 200 OK, 400 Bad Request(limit 비정수 등), 401, 403 |

**GovernanceCheckResultDto** (응답 한 건):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| id | number | O | TB_GOVERNANCE_CHECK_RESULT PK |
| runAt | string | O | 검사 실행 시각 (ISO-8601 instant) |
| market | string | O | KR \| US |
| strategyType | string | O | SHORT_TERM \| MEDIUM_TERM \| LONG_TERM |
| mddPct | number | - | 최대 낙폭(%) |
| sharpeRatio | number | - | 샤프 비율 |
| degraded | boolean | O | 열화 여부 |
| startDate | string | O | 백테스트 구간 시작 (yyyy-MM-dd) |
| endDate | string | O | 백테스트 구간 종료 (yyyy-MM-dd) |
| createdAt | string | O | 레코드 생성 시각 (ISO-8601) |

---

### 2.3 활성 Halt 목록

| 항목 | 내용 |
|------|------|
| **Method** | `GET` |
| **Path** | `/api/v1/ops/governance/halts` |
| **Query** | 없음 |
| **Request body** | 없음 |
| **Response 200** | `GovernanceHaltDto[]` (CLEARED_AT IS NULL인 행만) |
| **Status codes** | 200 OK, 401, 403 |

**GovernanceHaltDto** (응답 한 건):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| market | string | O | KR \| US |
| strategyType | string | O | SHORT_TERM \| MEDIUM_TERM \| LONG_TERM |
| haltedAt | string | O | halt 발생 시각 (ISO-8601) |
| reason | string | - | 사유 (최대 500자) |

---

### 2.4 Halt 해제 (One-Click Clear)

| 항목 | 내용 |
|------|------|
| **Method** | `PUT` |
| **Path** | `/api/v1/ops/governance/halts/{market}/{strategyType}/clear` |
| **Path variables** | `market`: KR \| US. `strategyType`: SHORT_TERM \| MEDIUM_TERM \| LONG_TERM |
| **Request body** | 선택. `GovernanceHaltClearRequestDto`: `{ "clearedBy": string }`. 생략 시 `clearedBy` = "admin" |
| **Response 204** | No Content (해제 성공 또는 이미 해제된 경우 동일 처리, 멱등) |
| **Status codes** | 204 No Content, 400 Bad Request(잘못된 market/strategyType), 401, 403 |

- 동작: 해당 (market, strategyType)의 활성 halt가 있으면 CLEARED_AT·CLEARED_BY 설정 후 저장. 없거나 이미 cleared면 아무 변경 없이 204 반환(멱등).

---

## 3. 에러 응답 형식

프로젝트 표준(GlobalExceptionHandler)에 따름:

```json
{
  "code": "ERROR_CODE",
  "message": "오류 메시지",
  "details": ["상세 목록"],
  "traceId": "UUID",
  "timestamp": "2026-03-13T14:00:00"
}
```

- 401: 인증 없음 또는 토큰 무효.
- 403: 인증됐으나 ADMIN 아님.

---

## 4. 모듈/패키지 경계 및 의존성 방향

### 4.1 참여 패키지

| 패키지 | 역할 | 참여 클래스 |
|--------|------|-------------|
| `api.controller` | REST 진입점, 인가·파라미터 검증 | `OpsGovernanceController` |
| `governance` | 애플리케이션 서비스: 조회·해제 오케스트레이션 | `GovernanceHaltService` |
| `ops.dto` | API 요청/응답 DTO (엔티티 비노출) | `GovernanceCheckResultDto`, `GovernanceHaltDto`, `GovernanceHaltClearRequestDto`, `GovernanceStatusDto` |
| `domain.entity` | 영속 엔티티 | `GovernanceCheckResult`, `GovernanceHalt`, `GovernanceHaltId` |
| `domain.repository` | 영속성 접근 | `GovernanceCheckResultRepository`, `GovernanceHaltRepository` |
| `setting.service` | 시스템 설정 조회 | `SystemSettingService` (status용 governance.enabled) |

### 4.2 의존성 방향

- **Controller** → **GovernanceHaltService**, **SystemSettingService**, **ops.dto**
- **GovernanceHaltService** → **domain.repository**, **domain.entity**, **ops.dto** (엔티티→DTO 변환)
- **Domain/Repository** ← 외부에서 의존받음만 함 (인프라·도메인은 상위 레이어에 의존하지 않음)

규칙: 엔티티는 API에 직접 노출되지 않으며, DTO만 노출된다(ADR §9.3).

### 4.3 신규/변경 컴포넌트

- **신규 DTO/컨트롤러 없음**. 기존 `OpsGovernanceController` 및 `ops.dto` 내 DTO들이 이 계약을 구현한다.
- 필요 시 **path variable 검증** 강화: `market` ∈ {KR, US}, `strategyType` ∈ {SHORT_TERM, MEDIUM_TERM, LONG_TERM} → 400 명시 (현재는 미검증 시 DB 조회 후 없으면 no-op 204).

---

## 5. 아키텍처·결정사항과의 정렬

### 5.1 [01-system-architecture.md](investment-backend/docs/02-architecture/01-system-architecture.md)

- **레이어**: Presentation(Controller) → Application(Service) → Domain(Entity, Repository). 본 API는 해당 구조를 따름.
- **§10.2 Kill Switch API**: Admin 전용 `/api/v1/system/kill-switch`와 동일하게, Ops 거버넌스 API도 **ADMIN 전용**으로 같은 인가 패턴(`@PreAuthorize("hasRole('ADMIN')")`) 사용.
- **패키지**: `governance`는 기관급 퀀트 엔진의 Risk Guard(Compliance) 영역(§3, §10.1)에 대응. `risk.service`(TradingHaltService, PortfolioPeakService)와 함께 거버넌스·halt 관리는 `governance` 패키지에서 제공하는 것이 일관됨.

### 5.2 [decisions.md](investment-backend/docs/decisions.md)

- **ADR 9 (API 설계)**: REST, `/api/v1`, DTO 패턴 준수.
- **ADR 10 (보안)**: 인가 서버 사이드 검증, ADMIN 전용 동작 명시.
- **ADR 17 (관리자 계정)**: Admin 전용 API는 기존 `POST /api/v1/admin/users` 등과 동일하게 `hasRole('ADMIN')`으로 제한.
- **ADR 21 (전략 거버넌스·중단 원칙)**: “전략이 말이 안 되면 즉시 거래 중단” → halt 조회/해제 API는 해당 원칙을 운영 측면에서 지원(활성 halt 가시화·원클릭 해제).

---

## 6. ADR 제안

본 기능은 **기존 구현을 계약 수준으로 명시**하는 것이며, Admin 전용 Ops API 확장 원칙을 문서화하는 것이 유용하다.

**제안: ADR 33 — Admin Ops 거버넌스 API 계약**

- **제목**: Admin Ops 거버넌스 API: 검사 결과·활성 halt 조회 및 halt 해제 계약
- **결정**: (1) 전략 거버넌스 검사 결과·활성 halt 조회·halt 해제는 `/api/v1/ops/governance` 하위 REST로 제공한다. (2) 모든 엔드포인트는 `hasRole('ADMIN')`으로 제한한다. (3) 응답은 DTO만 사용하며 엔티티를 노출하지 않는다. (4) halt 해제는 멱등(없거나 이미 해제된 경우 204 유지).
- **배경**: Ops 거버넌스 탭에서 “최근 N건 검사 결과 + 활성 halt 목록” 표시 및 “halt 원클릭 해제”를 위한 명시적 API 계약이 필요함.
- **참조**: ADR 9, 10, 17, 21; 02-api-endpoints.md §12.4; 01-system-architecture.md §10.

위 내용을 `investment-backend/docs/decisions.md`에 ADR 33으로 추가하는 것을 권장한다.

---

## 7. 프론트엔드 연동 요약

- **Ops 거버넌스 탭** (`/ops/governance`):  
  - `GET .../status` → 검사 활성 여부 표시.  
  - `GET .../results?limit=N` → 최근 N건 결과 테이블.  
  - `GET .../halts` → 활성 halt 목록 및 “해제” 버튼.  
  - `PUT .../halts/{market}/{strategyType}/clear` → 해제 버튼 1회 클릭 시 호출( body에 `clearedBy` 선택).
- **API 매핑**: [11-api-frontend-mapping.md](investment-backend/docs/04-api/11-api-frontend-mapping.md) § 전략 거버넌스 행에 이미 정의됨.

---

## 8. 문서 갱신 체크리스트

- [x] API 경계·스키마·상태 코드: 본 설계서 §2
- [x] 모듈 경계·의존성: §4
- [x] 아키텍처·decisions 정렬: §5
- [x] ADR 33 추가: `investment-backend/docs/decisions.md` (ADR 33 반영 완료)
- [ ] (선택) Path variable 검증 강화 시 02-api-endpoints.md §12.4에 400 조건 명시

---

**문서 버전**: 1.0  
**작성**: 2026-03-13
