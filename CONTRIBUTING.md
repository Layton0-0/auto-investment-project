# Contributing

## Before you open a PR

1. **Submodules** — Work in the correct repository (`investment-backend`, `investment-frontend`, …), commit and push there first when your change lives inside a submodule. Then update the parent repo’s submodule pointer if needed. See [.cursor/skills/commit-push-tasks/SKILL.md](.cursor/skills/commit-push-tasks/SKILL.md).
2. **Secrets** — Never commit `.env`, real API keys, tokens, or `mcp.json` with live credentials. Follow [.cursor/rules/security-baseline.md](.cursor/rules/security-baseline.md).
3. **Verify** — From the monorepo root, run checks in [docs/verification/README.md](docs/verification/README.md) when your change affects build or runtime behavior.

## Public clone checklist (maintainers)

- Parent and all linked submodule repos are **Public** on GitHub (or document which submodule is optional).
- CI secrets use GitHub **Actions secrets**, not hardcoded values in workflows.
- If credentials were ever exposed, **rotate** them; history rewriting is optional and risky.

## Code style

Match existing patterns in the touched module. Backend: layered Spring; frontend: React/TS patterns in `investment-frontend`. Cursor rules live under [.cursor/rules/](.cursor/rules/).
