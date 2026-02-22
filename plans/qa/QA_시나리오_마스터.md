# 퀀트트레이더 시스템 QA 시나리오 마스터

**작성일:** 2026-02-21  
**목적:** 전체 API·시나리오 목록 정의. 태스크별 실행·오류 수정·재QA 기준.

---

## 1. 인증 (auth) — 인증 불필요(login/signup), 나머지 Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/auth/signup | 201 | body: username, password, brokerType, appKey, appSecret 등 |
| POST | /api/v1/auth/verify-account | 200 | 회원가입 전 계좌인증 |
| POST | /api/v1/auth/login | 200 | body: username, password → token |
| GET | /api/v1/auth/mypage | 200 | Bearer |
| PUT | /api/v1/auth/mypage | 200 | Bearer |
| POST | /api/v1/auth/logout | 200 | Bearer |

---

## 2. 설정 (settings) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/settings/accounts | 200 | 모의·실 계좌 블록 |
| PUT | /api/v1/settings/accounts | 200 | body 필요 |
| GET | /api/v1/settings/{accountNo} | 200 또는 404 | 404=설정 없음(기본값 폼 표시 후 PUT 저장) |
| PUT | /api/v1/settings/{accountNo} | 200 | TradingSettingDto |

---

## 3. 시장데이터 (market-data) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/market-data/current-price/{symbol} | 200 | 예: 005930 |
| POST | /api/v1/market-data/current-prices | 200 | body: ["005930",...] |
| GET | /api/v1/market-data/daily-chart?symbol=005930&market=KR | 200 | TB_DAILY_STOCK 기반, 데이터 없으면 200+[] |

---

## 4. 계좌 (accounts) — Bearer, accountNo 필요

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/accounts/{accountNo}/balance | 200 | 404 계좌 없음 |
| GET | /api/v1/accounts/{accountNo}/positions | 200 | 404 |
| GET | /api/v1/accounts/{accountNo}/buyable | 200 | query: symbol 등 |
| GET | /api/v1/accounts/{accountNo}/sellable | 200 | query: symbol 등 |
| GET | /api/v1/accounts/{accountNo}/orders | 200 | 404 |
| GET | /api/v1/accounts/{accountNo}/asset | 200 | 404 |
| GET | /api/v1/accounts/{accountNo}/profit-loss | 200 | query: start, end |

---

## 5. 사용자 계좌 (user/accounts) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/user/accounts | 200 | 본인 계좌 목록 |

---

## 6. 대시보드 (dashboard) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/dashboard/performance-summary | 200 | 404/빈 데이터 가능 |

---

## 7. 리스크 (risk) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/risk/summary | 200 | PreAuthorize |
| GET | /api/v1/risk/limits | 200 | |
| GET | /api/v1/risk/portfolio-metrics | 200 또는 404 | query: accountNo |
| GET | /api/v1/risk/history | 200 | query: from, to (optional) |

---

## 8. 세금리포트 (report/tax) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/report/tax/summary | 200 | query: year 등 |
| GET | /api/v1/report/tax/summary/export | 200 | CSV 등 |

---

## 9. 주문 (orders) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/orders | 200/400/403 | OrderRequestDto (실거래 주의) |
| GET | /api/v1/orders?accountNo=xxx | 200 | |
| GET | /api/v1/orders/{orderId}?accountNo=xxx | 200/404 | |
| DELETE | /api/v1/orders/{orderId}?accountNo=xxx | 204 | |

---

## 10. 파이프라인 (pipeline) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/pipeline/summary?accountNo={accountNo} | 200 | accountNo 필수, basDt 선택 |

---

## 11. 시그널 (signals) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/signals/* | 200 | Controller 경로 확인 후 추가 |

---

## 12. 전략 (strategies) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/strategies/* | 200 | 목록·상세 등 |

---

