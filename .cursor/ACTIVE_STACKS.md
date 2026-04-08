# Active Cursor rules map (auto-investment-project)

Rules are merged English files under `.cursor/rules/`. Unused ECC language packs sit in `.cursor/archived-rules/ecc-bundled-unused/`.

| Area | Paths | Rule file |
|------|-------|-----------|
| Always-on policy | repo-wide | `security-baseline.md`, `docs-and-quality.md`, `local-dev-hygiene.md`, `ai-workflow-qa.md`, `monorepo-boundaries.md` |
| Spring Boot | `investment-backend/**/*.java` | `java-backend.md`, `korea-investment-api.md`, `quant-and-backtest.md` |
| Frontend | `investment-frontend/**/*.ts(x)` | `frontend-react-ts.md` |
| Python | `investment-data-collector/**/*.py`, `investment-prediction-service/**/*.py` | `python-services.md`, `quant-and-backtest.md` |
| Infra / CD | `investment-infra/**` | Covered in `ai-workflow-qa.md` (CD check) and `local-dev-hygiene.md` (ports) |
| Read-only submodule | `smart-portfolio-pal/**` | `monorepo-boundaries.md` |

Pre-ECC snapshots: `.cursor/archived-rules/pre-ecc-source/`. See also `.cursor/RULES_README.md`, `.cursor/CURSOR_HARNESS.md`. **Korean prompt map:** [`docs/ko-harness-triggers.md`](../docs/ko-harness-triggers.md).

## Daily skills (`.cursor/skills/`)

`agent-introspection-debugging`, `agent-sort`, `ai-regression-testing`, `api-design`, `auto-investment-project-patterns`, `code-tour`, `coding-standards`, `configure-ecc`, `continuous-learning-v2`, `documentation-lookup`, `e2e-testing`, `eval-harness`, `frontend-design`, `frontend-patterns`, `hookify-rules`, `iterative-retrieval`, `java-coding-standards`, `mcp-server-patterns`, `plankton-code-quality`, `python-patterns`, `python-testing`, `search-first`, `skill-stocktake`, `springboot-patterns`, `springboot-tdd`, `springboot-verification`, `strategic-compact`, `tdd-workflow`, `verification-loop`.

Other stacks: `.cursor/archived-skills/` ([`MANIFEST.md`](archived-skills/MANIFEST.md)).

## Daily agent presets (`.cursor/agents/`)

`architect`, `build-error-resolver`, `code-architect`, `code-explorer`, `code-reviewer`, `code-simplifier`, `comment-analyzer`, `database-reviewer`, `doc-updater`, `docs-lookup`, `e2e-runner`, `java-build-resolver`, `java-reviewer`, `performance-optimizer`, `planner`, `pr-test-analyzer`, `python-reviewer`, `refactor-cleaner`, `security-reviewer`, `silent-failure-hunter`, `tdd-guide`, `typescript-reviewer`.

Niche / other stacks: `.cursor/archived-agents/` ([`MANIFEST.md`](archived-agents/MANIFEST.md)).

## Hooks ([`hooks.json`](hooks.json))

| Event | Role |
|-------|------|
| `sessionStart` / `sessionEnd` | Optional ECC session bridge (adapter-gated). |
| `beforeShellExecution` | `block-no-verify`; tmux / dev-server / push hints. |
| `afterShellExecution` | PR URL log, build hints. |
| `afterFileEdit` | Format accumulation, console warn, optional design check. |
| `beforeMCPExecution` / `afterMCPExecution` | MCP audit + result log. |
| `beforeReadFile` / `beforeTabFileRead` | Secret-path warnings / block. |
| `beforeSubmitPrompt` | Secret pattern check in prompt. |
| `subagentStart` / `subagentStop` | Subagent logging. |
| `afterTabFileEdit` | Tab edit format. |
| `preCompact` | Pre-compaction state. |
| `stop` | Batch format / console.log audit. |
