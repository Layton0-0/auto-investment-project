# Skill: Debugging

**When to use**: Investigating failures, flaky tests, or runtime misbehavior in backend, frontend, or scripts.

## Procedure

1. **Reproduce**: Confirm steps or inputs that trigger the issue; note environment (local, CI, Docker). Check TASK_LOG and recent commits for related changes.
2. **Scope**: Determine layer (API, service, domain, DB, external call, frontend). Use logs and stack traces; avoid blind code changes.
3. **Logs**: Use existing structured logging; do not log secrets or PII (use LogMaskingUtil on backend). Add temporary debug logs only in dev; remove or guard before commit.
4. **Backend**: Use debugger or targeted logs; run locally with `.\scripts\bootRun-agent.ps1` (port 8084) if needed. Stop the process when done (see agent-cleanup).
5. **Frontend**: Use browser dev tools and Vitest/Playwright in debug mode if needed. Check network and console for API errors.
6. **External APIs**: Verify request format (GET vs POST, params) via MCP or API docs; confirm env (e.g. test account) and that 200 is expected in the scenario.
7. **Fix**: Apply minimal fix; add or adjust test to prevent regression. Separate refactor from fix unless explicitly scoped.
8. **Docs**: If the root cause implies a doc or contract change, update API/docs accordingly.

## Validation

- Issue is fixed and reproducible scenario now passes.  
- No new failing tests; no committed secrets or temporary debug code.  
- If new test added, it fails without the fix and passes with it.

## Commit

- Type: `fix(scope): description`. If debugging led to refactor, use `refactor` or separate commit.  
- Do not commit debug logs or credentials.  
- TASK_LOG/CHANGELOG per hooks.
