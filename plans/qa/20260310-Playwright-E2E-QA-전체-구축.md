# 자동투자 서비스 Playwright E2E QA 시스템 구축

- **일시**: 2026-03-10
- **목표**: 자동투자 서비스 전체에 대한 완전한 자동 QA 테스트 시스템 구축

## 1. 구성 요약

- **위치**: `investment-frontend/tests/`, `investment-frontend/playwright.config.ts`
- **실행**: `cd investment-frontend && npm run test:e2e` (또는 `test:e2e:ui`, `test:e2e:debug`, `test:e2e:report`)
- **환경 변수**: `E2E_USERNAME`, `E2E_PASSWORD` (로그인 필요 테스트), `E2E_API_PORT`, `E2E_BASE_URL`, `CI`

## 2. 테스트 구조

| 디렉터리 | 스펙 | 설명 |
|----------|------|------|
| tests/auth | login.spec.ts, logout.spec.ts | 로그인·로그아웃 |
| tests/dashboard | dashboard-load.spec.ts | 대시보드 로드 |
| tests/trading | trade-create, trade-execute, trade-cancel | 매매 생성/실행/취소 |
| tests/strategy | strategy-create, strategy-edit, strategy-delete | 전략 CRUD |
| tests/portfolio | portfolio-view.spec.ts | 포트폴리오 조회 |
| tests/system | navigation, all-buttons-click, console-error-check, api-error | 페이지 이동, 버튼 클릭, 콘솔/API 오류 |
| tests/full-flow | auto-invest-full-flow.spec.ts | 로그인→전략→실행→거래→포트폴리오→로그아웃 |

## 3. 공통 유틸 (tests/utils)

- **login.ts**: `login()`, `expectLoginPageVisible()` — 로그인 페이지 접속·입력·성공 확인
- **navigation.ts**: `ROUTES`, `goToDashboard`, `goToTrading`, `goToStrategyKr/US`, `goToPortfolio`, `goToAutoInvest`
- **error-checker.ts**: `checkConsoleErrors()`, `assertNoConsoleErrors()`, `saveLogsToFile()` — 콘솔 에러/경고 수집·저장
- **button-scanner.ts**: `scanAndClickAllButtons()`, `getFailedClicks()` — 전체 버튼 탐색·클릭·실패 로그

## 4. Playwright 설정

- **브라우저**: chromium, firefox, webkit
- **실패 시**: screenshot(only-on-failure), video(trace) retain-on-failure
- **리포트**: HTML(`test-results/html-report`), JUnit(`test-results/junit.xml`)
- **전역 설정**: `tests/global-setup.ts` — logs, test-results 디렉터리 생성

## 5. 로그·아티팩트

- **콘솔/API 로그**: `logs/` (에러 시 JSON 저장)
- **스크린샷/비디오/trace**: `test-results/artifacts/`

## 6. 환경별 실행

- **local**: 프론트 `npm run dev`, 백엔드 8080 가정 후 `npm run test:e2e`
- **docker**: Compose 기동 후 `E2E_BASE_URL` 등으로 URL 지정하여 동일 명령
- **CI**: `CI=true npm run test:e2e` (재시도 2회, 워커 1)

## 7. 참고

- 상세 실행 방법·환경 변수: `investment-frontend/tests/README.md`
- 기존 e2e: `investment-frontend/e2e/` (login.spec.ts, landing.spec.ts) 유지; 신규 스위트는 `tests/` 사용
