# 자동투자 화면~백엔드 E2E 검증 체크리스트

**목적**: 다음주 월요일 실계좌 사용 준비를 위해, 화면부터 백엔드까지 전체 프로세스를 하나씩 검증·수정·재검증할 때 사용하는 단일 체크리스트.

**기준 문서**: [QA_시나리오_마스터.md](./QA_시나리오_마스터.md), [11-api-frontend-mapping.md](../../investment-backend/docs/04-api/11-api-frontend-mapping.md), [13-manual-operator-tasks.md §1.11](../../investment-backend/docs/06-deployment/13-manual-operator-tasks.md).

**원칙**: mock 데이터는 테스트 코드 외 사용 금지. 데이터 없으면 원인 분석·수동 트리거·env 점검으로 해소.

---

## 1. 검증 흐름 (순서)

| 순서 | 단계 | 화면/동작 | 호출 API | 예상 | 비고 |
|------|------|-----------|----------|------|------|
| 1 | 로그인 | `/login` | POST /api/v1/auth/login | 200, token | |
| 2 | 설정(계좌) | `/settings` | GET /api/v1/settings/accounts | 200 | 모의·실 블록 |
| 3 | 설정(거래·자동매매 ON) | `/settings` | GET/PUT /api/v1/settings/{accountNo} | 200 | autoTradingEnabled, pipelineAutoExecute 등 |
| 4 | 대시보드 | `/` 또는 `/dashboard` | GET /api/v1/user/accounts/main, GET /api/v1/accounts/{accountNo}/assets, /positions, GET /api/v1/orders, GET /api/v1/pipeline/summary, GET /api/v1/settings/{accountNo}, GET /api/v1/dashboard/performance-summary | 200 또는 계좌 없음 시 graceful | |
| 5 | 자동투자 현황 | `/auto-invest` | getMainAccount, getPipelineSummary, getSignals, getStrategies | 200 | 시그널 0건 시 §3 점검 |
| 6 | 파이프라인 요약 | (대시/자동투자) | GET /api/v1/pipeline/summary?accountNo=... (basDt 선택) | 200 | basDt 미입력 시 전일 |
| 7 | Ops 준비상태 | `/ops/settings` 또는 Batch | GET /api/v1/ops/auto-trading-readiness | 200 (ADMIN) | dailyStockRowCount, signalScoreRowCount 등 |
| 8 | Ops 시스템 설정 | `/ops/settings` | GET /api/v1/system/settings, PUT /api/v1/system/settings | 200 (ADMIN) | pipeline.autoExecute, marketData.websocketEnabled 등 |

---

## 2. API·화면 매핑 누락 점검

- **GET /api/v1/system/settings**: Ops 시스템 설정 화면 (`SystemSettingsView`) — 연동 완료.
- **PUT /api/v1/system/settings**: 동일 — body `{ key, value }`.
- **GET /api/v1/ops/auto-trading-readiness**: Ops/Batch 또는 자동매매 가동 전 점검 — opsApi.getAutoTradingReadiness 연동 가능(11-api-frontend-mapping §2).
- **GET /api/v1/pipeline/summary**: accountNo 쿼리 필수. basDt 미입력 시 백엔드 전일 기준.

---

## 3. 데이터 부재(시그널 0건) 시 점검 순서

1. **파이프라인 요약 기준일**: 전일 basDt로 pipeline/summary 확인.
2. **준비 상태**: GET /api/v1/ops/auto-trading-readiness → dailyStockRowCount, signalScoreRowCount 확인.
3. **수동 트리거**: 0이면 순서대로 POST /api/v1/trigger/krx-daily, us-daily, factor-calculation 실행 후 재확인.
4. **원인**: KRX_AUTH_KEY·한투 폴백 env, 13-manual-operator-tasks §1.11 참조.

**상세**: [데이터_부재_점검_가이드.md](./데이터_부재_점검_가이드.md) — 점검 순서·원인 분석·데이터 생성 절차. 검증 스크립트: `plans/qa/scripts/verify-data-pipeline.ps1`.

---

## 4. 검증 실패 시 기록

| 항목 | 결과 | 원인·수정 포인트 |
|------|------|------------------|
| Phase A-2 백엔드 테스트 (gradlew test) | OK | 2026-03-06 |
| Phase A-2 API QA 62건 (run-api-qa.ps1) | OK (조건: Backend 기동, QA_USERNAME/QA_PASSWORD 또는 .env SUPER_ADMIN_*) | Docker: 8080. **IntelliJ 개발 시**: `$env:QA_BASE_URL="http://localhost:8084"; .\scripts\run-api-qa.ps1` |
| 로그인~설정~대시~자동투자~파이프라인~Ops | OK | 동일 스크립트로 검증 |

---

## 5. Docker local·배포 연계

- **로컬 검증**: `investment-infra/scripts/local-up.ps1` → compose up → backend/nginx 로그 tail로 기동·batch 스케줄·health 확인. 상세: [로컬_Docker_재배포_로그_검증_체크리스트.md](./로컬_Docker_재배포_로그_검증_체크리스트.md) (C-1/C-2).
- **배포**: 동일 세팅으로 배포용 compose·env 적용, SSH로 .env 세팅 후 기동·헬스 확인. 상세: [배포_Docker_동일_세팅_가이드.md](./배포_Docker_동일_세팅_가이드.md) (D-1/D-2).
