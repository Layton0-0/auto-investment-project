# 퀀트트레이더 시스템 QA 시나리오 마스터

**작성일:** 2026-02-21  
**갱신일:** 2026-03-10  
**목적:** 전체 API·시나리오 목록 정의. run-api-qa.ps1 SSoT. 실제 주문·얼마인지(매수가능금액·자산 등)·취소가능주문·TCA·알고리즘 주문 포함.

---

## [엄격 규칙] 타시스템 연동 구간

**타시스템(한국투자증권·시세 API 등)에 API를 쏘는 모든 테스트는 상대한테로부터 200을 받아야 한다.**

- 해당 시나리오는 **Expected = 200 만 허용**. 4xx/5xx 시 **FAIL**.
- 대상: `auth/verify-account`, `market-data/*`(시세/차트), `accounts/{accountNo}/*`(한국투자증권), `orders` POST·cancel-all-pending(한국투자증권 주문).
- 백엔드 통합/단위 테스트에서 실제 타시스템을 호출하는 경우에도, 상대 응답이 성공(200/정상 body)일 때만 통과하도록 단언.

---

## 1. 인증 (auth) — login/signup 인증 불필요, 나머지 Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/auth/signup | 201 | body: username, password, brokerType, appKey, appSecret 등 |
| POST | /api/v1/auth/verify-account | **200** | 회원가입 전 계좌인증 (타시스템 KIS → 200만 허용) |
| POST | /api/v1/auth/login | 200 | body: username, password → token |
| GET | /api/v1/auth/mypage | 200 | Bearer |
| PUT | /api/v1/auth/mypage | 200 | Bearer |
| POST | /api/v1/auth/logout | 200 | Bearer (마지막 실행) |

---

## 2. 설정 (settings) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/settings/accounts | 200 | 모의·실 계좌 블록 |
| PUT | /api/v1/settings/accounts | 200 | body 필요 |
| GET | /api/v1/settings/{accountNo} | 200, 400, 404 | 404=설정 없음 |
| PUT | /api/v1/settings/{accountNo} | 200 | TradingSettingDto |
| POST | /api/v1/settings/quick-start | 200, 400 | QuickStartRequestDto(accountNo, maxInvestmentAmount) |

---

## 3. 시장데이터 (market-data) — Bearer (타시스템 연동 → 200만 허용)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/market-data/ping | 200 | 연결 확인 |
| GET | /api/v1/market-data/current-price/{symbol} | **200** | 예: 005930 |
| POST | /api/v1/market-data/current-prices | 200 | body: ["005930",...] |
| GET | /api/v1/market-data/daily-chart?symbol=005930&market=KR | 200 | TB_DAILY_STOCK 기반 |
| GET | /api/v1/market-data/symbols/search?q=005930&market=KR | 200 | 종목 통합 검색 |

---

## 4. 계좌 (accounts) — Bearer, accountNo 필수 (타시스템: 한국투자증권 → 200만 허용)

**잔고·포지션·얼마인지(매수가능·매도가능)·주문체결·취소가능주문·자산·해외요약·기간손익·실현손익·손익현황**

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/accounts/{accountNo}/balance | **200** | 잔고 |
| GET | /api/v1/accounts/{accountNo}/positions | **200** | 보유 종목 (market 선택 가능) |
| GET | /api/v1/accounts/{accountNo}/positions?market=KR | **200** | 국내만 |
| GET | /api/v1/accounts/{accountNo}/buyable-amount?symbol=005930&price=50000 | **200** | **매수가능 금액·수량(얼마인지)** |
| GET | /api/v1/accounts/{accountNo}/sellable-quantity?symbol=005930 | **200** | 매도가능 수량 |
| GET | /api/v1/accounts/{accountNo}/order-history?startDate=...&endDate=... | **200** | 주문 체결 조회 |
| GET | /api/v1/accounts/{accountNo}/cancelable-orders | **200** | 미체결(정정·취소 가능) 주문 |
| GET | /api/v1/accounts/{accountNo}/assets | **200** | **자산 현황(얼마인지)** |
| GET | /api/v1/accounts/{accountNo}/overseas-summary | **200** | 해외(미국) 계좌 요약 |
| GET | /api/v1/accounts/{accountNo}/profit-loss?startDate=...&endDate=... | **200** | 기간별 손익 |
| GET | /api/v1/accounts/{accountNo}/balance-rlz-pl | **200** | 실현손익 |
| GET | /api/v1/accounts/{accountNo}/profit-loss-status?startDate=...&endDate=... | **200** | 기간별 매매손익 현황 |

---

## 5. 사용자 계좌 (user/accounts) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/user/accounts | 200 | 본인 계좌 목록 |
| GET | /api/v1/user/accounts/main | 200, 404 | 대표 계좌 |
| GET | /api/v1/user/accounts/{accountId} | 200, 404 | 계좌 단건 (숫자 ID) |
| PUT | /api/v1/user/accounts/{accountId}/main | 200, 404 | 대표 계좌 지정 |

