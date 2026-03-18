# Project Rules — Harness Development Orchestration

Derived from the actual project structure. These rules govern development discipline, boundaries, and AI usage. They do not replace existing `.cursor/rules/*.mdc`; they complement them.

---

## 1. Architecture Boundaries

- **Backend (investment-backend)**: Strict layering — Controller → Service → Domain (entity, repository) → Infrastructure. DTOs only at API boundary; entities stay internal. No controller-to-repository or bypass of service layer.
- **Frontend (investment-frontend)**: API calls only through dedicated `api` layer; business logic in hooks/services, not in view components. Single responsibility per component; no direct API logic in pages.
- **Python services**: data-collector and prediction-service are called by the backend via HTTP only; no shared database. Changes to contracts (ports, paths, request/response) must be reflected in backend clients and docs.
- **Dependency direction**: Inward. Infrastructure and API depend on domain; domain does not depend on framework or delivery details.

---

## 2. Naming Conventions

- **Java**: `com.investment.<domain>.<layer>` — e.g. `*.controller`, `*.service`, `*.dto`, `*.entity`, `*.repository`, `*.config`. DTOs: suffix `Dto` or `*Request`/`*Response` where appropriate.
- **API**: REST; base path `/api/v1/`; version increment on breaking changes.
- **Frontend**: Feature-based folders; components/hooks/lib; file names match component names.
- **Docs**: Korean or English as per existing docs; ADRs and tech decisions in `investment-backend/docs/decisions.md`.

---

## 3. Refactoring vs Feature Development

- **Must be separated**: Refactoring (structure, naming, dependency cleanup) and feature development (new behavior) are distinct. One PR/task should not mix both unless explicitly scoped.
- **Refactoring**: Preserve behavior; no change to API contracts or observable outcomes unless that is the stated goal. Tests must pass before and after.
- **Feature**: New or changed behavior; must be described in task/plan and reflected in docs (API, status, decisions as applicable).

---

## 4. One Task at a Time

- Only one primary task in progress per execution context unless parallelization is explicitly required.
- Task scope must be clear and bounded; completion criteria defined before implementation.
- Dependencies: a task that depends on another cannot start until the dependency is done.

---

## 5. Mandatory Verification Before Commit

- **Backend**: Run tests (`.\scripts\run-tests.ps1` or `gradlew test`); no commit with failing tests. Coverage targets (line ≥80%, branch ≥70%) enforced by JaCoCo.
- **Frontend**: Lint and tests (Vitest); E2E (Playwright) when touching UI flows. Run as per project scripts.
- **Full QA**: When touching cross-cutting or API contracts, run `.\scripts\run-full-qa.ps1` (or equivalent) with appropriate timeout; fix failures before commit.
- **Sensitive data**: No credentials, API keys, tokens, or production config values in commits. Use placeholders and env/secret managers.

---

## 6. AI Output Validation

- All AI-generated code, config, or docs must be validated: build, tests, and manual review where appropriate.
- Do not commit AI-suggested changes without running the relevant test/lint and verifying behavior.
- Security-sensitive or DB-related changes require extra scrutiny (no DML on prod; masking in logs; no secrets in repo).

---

## 7. Testing Requirements

- **Backend**: Unit and slice tests for new/changed logic; integration tests for API and external integrations where applicable. Prefer `@WebMvcTest`, `@DataJpaTest` for slice tests.
- **Frontend**: Unit tests for hooks and business logic; E2E for critical user flows.
- **External APIs**: Tests that call real external systems (e.g. Korea Investment API) must expect 200 and valid response shape; do not treat 4xx/5xx as success (see `external-api-test-strict-200.mdc`).

---

## 8. Documentation Consistency

- API signature or request/response changes → update API docs (overview, endpoints, Korea Investment API guide as applicable).
- Architecture or policy decisions → update `investment-backend/docs/decisions.md` or equivalent.
- Strategy/backtest logic or parameters → update strategy registry and backtest docs.
- Completed work → update development status and TASK_LOG/CHANGELOG as per hooks.

---

## 9. Behavior Preservation During Refactoring

- Refactoring must not change observable behavior unless explicitly scoped (e.g. “fix bug” or “change API contract”).
- Test suite must remain green; add or adjust tests only to reflect intended behavior, not to “make refactor pass.”

---

## 10. Safety Rules (Recap)

- **Never commit**: credentials, API keys, tokens, private data, production configuration values.
- **Use placeholders** in docs and examples (e.g. `YOUR_APP_KEY`, `YOUR_DB_PASSWORD`).
- **Logging**: Use `LogMaskingUtil`; never log secrets or raw PII. See `logging-masking.mdc`.
- **Production DB**: No manual DML; SELECT-only via SQLcl. See project security and DB rules.

---

*These rules are part of the Harness development environment. For domain-specific rules (security, MCP, Shrimp, QA, etc.) see the other `.cursor/rules/*.mdc` files.*
