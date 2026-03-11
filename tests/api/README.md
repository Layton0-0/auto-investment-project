# API 테스트 (루트 tests/api)

이 폴더는 **AI 팀 테스트 구조**의 API 테스트 분류용입니다.

- **실제 Spring API 테스트** 위치: `investment-backend/src/test/` (JUnit, @WebMvcTest, 통합 테스트)
- **API 시나리오(QA)** 정의: `plans/qa/QA_시나리오_마스터.md`, `plans/qa/api-qa.http`
- 실행: `.\scripts\run-full-qa.ps1` 또는 `investment-backend`에서 `.\gradlew test`

Cursor QA Agent는 위 위치에 테스트를 생성·유지합니다.
