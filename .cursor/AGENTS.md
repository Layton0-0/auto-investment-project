# Agent instructions (auto-investment-project)

**First:** Before orchestrating agents or doing implementation work in this repo, read the repository root [`CLAUDE.md`](../CLAUDE.md) (see [`.cursor/rules/claude-bootstrap.md`](rules/claude-bootstrap.md)). It defines **How to work**, then the spine and verification flow below.

**Operating flow:** [docs/program/00-operating-flow.md](../docs/program/00-operating-flow.md) (spine, Tier 0–3). **After editing files:** append one line to [docs/program/progress.md](../docs/program/progress.md) per [progress-log.md](rules/progress-log.md). **Verify:** [docs/verification/README.md](../docs/verification/README.md).

This file is **project-scoped**. The canonical list of **daily agent presets** in this repo is [`.cursor/ACTIVE_STACKS.md`](ACTIVE_STACKS.md) (section “Daily agent presets”). Each preset is a markdown file under [`.cursor/agents/`](agents/).

**Note:** Merging all mandatory commands into `CLAUDE.md` alone (“constitution”) is a **separate follow-up**; keep using `.cursor/rules/` as the enforcement source until then.

The upstream **Everything Claude Code** plugin ships many more agents; copies used less often live under [`.cursor/archived-agents/`](archived-agents/) — see [`MANIFEST.md`](archived-agents/MANIFEST.md). Do not assume every ECC agent name exists in `.cursor/agents/`.

## Daily agents (this repo)

| Agent | Purpose |
|-------|---------|
| architect | System design and scalability |
| build-error-resolver | Fix build/type errors |
| code-architect | Feature architecture / blueprint |
| code-explorer | Deep codebase tracing |
| code-reviewer | After substantive edits |
| code-simplifier | Clarity and simplification |
| comment-analyzer | Comment quality / rot |
| database-reviewer | PostgreSQL / schema / queries |
| doc-updater | Docs and codemaps |
| docs-lookup | Library docs via Context7 |
| e2e-runner | Playwright E2E |
| java-build-resolver | Gradle/Java build failures |
| java-reviewer | Spring Boot / Java review |
| performance-optimizer | Performance work |
| planner | Complex features / refactors |
| pr-test-analyzer | PR test coverage quality |
| python-reviewer | Python review |
| refactor-cleaner | Dead code / consolidation |
| security-reviewer | Auth, secrets, sensitive paths |
| silent-failure-hunter | Swallowed errors / bad fallbacks |
| tdd-guide | Tests-first workflow |
| typescript-reviewer | TS/JS review |

## When to delegate (orchestration)

- Complex feature or large refactor → **planner** (then implement).
- Code just written or changed → **code-reviewer**; security-sensitive areas → **security-reviewer**.
- New feature or bug fix with tests → **tdd-guide**.
- Architecture or cross-service design → **architect** or **code-architect**.
- Independent tasks → multiple agents in parallel when helpful.

## Principles (details in rules)

Always-on expectations are in [`.cursor/rules/`](rules/) — especially [`security-baseline.md`](rules/security-baseline.md), [`docs-and-quality.md`](rules/docs-and-quality.md), and stack-specific rules. Prefer those files for security checklists, coverage expectations, and git conventions rather than duplicating long policy here.

## Workflow surface

- **Skills:** [`.cursor/skills/`](skills/) — canonical workflow knowledge for this harness.
- **Hooks / profiles:** [`.cursor/CURSOR_HARNESS.md`](CURSOR_HARNESS.md), [`.cursor/hooks/README.md`](hooks/README.md).

ECC version vendored at last install: see `source.repoVersion` in [`.cursor/ecc-install-state.json`](ecc-install-state.json).

**Korean prompts:** see [`docs/ko-harness-triggers.md`](../docs/ko-harness-triggers.md) for intent → skill / agent / rule mapping.
