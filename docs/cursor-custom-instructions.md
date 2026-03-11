# Cursor Custom Instructions 설정

**프로젝트 규칙에 이미 반영됨**: `.cursor/rules/ai-team-primary.mdc`에 아래 지시가 포함되어 있어, 이 프로젝트를 열면 **자동으로 AI 팀 워크플로우가 최우선** 적용됩니다. (별도 설정 없이 동작)

원하면 **Settings → Custom Instructions**에 아래 내용을 추가해 전역으로도 적용할 수 있습니다.

## 추가할 내용 (복사용)

```
Always follow ai-team.md workflow.

Use the agent roles defined in /agents.

Never skip test generation.

Always run tests before finishing a task.
```

## 설명

| 문구 | 목적 |
|------|------|
| Always follow ai-team.md workflow | 요청 → 명세 → 설계 → 구현 → 테스트 → 수정 → 리뷰 흐름 준수 |
| Use the agent roles defined in /agents | Planner, Architect, Backend/Frontend Dev, QA, Fix, Reviewer 등 역할 파일 참조 |
| Never skip test generation | 기능/수정 시 테스트 코드 작성 생략 금지 |
| Always run tests before finishing a task | 작업 마무리 전 run-all-tests 또는 run-full-qa 실행 필수 |

프로젝트 루트의 **.cursor/rules/ai-team-workflow.mdc** 도 함께 적용되므로, 규칙과 Custom Instructions가 함께 동작합니다.
