# Agent Commands by Order (Chained, No Duplication)

**Purpose**: Commands only, in execution order. **Each step consumes the previous agent’s output** so the pipeline runs without repeating the same request.  
Personas: [04-agent-commands.md](04-agent-commands.md). Workflow: [01-agent-workflow-quant.md](01-agent-workflow-quant.md).

---

## Execution order overview

| Phase | Order | Agent | Consumes output of |
|-------|--------|--------|---------------------|
| **1. General feature** | 1→2→3→4→5 | Planner → Architect → Backend → Frontend → QA | (user) → Planner → Architect → Backend → Frontend |
| **1b. As needed** | — | Bug Fixer, Code Reviewer, DevOps | failing test / PR / infra request in context |
| **2. Domain** | 6→7→8→9 | Strategy → Risk → Market Data → Quant Dev | optional: prior analysis in context |
| **3. Quant loop** | 10→11→12→13→14 | strategist → architect → dev → backtest → auto | (user) → spec → design → implementation |

---

## 1. General workflow (feature development)

### 1.1 Planner

**Input**: User request (paste below). **Output**: Spec + task list for next agents.

```
Analyze the request below and produce a feature spec and task breakdown.

[PASTE USER REQUEST HERE — e.g. "Add Ops governance tab: show last N check results and active halts, with Clear button per halt."]

Deliverables:
- One-page spec: goal, requirements, constraints, acceptance criteria.
- Epic → Feature → Task breakdown (Shrimp); dependencies and order.
- Alignment with docs/09-planning/02-development-status.md and roadmap; propose doc updates if needed.
Output spec and task list only; no code.
```

---

### 1.2 Architect

**Input**: Planner’s spec (above). **Output**: Design doc for Backend + Frontend.

```
Using the feature spec and task list from the Planner above, design the system changes.

Produce:
- API boundary: HTTP method, path, request/response schema, status codes.
- Module/package boundaries and dependency direction; new DTOs/controllers if any.
- Alignment with investment-backend/docs/02-architecture and decisions.md; propose ADR if needed.
Output design and documentation only; no code. Backend and Frontend developers will implement from this.
```

---

### 1.3 Backend Developer

**Input**: Architect’s design (above). **Output**: Implemented backend + updated docs.

```
Using the design document from the Architect above, implement the backend parts in investment-backend.

- Follow their API paths, request/response shapes, and module boundaries.
- Keep controller → service → domain/repository; DTOs at API boundary only; no entity exposure.
- Use @Valid, GlobalExceptionHandler, LogMaskingUtil for sensitive data.
- Update 02-development-status and 02-api-endpoints (or equivalent) for new endpoints.
List changed files and one-line summary per file.
```

---

### 1.4 Frontend Developer

**Input**: Architect’s design + Backend’s API (above). **Output**: Implemented frontend.

```
Using the design from the Architect and the backend API implemented by the Backend Developer above, implement the frontend in investment-frontend.

- Use the same endpoints and response shapes as implemented/documented in backend.
- Single responsibility per component; API calls in hook or service; handle loading, error, empty states.
- Follow .cursor/rules (React-Security, React-Development) and 11-api-frontend-mapping.
List changed files and one-line summary per file.
```

---

### 1.5 QA Engineer

**Input**: Spec + design + Backend + Frontend work (above). **Output**: Tests + scenarios.

```
Add tests for the feature implemented in this conversation by the Backend and Frontend developers above.

- Backend: unit or slice tests for new controller/service (JUnit 5, Mockito); coverage in line with project goals.
- API: add scenarios to plans/qa/api-qa.http and QA_시나리오_마스터 for new endpoints (auth, 200/403 as appropriate).
- Frontend: unit tests for hooks/utils; E2E for critical flows if needed.
- State how to run: run-tests.ps1, run-full-qa.ps1, or npm run e2e.
```

---

## 1b. As needed (fixes, review, infra)

### 1.6 Bug Fixer

**Input**: Failing test or error output (in context). **Output**: Root cause + minimal fix + verification.

```
Using the failing test or error output above, find the root cause and fix it with the smallest change.

- Prefer fixing the test/request if the contract is correct; otherwise fix the implementation.
- Re-run the test (or run-tests.ps1) and confirm it passes.
- Reply with: one sentence cause, one sentence fix.
```

---

### 1.7 Code Reviewer

**Input**: Backend + Frontend changes from this conversation (or PR description). **Output**: Findings + concrete fix suggestions.

```
Review the Backend and Frontend changes from this conversation (or the PR described above).

Check: security (no secrets/PII in logs; server-side validation and auth); consistency with existing APIs and LogMaskingUtil; .cursor/rules; maintainability and naming.
For each issue: short finding + concrete fix suggestion (minimal code if needed). Do not rewrite the whole change.
```

---

### 1.8 DevOps Engineer

**Input**: Infra/deployment request (in context or below). **Output**: Compose/scripts + doc + verification step.

```
Using the infra or deployment request above (or in context), implement it.

- Update investment-infra (compose, scripts) and deployment docs (06-deployment) so they stay in sync.
- No real secrets in docs; use placeholders or .env.example.
- Give one-line verification step.
```

---

## 2. Domain expert agents

*Each can use prior analysis in context if present; otherwise the one-line request is the input.*

### 2.1 Strategy Analyst

