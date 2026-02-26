# Development Guidelines (AI Agent)

**Purpose:** Rules for AI Coding Agent. **Project-specific only** — no general development knowledge. All content is based on this repository.

---

## 1. Project Overview

- **Product:** Auto-investment robo-advisor — KR/US 4-stage pipeline (Universe → Signal → Capital → Execution), target MDD -15%, CAGR 30%+.
- **References:** [02-development-status.md](investment-backend/docs/09-planning/02-development-status.md), [roadmap.md](investment-backend/docs/roadmap.md). On conflict, **development-status wins**.

---

## 2. Project Architecture

### 2.1 Repository modules (this repo)

| Module | Path | Role |
|--------|------|------|
| Backend | `investment-backend/` | Spring Boot 2.7.x (Java 11), Gradle. REST API, Batch, domain, repositories. TimescaleDB(PostgreSQL), Redis. |
| Frontend | `investment-frontend/` | React 18, TypeScript, Vite 6, Tailwind CSS 4, React Router 6. API client → Backend `/api/v1`. Vitest. |
| Data collector (Python) | `investment-data-collector/` | FastAPI. DART 공시, SEC EDGAR, Yahoo 뉴스, US 일봉(yfinance) 수집. Spring 호출 또는 `POST /api/v1/internal/collected-news` 전달. Port 8001. |
| Prediction (Python) | `investment-prediction-service/` | FastAPI. LSTM/ML 추론. `GET /api/v1/health`, `POST /api/v1/predict`. Backend가 HTTP 클라이언트로 호출. |
| Infra | `investment-infra/` | Docker Compose, CD 스크립트, 배포(Oracle Cloud, AWS). Backend / prediction / data-collector / nginx 구성. |

### 2.2 Backend layers and Python 연동

- **Backend layers:** Controller → Service → Domain → Repository → Infrastructure.
- **API version:** `/api/v1`. DTO at boundary only; do not expose JPA entities.
- **Data collector 연동:** Backend는 `investment.data.us.collector-url` 등으로 data-collector의 `/dart-collect`, `/sec-collect`, `/us-daily` 호출. 수집기는 Spring `POST /api/v1/internal/collected-news`(X-Internal-Data-Key)로 전달. [10-data-collection-api.md](investment-backend/docs/04-api/10-data-collection-api.md), [investment-data-collector/README.md](investment-data-collector/README.md).
- **Prediction 연동:** Backend `AiPredictionClient` / `FastApiPredictionClient`가 prediction-service URL로 `/api/v1/predict`, `/api/v1/health` 호출. Circuit breaker·fallback 적용.

---

## 3. Task and Workflow Standards

- **Shrimp Task Manager:** All implementation must have a corresponding task. No coding without a task.
- **Lifecycle:** todo → in_progress → blocked | done. Only **one** task in_progress per context unless parallelization is explicit.
- **Before coding:** Confirm current task, scope, and acceptance criteria.
- **After coding:** Run tests/build, then mark task done and update docs (see §7).
- **Task completion:** After shrimp-task-manager tasks are verified/completed, **always update [02-development-status.md](investment-backend/docs/09-planning/02-development-status.md)** — add to §1 Completed and add a version entry in §5.
- **Blocked:** Set task to blocked with a clear reason; create a blocker-resolution task if needed.

### 3.1 수정사항 수신 시 워크플로우 (사용자 전달 수정사항)

- 사용자가 "수정해야 할 사항"을 보낼 때마다:
  1. **Shrimp에 task 등록:** 해당 수정사항을 `plan_task`(또는 적절한 Shrimp 도구)로 등록한다. 제목·설명에 수정 요청 내용을 명확히 적는다.
  2. **순차 처리:** 등록한 task를 하나씩 in_progress로 두고, `execute_task` 가이드에 따라 구현·검증 후 done 처리한다.
  3. **후속 작업 선등록:** 구현 중에 "나중에 해야 할 작업"(예: 문서 보강, 다른 메뉴 동일 적용, 성능 측정 등)이 보이면 **즉시** Shrimp에 별도 task로 등록해 둔다. 한꺼번에 처리하지 말고, 현재 task 완료 후 다음 task로 이어가도록 한다.
- 정리: **수정사항 → task 등록 → 하나씩 처리 → 후속은 미리 task 등록.**

---

## 4. Code Standards

- **Java 11.** Bean Validation (`@Valid`) + custom validators at API boundary.
- **Naming:** Clear intent; avoid abbreviations; broader scope → more specific names.
- **Functions:** ~20–30 lines, single responsibility. Prefer immutability.
- **Exceptions:** DomainException / AppException + `@ControllerAdvice`. Do not expose stack traces to clients.
- **Logging:** Use `LogMaskingUtil` for app key, secret, account no, userId. Never log raw secrets.
- **Tests:** JUnit5 + Mockito; slice tests (`@WebMvcTest`, `@DataJpaTest`). Line ≥80%, branch ≥70%.

