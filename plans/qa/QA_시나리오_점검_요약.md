# QA 시나리오 점검 요약

**작성일:** 2026-03-05  
**목적:** 각 QA 단계별 프로세스·시나리오 포함 여부 점검 및 태스크 단위 정리.

---

## 1. 전체 파이프라인 (run-full-qa.ps1)

| 단계 | 내용 | 스크립트/명령 | 프로세스 문서화 |
|------|------|----------------|-----------------|
| 1 | Backend JUnit | investment-backend\scripts\run-tests.ps1 | run-tests.ps1 주석, script-run-timeouts.mdc |
| 2 | API 시나리오 | scripts\run-api-qa.ps1 | QA_시나리오_마스터.md, 전체_QA_실행_가이드.md |
| 3 | Python 서비스 QA | scripts\run-python-qa.ps1 | 전체_QA_실행_가이드.md §4 |
| 4 | Python 단위 테스트 | py/python -m unittest discover (prediction-service) | README.md, run-full-qa.ps1 내 SKIP 조건 |
| 5 | Frontend E2E | investment-frontend npm run e2e | playwright.config.ts, 가이드 §2 |
| 6 | 보안 점검 | npm audit --audit-level=high | run-full-qa.ps1 |

**실패 루프:** qa-automation-flow.mdc에 5→6→7단계(원인 분석→수정·PR→재테스트) 정의. **단, 규칙에는 Python QA·Python 단위테스트가 명시되어 있지 않음** — run-full-qa.ps1은 6단계 포함.

---

## 2. QA-Backend (JUnit)

- **실행 프로세스:** run-tests.ps1 → gradlew test --no-daemon. 임시 빌드(agent-build-*) 사용 시 실행 후 삭제.
- **시나리오:** 단위/통합 테스트 전체(JUnit discover). 별도 “시나리오 목록” 문서 없음 — 소스 기준.
- **포함 여부:** 실행 순서·실패 시 로그(콘솔 출력)·타임아웃 권장(script-run-timeouts.mdc) 문서화됨.
- **점검 포인트:** run-tests.ps1와 03-test-execution.md 등 문서 일치, 실패 시 로그/경로 안내 존재 여부.

---

## 3. QA-API (run-api-qa.ps1)

- **프로세스:** 1) 로그인(POST /auth/login) → token 획득 2) Bearer로 시나리오 순차 호출 3) 상태코드·응답 본문(ResponseKeys) 검증.
- **시나리오 SSoT:** QA_시나리오_마스터.md (도메인별 엔드포인트).
- **점검 결과(2026-03-05):** run-api-qa.ps1이 마스터 §1~§22 대부분 반영함. 포함: auth(mypage, verify-account, mypage PUT, logout), settings GET/PUT, market-data(current-price, current-prices POST, daily-chart), accounts(balance, positions, buyable-amount, sellable-quantity, order-history, assets, profit-loss), user/accounts, dashboard/performance-summary, risk/summary·limits·portfolio-metrics·history, report/tax/summary·export, orders GET/POST, pipeline/summary, signals, strategies/comparison·{accountNo}, trading-portfolios(today, date, latest, rebalance-suggestions), backtest/robo/last-pre-execution, analysis POST·sector·correlation, macro(dashboard, indicators, regime, refresh), factor-zoo(factors, codes, rank), stress-test/scenarios, news·news/collect, system/kill-switch GET·PUT, ops(health, audit, governance/results·halts, alerts, model/status, data-pipeline/status), admin/users POST. **의도적 누락:** signup(별도 회원가입 플로우). api-qa.http는 로그인·mypage·verify-account·시장데이터·설정 등과 동기화되어 있으며, run-api-qa.ps1이 더 많은 시나리오를 자동 실행.
- **점검 포인트:** 마스터와 스크립트 시나리오 매핑, 필수 시나리오 선정·추가, api-qa.http와의 동기화.

---

## 4. QA-Python (run-python-qa.ps1)

