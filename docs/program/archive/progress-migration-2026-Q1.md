# Progress / 작업 이력 마이그레이션 인덱스 (2026 Q1)

계획 **이전**에는 미세 작업 이력이 한 파일에 모이지 않았다. 아래를 **원본·권위**로 두고, **신규**는 [../progress.md](../progress.md) Session log만 사용한다.

| 원본 유형 | 위치 | 비고 |
|-----------|------|------|
| 제품 완료·백로그·변경 이력 | [investment-backend/docs/09-planning/02-development-status.md](../../../investment-backend/docs/09-planning/02-development-status.md) | 특히 **문서 변경 이력** 절 |
| 저장소 요약·다음 작업 (구) | Git history: `docs/09-planning/repo-status-and-next-tasks.md` (본 계획 적용 이전 커밋) | 중복 제거 후 단일 원천은 development-status |
| 워크플로 TASK_LOG | [docs/04_process/development_workflow.md](../../04_process/development_workflow.md) Record 절에서 언급 (루트 `TASK_LOG.md`는 미사용) | 앞으로는 `progress.md`로 대체 |
| QA·검증 플랜 | [plans/qa/](../../plans/qa/) | 체크리스트·스크립트 |

색인층 `progress-index.jsonl`은 **롤업 이후**부터 채워진다. 과거 항목을 JSONL로 백필할지는 선택이다.
