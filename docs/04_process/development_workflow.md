# Development Workflow

This document defines the development workflow for the auto-investment project: from task selection to commit and record. It is part of the Harness-based development environment and should be followed by both humans and AI agents.

---

## 1. Task selection

- **Source**: Tasks come from Shrimp Task Manager, a plan (e.g. from Cursor/plan artifact), or an agreed ticket.
- **Single focus**: Only one primary task is in progress at a time per execution context, unless parallelization is explicitly required.
- **Clarity**: The task has a clear goal and completion criteria. If not, refine or split the task before starting.
- **Pre-task**: Run through [.hooks/pre-task.md](../../.hooks/pre-task.md) (scope, refactor vs feature, clarity, environment).

---

## 2. Focused work

- **Boundaries**: Work stays within the task scope. If the scope grows, create a new task and complete the current one first, or explicitly expand the scope and document it.
- **Layers**: Respect architecture boundaries (controller → service → domain → infrastructure; no bypass). Use the appropriate skill (e.g. backend_api, frontend_component, refactoring, database_change) from [.cursor/skills/](../../.cursor/skills/).
- **External API**: For Korea Investment API or other external integrations, use MCP to verify request format and parameters; do not assume from docs alone (see `.cursor/rules/MCP.mdc`).
- **No mixing**: Refactoring and feature development are not mixed in the same task unless explicitly scoped.

---

## 3. Verification

- **Tests**: Run the relevant test suite before considering the task done.
  - Backend: `.\scripts\run-tests.ps1` or `./gradlew test` (and coverage when required).
  - Frontend: `npm run test`; for UI/flow changes, `npm run e2e` where applicable.
  - Full QA: For cross-cutting or API contract changes, run `.\scripts\run-full-qa.ps1` with sufficient timeout (see script-run-timeouts rule).
- **Lint**: Resolve any new lint or type errors.
- **Behavior**: For refactoring, confirm behavior is preserved (same inputs → same outputs). For features/fixes, confirm acceptance criteria are met.
- **Security**: No secrets or PII in code or logs; use placeholders in docs and LogMaskingUtil where required.

---

## 4. Commit

- **Pre-commit**: Run through [.hooks/pre-commit.md](../../.hooks/pre-commit.md) (tests, lint, no sensitive data, correct commit type, docs).
- **Message**: Use conventional type and scope: `type(scope): description` (e.g. `feat(api): add X`, `fix(ui): Y`, `refactor(backend): Z`).
- **Single concern**: One logical change per commit; no unrelated edits.
- **No secrets**: Never commit credentials, API keys, tokens, or production config. Use `.env.example` or placeholders.

---

## 5. Record

- **Post-task**: Run through [.hooks/post-task.md](../../.hooks/post-task.md).
- **TASK_LOG.md**: Add a row with date, task/scope, verification, and notes.
- **CHANGELOG.md**: Update if the change affects repo-wide tooling, workflow, or conventions.
- **Docs**: Update API docs, decisions, or strategy/backtest docs if behavior or contract changed. Keep `.cursor/memory/project_memory.md` in sync when conventions or key decisions change.
- **Next task**: If there is a follow-up, create or update the task (e.g. in Shrimp) and mark it as next; document blockers if any.

---

## Summary

| Step           | Action |
|----------------|--------|
| 1. Task selection | Pick one task; confirm scope and completion criteria; run pre-task hook. |
| 2. Focused work   | Stay in scope; use skills and architecture boundaries; separate refactor vs feature. |
| 3. Verification   | Tests and lint pass; behavior confirmed; no secrets. |
| 4. Commit         | Pre-commit hook; conventional message; one change per commit; no secrets. |
| 5. Record         | Post-task hook; TASK_LOG; CHANGELOG if needed; docs updated; next task identified. |

---

*This workflow ensures one task at a time, mandatory verification before commit, and consistent documentation and traceability. For AI-specific workflow (e.g. quant strategy pipeline), see [docs/ai-quant-development/](../ai-quant-development/).*