---

## 6. 대시보드 (dashboard) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/dashboard/performance-summary | 200, 404 | 성과 요약 |

---

## 7. 리스크 (risk) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/risk/summary | 200 | |
| GET | /api/v1/risk/attribution | 200 | 리스크 기여도 |
| GET | /api/v1/risk/limits | 200 | |
| GET | /api/v1/risk/portfolio-metrics?accountNo=xxx | 200, 404 | |
| GET | /api/v1/risk/history?from=...&to=... | 200 | |

---

## 8. 세금리포트 (report/tax) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/report/tax/summary | 200 | query: year 등 |
| GET | /api/v1/report/tax/summary/export | 200, 404 | CSV 등 |

---

## 9. 주문 (orders) — Bearer, **실제 주문·취소·미체결전체취소 포함** (타시스템 KIS 주문 → 200만 허용)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/orders?accountNo=xxx | 200 | 주문 목록 |
| **POST** | **/api/v1/orders** | **200** | **실제 주문 실행** (타시스템 KIS → 200만 허용) |
| GET | /api/v1/orders/{orderId}?accountNo=xxx | 200, 404 | 주문 단건 조회 |
| DELETE | /api/v1/orders/{orderId}?accountNo=xxx | 204, 404 | 주문 취소 |
| POST | /api/v1/orders/cancel-all-pending?accountNo=xxx | **200** | 미체결 전체 취소 (타시스템 KIS) |

---

## 10. 파이프라인 (pipeline) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/pipeline/summary?accountNo=xxx | 200 | accountNo 필수 |

---

## 11. 시그널 (signals) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/signals | 200 | |

---

## 12. 전략 (strategies) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/strategies/comparison | 200 | |
| GET | /api/v1/strategies/{accountNo} | 200, 404 | |
| GET | /api/v1/strategies/{accountNo}/{strategyType} | 200, 404 | SHORT_TERM 등 |
| POST | /api/v1/strategies | 200, 400 | StrategyDto |
| PUT | /api/v1/strategies/{accountNo}/{strategyType}/status | 200, 404 | StrategyStatusUpdateDto |
| POST | /api/v1/strategies/{accountNo}/{strategyType}/activate | 200, 404 | |
| POST | /api/v1/strategies/{accountNo}/{strategyType}/stop | 200, 404 | |

---

## 13. 트레이딩 포트폴리오 (trading-portfolios) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/trading-portfolios/today | 200 | |
| GET | /api/v1/trading-portfolios/date/{date} | 200, 400, 404 | |
| GET | /api/v1/trading-portfolios/latest | 200 | |
| POST | /api/v1/trading-portfolios/generate | 200, 500 | ?date= (선택) |
| GET | /api/v1/trading-portfolios/rebalance-suggestions?accountNo=xxx&market=US | 200 | |

---

## 14. 백테스트 (backtest) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/backtest | 200, 400 | BacktestRunRequest |
| POST | /api/v1/backtest/walk-forward | 200, 400 | WalkForwardBacktestRequest |
| POST | /api/v1/backtest/robo | 200, 400 | RoboBacktestRequest |
| GET | /api/v1/backtest/robo/last-pre-execution?accountNo=xxx | 200, 204 | |
| POST | /api/v1/backtest/robo/collect-us-daily | 200 | body 선택 |

---

## 15. 분석 (analysis) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/analysis | 200, 400 | body |
| GET | /api/v1/analysis/sector | 200 | |
| GET | /api/v1/analysis/correlation | 200 | |

---

## 16. 매크로 (macro) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/macro/dashboard | 200 | |
| GET | /api/v1/macro/indicators | 200 | |
| GET | /api/v1/macro/indicators/{code} | 200, 404 | 예: GDP |
| GET | /api/v1/macro/indicators/{code}/history | 200, 404 | |
| GET | /api/v1/macro/regime | 200 | |
| POST | /api/v1/macro/refresh | 200 | |

---

## 17. 팩터줌 (factor-zoo) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/factor-zoo/factors | 200 | |
| GET | /api/v1/factor-zoo/codes | 200 | |
| GET | /api/v1/factor-zoo/test/{factorCode} | 200, 404 | |
| GET | /api/v1/factor-zoo/factors/{factorCode} | 200, 404 | |
| GET | /api/v1/factor-zoo/factors/category/{category} | 200, 400 | VALUE, MOMENTUM 등 |
| GET | /api/v1/factor-zoo/rank?market=KR&startDate=...&endDate=... | 200 | |
| POST | /api/v1/factor-zoo/combined-score | 200, 400 | CombinedScoreRequest |
| POST | /api/v1/factor-zoo/rank-stocks | 200, 400 | StockRankingRequest |

