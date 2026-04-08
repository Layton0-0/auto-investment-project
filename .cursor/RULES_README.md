# Cursor rules (this repo)

Active rule files live in `.cursor/rules/` as short English `.md` files (YAML frontmatter + body max 300 characters after the closing `---`).

**Current set (10):** `security-baseline.md`, `docs-and-quality.md`, `local-dev-hygiene.md`, `ai-workflow-qa.md`, `monorepo-boundaries.md`, `korea-investment-api.md`, `quant-and-backtest.md`, `frontend-react-ts.md`, `python-services.md`, `java-backend.md`.

**Archives:** `.cursor/archived-rules/ecc-bundled-unused/` (unused language packs), `pre-ecc-source/` (pre-merge snapshot). Re-extract: `node .cursor/scripts/extract-pre-ecc-rules.js`.

**Validation:** `node .cursor/scripts/validate-rule-body-length.js`

Upstream ECC folder layout is historical; this repo uses flat merged names only.

**Skills, agents, hooks:** [`.cursor/CURSOR_HARNESS.md`](CURSOR_HARNESS.md) and [`.cursor/ACTIVE_STACKS.md`](ACTIVE_STACKS.md). Optional: `node .cursor/scripts/validate-skill-agent-description.js`, `node .cursor/scripts/validate-hook-paths.js`.
