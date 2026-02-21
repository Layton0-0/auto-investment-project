# 백엔드-프론트엔드 API 매핑 문서

**작성일:** 2026-02-21  
**목적:** Backend 엔드포인트와 Frontend `api/*.ts` 호출 경로 대조, 적재적소 사용 검증 및 불일치 목록 산출.

---

## 1. 매핑 테이블 (Frontend 사용 API)

| Method | Frontend Path | Backend Path | Frontend 사용처 |
|--------|---------------|--------------|-----------------|
| POST | /api/v1/auth/login | AuthController POST /api/v1/auth/login | authApi.login, LoginPage |
| POST | /api/v1/auth/signup | AuthController POST /api/v1/auth/signup | authApi.signup, RegisterPage |
| POST | /api/v1/auth/verify-account | AuthController POST /api/v1/auth/verify-account | authApi.verifyAccount, RegisterPage |
| GET | /api/v1/auth/mypage | AuthController GET /api/v1/auth/mypage | authApi.getMyPage, MyPage, AuthContext, AppRoutes.test |
| PUT | /api/v1/auth/mypage | AuthController PUT /api/v1/auth/mypage | authApi.updateMyPage, MyPage |
| POST | /api/v1/auth/logout | AuthController POST /api/v1/auth/logout | authApi.logout, AuthContext |
| GET | /api/v1/user/accounts/main | UserAccountController GET /api/v1/user/accounts/main | userAccountsApi.getMainAccount, useDashboardData, Market, Investment, System |
| GET | /api/v1/user/accounts | UserAccountController GET /api/v1/user/accounts | userAccountsApi.getUserAccounts |
| GET | /api/v1/user/accounts/{id} | UserAccountController GET /api/v1/user/accounts/{accountId} | userAccountsApi.getAccount |
| PUT | /api/v1/user/accounts/{id}/main | UserAccountController PUT /api/v1/user/accounts/{accountId}/main | userAccountsApi.setMainAccount |
| GET | /api/v1/settings/accounts | SettingController GET /api/v1/settings/accounts | settingsApi.getSettingsAccounts, useSettingsAccounts, System |
| PUT | /api/v1/settings/accounts | SettingController PUT /api/v1/settings/accounts | settingsApi.updateSettingsAccounts, useSettingsAccounts |
| GET | /api/v1/settings/{accountNo} | SettingController GET /api/v1/settings/{accountNo} | settingsApi.getSettingByAccountNo, useDashboardData |
| PUT | /api/v1/settings/{accountNo} | SettingController PUT /api/v1/settings/{accountNo} | settingsApi.updateSetting |
| GET | /api/v1/accounts/{accountNo}/assets | AccountController GET /api/v1/accounts/{accountNo}/assets | accountApi.getAccountAssets, useDashboardData |
| GET | /api/v1/accounts/{accountNo}/positions | AccountController GET /api/v1/accounts/{accountNo}/positions | accountApi.getPositions, useDashboardData |
| GET | /api/v1/accounts/{accountNo}/balance | AccountController GET /api/v1/accounts/{accountNo}/balance | accountApi.getBalance |
| GET | /api/v1/accounts/{accountNo}/buyable-amount | AccountController GET /api/v1/accounts/{accountNo}/buyable-amount | accountApi.getBuyableAmount |
| GET | /api/v1/accounts/{accountNo}/sellable-quantity | AccountController GET /api/v1/accounts/{accountNo}/sellable-quantity | accountApi.getSellableQuantity |
| GET | /api/v1/accounts/{accountNo}/order-history | AccountController GET /api/v1/accounts/{accountNo}/order-history | accountApi.getOrderHistory |
| GET | /api/v1/accounts/{accountNo}/profit-loss | AccountController GET /api/v1/accounts/{accountNo}/profit-loss | accountApi.getProfitLoss |
| GET | /api/v1/orders?accountNo= | OrderController GET /api/v1/orders | ordersApi.getOrders, useDashboardData, Market |
| GET | /api/v1/orders/{orderId} | OrderController GET /api/v1/orders/{orderId} | ordersApi.getOrder |
| POST | /api/v1/orders | OrderController POST /api/v1/orders | ordersApi.placeOrder, Market |
| DELETE | /api/v1/orders/{orderId} | OrderController DELETE /api/v1/orders/{orderId} | ordersApi.cancelOrder, Market |
| GET | /api/v1/pipeline/summary | PipelineController GET /api/v1/pipeline/summary | pipelineApi.getPipelineSummary, useDashboardData, Investment |
| GET | /api/v1/dashboard/performance-summary | DashboardController GET /api/v1/dashboard/performance-summary | dashboardApi.getPerformanceSummary, useDashboardData |
| GET | /api/v1/report/tax/summary | TaxReportController GET /api/v1/report/tax/summary | reportApi.getTaxSummary, TaxReportPage |
| GET | /api/v1/report/tax/summary/export | TaxReportController GET /api/v1/report/tax/summary/export | reportApi.downloadTaxSummaryExport (window.open), TaxReportPage |
| GET | /api/v1/risk/summary | RiskReportController GET /api/v1/risk/summary | riskApi.getRiskSummary, Ops |
| GET | /api/v1/risk/limits | RiskReportController GET /api/v1/risk/limits | riskApi.getRiskLimits, Ops |
| GET | /api/v1/risk/history | RiskReportController GET /api/v1/risk/history | riskApi.getRiskHistory, Ops |
| GET | /api/v1/risk/portfolio-metrics | RiskReportController GET /api/v1/risk/portfolio-metrics | riskApi.getPortfolioRiskMetrics, Market |
| GET | /api/v1/ops/data-pipeline/status | OpsDataPipelineController GET /api/v1/ops/data-pipeline/status | opsApi.getDataPipelineStatus, Ops |
| GET | /api/v1/ops/alerts | OpsAlertsController GET /api/v1/ops/alerts | opsApi.getAlerts, Ops |
| GET | /api/v1/ops/audit | OpsAuditController GET /api/v1/ops/audit | opsApi.getAuditLogs, Ops |
| GET | /api/v1/ops/model/status | OpsModelController GET /api/v1/ops/model/status | opsApi.getModelStatus, Ops |
| GET | /api/v1/ops/health | OpsHealthController GET /api/v1/ops/health | opsApi.getHealth, Ops |
| GET | /api/v1/ops/governance/results | OpsGovernanceController GET /api/v1/ops/governance/results | opsApi.getGovernanceResults, Ops |
| GET | /api/v1/ops/governance/halts | OpsGovernanceController GET /api/v1/ops/governance/halts | opsApi.getGovernanceHalts, Ops |
| PUT | /api/v1/ops/governance/halts/{m}/{t}/clear | OpsGovernanceController PUT .../clear | opsApi.clearGovernanceHalt, Ops |
| GET | /batch/api/jobs | BatchManagementController GET /batch/api/jobs | batchApi.getBatchJobs, Ops (nginx /batch → backend) |
| POST | /api/v1/trigger/{path} | TriggerController POST /api/v1/trigger/{path} | triggerApi.trigger, Ops |
| GET | /api/v1/trading-portfolios/today | TradingPortfolioController GET /api/v1/trading-portfolios/today | tradingPortfolioApi.getTodayPortfolio, Market, System |
| GET | /api/v1/trading-portfolios/date/{date} | TradingPortfolioController GET /api/v1/trading-portfolios/date/{date} | tradingPortfolioApi.getPortfolioByDate |
| GET | /api/v1/trading-portfolios/latest | TradingPortfolioController GET /api/v1/trading-portfolios/latest | tradingPortfolioApi.getLatestPortfolios, Market, System |
| POST | /api/v1/trading-portfolios/generate | TradingPortfolioController POST /api/v1/trading-portfolios/generate | tradingPortfolioApi.generatePortfolio |
| GET | /api/v1/trading-portfolios/rebalance-suggestions | TradingPortfolioController GET .../rebalance-suggestions | tradingPortfolioApi.getRebalanceSuggestions, Market, System |
| GET | /api/v1/strategies/{accountNo} | StrategyApiController GET /api/v1/strategies/{accountNo} | strategyApi.getStrategies, Investment |
| GET | /api/v1/strategies/{accountNo}/{type} | StrategyApiController GET /api/v1/strategies/{accountNo}/{strategyType} | strategyApi.getStrategy |
| POST | /api/v1/strategies | StrategyApiController POST /api/v1/strategies | strategyApi.createOrUpdateStrategy |
| PUT | /api/v1/strategies/.../status | StrategyApiController PUT .../status | strategyApi.updateStrategyStatus |
| POST | /api/v1/strategies/.../activate | StrategyApiController POST .../activate | strategyApi.activateStrategy |
| POST | /api/v1/strategies/.../stop | StrategyApiController POST .../stop | strategyApi.stopStrategy |
| GET | /api/v1/signals | SignalController GET /api/v1/signals | signalsApi.getSignals, Investment |
| GET | /api/v1/market-data/current-price/{symbol} | MarketDataController GET /api/v1/market-data/current-price/{symbol} | marketDataApi.getCurrentPrice, Market |
| POST | /api/v1/market-data/current-prices | MarketDataController POST /api/v1/market-data/current-prices | marketDataApi.getCurrentPrices |
| GET | /api/v1/market-data/daily-chart | MarketDataController GET /api/v1/market-data/daily-chart | marketDataApi.getDailyChart, PriceChart |
| GET | /api/v1/news | NewsController GET /api/v1/news | newsApi.getNews, Market |
| POST | /api/v1/news/collect | NewsController POST /api/v1/news/collect | newsApi.collectNews, Market |
| POST | /api/v1/analysis | AnalysisController POST /api/v1/analysis | analysisApi.analyze, Market |
| GET | /api/v1/analysis/sector | AnalysisController GET /api/v1/analysis/sector | analysisApi.getSectorAnalysis, Market |
| GET | /api/v1/analysis/correlation | AnalysisController GET /api/v1/analysis/correlation | analysisApi.getCorrelationAnalysis, Market |
| POST | /api/v1/backtest | BacktestController POST /api/v1/backtest | backtestApi.runBacktest, System |
| POST | /api/v1/backtest/robo | BacktestController POST /api/v1/backtest/robo | backtestApi.runRoboBacktest, System |
| GET | /api/v1/backtest/robo/last-pre-execution | BacktestController GET .../last-pre-execution | backtestApi.getLastPreExecution, System |
| POST | /api/v1/backtest/robo/collect-us-daily | BacktestController POST .../collect-us-daily | backtestApi.collectUsDaily, System |

