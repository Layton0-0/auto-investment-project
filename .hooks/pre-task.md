# Pre-Task Hook — Safety Checks Before Starting Work

Use this as a checklist before beginning a task. These are safety checks, not automation replacements.

## 1. Task scope

- [ ] Task is clearly defined (from Shrimp, plan, or ticket).
- [ ] Completion criteria are known (what “done” looks like).
- [ ] Scope is bounded (no open-ended “improve X” without a concrete outcome).

## 2. Refactor vs feature separation

- [ ] This task is either **refactoring only** (no behavior change) or **feature/fix only** (behavior change). Not both in one task unless explicitly scoped.
- [ ] If refactoring: behavior preservation is the goal; tests must stay green.
- [ ] If feature/fix: required behavior and acceptance criteria are documented or agreed.

## 3. Clarity of goal

- [ ] You can state in one sentence what will be delivered at the end of this task.
- [ ] Dependencies (other tasks, PRs, or environment) are identified; blocked tasks are marked blocked, not in progress.

## 4. Environment (if applicable)

- [ ] If backend run is needed: know whether you will use Docker Compose (8080) or local bootRun (8084). If 8084, plan to stop the process when done (agent-cleanup).
- [ ] If DB or external API is needed: use test/dev config only; no production credentials.

---

*Proceed only when the above are satisfied. If in doubt, narrow the scope or split the task.*