- **프로세스:** data-collector(8001) / prediction-service(8000) HTTP 호출 → 상태코드·본문 키·커스텀 검증.
- **시나리오:**  
  - data-collector: GET /health → 200, status=ok  
  - prediction: GET / → 200 (service, version, status); GET /api/v1/health → 200 (status, service, timestamp); POST /api/v1/predict (단일); POST /api/v1/predict/batch (배열 2건).
- **점검 결과(2026-03-05):** 전체_QA_실행_가이드 §4와 run-python-qa.ps1 시나리오 1:1 대응 확인. 전제 조건(QA_DATA_COLLECTOR_URL, QA_PREDICTION_URL, 풀스택 기동) 가이드 §1·§4에 명시. 실패 시 스크립트가 exit 1·실패 건수 출력.
- **점검 포인트:** 가이드와 스크립트 시나리오 1:1 대응, 실패 시 로그/에러 메시지 안내.

---

## 5. QA-PythonTests (prediction-service unittest)

- **프로세스:** investment-prediction-service에서 `python -m unittest discover -s tests -p "test_*.py" -v` (또는 py). python 미설치(9009) 또는 ModuleNotFoundError 시 SKIP.
- **시나리오:** tests/test_preprocessing.py, test_api.py, test_lstm_model.py (실행 가능한 것만 실행, import 실패 시 해당 모듈 스킵).
- **점검 결과(2026-03-05):** run-full-qa.ps1 4단계와 README.md·discover 범위(-s tests -p test_*.py) 일치. SKIP 조건: 9009 → "python/py not in PATH", exit 1+ModuleNotFoundError → "Python deps missing". README에 Python 3.10~3.12 권장·스킵 설명 반영.
- **점검 포인트:** discover 범위·스킵 조건·문서와 run-full-qa.ps1 동기화.

---

## 6. QA-E2E (Playwright)

- **프로세스:** PLAYWRIGHT_BROWSERS_PATH=.playwright-browsers, npm run e2e. webServer로 프론트(5173) 기동, baseURL 5173, E2E_API_PORT로 백엔드(기본 8080) 연동.
- **시나리오(스펙):**  
  - landing.spec.ts: 랜딩 브랜드·메인 콘텐츠, 로그인 링크 이동  
  - login.spec.ts: 로그인 폼 로드, 빈 제출 시 유효성 메시지  
  - dashboard.spec.ts: (E2E_USERNAME/PASSWORD 필요) 로그인 후 대시보드 제목·메인 섹션, 자동투자 상세 링크  
  - onboarding.spec.ts: (동일 인증) 로그인 → 온보딩 퀴즈 3단계 → 원클릭 자동투자 시작 → 대시보드 3대 지표  
  - settings.spec.ts: (동일 인증) 로그인 후 설정 페이지·제목·초보자/중급자/고급 탭  
  - auto-invest.spec.ts: (동일 인증) 로그인 후 자동투자 현황 페이지·제목
- **포함 여부:** playwright.config.ts에 baseURL·webServer·실패 시 스크린샷·트레이스. 전체_QA_실행_가이드에는 “Frontend E2E (Playwright)” 단계만 명시, 스펙 목록은 없음.
- **점검 포인트:** E2E 스펙 목록·전제(E2E_USERNAME/PASSWORD)·실패 시 playwright-report/test-results 경로를 가이드에 명시 여부.

---

## 7. QA-Security (npm audit)

- **프로세스:** investment-frontend에서 npm audit --audit-level=high. exit 0이면 high 이상 없음.
- **시나리오:** 별도 시나리오 없음 — 의존성 취약점 검사.
- **점검 결과(2026-03-05):** run-full-qa.ps1 6단계에서 npm audit --audit-level=high 실행·실패 시 리포트에 출력. 실패 시 조치: npm update / npm audit fix 또는 package override; 상세는 통합 QA 리포트(plans/qa/reports/) 참조.
- **점검 포인트:** 실행 조건·실패 시 조치(업데이트/override) 안내 문서 유무.

