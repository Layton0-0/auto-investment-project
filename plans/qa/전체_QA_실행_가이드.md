# 전체 QA 실행 가이드 (Backend + API + Python + E2E + 보안)

**목적:** 파이썬 프로젝트 포함 전체 자동화 QA 실행 절차 및 응답 검증 범위 정리.

---

## 1. 전제 조건

- **로컬 풀스택**: `investment-infra/docker-compose.local-full.yml` 기동 (Backend 8080, data-collector 8001, prediction-service 8000, Frontend, Nginx 80).
- **API 시나리오**: 환경 변수 `QA_USERNAME`, `QA_PASSWORD` 설정 또는 `investment-backend/.env`에 `SUPER_ADMIN_USERNAME`, `SUPER_ADMIN_PASSWORD` 설정 (모의 계정 권장).
- **Python QA URL** (선택): `QA_DATA_COLLECTOR_URL`, `QA_PREDICTION_URL` 미설정 시 기본값 `http://localhost:8001`, `http://localhost:8000` 사용.
- **Python 단위 테스트**: `investment-prediction-service`에서 `pip install -r requirements.txt` 완료 (또는 venv 활성화 후).

### 1.1 QA-Prep 검증 (선택)

전체 QA 실행 전 환경이 준비되었는지 확인하려면:

```powershell
.\scripts\verify-qa-prep.ps1
```

- **검사 항목**: Backend 8080, data-collector 8001, prediction-service 8000 포트 응답, API 시나리오용 인증 정보(QA_USERNAME/QA_PASSWORD 또는 backend .env SUPER_ADMIN_*).
- 통과 시 exit 0, 실패 시 부족한 항목 안내 후 exit 1.

---

## 2. 실행 순서 (run-full-qa.ps1)

| 단계 | 내용 | 스킵 옵션 |
|------|------|------------|
| 1 | Backend (JUnit) | — |
| 2 | API 시나리오 (상태 코드 + **응답 본문 검증**) | `-SkipApiScenario` |
| 3 | **Python 서비스 QA** (data-collector, prediction-service) | `-SkipPythonQA` |
| 4 | **Python 단위 테스트** (prediction-service unittest) | `-SkipPythonTests` |
| 5 | Frontend E2E (Playwright) | `-SkipE2e` |
| 6 | 보안 점검 (npm audit) | `-SkipSecurity` |

**E2E 스펙:** `investment-frontend/e2e/` — landing.spec.ts(랜딩·로그인 링크), login.spec.ts(폼·유효성), dashboard.spec.ts(인증 후 대시보드·자동투자 링크), onboarding.spec.ts(로그인→퀴즈 3단계→원클릭 시작→대시보드), **settings.spec.ts**(인증 후 설정 페이지·제목·초보자/중급자/고급 탭), **auto-invest.spec.ts**(인증 후 자동투자 현황 페이지·제목). dashboard/onboarding/settings/auto-invest는 `E2E_USERNAME`, `E2E_PASSWORD` 필요. 실패 시 스크린샷·트레이스: `investment-frontend/playwright-report/`, `investment-frontend/test-results/`. 상세: [QA_시나리오_점검_요약.md](./QA_시나리오_점검_요약.md) §6.

---

## 3. API 시나리오 응답 검증 (run-api-qa.ps1)

- **로그인**: 응답에 `token` 필수, `userId` 또는 `username` 권장.
- **GET /api/v1/auth/mypage**: 200 시 본문에 `userId`, `username` 필수.
- **GET /api/v1/market-data/current-price/005930**: 200 시 `symbol` 필수.
- **GET /api/v1/market-data/daily-chart**: 200 시 **배열** 반환 검증.
- **GET /api/v1/ops/health**: 200 시 `db`, `lastCheckedAt` 필수.

그 외 엔드포인트는 **HTTP 상태 코드**만 검증 (200/400/404 등 시나리오별 허용 코드).

---

## 4. Python 서비스 QA (run-python-qa.ps1)

- **data-collector (8001)**  
  - GET /health → 200, 본문 `status` = `"ok"`.
- **prediction-service (8000)**  
  - GET / → 200, `service`, `version`, `status` = `"running"`.  
  - GET /api/v1/health → 200, `status` = `"ok"`, `service` = `"ai-prediction-service"`.  
  - POST /api/v1/predict (body: `{"symbol":"005930","predictionMinutes":60}`) → 200, 본문에 `symbol`, `currentPrice`, `predictedPrice`, `confidence`, `direction`, `modelType`, `predictionMinutes` 및 값 일치.  
  - POST /api/v1/predict/batch (2건 요청) → 200, **배열 길이 2**, 순서대로 symbol 005930, 000660.

---

## 5. 실행 예시

```powershell
# 풀스택 기동 후 (docker compose -f docker-compose.local-full.yml up -d)
$env:QA_USERNAME = "your_username"
$env:QA_PASSWORD = "your_password"
.\scripts\run-full-qa.ps1
```

- API만 스킵: `.\scripts\run-full-qa.ps1 -SkipApiScenario`
- Python QA만 스킵: `.\scripts\run-full-qa.ps1 -SkipPythonQA`
- Python 단위 테스트만 스킵: `.\scripts\run-full-qa.ps1 -SkipPythonTests`

---

## 6. 리포트

- 경로: `plans/qa/reports/YYYYMMDD-HHMM-qa-report.md`
- 실패 시 로그·의존성 안내(예: Python 테스트 실패 시 `pip install -r requirements.txt`) 포함.  
- 규칙: `.cursor/rules/qa-automation-flow.mdc`, `.cursor/rules/test-code-after-agent-by-plan.mdc`
