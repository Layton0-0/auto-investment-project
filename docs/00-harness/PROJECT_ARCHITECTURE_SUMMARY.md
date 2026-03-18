# Project Architecture Summary

**Generated**: Harness setup / repository analysis  
**Purpose**: Single source of truth for AI and developer context. Do not redesign; preserve existing behavior.

---

## 1. Architecture Style

- **Overall**: Monorepo with **layered architecture** (Presentation → Application → Domain → Infrastructure).
- **Backend**: Single Spring Boot application; API layer → Service layer → Domain (entities, repositories) → Infrastructure (DB, external clients).
- **Frontend**: React SPA; feature-based folders (api, app, components, hooks, lib, pages, root, styles, types, utils).
- **Supporting services**: Two Python services (data-collector, prediction-service) invoked by backend via HTTP; same repo, separate deployables.
- **Deployment**: Docker Compose for local and multi-environment (Oracle/AWS variants); backend is the single “operational” app; Python services are data/AI helpers.

---

## 2. Backend Stack

| Item | Choice |
|------|--------|
| Runtime | Java 17 (SE) |
| Framework | Spring Boot 3.2.2 |
| Build | Gradle (agent-build / unique dir for CI) |
| API | REST, Spring Web + WebFlux |
| Data | Spring Data JPA, Flyway, PostgreSQL (TimescaleDB) |
| Cache / realtime | Redis, Spring Data Redis, Spring Cache |
| Auth | Spring Security, JWT (jjwt 0.12.3) |
| Docs | springdoc-openapi (OpenAPI 2.3.0) |
| Resilience | Resilience4j (circuit breaker, reactor) |
| Observability | Micrometer Prometheus, Brave tracing |
| PDF | OpenPDF (e.g. tax report) |
| Test | JUnit 5, Mockito, Reactor Test, H2 for tests, JaCoCo (line ≥80%, branch ≥70%) |

**Package root**: `com.investment` with domains: account, ai, alert, analysis, api, auth, backtest, batch, common, config, core, datacollection, domain, factor, governance, marketdata, news, onboarding, ops, order, report, risk, setting, strategy, tradingportfolio, web, etc.

---

## 3. Frontend Stack

| Item | Choice |
|------|--------|
| Runtime | Node (ES modules) |
| Framework | React 18 |
| Build | Vite 6 |
| Language | TypeScript |
| Styling | Tailwind v4, CVA, clsx, tailwind-merge |
| UI | Radix UI, Lucide React, Framer Motion, Recharts |
| Router | React Router 6 |
| Test | Vitest, Testing Library, Playwright E2E |

**Key folders**: `src/api`, `src/app`, `src/components`, `src/hooks`, `src/lib`, `src/pages`, `src/root`, `src/styles`, `src/types`, `src/utils`.

---

## 4. Python Services

| Service | Role | Stack |
|---------|------|--------|
| **investment-data-collector** | News, disclosure, KRX/US data; called by backend | FastAPI, yfinance, APScheduler, port 8001 |
| **investment-prediction-service** | AI prediction (e.g. LSTM) | FastAPI, PyTorch, scikit-learn, NumPy, Pandas, port 8000 |

Dependency management: `requirements.txt` per service.

---

## 5. Build Tools & Dependency Managers

- **Backend**: Gradle (no wrapper path assumed; use project `gradlew`).
- **Frontend**: npm (package.json); Vite for build/dev.
- **Python**: pip, requirements.txt per service.
- **Agent build**: `GRADLE_UNIQUE_BUILD_DIR=1` → `agent-build`; cleanup after runs (see agent-cleanup rules).

---

## 6. Database Technology

- **Primary**: PostgreSQL 16 with TimescaleDB 2.13 (timescaledb image).
- **Cache / sessions**: Redis 7.
- **Test**: H2 for backend integration tests (no external DB).

---

## 7. Testing Tools

- **Backend**: JUnit 5, Mockito, Spring Boot Test, Spring Security Test, Reactor Test; JaCoCo for coverage (line 80%, branch 70%); exclusions for DTOs, config, entities, enums.
- **Frontend**: Vitest, @testing-library/react, jsdom; Playwright for E2E.
- **QA**: Root `scripts/run-full-qa.ps1` (backend tests, API QA, Python QA, E2E, security audit); `run-api-qa.ps1`, `run-python-qa.ps1`; API scenario SSoT in `plans/qa/`.

---

