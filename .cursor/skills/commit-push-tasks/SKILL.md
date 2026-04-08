---
name: commit-push-tasks
description: Group git changes into meaningful commits and push — monorepo root, submodules, and when to split topics. 한: 커밋 푸시, 서브모듈, 의미 단위
---

# commit-push-tasks — Meaningful commit and push

Use when the user asks to **commit**, **push**, **정리해서 올려**, **유의미한 단위로 커밋**, or to ship work across **parent repo + submodules**.

## Principles

1. **One theme per commit** — A reviewer should understand the PR from the subject line. Mixing unrelated doc fixes with a `.cursor` harness overhaul forces painful reverts.
2. **Smallest safe split** — Prefer several focused commits over one giant blob, unless every file is the same mechanical change (e.g. rename only).
3. **Submodules are separate repos** — Enter each submodule (`investment-backend`, `investment-frontend`, `investment-infra`, …), commit on the correct **branch** (`dev` vs `main` per submodule convention), **push**, then update the **parent** pointer in the monorepo root.
4. **Do not commit dirty submodules by accident** — If `git status` shows `modified content` inside a submodule, either commit inside the submodule or discard; the parent should only record a new SHA after the child is pushed (when sharing with others).
5. **PowerShell** — On Windows use `Set-Location path; git ...` (not `&&` in older PowerShell).

## Suggested commit buckets (this monorepo)

| Bucket | Typical paths | Example message prefix |
|--------|----------------|-------------------------|
| Program / progress spine | `docs/program/`, `docs/verification/`, `scripts/rollup-progress.ps1` | `docs(program):` |
| Root CLAUDE & entrypoints | `CLAUDE.md`, `.cursor/rules/claude-*.md`, `progress-log`, `AGENTS.md`, `docs/ko-harness-triggers.md`, `ai-team.md`, `shrimp-rules.md`, `plans/` link fixes | `docs:` or `chore(docs):` |
| Cursor harness bulk | `.cursor/` agents, archived rules/skills, hooks | `chore(cursor):` |
| Backend product/docs only | `investment-backend/docs/` (on submodule `dev`) | `docs:` inside submodule |
| Frontend docs only | `investment-frontend/docs/` (on submodule `main`) | `docs:` inside submodule |
| Infra only | `investment-infra/` | `chore(infra):` or `ci:` |

## Submodule workflow (checklist)

```text
For each submodule with local changes:
  cd investment-<name>
  git status
  git checkout <expected-branch>   # backend: dev; frontend: main — confirm with team
  git pull --rebase origin <branch>  # if behind remote before push
  git add <paths>
  git commit -m "type(scope): concise subject" -m "Optional body."
  git push origin <branch>

Then at monorepo root:
  git add investment-backend investment-frontend ...
  git commit -m "chore(submodules): sync backend dev & frontend main"
  git push origin main
```

If submodule is **detached HEAD**, switch to `main` or `dev` before committing; never push only a detached commit unless you intend to.

## Parent repo

- Default branch here is **`main`** for `auto-investment-project`.
- After submodule pushes, **always** commit the updated submodule references so CI and other clones see the same SHAs.

## Anti-patterns

- One commit titled `fix` touching 300 files across `.cursor`, docs, and code.
- Pushing parent without pushing submodule first (others get parent pointer to unpushed SHAs).
- Staging `investment-backend` when only **nested** uncommitted work exists without committing inside the submodule first.

## Related

- Monorepo layout: [CLAUDE.md](../../../CLAUDE.md) Repository Structure.
- Daily harness list: [`.cursor/ACTIVE_STACKS.md`](../../ACTIVE_STACKS.md).
- Progress after writes: [`.cursor/rules/progress-log.md`](../../rules/progress-log.md).