---

## 8. 점검 태스크 등록 (Shrimp) — 등록 완료

아래 태스크가 Shrimp에 등록됨. 의존성 없이 병렬 점검 가능.

| # | 태스크 제목 | Shrimp Task ID | 점검 내용 |
|---|-------------|----------------|-----------|
| 1 | QA-Backend 시나리오 점검 | 4555455a-8ae5-40a7-8e1c-35d38b912446 | run-tests.ps1 실행 범위·프로세스·실패 로그 경로·문서 일치 |
| 2 | QA-API 시나리오 점검 | b6f2dd88-0bcc-41f3-8e85-8648fbf8e1d4 | QA_시나리오_마스터 vs run-api-qa.ps1 매핑, 누락 엔드포인트·api-qa.http 동기화 |
| 3 | QA-Python 시나리오 점검 | ab015f72-d06a-401a-821c-26a92523cf5b | run-python-qa.ps1 검사 항목과 전체_QA_실행_가이드 §4·프로세스 일치 |
| 4 | QA-PythonTests 시나리오 점검 | 73e95a1d-4f21-41af-ace6-049bab8c1c02 | unittest discover 범위·스킵 조건·README·run-full-qa.ps1 동기화 |
| 5 | QA-E2E 시나리오 점검 | 1f6124a6-a45c-4c51-a758-8d937072cabd | E2E 스펙 목록·전제·실패 시 리포트 경로 가이드 반영 |
| 6 | QA-Security 시나리오 점검 | 868f0d82-93c8-4ebe-8140-22bc0737e853 | npm audit 조건·실패 시 조치 안내 문서 |
| 7 | 전체 QA 파이프라인 점검 | 1ed426fe-893f-45cc-93e1-25250e757dfd | run-full-qa.ps1 6단계 순서·실패 루프·qa-automation-flow.mdc 동기화(Python 단계 명시) |

---

## 9. QA 시나리오 “모든 케이스” 추가 태스크 (Shrimp) — 등록 완료

QA_시나리오_마스터의 전체 엔드포인트/플로우를 run-api-qa.ps1·E2E·api-qa.http에 반영하기 위한 추가 태스크. 의존성 없이 병렬 진행 가능.

| # | 태스크 제목 | Shrimp Task ID | 대상 |
|---|-------------|----------------|------|
| 1 | API QA 시나리오 추가 — 인증·설정·시장데이터 | 9db01958-5fd2-48df-87e4-5f2af5c1eab4 | auth(verify-account, logout, mypage PUT), settings PUT, current-prices POST |
| 2 | API QA 시나리오 추가 — 계좌·리스크·리포트 | da1c39e8-2ae0-48fe-95c4-5c43b30ce0a5 | accounts/*, risk/portfolio-metrics·history, report/tax/export |
| 3 | API QA 시나리오 추가 — 주문·파이프라인·시그널 | b625f730-cb12-48b5-9bf3-c1196b962c0b | orders GET/POST(검증만), signals GET |
| 4 | API QA 시나리오 추가 — 전략·트레이딩·백테스트 | b5fe93c7-b40e-419d-96e0-ab1c070310c6 | strategies, trading-portfolios, backtest |
| 5 | API QA 시나리오 추가 — 분석·매크로·팩터·스트레스·뉴스 | 5f5a24b9-4f14-4571-bcae-9270da408920 | analysis, macro, factor-zoo, stress-test, news |
| 6 | API QA 시나리오 추가 — 시스템·Ops·관리자 | 4bd39982-3e49-47b8-bb5a-3e72d000ffa3 | kill-switch PUT, ops 나머지, admin |
| 7 | E2E 시나리오 추가 — 누락 플로우 | 849799e0-95da-4ce4-95f8-e3014f335dde | 설정·계좌·자동투자 상세 등 필수 플로우 |
