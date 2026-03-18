# Skill: Backend API (Spring Boot)

**When to use**: Adding or changing REST API endpoints, request/response DTOs, or controller behavior in investment-backend.

## Procedure

1. **Scope**: Confirm the task is either feature or refactor; do not mix. Identify affected domain (e.g. account, order, strategy).
2. **Contract**: Define or read existing API contract (path, method, request/response body). For Korea Investment API integration, use MCP to verify spec (GET vs POST, parameters).
3. **Layers**: Implement or change in order: DTO (api/dto or domain dto) → Service → Controller. Do not skip service layer; do not expose entities directly.
4. **Validation**: Use Bean Validation (`@Valid`) on request DTOs; document constraints in OpenAPI.
5. **Errors**: Use existing exception hierarchy and global handler; return consistent error response shape (`code`, `message`, `details`, `traceId`).
6. **Docs**: Update API overview and endpoint docs if signature or behavior changes. Update `decisions.md` if there is an architectural choice.
7. **Tests**: Add or update `@WebMvcTest` (slice) or integration tests for new/changed endpoints. For external API calls, assert 200 and valid body where applicable (see external-api-test-strict-200 rule).

## Validation

- `./gradlew test` (or `.\scripts\run-tests.ps1`) passes.
- No new lint/compilation warnings.
- OpenAPI/Swagger reflects the change if public API changed.
- Sensitive data (tokens, keys, PII) not logged; use LogMaskingUtil if needed.

## Commit

- Type: `feat(api): ...` or `fix(api): ...` or `refactor(api): ...` as appropriate.
- No credentials or production config in commit.
- If behavior change, ensure CHANGELOG or task log updated as per project rules.