---

## 2. 불일치: Frontend 호출 but Backend 없음

- **없음.** 위 매핑 테이블 기준으로 프론트엔드 `api/*.ts`에서 호출하는 모든 경로에 대응하는 백엔드 엔드포인트가 존재함.
- **참고:** `/batch/api/jobs`는 Backend `BatchManagementController`가 `/batch` + `/api/jobs`로 노출. nginx에서 `location /batch`로 backend:8080 프록시 필요 (이미 반영됨).

---

## 3. 불일치: Backend만 있고 Frontend 미사용 (예비/Admin/외부)

| Backend Path | 용도 |
|--------------|------|
| GET /api/v1/batch/jobs | BatchController (API prefix). 프론트는 /batch/api/jobs 사용하므로 이 경로는 미사용. |
| GET/PUT /api/v1/system/kill-switch | KillSwitchController. 대시보드 TODO에서 연동 예정, 현재 프론트 api 미정의. |
| POST /api/v1/tca/* | TcaController (estimate, analyze, round-trip, market-impact). 프론트 미호출. |
| POST/GET /api/v1/stress-test/* | StressTestController. 프론트 미호출. |
| GET/POST /api/v1/macro/* | MacroController. 프론트 미호출. |
| GET/POST /api/v1/factor-zoo/* | FactorZooController. 프론트 미호출. |
| POST/GET /api/v1/algo-orders/* | AlgorithmicOrderController. 프론트 미호출. |
| POST /api/v1/admin/users | AdminUserController. Admin 전용, 프론트에서 별도 화면/API 레이어로 호출 가능. |
| GET /api/v1/market-data/ping | MarketDataController. 헬스/핑, 프론트 미호출. |

---

## 4. 수정 이력

| 일자 | 내용 |
|------|------|
| 2026-02-21 | 최초 작성. 매핑 테이블 및 불일치 목록 산출. |
| 2026-02-21 | 태스크2 검증: 프론트 호출 경로에 대응하는 백엔드 엔드포인트 모두 존재 확인. 누락·경로 불일치 없음. Backend-only API는 문서만 유지. |
| 2026-02-21 | 태스크3 검증: Docker 로컬 풀스택 기동 후 로그인·mypage·settings/accounts·dashboard/performance-summary·batch/api/jobs·ops/health·risk/summary 호출 200 확인. |
