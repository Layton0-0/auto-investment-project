---
name: auto-investment-project-patterns
description: Monorepo layout, submodule workflow, QA/scripts, and commit habits inferred from the parent repo git history. Use when editing auto-investment-project, coordinating submodules, or running full QA.
version: 1.0.0
source: local-git-analysis
analyzed_commits: 52
analyzed_scope: parent-repository-only
---

# Auto Investment Project — Repo Patterns

Patterns below are derived from the **parent** repository `auto-investment-project` (not from full history inside each submodule). Submodule code changes mostly appear as pointer bumps (`investment-backend`, `investment-frontend`, etc.).

## Commit conventions

- **Conventional Commits appear often**: `chore:`, `feat:`, `docs:`, scoped forms like `chore(gitignore):`, `docs(plans):`, `feat(qa):`.
- **Automated / bulk sync messages**: `Daily sync YYYY-MM-DD HH:MM` — treat as snapshot commits; prefer explicit `chore:` / `docs:` messages for hand-written work.
- **Submodule maintenance**: frequent subjects like `chore: update submodule refs`, `chore(submodule): update investment-backend` — when only submodules move, the real code review happens in the child repos.

**Suggestion for new work**: use Conventional Commits with a scope when touching a specific area (`feat(backend):`, `fix(frontend):`, `chore(infra):`).

## Architecture (parent repo)

```
auto-investment-project/     # parent; Cursor rules, plans, QA scripts, docs
├── investment-backend/      # Git submodule — Spring Boot, Java 17, Korean Investment API
├── investment-frontend/     # Git submodule — React, Vite, TypeScript
├── investment-infra/        # Git submodule — Docker Compose, CI/CD
├── investment-data-collector/   # Git submodule — Python / FastAPI
├── investment-prediction-service/  # Git submodule — Python / ML service
├── smart-portfolio-pal/     # Git submodule — Lovable-owned; read-only in this monorepo
├── .cursor/                 # Project rules, skills, hooks (ECC + local)
├── plans/                   # QA scenarios, architecture notes, reports
├── scripts/                 # run-full-qa.ps1, run-api-qa.ps1, run-python-qa.ps1, etc.
└── docs/                    # Harness, AI team, planning docs
```

**Hot paths in recent history** (frequency in ~200 parent commits): `investment-backend` > `investment-frontend` > `investment-infra` > `investment-data-collector` > `investment-prediction-service`; root automation touches `scripts/run-api-qa.ps1`, `scripts/run-full-qa.ps1`, `plans/qa/*`, `.cursor/rules/*`.

## Workflows

### Changing application code

1. Work inside the **relevant submodule** (`investment-backend`, `investment-frontend`, …), commit and push there.
2. In the **parent** repo, bump the submodule pointer and commit with `chore: update <submodule> ref` (or similar).

### QA and verification

1. Full pipeline: parent `scripts/run-full-qa.ps1` (see workspace rules for timeout — prefer 600000 ms or more).
2. API scenarios: `scripts/run-api-qa.ps1` (requires credentials env vars per project docs).
3. Python services: `scripts/run-python-qa.ps1` when applicable.
4. **External API tests**: project rules expect strict HTTP **200** for Korean Investment–backed endpoints in QA; do not treat 4xx as success.

### Docs and planning

- `plans/qa/QA_시나리오_마스터.md`, `plans/qa/api-qa.http` — scenario source of truth.
- `docs/09-planning/`, `CLAUDE.md` — orientation for agents and humans.
- Updating behavior: keep `investment-backend/docs/09-planning/02-development-status.md` and related API/architecture docs in sync when features change (per project rules).

### smart-portfolio-pal

- **Do not edit** under `smart-portfolio-pal/` in this monorepo; sync only via parent `git submodule update` per pinned commit. UI work belongs in `investment-frontend` unless directed otherwise.

## Testing patterns (by service)

| Area | Typical stack | Location hint |
|------|----------------|---------------|
| Backend | JUnit, Mockito, Gradle | `investment-backend` — `src/test`, `gradlew test` |
| Frontend | Vitest, Playwright | `investment-frontend` — `npm test`, `npm run test:e2e` |
| Python services | `unittest` / project tests | `investment-data-collector`, `investment-prediction-service` |

Parent repo itself rarely contains unit tests; validation is orchestration (QA scripts, plans).

## Co-change signals

These files or areas often move together in parent history:

- **Submodules + plans**: infra/backend/frontend pointer updates alongside `plans/qa/*` or `plans/docs/*`.
- **QA hardening**: `.cursor/rules/qa-automation-flow.mdc`, `script-run-timeouts.mdc`, `run-full-qa.ps1`, `run-api-qa.ps1`.
- **Tooling**: `.cursor/mcp.json.template` with submodule or rules updates.

## Limits of this skill

- Does **not** replace `CLAUDE.md` or `.cursor/rules/*.mdc`; it summarizes **git-derived** habits.
- **Submodule interiors** were not mined; open the child repo for file-level patterns, reviewers, and CI config.

---

*Generated by local `/skill-create` analysis. Re-run after major workflow changes or with `--commits N` in a harness that supports it.*
