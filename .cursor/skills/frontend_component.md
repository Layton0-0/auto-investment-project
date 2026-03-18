# Skill: Frontend Component (React)

**When to use**: Adding or changing React components, pages, or UI flows in investment-frontend.

## Procedure

1. **Scope**: Confirm task (feature vs refactor). Identify feature area (e.g. dashboard, settings, Ops).
2. **Structure**: Place component under appropriate folder (`components/`, `pages/`, or feature-specific). Single responsibility; file name matches component name.
3. **API**: Do not put API call logic inside presentational components. Use hooks or `api/` layer; handle loading, success, error states explicitly.
4. **Types**: Use TypeScript; no `any`. Define or reuse types in `types/` or next to the feature.
5. **Styling**: Use Tailwind and existing design tokens; prefer CVA/clsx for variants. Do not commit inline secrets or env-specific URLs.
6. **Accessibility**: Follow existing patterns; ensure interactive elements are focusable and labeled where applicable.
7. **Tests**: Add or update unit tests (Vitest + Testing Library) for logic/hooks; add or update E2E (Playwright) for critical user flows if needed.
8. **Docs**: If the change affects UX or contract with backend, update feature/docs as needed.

## Validation

- `npm run build` and `npm run test` pass in investment-frontend.
- For UI changes that affect E2E flows: run `npm run e2e` (or project E2E script) and fix failures.
- No sensitive data or tokens in client bundle or committed files.
- Lint passes.

## Commit

- Type: `feat(ui): ...`, `fix(ui): ...`, or `refactor(ui): ...`.
- No credentials or production-only config in commit.
- Update TASK_LOG/CHANGELOG if required by hooks.
