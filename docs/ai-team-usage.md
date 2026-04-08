# AI 팀 구조 사용법 (Pulsarve / auto-investment-project)

## 구조 요약

| 폴더/파일 | 역할 |
|-----------|------|
| **[`docs/program/00-operating-flow.md`](program/00-operating-flow.md)** | **단일 운영 동선** (방향→기록), 읽기 예산 Tier |
| **[`docs/program/progress.md`](program/progress.md)** | 세션별 파일 변경 미세 로그 (`.cursor/rules/progress-log.md`) |
| **[`docs/verification/README.md`](verification/README.md)** | 점검 허브 (`run-all-tests`, `run-full-qa` 등) |
| **[`.cursor/agents/*.md`](../.cursor/agents/)** | Cursor 에이전트 프리셋 (planner, architect, java-reviewer, tdd-guide 등). **일일 목록:** [`.cursor/ACTIVE_STACKS.md`](../.cursor/ACTIVE_STACKS.md) |
| **[`.cursor/AGENTS.md`](../.cursor/AGENTS.md)** | 이 레포에서 어떤 에이전트를 쓰는지·위임 힌트 |
| **[`.cursor/rules/ai-workflow-qa.md`](../.cursor/rules/ai-workflow-qa.md)** | **최우선** — AI 플로·테스트·CD·Shrimp·프로젝트 경계 |
| **[`.cursor/CURSOR_HARNESS.md`](../.cursor/CURSOR_HARNESS.md)** · **[`.cursor/hooks/README.md`](../.cursor/hooks/README.md)** | 스킬/훅 정책, 훅 id·프로파일 매트릭스 |
| **[`docs/ko-harness-triggers.md`](ko-harness-triggers.md)** | 한글만 쳐도 스킬·에이전트·규칙 연상용 표 (`@` 참고) |
| **`docs/ai-team/`** | 전략 자동 생성, 백테스트, 코드 리뷰 체크리스트, 실시간 시장 데이터 등 |
| **`tasks/`** | 작업 목록 (Shrimp 연동) |
| **테스트** | 실제 스위트는 각 서브모듈(`investment-backend`, `investment-frontend` 등) 내부 |
| **`scripts/run-all-tests.ps1`** | Backend + Frontend unit + E2E 통합 실행 (저장소 루트) |
| **`scripts/run-backtest.ps1`** | 백테스트 자동 실행 (Backend 8080 필요) |
| **[`ai-team.md`](../ai-team.md)** | 마스터 프롬프트·워크플로·역할(개념적 역할 vs `.cursor/agents` 매핑) |

루트에 **`agents/`** 폴더는 두지 않습니다. 예전 문서의 “agents/reviewer.md” 같은 경로는 **`.cursor/agents/`의 해당 프리셋 + 프로젝트 규칙**으로 대체합니다 (예: 리뷰 → `code-reviewer`, `security-reviewer` + `docs/ai-team/code-review-checklist.md`).

## Cursor에 지시하는 예

- *"Add a new trading strategy module. Strategy: RSI + moving average. Include: backend API, strategy calculation, backtesting, UI panel, tests."*
- *"Generate a new trading strategy and backtest it."*
- *"Analyze portfolio risk and suggest improvements."*

Cursor는 요청에 맞게 **planner**, **architect**, **tdd-guide**, **java-reviewer** / **typescript-reviewer** 등 [ACTIVE_STACKS](../.cursor/ACTIVE_STACKS.md)에 있는 프리셋을 조합하고, `run-all-tests.ps1` 또는 `run-full-qa.ps1`로 검증하는 흐름을 따릅니다.

## 완전 자동 개발 루프

```
request → task breakdown (Shrimp) → design → code → test generation → test run → fix → review
```

## 적용된 자동화 (구현 완료)

1. **Strategy 자동 생성 AI** — `docs/ai-team/strategy-auto-generation.md`: 설계·구현·백테스트 플로우. 사용 예: "RSI+MA 전략 추가해줘".
2. **백테스트 자동 실행** — `scripts/run-backtest.ps1`: 기간·시장·전략타입·초기자본으로 POST /api/v1/backtest 호출. CI/스케줄에서 사용.
3. **AI 코드 리뷰** — `.cursor/agents/code-reviewer.md`, `security-reviewer.md` 및 프로젝트 규칙. 상세: `docs/ai-team/code-review-checklist.md`.
4. **실시간 시장 데이터** — `docs/ai-team/realtime-market-data-agent.md` 등 (도메인 가이드). 전용 단일 `.md` 에이전트 파일이 없을 수 있으므로 문서와 백엔드 서비스 코드를 기준으로 합니다.

## 다음 단계 (선택)

- **Pulsarve 전용 AI 아키텍처** 확장 (전략 템플릿 코드 생성, Discord 시장 요약 배치 등).
