# Post-Task Hook — After Completing a Task

Use this checklist after completing a task. These are safety checks, not automation replacements.

## 1. Progress log (`docs/program/progress.md`)

- [ ] If this task **modified, added, or deleted** files in the repo: **Session log** in [docs/program/progress.md](../docs/program/progress.md) has a new line with **files**, **scope**, **verify** (see `.cursor/rules/progress-log.md`).
- [ ] If the task was **read-only** (no writes): progress line is optional.

## 2. CHANGELOG update

- [ ] **CHANGELOG.md** (at repo root) has been updated if this task introduced:
  - New orchestration/tooling (Harness, scripts, hooks, docs layout), or
  - Notable change to development workflow or conventions.
- [ ] Application feature changes may be recorded in subproject changelogs or in the task/PR description; root CHANGELOG is for repo-wide tooling and process.

## 3. Documentation consistency

- [ ] Any design, API, or decision change made during the task is reflected in the relevant docs (API overview, endpoints, decisions.md, strategy registry, etc.).
- [ ] No stale references: links and paths in updated docs are valid.
- [ ] If you added or changed a skill (`.cursor/skills/`) or rule (`.cursor/rules/`), the content matches current project structure and conventions.

## 4. Cleanup (if applicable)

- [ ] **Agent cleanup**: If you started backend with `bootRun-agent.ps1` (port 8084), the process has been stopped.
- [ ] **Temp build**: If you used `agent-build` or similar, it has been removed per agent-cleanup rules.
- [ ] **Branches**: If you created a branch for the task, it is pushed and (if applicable) PR is created or linked; no local-only branches that should be shared are left unpushed.

## 5. Handoff / next task

- [ ] If there is a follow-up task (e.g. from Shrimp or plan), it is created or updated and marked as next.
- [ ] Blockers or dependencies for the next task are documented (e.g. in progress.md, Shrimp task, or PR).

---

*Complete the above before considering the task fully done. This keeps the project traceable and consistent.*
