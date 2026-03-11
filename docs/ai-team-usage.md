# AI 팀 구조 사용법 (Pulsarve)

## 구조 요약

| 폴더/파일 | 역할 |
|-----------|------|
| **agents/** | AI 역할 정의 (planner, architect, backend-dev, frontend-dev, qa, fix, reviewer, deploy, strategy, risk, **market-data-analyst**) |
| **.cursor/rules/ai-team-primary.mdc** | **최우선** 적용 — Custom Instructions 포함, AI 팀 플로우 우선 |
| **.cursor/rules/ai-team-workflow.mdc** | AI 팀 루프·테스트 명령·역할별 규칙 참조 |
| **docs/ai-team/** | 전략 자동 생성, 백테스트 자동 실행, 코드 리뷰 체크리스트, 실시간 시장 데이터 Agent |
| **tasks/** | 작업 목록 (Shrimp 연동) |
| **tests/api**, **tests/strategy**, **tests/e2e** | 테스트 분류(실제 테스트는 각 서브프로젝트 내부) |
| **scripts/run-all-tests.ps1** | Backend + Frontend unit + E2E 통합 실행 |
| **scripts/run-backtest.ps1** | 백테스트 자동 실행 (Backend 8080 필요) |
| **ai-team.md** | 마스터 프롬프트·워크플로우·규칙 |

## Cursor에 지시하는 예

- *"Add a new trading strategy module. Strategy: RSI + moving average. Include: backend API, strategy calculation, backtesting, UI panel, tests."*
- *"Generate a new trading strategy and backtest it."*
- *"Analyze portfolio risk and suggest improvements."*

Cursor는 Planner → Architect → Developer → QA → Fix → Review 단계를 수행하고, `run-all-tests.ps1` 또는 `run-full-qa.ps1`로 검증 후 완료한다.

## 완전 자동 개발 루프

```
request → task breakdown (Shrimp) → design → code → test generation → test run → fix → review
```

## 적용된 자동화 (구현 완료)

1. **Strategy 자동 생성 AI** — docs/ai-team/strategy-auto-generation.md: Planner → Architect → Strategy Analyst → Backend → QA → 백테스트 플로우. 사용 예: "RSI+MA 전략 추가해줘".
2. **백테스트 자동 실행** — scripts/run-backtest.ps1: 기간·시장·전략타입·초기자본으로 POST /api/v1/backtest 호출. CI/스케줄에서 사용.
3. **AI 코드 리뷰** — agents/reviewer.md에 Applicable project rules + Code review checklist. 상세: docs/ai-team/code-review-checklist.md.
4. **실시간 시장 데이터 Agent** — agents/market-data-analyst.md, docs/ai-team/realtime-market-data-agent.md. RealtimeMarketDataService·WebSocket 연동 요약·알림 시나리오.

## 다음 단계 (선택)

- **Pulsarve 전용 AI 아키텍처** 확장 (전략 템플릿 코드 생성, Discord 시장 요약 배치 등).
