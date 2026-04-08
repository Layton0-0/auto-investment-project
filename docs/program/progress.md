# Program progress log

운영·에이전트 **미세 작업 이력** (제품 백로그는 [investment-backend/docs/09-planning/02-development-status.md](../../investment-backend/docs/09-planning/02-development-status.md)).

## Tier 0 — 읽는 법 (옵션 B)

- 신규 항목은 **항상 파일 끝**의 Session log에만 추가한다.
- 맥락 파악 시 **마지막 ~60줄**(또는 마지막 `### YYYY-MM-DD` 블록부터 끝까지)만 읽는다.
- 롤업: [archive/README.md](archive/README.md), 스크립트 `scripts/rollup-progress.ps1`.

## 규칙 요약

- 저장소 **파일을 변경한 턴**마다 아래 포맷으로 **한 줄** 추가 (`files` 필수).
- **질문만** / **로컬 재기동만** / **쓰기 없음** → 생략 가능.
- 항목 본문은 **300자 이하** 권장. 7일 지난 항목·300자 초과는 롤업 대상.

## 마이그레이션·과거 이력

- [progress-migration-2026-Q1.md](archive/progress-migration-2026-Q1.md) — 이전에 흩어져 있던 요약·인덱스.

---

## Session log (rollup processes below)

### 2026-04-08

- [12:00] cursor-agent | files: docs/program/**, docs/verification/README.md, docs/08_status/README.md, docs/09-planning/repo-status-and-next-tasks.md, docs/09-planning/README.md, docs/04_process/development_workflow.md, docs/ai-team-usage.md, docs/ko-harness-triggers.md, .cursor/rules/progress-log.md, .cursor/AGENTS.md, .hooks/post-task.md, ai-team.md, shrimp-rules.md, CLAUDE.md, scripts/rollup-progress.ps1, agents/planner.md, plans/qa/20260226-1600_*.md, plans/dashboard/20260305-1200_*.md | scope: 단일 흐름 스파인·progress·verification·보관/색인·rollup·강제 규칙·입구 문서·repo-status 단일화·깨진 dev-status 링크 수정 | verify: rollup-progress.ps1 -WhatIf | refs: plan
- [18:00] cursor-agent | files: CLAUDE.md, .cursor/rules/claude-md-scope.md, docs/program/00-operating-flow.md, docs/program/progress.md, docs/verification/README.md | scope: CLAUDE 헌법 문안(How to work, repo tree, Tier3 docs), claude-md-scope 봉인, verification CD 링크, 스파인 migration 링크 및 Follow-ups 절, progress 로그 | verify: — | refs: plan claude.md 개편 및 후속
- [19:30] cursor-agent | files: .cursor/rules/claude-bootstrap.md, .cursor/AGENTS.md, docs/program/progress.md | scope: 필수 CLAUDE 읽기 플랜 — claude-bootstrap.md(alwaysApply), AGENTS.md 선행 읽기 문단 | verify: — | refs: plan 필수 CLAUDE.md 읽기
