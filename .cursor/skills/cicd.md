# Skill: CI/CD

**When to use**: Changing GitHub Actions workflows, build steps, or deployment configuration (investment-backend, investment-frontend, investment-infra, or other subprojects).

## Procedure

1. **Scope**: Identify which repo or workflow is affected (e.g. `.github/workflows/ci.yml` in backend/frontend, or `cd.yml` in infra). Do not mix unrelated jobs in one change.
2. **Secrets**: Never log or commit secrets. Use GitHub Secrets (e.g. `GITHUB_TOKEN`, `GITHUB_PERSONAL_ACCESS_TOKEN`) or env vars; reference with `${{ secrets.NAME }}`. Use placeholders in docs.
3. **Build**: Backend: JDK 17; Gradle test and bootJar. Frontend: npm install, build, test. Python: install deps and run tests if defined. Keep cache usage consistent (e.g. Gradle cache).
4. **Artifacts**: Backend pushes Docker image to GHCR; tags include sha and latest. Do not overwrite production tags from feature branches unless by design.
5. **Tests**: CI must run tests; no skip unless justified and documented. Backend tests with `./gradlew test --no-daemon`; frontend with npm test; E2E in CI if configured.
6. **Deployment**: Infra CD workflow; document manual steps or approvals if any. No production credentials in repo.
7. **Docs**: Update runbooks or README if CI steps or required secrets change.

## Validation

- Workflow runs in branch; all steps pass.  
- No secrets in logs or in committed workflow files.  
- Build and test steps match local expectations (same Java/npm versions, same test commands where applicable).  
- Image tags and registries are correct and documented.

## Commit

- Type: `ci: ...` or `chore(ci): ...`.  
- Do not add or commit real tokens or production URLs.  
- TASK_LOG/CHANGELOG per hooks if required.
