# Skill: Database Change

**When to use**: Adding or changing schema, migrations, or repository usage in investment-backend (TimescaleDB/PostgreSQL).

## Procedure

1. **Scope**: Confirm whether change is schema (migration), query only, or repository/entity change. Do not perform manual DML on production; use migrations and application code.
2. **Migrations**: Use Flyway. Add new migration script under the project’s migration path; name consistently (e.g. `V{n}__description.sql`). Test migration up/down on a copy of schema if possible.
3. **Entities**: Update JPA entities to match schema; keep entities internal (not exposed at API boundary). Use DTOs for API.
4. **Repositories**: Prefer Spring Data JPA; avoid N+1; use paging and indexes for large data. Do not expose raw SQL in controller layer.
5. **Backup/rollback**: For destructive or data-changing migrations, document rollback steps and backup strategy. In production, changes go through approved deployment pipeline only.
6. **Docs**: Update schema or DB docs if structure or conventions change. Document any new env or config required.
7. **Tests**: Use H2 or test containers for integration tests if needed; do not rely on production DB for tests.

## Validation

- Migration runs successfully on a clean and on an already-migrated DB (if applicable).
- `./gradlew test` passes; no new repository/entity-related failures.
- No production credentials or connection strings in code or committed config.
- Rollback path documented for destructive changes.

## Commit

- Type: `feat(db): ...` or `refactor(db): ...`. Do not include production data or credentials.
- If migration is backward-incompatible, note in commit message and docs.
- TASK_LOG/CHANGELOG per hooks.
