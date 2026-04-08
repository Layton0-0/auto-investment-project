# Operating flow (스파인)

**목표:** 방향 → 계획 → 실행 → 점검 → 기록을 **한 줄기**로 두고, 링크는 **허브 1홉**만 넘기지 않는다. 제품 진실(API·스키마·전략)은 `investment-backend/docs/` 에 있다.

## 읽기 예산 (Tier)

| Tier | 읽을 것 | 링크 정책 |
|------|---------|-----------|
| **0** | [progress.md](progress.md) **끝쪽 Session log ~60줄** + 이 파일 **다음 절 한 줄 요약** | 여기서 스파인만 연다 |
| **1** | **이 문서 전체**(2~3분) | 단계마다 허브 **최대 1개** |
| **2** | [verification/README.md](../verification/README.md), [08_status/README.md](../08_status/README.md) | 허브는 명령·경로 위주; 상세는 "필요 시"만 |
| **3** | `investment-backend/docs/**` | 스파인에서 제품 문서 **직링크 금지** — 작업 티켓·허브 경유 |

## 5단계 (한 줄 요약 + 허브)

1. **Direction** — 비전·요구·리스크 원칙: [roadmap.md](../../investment-backend/docs/roadmap.md), [PRD](../../investment-backend/docs/PRD.md) (있을 때), 규칙 `.cursor/rules/quant-and-backtest.md` 등. *(허브: 백엔드 기획 트리.)*
2. **Plan** — 백로그·진행: **[02-development-status.md](../../investment-backend/docs/09-planning/02-development-status.md)** 단일 원천. 실행 플랜·날짜 문서는 `investment-backend/docs/09-planning/plans/` · 루트 `plans/`.
3. **Execute** — 구현: Shrimp·태스크, [development_workflow.md](../04_process/development_workflow.md), 역할·에이전트 [ai-team.md](../../ai-team.md).
4. **Verify** — 검증: **[verification/README.md](../verification/README.md)** 한 화면만 연다 (`run-all-tests` / `run-full-qa`, QA 체크리스트 링크).
5. **Record** — 큰 단위: `02-development-status.md` 갱신. **미세 이력:** [progress.md](progress.md) Session log에 `files`·`scope` 한 줄. 롤업·아카이브: [archive/README.md](archive/README.md).

## 퀀트·전략 파이프라인만 해당할 때

- **한 링크만:** [ai-quant-development/00-index.md](../ai-quant-development/00-index.md) — 위 5단계와 병행하지 않고 대체 플로가 아니라 **도메인 보조**다.

## 빠른 링크

| 무엇을 | 어디 |
|--------|------|
| 최근에 무슨 작업했나 | [progress.md](progress.md) Session log 끝 |
| 무엇을 검증하나 | [verification/README.md](../verification/README.md) |
| 상태·로드맵 허브 | [08_status/README.md](../08_status/README.md) |
| Cursor 에이전트 목록 | [.cursor/AGENTS.md](../../.cursor/AGENTS.md) |
| progress 이전 분산 이력 인덱스 | [archive/progress-migration-2026-Q1.md](archive/progress-migration-2026-Q1.md) |

## Follow-ups (CLAUDE.md에 반복 반영하지 않음)

아래는 **이 스파인** 또는 [archive/README.md](archive/README.md)에만 유지한다. 루트 `CLAUDE.md`를 후속 작업 목록으로 부풀리지 않는다.

- `rollup-progress.ps1` — `pre-commit` 또는 주간 CI 연결
- `docs/program/archive/INDEX.md` — 사람용 색인 (선택)
- `progress-index.jsonl` — 과거 항목 백필 정책 결정
- 루트 `docs/09-planning` → cross-cutting 등 폴더 rename (2차, 링크 일괄 갱신)
- CLAUDE **전면** 대법전화(규칙 흡수) — 별도 설계 (`claude-constitution-followup`)
