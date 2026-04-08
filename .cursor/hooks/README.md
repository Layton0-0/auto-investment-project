# Cursor hooks (this repo)

Thin routers in this folder adapt Cursor hook events to the same `scripts/hooks/*.js` implementations vendored from ECC. **Harness root** is `.cursor` (see [`adapter.js`](adapter.js) `getPluginRoot()`); optional override: `CLAUDE_PLUGIN_ROOT` pointing at that folder.

## Runtime controls

- **`ECC_HOOK_PROFILE`**: `minimal` | `standard` (default) | `strict`
- **`ECC_DISABLED_HOOKS`**: comma-separated hook ids (case-insensitive), e.g. `pre:bash:tmux-reminder,stop:cost-tracker`

Ids below match the second argument to `hookEnabled()` in the router, or are marked *always* when not gated.

## Wired in [`hooks.json`](../hooks.json)

| Cursor event | Router | Hook id(s) | Profiles | Delegates to `scripts/hooks/` or behavior |
|--------------|--------|------------|----------|-------------------------------------------|
| `sessionStart` | `session-start.js` | `session:start` | minimal, standard, strict | `session-start.js` |
| `sessionEnd` | `session-end.js` | `session:end:marker` | minimal, standard, strict | `session-end-marker.js` |
| `beforeShellExecution` | *(external)* | — | always | `npx block-no-verify@1.1.2` |
| `beforeShellExecution` | `before-shell-execution.js` | `pre:bash:dev-server-block` | standard, strict | inline (non-Windows: block dev server outside tmux) |
| | | `pre:bash:tmux-reminder` | strict only | inline stderr |
| | | `pre:bash:git-push-reminder` | strict only | inline stderr |
| `afterShellExecution` | `after-shell-execution.js` | `post:bash:pr-created` | standard, strict | inline PR URL hint |
| | | `post:bash:build-complete` | standard, strict | inline build hint |
| `afterFileEdit` | `after-file-edit.js` | *(no id)* | always | `post-edit-accumulator.js`, `post-edit-console-warn.js` |
| | | `post:edit:design-quality-check` | standard, strict | `design-quality-check.js` |
| `beforeMCPExecution` | `before-mcp-execution.js` | *always* | — | stderr audit only |
| `afterMCPExecution` | `after-mcp-execution.js` | *always* | — | stderr result log |
| `beforeReadFile` | `before-read-file.js` | *always* | — | warn on secret-like paths |
| `beforeSubmitPrompt` | `before-submit-prompt.js` | *always* | — | warn on secret-like prompt patterns |
| `subagentStart` | `subagent-start.js` | *always* | — | stderr agent name |
| `subagentStop` | `subagent-stop.js` | *always* | — | stderr agent name |
| `beforeTabFileRead` | `before-tab-file-read.js` | *always* | — | **exit 2** on secret-like paths |
| `afterTabFileEdit` | `after-tab-file-edit.js` | *(no id)* | always | `post-edit-format.js` |
| `preCompact` | `pre-compact.js` | *(no id)* | always | `pre-compact.js` |
| `stop` | `stop.js` | `stop:check-console-log` | standard, strict | `check-console-log.js` |
| | | `stop:session-end` | minimal, standard, strict | `session-end.js` |
| | | `stop:evaluate-session` | minimal, standard, strict | `evaluate-session.js` |
| | | `stop:cost-tracker` | minimal, standard, strict | `cost-tracker.js` |

## On disk but not connected to Cursor routers

These live under [`.cursor/scripts/hooks/`](../scripts/hooks/). Opt in by extending the matching router in this folder and documenting new ids here (see also [`CURSOR_HARNESS.md`](../CURSOR_HARNESS.md)).

| Script | Typical reason to leave off |
|--------|----------------------------|
| `quality-gate.js` | Cost; overlaps CI |
| `stop-format-typecheck.js` | Slow on large trees |
| `pre-bash-commit-quality.js` | Overlaps husky; blocks WIP commits |
| `mcp-health-check.js` | stdin shape tuned for Claude Code |
| `post-edit-format.js`, `post-edit-typecheck.js` | Partially covered by accumulator + stop patterns in ECC |

## Upstream reference

Full Claude Code hook matrix and JSON shape: [everything-claude-code `hooks/README.md`](https://github.com/affaan-m/everything-claude-code/blob/main/hooks/README.md) (or a local clone). For vendored script diff workflow see **Upstream hook sync** in [`CURSOR_HARNESS.md`](../CURSOR_HARNESS.md).