**Input**: Strategy question (below or in context). **Output**: Analysis + registry/backtest references.

```
Using the strategy question below (or in context), perform the analysis.

[PASTE STRATEGY QUESTION — e.g. "Impact of changing volatility breakout k from [0.3,0.7] to [0.35,0.65] for KR short-term."]

- Reference 00-strategy-registry.md and 18-kr-short-term-strategies-top10.md.
- Describe usage in backend (services, config) and what to verify in backtest; propose version-stack entry if we adopt.
- Do not run backtest; state how to run it (run-backtest.ps1 or POST /api/v1/backtest).
```

---

### 2.2 Risk Analyst

**Input**: Risk topic (below or in context). **Output**: Flow doc + gap list + minimal change suggestions.

```
Using the risk topic below (or in context), document the flow and recommend changes.

[PASTE RISK TOPIC — e.g. "Document daily loss limit: when we record opening balance, when we check threshold, what we do (block/alert)."]

- Reference 00-strategy-registry.md §2.9 and the actual service classes.
- List gaps and suggest minimal code/config changes with service and setting names.
```

---

### 2.3 Market Data Analyst

**Input**: Market data question (below or in context). **Output**: Flow doc + bug/minimal fix if any.

```
Using the market data question below (or in context), verify and document.

[PASTE QUESTION — e.g. "Trace KR current-price flow: cache → WebSocket → REST fallback."]

- Reference 10-korea-investment-api-spec.md and MCP.
- Document flow; if you find a bug, suggest minimal fix with file and method names.
```

---

### 2.4 Quant Developer

**Input**: Python-service task (below or in context). **Output**: Implementation + tests.

```
Using the Python service task below (or in context), implement in investment-data-collector or investment-prediction-service.

[PASTE TASK — e.g. "Add DART keyword '무상증자' to signal-relevant list; set signalRelevant and eventType prefix; add unit test."]

- Follow .cursor/rules/python-services.md and quant-and-backtest.md; type hints, structured logging, no secrets.
```

---

## 3. Quant strategy development loop (strict order)

### 3.1 quant-strategist

**Input**: Strategy choice or user goal (below). **Output**: One-page strategy spec for Architect.

```
Design a Korean short-term strategy we can implement in the backend.

[PASTE GOAL OR CHOICE — e.g. "Volume spike + breakout" or "Volatility breakout (시가 + Range×k)"]

Use docs/ai-quant-development, 18-kr-short-term-strategies-top10.md, 00-strategy-registry.md. Produce one-page spec: name, entry (formula + params), exit rules, backtest checklist (PIT, costs, CAGR/Sharpe/MDD/win rate/profit factor). No code.
```

---

### 3.2 quant-architect

**Input**: Strategy spec from quant-strategist (above). **Output**: Design doc for quant-dev.

```
Using the strategy spec from the quant-strategist above, design where it fits in the system.

- Map to the 4-stage pipeline (universe → signal → sizing → execution): which stages need new/changed logic, config keys, API contract if needed.
- Align with BacktestRunResult (cagr, sharpeRatio, mddPct, winRate, profitFactor, tradesCount).
Output a short design document only; no code.
```

---

### 3.3 quant-dev

**Input**: Design from quant-architect (above). **Output**: Implementation + registry update.

```
Using the design from the quant-architect above, implement in investment-backend.

- Add or change only what the design specifies (e.g. filters, config, signal combination).
- Update 00-strategy-registry.md: one version-stack row and formula/signal section if needed.
- Do not change exit rules or backtest engine in this step.
List each changed file and one-line summary.
```

---

### 3.4 quant-backtest

**Input**: Strategy + implementation from above. **Output**: Verification report + tests/docs.

```
Using the strategy and implementation from the quant-strategist and quant-dev above, verify the backtest.

- Costs: commission/slippage (and KR sell tax if applicable) applied; result DTO exposes friction cost.
- Metrics: BacktestRunResult has cagr, sharpeRatio, mddPct, winRate, profitFactor, trade count.
- Stress: document in backtest-stress-results.md how to run 2020-02–04 and 2022-01–06 and where to paste results.
If anything is missing, propose minimal code change and add or extend one test. Output short verification report and list of changes/tests.
```

---

### 3.5 quant-auto

**Input**: Full quant loop + repo state (above and codebase). **Output**: Gap list + minimal impl + logging + tests.

```
Using the strategy pipeline from the quant loop above and the current repo, analyze and improve.

- List up to 5 gaps vs strategy registry and architecture docs.
- Propose refactors only where boundaries are unclear or there are circular deps; no large rewrites.
- Implement only the highest-priority gap minimally; add or extend logging in one key flow; add at least one unit test (and slice/integration if API was added).
- If obvious performance issue: suggest in one sentence; implement only if one-file change.
Modify only what is necessary; list every changed file and one-line summary.
```

---

## 4. Run and test commands

| Purpose | Command |
|---------|---------|
| Backend unit tests | `.\scripts\run-tests.ps1` or from `investment-backend`: `.\gradlew test` |
| Full QA | `.\scripts\run-full-qa.ps1` |
| Single backtest (Backend up) | `.\scripts\run-backtest.ps1` or `POST /api/v1/backtest` |
| API scenarios only | `.\scripts\run-api-qa.ps1` |