---

## 18. TCA (Transaction Cost Analysis) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/tca/estimate | 200, 400 | 사전 비용 예측 |
| POST | /api/v1/tca/analyze | 200, 400 | 사후 비용 분석 |
| GET | /api/v1/tca/round-trip?market=KR&assetType=STOCK&notional=...&quantity=... | 200 | 왕복 거래 비용 |
| GET | /api/v1/tca/market-impact?orderQuantity=...&avgDailyVolume=... | 200 | 시장 충격 비용 |

---

## 19. 알고리즘 주문 (algo-orders) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/algo-orders/execute | 200, 400 | TWAP/VWAP/POV 실행 |
| GET | /api/v1/algo-orders/{executionId} | 200, 404 | 진행 상태 |
| POST | /api/v1/algo-orders/{executionId}/cancel | 200, 404 | 취소 |
| POST | /api/v1/algo-orders/{executionId}/resume | 200, 404 | 재개 |
| GET | /api/v1/algo-orders/active | 200 | 활성 주문 목록 |
| GET | /api/v1/algo-orders/algorithms | 200 | 지원 알고리즘 목록 |
| POST | /api/v1/algo-orders/preview | 200, 400 | 슬라이스 계획 미리보기 |

---

## 20. 스트레스테스트 (stress-test) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/stress-test/scenarios | 200 | |
| GET | /api/v1/stress-test/scenarios/{scenarioCode} | 200, 404 | |
| POST | /api/v1/stress-test/run/{scenarioCode} | 200 | body: StressTestRequest(positions) |
| POST | /api/v1/stress-test/run/all | 200 | body: StressTestRequest |
| POST | /api/v1/stress-test/run/custom | 200, 400 | CustomStressTestRequest |

---

## 21. 배치 (batch) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/batch/jobs | 200 | |

---

## 22. 뉴스 (news) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/news | 200 | |
| POST | /api/v1/news/collect | 200, 500, 504 | |

---

## 23. 시스템 (kill-switch) — Bearer

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/system/kill-switch | 200 | |
| PUT | /api/v1/system/kill-switch | 200, 403 | body: enabled |

---

## 24. Ops — Bearer (health 등 ADMIN/403 가능)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| GET | /api/v1/ops/health | 200 | DB·Redis 등 (ADMIN 시 200) |
| GET | /api/v1/ops/auto-trading-readiness | 200, 403, 404 | 미구현 시 404 |
| GET | /api/v1/system/settings | 200, 403, 404 | 미구현 시 404 |
| GET | /api/v1/ops/audit | 200, 403 | |
| GET | /api/v1/ops/governance/results | 200, 403 | |
| GET | /api/v1/ops/governance/halts | 200, 403 | |
| PUT | /api/v1/ops/governance/halts/{market}/{strategyType}/clear | 204, 403 | noContent |
| GET | /api/v1/ops/alerts | 200, 403 | |
| GET | /api/v1/ops/model/status | 200, 403 | |
| GET | /api/v1/ops/data-pipeline/status | 200, 403 | |

---

## 25. 트리거 (trigger) — Bearer, cron/내부용 샘플

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/trigger/discord-test | 200, 403, 404 | 샘플 1건 |

---

## 26. 관리자 (admin) — Bearer (Admin 역할)

| 메서드 | 경로 | 예상 | 비고 |
|--------|------|------|------|
| POST | /api/v1/admin/users | 201, 400, 403 | Admin 전용 |

---

## 실행 순서 (run-api-qa.ps1)

1. 로그인 → 인증·설정·시장데이터·계좌(잔고·얼마인지·자산·취소가능주문 등)·사용자계좌  
2. 대시보드·리스크·세금리포트  
3. **주문(목록·실제 주문 POST·단건·취소·미체결전체취소)**·파이프라인·시그널  
4. 전략·트레이딩포트폴리오·백테스트·분석·매크로·팩터줌·TCA·알고리즘주문  
5. 스트레스테스트·배치·뉴스·시스템·Ops·트리거·관리자  
6. 로그아웃 (마지막)

---

## SSoT

- **스크립트:** `scripts/run-api-qa.ps1` — 위 표와 동일한 시나리오를 순차 호출.  
- **환경:** QA_BASE_URL, QA_USERNAME, QA_PASSWORD, QA_ACCOUNT_NO (또는 investment-backend\.env 의 SUPER_ADMIN_*·계좌번호).  
- **판정:** 각 요청의 HTTP 상태코드가 Expected 목록에 있으면 PASS. 500은 FAIL.

---

## Known issues (사전 정리)

- **GET /api/v1/market-data/daily-chart** — 데이터 없으면 200+[].
- **GET /api/v1/ops/auto-trading-readiness**, **GET /api/v1/system/settings** — 미구현 시 404 허용.
