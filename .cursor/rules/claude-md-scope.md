---
description: When CLAUDE.md may be edited (constitutional scope only)
alwaysApply: true
---

## Scope

**`CLAUDE.md` (repo root) is not the place for routine documentation updates.** Edit it only for **constitutional**, repo-wide changes, for example:

- Monorepo **layout or submodule** model changes (what lives where, read-only submodule policy).
- **Tooling baseline** that every contributor must see first (e.g. required Java/Node versions, primary entrypoint contract).
- **One-time operating-model shifts** that redefine this file’s role (e.g. adopting `docs/program` as the spine and reflecting that in the root guide).

## Do not edit CLAUDE.md for

- Day-to-day workflow wording, new checklist items, or extra links to QA scripts.
- Progress log format, Shrimp steps, or agent orchestration detail.
- Harness or skill lists that belong in [`.cursor/AGENTS.md`](../AGENTS.md), [`ai-team.md`](../../ai-team.md), [`shrimp-rules.md`](../../shrimp-rules.md), or [`docs/program/00-operating-flow.md`](../../docs/program/00-operating-flow.md).

Put those updates in:

- [`docs/program/00-operating-flow.md`](../../docs/program/00-operating-flow.md) — spine and reading order.
- `.cursor/rules/*.md` — enforceable conventions.
- [`.cursor/AGENTS.md`](../AGENTS.md) — agent presets.
- [`ai-team.md`](../../ai-team.md) / [`shrimp-rules.md`](../../shrimp-rules.md) — team and task workflow.

If a PR only needs to refresh “how we work” without changing constitutional facts, **revert `CLAUDE.md` changes** and move the text to the files above.