---

## 5. Functionality Implementation Standards

- **API changes:** RESTful HTTP status; error body `{code, message, details, traceId}`. Version breaking changes under new path.
- **Korean Investment (KIS) API:** **Always** confirm with Korea Investment MCP before implementing or changing requests (GET+query vs POST+body). Do not assume from docs only.
- **Strategy / factor / parameter changes:** Update [00-strategy-registry.md](investment-backend/docs/02-architecture/00-strategy-registry.md) and add a version stack entry (summary, result, lesson).
- **Manual operator steps:** Document in [13-manual-operator-tasks.md](investment-backend/docs/06-deployment/13-manual-operator-tasks.md).
- **Python (data-collector / prediction-service):** Request/response 또는 경로 변경 시 Backend 쪽 설정·클라이언트·문서 동기화. 수집기: `investment.data.*`, Internal API 스펙. 예측: `prediction-service` URL, `/api/v1/predict` 요청/응답.

---

## 6. Framework and External Usage

- **Resilience4j:** Circuit breaker for external APIs (market data, order, prediction).
- **Flyway:** New schema changes as `db/migration/Vnn__description.sql`. Do not edit applied migrations.
- **Secrets:** Never commit `.env`, `application-*-secret.yml`, real keys. Use `.env.example`, `mcp.json.template` with placeholders only.

---

## 7. Key File Interaction (Multi-File Sync)


| Change type                             | Must update                                                                                                                                                                                                                                                         |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| API signature / request or response     | [02-api-endpoints.md](investment-backend/docs/04-api/02-api-endpoints.md), [01-api-overview.md](investment-backend/docs/04-api/01-api-overview.md); KIS usage → [09-korea-investment-api-guide.md](investment-backend/docs/04-api/09-korea-investment-api-guide.md) |
| Strategy / factor / formula / parameter | [00-strategy-registry.md](investment-backend/docs/02-architecture/00-strategy-registry.md) + version stack                                                                                                                                                          |
| Architecture / policy decision          | [decisions.md](investment-backend/docs/decisions.md) (ADR)                                                                                                                                                                                                          |
| Completed feature / task                | [02-development-status.md](investment-backend/docs/09-planning/02-development-status.md) §1 Completed; adjust §2 In progress, §3 Planned if needed                                                                                                                  |
| New or changed manual operator step     | [13-manual-operator-tasks.md](investment-backend/docs/06-deployment/13-manual-operator-tasks.md)                                                                                                                                                                    |
| Data-collector / prediction API 변경    | Backend 호출부·설정 문서. 수집: [10-data-collection-api.md](investment-backend/docs/04-api/10-data-collection-api.md), [investment-data-collector/README.md](investment-data-collector/README.md). 예측: application.yml prediction-service, [01-api-overview.md](investment-backend/docs/04-api/01-api-overview.md) 등.             |


**Rule:** Do not finish work with code-only changes; always update the relevant docs above.

---

## 8. AI Decision-Making Standards

- **Priority:** Security & tests > maintainability > performance > delivery speed.
- **Scope creep:** If the current task grows, create a **new** task; do not expand the current one without a task.
- **Unclear requirement:** Prefer checking codebase and docs (development-status, roadmap, API docs) before asking; cite file and section.
- **Test/run timeouts (Agent):** Use ≥300000 ms for `bootRun-agent.ps1` and `run-tests.ps1`; ≥360000 ms for coverage.

---

## 9. Prohibited Actions

- **Never** run DML (INSERT/UPDATE/DELETE) on PROD DB. SQLcl SELECT only for PROD.
- **Never** commit or log real secrets, API keys, passwords, or internal IPs.
- **Never** skip doc updates when API, strategy, or completion status changes (§7).
- **Never** implement or change Korea Investment API calls without MCP verification.
- **Never** leave Agent resources uncleaned: remove `agent-build`*, `.agent-build-dir`; stop process on 8084 if started by Agent; follow [agent-cleanup.mdc](.cursor/rules/agent-cleanup.mdc).

---

## 10. Local and Agent Environment

- **Ports:** 8083 = user (e.g. IntelliJ); 8084 = Agent only (`.\scripts\bootRun-agent.ps1`). Stop 8084 when done.
- **Tests:** `.\scripts\run-tests.ps1` or `.\scripts\run-tests-with-coverage.ps1` from repo root; respect script timeouts in rules.