## 8. CI/CD Setup

- **Per-repo GitHub Actions**: Backend, frontend, data-collector, prediction-service each have `.github/workflows/ci.yml` (build, test, Docker image push to GHCR).
- **Infra**: `investment-infra` has `.github/workflows/cd.yml` for deployment.
- **Images**: GHCR; tags include `sha-<sha>`, `latest`.
- **No Harness.io or other external CI in repo**; only GitHub Actions.

---

## 9. Containerization

- **Docker**: Dockerfile per service (e.g. backend `Dockerfile.local` for local-full).
- **Compose**: `investment-infra/docker-compose.*.yml` — local-full (TimescaleDB, Redis, backend, frontend, Nginx, Python services), local-db-only, prod, aws, oracle variants.
- **Ports (local)**: Backend 8080 (Compose), 8084 (agent/local dev); Frontend 5173 (Vite); Data-collector 8001; Prediction 8000; TimescaleDB 5432; Redis 6379.
- **Kubernetes**: Referenced in plans; not the primary local path (Compose is).

---

## 10. Naming Conventions

- **Java**: `com.investment.<domain>.<layer>` — controller, service, dto, entity, repository, config; DTOs at API boundary only; entities internal.
- **API**: REST, `/api/v1/...`; versioned.
- **Frontend**: Feature folders; components/hooks/lib separation.
- **Docs**: Korean + English in docs; ADRs in `investment-backend/docs/decisions.md`.

---

## 11. Module Boundaries

- **Backend**: Controller → Service → Domain (entity, repository) → Infrastructure; no controller-to-repository skip; DTOs at API edge.
- **Frontend**: Pages use components and hooks; API calls via dedicated api layer; no business logic in views.
- **Cross-service**: Backend calls data-collector and prediction-service via HTTP; no DB sharing between backend and Python services.

---

## 12. Folder Responsibilities

| Path | Responsibility |
|------|----------------|
| `investment-backend/` | Spring Boot app, main API, pipeline, backtest, orders, strategy, risk, batch. |
| `investment-backend/docs/` | Architecture, API, DB, security, deployment, planning (01–09). |
| `investment-frontend/` | React SPA, dashboard, settings, Ops, backtest UI. |
| `investment-data-collector/` | Data ingestion service. |
| `investment-prediction-service/` | ML prediction service. |
| `investment-infra/` | Docker Compose, scripts (local-up, etc.), CD. |
| `docs/` (root) | Planning, AI/quant workflow, repo status (09-planning, ai-quant-development, ai-team). |
| `.cursor/rules/` | Cursor/agent rules (security, MCP, cleanup, ports, logging, QA, Shrimp, etc.). |
| `scripts/` (root) | run-full-qa, run-api-qa, run-python-qa, run-backtest, git sync, etc. |
| `plans/` | QA scenarios, plan artifacts (cursor, shrimp, etc.). |
| `smart-portfolio-pal/` | Reference submodule; read-only in this repo. |

---

## 13. Existing Documentation

- **Backend**: `investment-backend/docs/` — requirements, architecture, design, features, api, database, operations, deployment, security, setup-guides, planning; `decisions.md` (ADRs); `roadmap.md`, `PRD.md`.
- **Root**: `docs/09-planning/`, `docs/ai-quant-development/`, `docs/ai-team/`; `SYSTEM_READINESS_REPORT.md`, `ai-team.md`, `shrimp-rules.md`.
- **QA**: `plans/qa/` (e.g. QA_시나리오_마스터.md, api-qa.http); scripts reference these.

---

## 14. Conventions and Constraints

- **Tasks**: Shrimp Task Manager MCP; one task at a time; plan-based development.
- **Security**: No secrets in repo; `.env`, `application-*-secret.yml`, `mcp.json` not committed; masking in logs (LogMaskingUtil).
- **Korea Investment API**: MCP required for API spec; GET vs POST and parameters verified via MCP.
- **Production DB**: No manual DML on prod; SQLcl SELECT only.
- **Agent**: Cleanup agent-build, 8084 process, coverage-report when done; script timeouts (e.g. 5 min bootRun, 5 min test, 10 min full-qa).
- **Refactor vs feature**: Refactoring and feature development must be separated; behavior preserved during refactor.
- **Verification**: Mandatory verification before commit; AI output always validated; tests and lint required.

---

*This summary is for development orchestration and AI context only. It does not change application behavior or architecture.*
