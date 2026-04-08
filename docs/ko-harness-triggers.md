# 한글 프롬프트 → 스킬 · 에이전트 · 규칙 (빠른 매핑)

한국어로만 요청해도 아래 표를 근거로 적절한 harness를 고를 수 있게 정리했습니다. **결정론적 자동 실행은 아니며**, 모델 연상·`@` 참조용입니다. 일일 목록은 [`.cursor/ACTIVE_STACKS.md`](../.cursor/ACTIVE_STACKS.md)를 따릅니다.

| 한글로 말할 때 (예) | 문서/규칙 |
|---------------------|-----------|
| 운영 동선, 방향·점검 한 흐름, 읽기 예산 | `docs/program/00-operating-flow.md` |
| 작업 이력, files 남기기, progress | `docs/program/progress.md`, 규칙 `progress-log.md` |

## 스킬 (고빈도 · 의도별)

| 한글로 말할 때 (예) | 스킬 폴더 |
|---------------------|-----------|
| 먼저 검색, 라이브러리 있나, 기존 코드 찾아 | `.cursor/skills/search-first/` |
| TDD, 테스트 먼저, 커버리지 | `.cursor/skills/tdd-workflow/` |
| 스프링 테스트, JUnit, MockMvc | `.cursor/skills/springboot-tdd/` |
| 스프링 빌드 검증, PR 전 점검 | `.cursor/skills/springboot-verification/` |
| 스프링 구조, 레이어드 API | `.cursor/skills/springboot-patterns/` |
| 라이브러리 문서, Context7, 공식 API | `.cursor/skills/documentation-lookup/` |
| 모노레포, 서브모듈, run-all-tests | `.cursor/skills/auto-investment-project-patterns/` |
| E2E, Playwright | `.cursor/skills/e2e-testing/` |
| 릴리즈 전 검증 루프 | `.cursor/skills/verification-loop/` |
| 자바 스타일, Optional, 스트림 | `.cursor/skills/java-coding-standards/` |
| 프론트 패턴, React | `.cursor/skills/frontend-patterns/` |
| UI 디자인 퀄리티 | `.cursor/skills/frontend-design/` |
| REST API 설계 | `.cursor/skills/api-design/` |
| 퀀트·백테스트·리스크 (도메인) | 규칙 `quant-and-backtest.md` + 백엔드 docs |
| 한투 API, 모의투자, OAuth | 규칙 `korea-investment-api.md` |
| Python 서비스 | 규칙 `python-services.md` + `.cursor/skills/python-patterns/` |

## 에이전트 (일일 프리셋)

본문에 한국어 안내가 있는 8개: `planner`, `architect`, `code-architect`, `tdd-guide`, `java-reviewer`, `typescript-reviewer`, `security-reviewer`, `code-reviewer`. 나머지는 아래 표만 참고.

| 한글로 말할 때 (예) | 에이전트 파일 |
|---------------------|----------------|
| 단계 나눠, 큰 기능 계획, 마일스톤 | `.cursor/agents/planner.md` |
| 시스템 설계, 경계, 확장 | `.cursor/agents/architect.md` |
| 모듈/API 설계 상세 | `.cursor/agents/code-architect.md` |
| 테스트 먼저, TDD 코치 | `.cursor/agents/tdd-guide.md` |
| 스프링·백엔드 리뷰 | `.cursor/agents/java-reviewer.md` |
| 리액트·TS 리뷰 | `.cursor/agents/typescript-reviewer.md` |
| 보안, 시크릿, 인증 | `.cursor/agents/security-reviewer.md` |
| 방금 고친 코드 리뷰 | `.cursor/agents/code-reviewer.md` |
| 빌드 에러, 컴파일 실패 | `.cursor/agents/build-error-resolver.md` |
| Gradle/Java 빌드만 | `.cursor/agents/java-build-resolver.md` |
| DB, 스키마, 쿼리 | `.cursor/agents/database-reviewer.md` |
| E2E 실행·플레이wright | `.cursor/agents/e2e-runner.md` |
| Python 리뷰 | `.cursor/agents/python-reviewer.md` |
| 코드 탐색, 어디에 있지 | `.cursor/agents/code-explorer.md` |
| 문서·코드맵 갱신 | `.cursor/agents/doc-updater.md` |
| 데드코드, 정리 | `.cursor/agents/refactor-cleaner.md` |
| PR 테스트 품질 | `.cursor/agents/pr-test-analyzer.md` |
| 성능 | `.cursor/agents/performance-optimizer.md` |
| 침묵 실패, 삼킨 에러 | `.cursor/agents/silent-failure-hunter.md` |
| 주석 품질 | `.cursor/agents/comment-analyzer.md` |
| 단순화 | `.cursor/agents/code-simplifier.md` |
| 문서 검색 (Context7) | `.cursor/agents/docs-lookup.md` |

## 규칙 (경로별 자동 적용)

| 주제 | 규칙 파일 |
|------|-----------|
| Shrimp, QA 스크립트, CD | `ai-workflow-qa.md` |
| 보안·시크릿 | `security-baseline.md` |
| 개발 상태·문서 | `docs-and-quality.md` |
| 포트·로컬 실행 | `local-dev-hygiene.md` |
| 서브모듈·smart-portfolio-pal | `monorepo-boundaries.md` |
| 백엔드 Java | `java-backend.md` |
| 프론트 React/TS | `frontend-react-ts.md` |

전체 규칙: [`.cursor/rules/`](../.cursor/rules/), harness 개요: [`.cursor/CURSOR_HARNESS.md`](../.cursor/CURSOR_HARNESS.md).
