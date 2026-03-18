# Project Memory — Persistent Context for AI

Auto-populated from repository analysis. Use this as persistent project context; update when conventions or decisions change.

---

## Detected Architecture

- **Style**: Layered (Presentation → Application → Domain → Infrastructure). Monorepo: backend (Spring Boot), frontend (React), Python services (data-collector, prediction-service), infra (Docker Compose).
- **Backend**: Single deployable; API → Service → Domain → Infrastructure. Domains: account, auth, order, strategy, backtest, batch, risk, marketdata, news, ops, etc.
- **Frontend**: React SPA; Vite; feature folders (api, app, components, hooks, lib, pages, root, styles, types, utils).
- **Python**: data-collector (port 8001), prediction-service (port 8000); HTTP-only integration with backend.

---

## Coding Conventions

- **Java**: Java 17; Spring Boot 3.2.2; package `com.investment.<domain>.<layer>`; DTO at API boundary only; entities internal; Lombok allowed; explicit types preferred.
- **Frontend**: TypeScript; React 18; functional components; hooks for state and side effects; no business logic in presentational components.
- **API**: REST, `/api/v1/`; version bump on breaking changes; OpenAPI/Swagger maintained.
- **Naming**: Clear intent; avoid abbreviations in public APIs; broader scope → more specific names.

---

## Framework Versions (Snapshot)

| Component | Version |
|-----------|---------|
| Java | 17 |
| Spring Boot | 3.2.2 |
| Gradle | (project gradlew) |
| Node / npm | (local) |
| React | 18.x |
| Vite | 6.x |
| TypeScript | 5.x |
| Python (services) | 3.x (see requirements.txt) |
| TimescaleDB | 2.13.0-pg16 |
| Redis | 7-alpine |

---

## Project Decisions (Summary)

- **Monorepo**: Single repo; backend is the main application; Python services are supporting.
- **DB**: TimescaleDB (PostgreSQL) for primary data; Redis for cache/sessions.
- **Auth**: JWT; short-lived access tokens; refresh flow; server-side validation only.
- **Secrets**: Env/secret managers; never in repo; `.env`, `application-*-secret.yml`, `mcp.json` not committed; templates only.
- **Korea Investment API**: MCP required for spec and parameter verification; GET vs POST and params confirmed via MCP.
- **Production DB**: No manual DML; SELECT only (e.g. SQLcl).
- **Logging**: Structured; PII/secrets masked via LogMaskingUtil.
- **Tasks**: Shrimp Task Manager; one task at a time; plan-based development; verification before done.

---

## Module Responsibilities

| Module | Responsibility |
|--------|----------------|
| investment-backend | Main API, pipeline, backtest, orders, strategy, risk, batch, auth, account, market data integration. |
| investment-frontend | Dashboard, settings, Ops UI, backtest UI, onboarding; consumes backend API. |
| investment-data-collector | Data ingestion (news, disclosure, KRX/US); called by backend. |
| investment-prediction-service | ML predictions; called by backend. |
| investment-infra | Docker Compose, local/prod/aws/oracle variants; CD workflows. |
| smart-portfolio-pal | Reference submodule; read-only in this repo. |

---

## Key Paths

- **Backend source**: `investment-backend/src/main/java/com/investment/`
- **Backend docs**: `investment-backend/docs/` (01–09, decisions.md)
- **Frontend source**: `investment-frontend/src/`
- **Root docs**: `docs/` (09-planning, ai-quant-development, ai-team, 00-harness, 01_architecture–08_status)
- **Scripts**: `scripts/` (run-full-qa, run-api-qa, run-python-qa, run-backtest, etc.)
- **Cursor rules**: `.cursor/rules/*.mdc`; project_rules.md
- **Plans/QA**: `plans/`, `plans/qa/`

---

## Verification Commands (Reference)

- Backend tests: `.\scripts\run-tests.ps1` or `cd investment-backend && ./gradlew test`
- Backend with coverage: `.\scripts\run-tests-with-coverage.ps1` or `./gradlew test jacocoTestReport`
- Full QA: `.\scripts\run-full-qa.ps1` (timeout ≥10 min recommended)
- Backend run (agent): `.\scripts\bootRun-agent.ps1` (port 8084); stop process when done
- Frontend dev: `cd investment-frontend && npm run dev` (port 5173)
- E2E: `cd investment-frontend && npm run e2e`

---

*Update this file when architecture, conventions, or key decisions change so that AI and developers share consistent context.*
