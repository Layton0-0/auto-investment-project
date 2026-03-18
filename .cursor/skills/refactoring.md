# Skill: Refactoring

**When to use**: Restructuring code, renaming, extracting modules, or improving dependencies without changing observable behavior.

## Procedure

1. **Separate from features**: Do not add new behavior in the same task/PR as refactoring. One refactor scope per task.
2. **Define scope**: Clearly state what is being refactored (e.g. “extract service X”, “rename package Y”, “move DTOs to api boundary”). Document intended boundaries.
3. **Preserve behavior**: No change to API contracts, return values, or side effects unless that is an explicit part of the refactor (and then document).
4. **Small steps**: Prefer small, reviewable steps. Each step should leave the system in a passing state.
5. **Tests first**: Ensure existing tests pass before refactor; use them as safety net. Add or adjust tests only to reflect intended behavior, not to “make refactor pass.”
6. **Dependency direction**: Respect inward dependency rule (domain does not depend on delivery or infrastructure). Do not introduce new outward dependencies from domain.
7. **Docs**: Update package/module docs or ADRs if structure or boundaries change. Update project_memory or architecture summary if module responsibilities change.

## Validation

- Full test suite passes (`.\scripts\run-tests.ps1` for backend; frontend tests and E2E as applicable).
- No new public API surface unless explicitly scoped.
- Lint and build pass.
- Behavior preservation: same inputs produce same outputs (or documented intentional change).

## Commit

- Type: `refactor(scope): description`. Do not mix with `feat` or `fix` in the same commit unless explicitly scoped.
- No credentials or production config.
- TASK_LOG/CHANGELOG updated per hooks if required.
