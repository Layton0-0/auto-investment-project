# Verification hub (점검 한 화면)

**언제:** API/계약·크로스모듈·릴리즈 전·PR 마무리. 상세 체크리스트는 링크만 열고, 이 페이지는 **명령과 경로**만 유지한다.

## 통합 스크립트 (저장소 루트)

| 상황 | 명령 (PowerShell, 루트) |
|------|-------------------------|
| 백엔드+프론트 단위+E2E | `.\scripts\run-all-tests.ps1` |
| 풀 QA (백엔드·API·Python·E2E·보안 등) | `.\scripts\run-full-qa.ps1` — 타임아웃 여유 `.cursor/rules/local-dev-hygiene.md` 참고 |
| API 시나리오만 | `.\scripts\run-api-qa.ps1` |
| 백테스트 (백엔드 8080 가동 시) | `.\scripts\run-backtest.ps1` |

## 체크리스트·시나리오 (필요 시만)

- [plans/qa/](../plans/qa/) — E2E·데이터 파이프라인·배포 검증 등
- [docs/ai-team/code-review-checklist.md](../ai-team/code-review-checklist.md)
- 백엔드 API 매핑: `investment-backend/docs/04-api/11-api-frontend-mapping.md`

## CD·인프라

- Shrimp·태스크 라이프사이클·infra 푸시 후 CD 확인: [ai-workflow-qa](../../.cursor/rules/ai-workflow-qa.md)
- 로컬 풀스택: `investment-infra/scripts/local-up.ps1`

## 운영 동선

- 전체 흐름: [docs/program/00-operating-flow.md](../program/00-operating-flow.md) — Verify 단계는 **이 허브만** 링크한다.
