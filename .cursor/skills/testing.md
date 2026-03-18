# Skill: Testing

**When to use**: Adding or updating unit, slice, integration, or E2E tests in backend or frontend.

## Procedure

1. **Backend (Spring Boot)**  
   - **Unit**: Test service logic with mocks; use JUnit 5 and Mockito.  
   - **Slice**: Use `@WebMvcTest`, `@DataJpaTest`, etc., to test controller or repository in isolation.  
   - **Integration**: Use `@SpringBootTest` with H2 or test profile; avoid external services unless required (then use strict 200 rule for external API tests).  
   - **Coverage**: JaCoCo line ≥80%, branch ≥70%; respect exclusions (config, DTOs, entities, enums as configured).  
   - **Naming**: Clear test method names that describe scenario and expected outcome.

2. **Frontend**  
   - **Unit**: Vitest + Testing Library for components and hooks; test behavior, not implementation details.  
   - **E2E**: Playwright for critical flows; run via `npm run e2e` in investment-frontend.  
   - **API contract**: If tests call real backend or external API, expect 200 and valid response shape; do not treat 4xx/5xx as success (see external-api-test-strict-200).

3. **External APIs**: Tests that hit Korea Investment API or other external systems must assert on 200 and valid body where applicable; document env (e.g. test account) and do not commit secrets.

4. **No mock data outside tests**: Do not introduce mock/fake data in production code paths; keep test data in test sources only (see no-mock-data-outside-tests rule).

## Validation

- Backend: `.\scripts\run-tests.ps1` or `./gradlew test` passes; coverage meets project thresholds.  
- Frontend: `npm run test` and, when relevant, `npm run e2e` pass.  
- No flaky tests; no committed credentials or production URLs in test code.  
- Test run is deterministic where possible (no reliance on unconstrained randomness or time unless explicitly tested).

## Commit

- Type: `test(scope): ...` or include test changes in the same commit as the feature/fix they cover.  
- Do not commit test code that is disabled or that expects failures without a ticket/task reference.  
- TASK_LOG/CHANGELOG per hooks.
