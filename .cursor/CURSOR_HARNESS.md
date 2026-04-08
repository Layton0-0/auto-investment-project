# Cursor harness (skills, agents, hooks)

Single source for **skills**: `.cursor/skills/*/SKILL.md`. The former duplicate tree `.cursor/.agents/skills/` is removed except [`MANIFEST.md`](.agents/skills/MANIFEST.md) (explains canonical path).

| Surface | Location | Notes |
|---------|----------|--------|
| Rules | `.cursor/rules/*.md` | See [`RULES_README.md`](RULES_README.md) |
| Skills (daily) | `.cursor/skills/` | Archived: `.cursor/archived-skills/` + [`MANIFEST.md`](archived-skills/MANIFEST.md) |
| Agent presets | `.cursor/agents/*.md` | Archived: `.cursor/archived-agents/` + [`MANIFEST.md`](archived-agents/MANIFEST.md) |
| Hooks | [`.cursor/hooks.json`](hooks.json) + [`.cursor/hooks/*.js`](hooks/) | **[Hook matrix (ids, profiles, scripts)](hooks/README.md)** |

Full daily lists: [`.cursor/ACTIVE_STACKS.md`](ACTIVE_STACKS.md). **Korean prompt routing (skills/agents/rules):** [`docs/ko-harness-triggers.md`](../docs/ko-harness-triggers.md).

**Harness root** is the `.cursor` directory (ECC install target in `ecc-install-state.json`). Hook scripts resolve to `.cursor/scripts/hooks/`. For subprocesses that expect ECC layout, set `CLAUDE_PLUGIN_ROOT` to the absolute path of `.cursor` in this repo.

Optional checks: `node .cursor/scripts/validate-skill-agent-description.js` · hook paths: `node .cursor/scripts/validate-hook-paths.js`

## Workflow skill (low overhead)

- **`search-first`** — Before new code or dependencies, search the repo, registries, MCP, and OSS ([`.cursor/skills/search-first/SKILL.md`](skills/search-first/SKILL.md)). No extra hooks; behavior is prompt/skill-driven.

## Hook profile and complexity budget

[`adapter.js`](hooks/adapter.js) and [`.cursor/scripts/lib/hook-flags.js`](scripts/lib/hook-flags.js) support:

- **`ECC_HOOK_PROFILE`**: `minimal` | `standard` (default) | `strict`
- **`ECC_DISABLED_HOOKS`**: comma-separated hook ids to turn off (e.g. `pre:bash:tmux-reminder`)

**Cursor `hooks.json` today** wires a **small** set of router scripts (session, shell, file edit, MCP log, secrets, stop, etc.). Additional ECC scripts under [`.cursor/scripts/hooks/`](scripts/hooks/) (e.g. `quality-gate.js`, `stop-format-typecheck.js`, `pre-bash-commit-quality.js`, `mcp-health-check.js`) are **not** connected by default so agent sessions stay responsive and to avoid overlapping CI/husky. To opt in later, extend the matching `.cursor/hooks/*.js` router and document new ids here.

| Script (exists on disk) | Default in Cursor router | Why often left off |
|-------------------------|---------------------------|---------------------|
| `quality-gate.js` | No | Runs on many edits; sync cost; overlap with CI / `/quality-gate` |
| `stop-format-typecheck.js` | No | Runs at stop; can be slow on large trees |
| `pre-bash-commit-quality.js` | No | Blocks commits; overlap with husky; WIP friction |
| `mcp-health-check.js` | No | stdin/config tuned for Claude; needs Cursor mapping |

Upstream hook catalog: clone [everything-claude-code](https://github.com/affaan-m/everything-claude-code) locally and read `hooks/README.md` for the full Claude Code hook matrix.

## Upstream hook sync (checklist)

Use when pulling changes from ECC or auditing drift.

1. Open [`.cursor/ecc-install-state.json`](ecc-install-state.json) and note `source.repoCommit` (pinned upstream revision at last install).
2. Clone or update a local [everything-claude-code](https://github.com/affaan-m/everything-claude-code) checkout; optionally `git checkout <that commit>` for an apples-to-apples diff.
3. Diff only hook implementations: `everything-claude-code/scripts/hooks/` vs `.cursor/scripts/hooks/` (names should largely match).
4. If upstream changes behavior you rely on, copy or merge into `.cursor/scripts/hooks/` and re-verify with `node .cursor/scripts/validate-hook-paths.js`.
5. If Cursor routers need new steps, extend [`.cursor/hooks/*.js`](hooks/) and document hook ids in [`hooks/README.md`](hooks/README.md).

## Claude Code vs Cursor

Same policy surface (profiles, disabled-hook ids, vendored `scripts/hooks`), **different entry points**: Claude Code uses the plugin `hooks.json` with `${CLAUDE_PLUGIN_ROOT}`; Cursor uses [`.cursor/hooks.json`](hooks.json) and the routers in [`.cursor/hooks/`](hooks/). See [`hooks/README.md`](hooks/README.md) for the Cursor-specific matrix.
