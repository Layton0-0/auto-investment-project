# Pre-Commit Hook — Checks Before Committing

Use this as a checklist before committing. These are safety checks, not automation replacements.

## 1. Tests executed

- [ ] Backend: `.\scripts\run-tests.ps1` or `./gradlew test` has been run and **all tests passed** (or equivalent in the subproject you changed).
- [ ] Frontend (if changed): `npm run test` passed; for UI/flow changes, `npm run e2e` run and passed where applicable.
- [ ] No tests were disabled or skipped to “make the build pass” unless there is a documented reason (e.g. ticket reference).

## 2. Lint executed

- [ ] Backend: No new compiler or lint warnings (or they are documented and accepted).
- [ ] Frontend: Lint (and type-check if applicable) has been run and is clean.
- [ ] Scripts or config: Any project lint/format rules have been followed.

## 3. No sensitive data committed

- [ ] No credentials, API keys, tokens, or production passwords in the commit.
- [ ] No `.env`, `application-*-secret.yml`, or real `mcp.json` content in the commit (templates/placeholders only).
- [ ] No PII or production connection strings in code or committed config.
- [ ] Logs: No new logging of secrets or raw PII (use LogMaskingUtil on backend).

## 4. Correct commit type

- [ ] Commit message follows project convention: type(scope): description (e.g. `feat(api): add X`, `fix(ui): Y`, `refactor(backend): Z`).
- [ ] Type matches the change: `feat` for new behavior, `fix` for bug fix, `refactor` for structure-only, `test`, `docs`, `chore`, `ci` as appropriate.
- [ ] No unrelated changes in the same commit (one logical change per commit).

## 5. Documentation (if applicable)

- [ ] If API or contract changed: API docs (overview, endpoints, or OpenAPI) updated.
- [ ] If architecture or decision changed: `decisions.md` or equivalent updated.
- [ ] If strategy/backtest logic changed: strategy registry or backtest docs updated as per project rules.

---

*Do not commit until the above are satisfied. When in doubt, run full QA (`.\scripts\run-full-qa.ps1`) for cross-cutting changes.*