## 13. 트레이딩 포트폴리오 (trading-portfolios) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/trading-portfolios/today | 200 | query: accountNo |
| GET | /api/v1/trading-portfolios/date/{date} | 200 | |
| GET | /api/v1/trading-portfolios/latest | 200 | |
| POST | /api/v1/trading-portfolios/generate | 200/201 | body |
| GET | /api/v1/trading-portfolios/rebalance-suggestions | 200 | query: accountNo, market |

---

## 14. 백테스트 (backtest) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/backtest | 200/201 | body |
| POST | /api/v1/backtest/walk-forward | 200 | |
| POST | /api/v1/backtest/robo | 200 | |
| GET | /api/v1/backtest/robo/last-pre-execution | 200 | |
| POST | /api/v1/backtest/robo/collect-us-daily | 200 | |

---

## 15. 분석 (analysis) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/analysis | 200 | body |
| GET | /api/v1/analysis/sector | 200 | |
| GET | /api/v1/analysis/correlation | 200 | |

---

## 16. 매크로 (macro) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/macro/dashboard | 200 | |
| GET | /api/v1/macro/indicators/{code} | 200 | |
| GET | /api/v1/macro/indicators/{code}/history | 200 | |
| GET | /api/v1/macro/regime | 200 | |
| GET | /api/v1/macro/indicators | 200 | |
| POST | /api/v1/macro/refresh | 200 | |

---

## 17. 팩터줌 (factor-zoo) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/factor-zoo/test/{factorCode} | 200 | |
| GET | /api/v1/factor-zoo/rank | 200 | |
| POST | /api/v1/factor-zoo/combined-score | 200 | |
| POST | /api/v1/factor-zoo/rank-stocks | 200 | |
| GET | /api/v1/factor-zoo/factors | 200 | |
| GET | /api/v1/factor-zoo/factors/{factorCode} | 200 | |
| GET | /api/v1/factor-zoo/factors/category/{category} | 200 | |
| GET | /api/v1/factor-zoo/codes | 200 | |

---

## 18. 스트레스테스트 (stress-test) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/stress-test/run/{scenarioCode} | 200 | |
| POST | /api/v1/stress-test/run/all | 200 | |
| POST | /api/v1/stress-test/run/custom | 200 | |
| GET | /api/v1/stress-test/scenarios | 200 | |
| GET | /api/v1/stress-test/scenarios/{code} | 200 | |

---

## 19. 뉴스 (news) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/news | 200 | |
| POST | /api/v1/news/collect | 200 | |

---

## 20. 시스템 (kill-switch) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/system/kill-switch | 200 | |
| PUT | /api/v1/system/kill-switch | 200 | body |

---

## 21. Ops — Bearer (health는 공개 가능)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/ops/health | 200 | 인증 제외 가능 |
| GET | /api/v1/ops/audit | 200 | |
| GET | /api/v1/ops/governance/results | 200 | |
| GET | /api/v1/ops/governance/halts | 200 | |
| PUT | /api/v1/ops/governance/halts/{market}/{strategyType}/clear | 200 | |
| GET | /api/v1/ops/alerts | 200 | |
| GET | /api/v1/ops/model/status | 200 | |
| GET | /api/v1/ops/data-pipeline/status | 200 | |

---

## 22. 관리자 (admin) — Bearer (Admin 역할)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/admin/users | 201/403 | Admin 전용 |

---

## 실행 순서 (태스크 그룹)

1. **인증·설정** — login → mypage, settings/accounts, settings/{accountNo}, logout  
2. **시장데이터·계좌** — current-price, current-prices, accounts, user/accounts  
3. **대시보드·리스크·리포트** — dashboard, risk/*, report/tax/*  
4. **주문·파이프라인·시그널** — orders GET, pipeline, signals  
5. **트레이딩·백테스트·전략** — trading-portfolios, backtest GET, strategies  
6. **Ops·시스템·기타** — ops/*, system/kill-switch, macro, factor-zoo, news  

---

## Known issues (사전 정리)

- **GET /api/v1/market-data/daily-chart** — 404. 백엔드 미구현. 프론트 호출 시 404 처리 또는 API 추가 필요.
