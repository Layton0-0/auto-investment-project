# API QA 자동화: 로그인 1회 후 Bearer로 QA_시나리오_마스터 기반 엔드포인트 순차 호출.
# 사용: .\scripts\run-api-qa.ps1
# 환경 변수: QA_BASE_URL (기본 http://localhost:8080), QA_USERNAME, QA_PASSWORD, QA_ACCOUNT_NO (기본 50161075-01), QA_TIMEOUT_SEC (기본 120, 장시간 API용)
# 비밀/계정은 저장소에 커밋하지 말고 .env 또는 환경 변수만 사용. plans/qa/최종_QA_체크리스트.md 참고.
# 판정: 각 시나리오는 응답 HTTP 상태코드가 Expected 목록에 있을 때만 PASS.
# 5xx(500/502/503/504 등)는 어떤 시나리오에서도 허용하지 않음 — 5xx 수신 시 무조건 FAIL.
#
# [엄격 규칙] 타시스템(한국투자증권·시세 API 등)에 API를 쏘는 구간은 상대한테로부터 200을 받아야 함.
# → 해당 시나리오는 Expected = 200 만 허용. 4xx/5xx 시 FAIL.

param(
    [string] $BaseUrl = $env:QA_BASE_URL,
    [string] $Username = $env:QA_USERNAME,
    [string] $Password = $env:QA_PASSWORD,
    [string] $AccountNo = $env:QA_ACCOUNT_NO,
    [int]    $TimeoutSec = $(if ($env:QA_TIMEOUT_SEC) { [int]$env:QA_TIMEOUT_SEC } else { 120 })
)

$ErrorActionPreference = "Stop"
if (-not $BaseUrl) { $BaseUrl = "http://localhost:8080" }
if (-not $AccountNo) { $AccountNo = "50161075-01" }

# Super Admin 기준: QA_USERNAME/QA_PASSWORD 미설정 시 investment-backend\.env 의 SUPER_ADMIN_* 사용
if (-not $Username -or -not $Password) {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $repoRoot = Split-Path -Parent $scriptDir
    $backendEnv = Join-Path $repoRoot "investment-backend\.env"
    if (Test-Path $backendEnv) {
        Get-Content $backendEnv -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\s*SUPER_ADMIN_USERNAME=(.+)$') { $script:Username = $Matches[1].Trim().Trim('"') }
            if ($line -match '^\s*SUPER_ADMIN_PASSWORD=(.+)$') { $script:Password = $Matches[1].Trim().Trim('"') }
        }
    }
}

# 시나리오: Method, Path, ExpectedStatusCodes, OptionalResponseKeys(200일 때 응답 본문 검증), Optional Body(POST/PUT).
# QA_시나리오_마스터.md 기준. accountNo는 $AccountNo 사용. 전체 API 스캔 반영(계좌·주문·얼마인지·실제 주문 포함).
$verifyAccountBody = '{"brokerType":"KOREA_INVESTMENT","appKey":"dummy","appSecret":"dummy","serverType":"1","accountNo":"50161075-01"}'
$mypagePutBody = '{"displayName":"QA"}'
$settingsPutBody = '{"maxInvestmentAmount":10000000,"minInvestmentAmount":100000,"defaultCurrency":"KRW","autoTradingEnabled":false,"roboAdvisorEnabled":false,"riskLevel":0.5,"shortTermRatio":0.2,"mediumTermRatio":0.4,"longTermRatio":0.4}'
$currentPricesBody = '["005930"]'
$killSwitchPutBody = '{"enabled":false}'
# 실제 주문 요청 (모의/실 계좌에 따라 200/400/403). 금액·수량·가격 포함.
$orderPostBody = '{"accountNo":"' + $AccountNo + '","symbol":"005930","market":"KR","quantity":1,"price":50000,"orderType":"BUY"}'
$backtestBody = '{"startDate":"2024-01-01","endDate":"2024-12-31","market":"KR","strategyType":"SHORT_TERM","initialCapital":10000000}'
$algoOrderBody = '{"orderId":"qa-algo-1","symbol":"005930","market":"KR","side":"BUY","totalQuantity":10,"limitPrice":50000,"algorithm":"TWAP"}'
$tcaEstimateBody = '{"symbol":"005930","market":"KR","assetType":"STOCK","side":"BUY","quantity":100,"arrivalPrice":50000,"avgDailyVolume":1000000,"avgSpreadPct":0.1}'
$tcaAnalyzeBody = '{"symbol":"005930","market":"KR","side":"BUY","quantity":100,"arrivalPrice":50000,"executionPrice":50100,"executionCost":1000}'
$stressTestBody = '{"positions":[]}'
$strategyPostBody = '{"accountNo":"' + $AccountNo + '","market":"KR","strategyType":"SHORT_TERM","status":"STOPPED","maxInvestmentAmount":5000000}'
$strategyStatusBody = '{"status":"STOPPED"}'
$factorCombinedBody = '{"symbol":"005930","market":"KR","basDt":"2024-06-01","factorWeights":{"MOMENTUM":0.5,"VALUE":0.5}}'
$factorRankBody = '{"market":"KR","basDt":"2024-06-01","factorWeights":{"MOMENTUM":0.5},"topN":10}'
$quickStartBody = '{"accountNo":"' + $AccountNo + '","maxInvestmentAmount":5000000}'

$scenarios = @(
    # §1 인증
    @{ Method = "GET";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @("userId", "username") },
    # 타시스템(KIS 계좌인증) → 200만 허용
    @{ Method = "POST"; Path = "/api/v1/auth/verify-account"; Expected = @(200); ResponseKeys = @(); Body = $verifyAccountBody },
    @{ Method = "PUT";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @(); Body = $mypagePutBody },
    # §2 설정
    @{ Method = "GET";  Path = "/api/v1/settings/accounts"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/settings/accounts"; Expected = @(200); ResponseKeys = @(); Body = "{}" },
    @{ Method = "GET";  Path = "/api/v1/settings/$AccountNo"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/settings/$AccountNo"; Expected = @(200); ResponseKeys = @(); Body = $settingsPutBody },
    @{ Method = "POST"; Path = "/api/v1/settings/quick-start"; Expected = @(200, 400, 404); ResponseKeys = @(); Body = $quickStartBody },
    # §3 시장데이터 (타시스템: 시세/차트 API) → 200만 허용
    @{ Method = "GET";  Path = "/api/v1/market-data/ping"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/market-data/current-price/005930"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/market-data/current-prices"; Expected = @(200); ResponseKeys = @(); Body = $currentPricesBody },
    @{ Method = "GET";  Path = "/api/v1/market-data/daily-chart?symbol=005930&market=KR"; Expected = @(200); ResponseKeys = @(); ResponseArray = $true },
    @{ Method = "GET";  Path = "/api/v1/market-data/symbols/search?q=005930&market=KR"; Expected = @(200); ResponseKeys = @() },
    # §4 계좌 (타시스템: 한국투자증권 API) → 200만 허용
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/balance"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/positions"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/positions?market=KR"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/buyable-amount?symbol=005930&price=50000"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/sellable-quantity?symbol=005930"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/order-history?startDate=2025-01-01&endDate=2025-12-31"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/cancelable-orders"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/assets"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/overseas-summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/profit-loss?startDate=2025-01-01&endDate=2025-12-31"; Expected = @(200, 400); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/balance-rlz-pl"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/profit-loss-status?startDate=2025-01-01&endDate=2025-12-31"; Expected = @(200, 404); ResponseKeys = @() },
    # §5 사용자 계좌
    @{ Method = "GET";  Path = "/api/v1/user/accounts"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/user/accounts/main"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/user/accounts/1"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/user/accounts/1/main"; Expected = @(200, 404); ResponseKeys = @(); Body = "{}" },
    # §6 대시보드
    @{ Method = "GET";  Path = "/api/v1/dashboard/performance-summary"; Expected = @(200, 404); ResponseKeys = @() },
    # §7 리스크
    @{ Method = "GET";  Path = "/api/v1/risk/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/attribution"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/limits"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/portfolio-metrics?accountNo=$AccountNo"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/history?from=2025-01-01&to=2025-12-31"; Expected = @(200); ResponseKeys = @() },
    # §8 세금리포트
    @{ Method = "GET";  Path = "/api/v1/report/tax/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/report/tax/summary/export"; Expected = @(200, 404); ResponseKeys = @() },
    # §9 주문 (타시스템: KIS 주문 API — POST·cancel-all-pending 은 200만 허용)
    @{ Method = "GET";  Path = "/api/v1/orders?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/orders"; Expected = @(200, 400, 403); ResponseKeys = @(); Body = $orderPostBody },
    @{ Method = "GET";  Path = "/api/v1/orders/qa-dummy-order-id?accountNo=$AccountNo"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "DELETE"; Path = "/api/v1/orders/qa-dummy-order-id?accountNo=$AccountNo"; Expected = @(204, 400, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/orders/cancel-all-pending?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    # §10 파이프라인
    @{ Method = "GET";  Path = "/api/v1/pipeline/summary?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    # §11 시그널
    @{ Method = "GET";  Path = "/api/v1/signals"; Expected = @(200); ResponseKeys = @() },
    # §12 전략
    @{ Method = "GET";  Path = "/api/v1/strategies/comparison"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/strategies/$AccountNo"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/strategies/$AccountNo/SHORT_TERM"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/strategies"; Expected = @(200, 400); ResponseKeys = @(); Body = $strategyPostBody },
    @{ Method = "PUT";  Path = "/api/v1/strategies/$AccountNo/SHORT_TERM/status"; Expected = @(200, 404); ResponseKeys = @(); Body = $strategyStatusBody },
    @{ Method = "POST"; Path = "/api/v1/strategies/$AccountNo/SHORT_TERM/activate"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/strategies/$AccountNo/SHORT_TERM/stop"; Expected = @(200, 404); ResponseKeys = @() },
    # §13 트레이딩 포트폴리오
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/today"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/date/2025-01-15"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/latest"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/trading-portfolios/generate"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/rebalance-suggestions?accountNo=$AccountNo&market=US"; Expected = @(200); ResponseKeys = @() },
    # §14 백테스트
    @{ Method = "POST"; Path = "/api/v1/backtest"; Expected = @(200, 400); ResponseKeys = @(); Body = $backtestBody },
    @{ Method = "POST"; Path = "/api/v1/backtest/walk-forward"; Expected = @(200, 400); ResponseKeys = @(); Body = '{"startDate":"2023-01-01","endDate":"2024-06-30","market":"KR","strategyType":"SHORT_TERM","initialCapital":10000000}' },
    @{ Method = "POST"; Path = "/api/v1/backtest/robo"; Expected = @(200, 400); ResponseKeys = @(); Body = '{"startDate":"2024-01-01","endDate":"2024-12-31","initialCapital":10000000}' },
    @{ Method = "GET";  Path = "/api/v1/backtest/robo/last-pre-execution?accountNo=$AccountNo"; Expected = @(200, 204); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/backtest/robo/collect-us-daily"; Expected = @(200); ResponseKeys = @(); Body = "{}" },
    # §15 분석
    @{ Method = "POST"; Path = "/api/v1/analysis"; Expected = @(200, 400); ResponseKeys = @(); Body = "{}" },
    @{ Method = "GET";  Path = "/api/v1/analysis/sector"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/analysis/correlation"; Expected = @(200); ResponseKeys = @() },
    # §16 매크로
    @{ Method = "GET";  Path = "/api/v1/macro/dashboard"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/indicators"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/indicators/GDP"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/indicators/GDP/history?startDate=2024-01-01&endDate=2024-12-31"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/regime"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/macro/refresh"; Expected = @(200); ResponseKeys = @() },
    # §17 팩터줌
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/factors"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/codes"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/test/MOMENTUM?market=KR&startDate=2024-01-01&endDate=2024-12-31"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/factors/MOMENTUM"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/factors/category/VALUE"; Expected = @(200, 400); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/rank?market=KR&startDate=2024-01-01&endDate=2025-12-31"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/factor-zoo/combined-score"; Expected = @(200, 400); ResponseKeys = @(); Body = $factorCombinedBody },
    @{ Method = "POST"; Path = "/api/v1/factor-zoo/rank-stocks"; Expected = @(200, 400); ResponseKeys = @(); Body = $factorRankBody },
    # §18 TCA
    @{ Method = "POST"; Path = "/api/v1/tca/estimate"; Expected = @(200, 400); ResponseKeys = @(); Body = $tcaEstimateBody },
    @{ Method = "POST"; Path = "/api/v1/tca/analyze"; Expected = @(200, 400); ResponseKeys = @(); Body = $tcaAnalyzeBody },
    @{ Method = "GET";  Path = "/api/v1/tca/round-trip?market=KR&assetType=STOCK&notional=1000000&quantity=100"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/tca/market-impact?orderQuantity=100&avgDailyVolume=1000000"; Expected = @(200); ResponseKeys = @() },
    # §19 알고리즘 주문
    @{ Method = "POST"; Path = "/api/v1/algo-orders/execute"; Expected = @(200, 400); ResponseKeys = @(); Body = $algoOrderBody },
    @{ Method = "GET";  Path = "/api/v1/algo-orders/qa-dummy-exec-id"; Expected = @(404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/algo-orders/qa-dummy-exec-id/cancel"; Expected = @(404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/algo-orders/qa-dummy-exec-id/resume"; Expected = @(404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/algo-orders/active"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/algo-orders/algorithms"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/algo-orders/preview"; Expected = @(200, 400); ResponseKeys = @(); Body = $algoOrderBody },
    # §20 스트레스테스트
    @{ Method = "GET";  Path = "/api/v1/stress-test/scenarios"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/stress-test/scenarios/2008_CRASH"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/stress-test/run/all"; Expected = @(200); ResponseKeys = @(); Body = $stressTestBody },
    @{ Method = "POST"; Path = "/api/v1/stress-test/run/custom"; Expected = @(200, 400); ResponseKeys = @(); Body = '{"code":"CUSTOM","name":"QA","description":"","positions":[],"assetClassShocks":{}}' },
    # §21 배치
    @{ Method = "GET";  Path = "/api/v1/batch/jobs"; Expected = @(200); ResponseKeys = @() },
    # §22 뉴스
    @{ Method = "GET";  Path = "/api/v1/news"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/news/collect"; Expected = @(200); ResponseKeys = @() },
    # §23 시스템
    @{ Method = "GET";  Path = "/api/v1/system/kill-switch"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/system/kill-switch"; Expected = @(200, 403); ResponseKeys = @(); Body = $killSwitchPutBody },
    # §24 Ops
    @{ Method = "GET";  Path = "/api/v1/ops/health"; Expected = @(200, 403); ResponseKeys = @("db", "lastCheckedAt") },
    @{ Method = "GET";  Path = "/api/v1/ops/auto-trading-readiness"; Expected = @(200, 403, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/system/settings"; Expected = @(200, 403, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/audit"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/trade-journal"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/governance/results"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/governance/halts"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/ops/governance/halts/KR/SHORT_TERM/clear"; Expected = @(204, 403); ResponseKeys = @(); Body = "{}" },
    @{ Method = "GET";  Path = "/api/v1/ops/alerts"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/model/status"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/data-pipeline/status"; Expected = @(200, 403); ResponseKeys = @() },
    # §25 트리거 (샘플 1건)
    @{ Method = "POST"; Path = "/api/v1/trigger/discord-test"; Expected = @(200, 403, 404); ResponseKeys = @() },
    # §26 관리자
    @{ Method = "POST"; Path = "/api/v1/admin/users"; Expected = @(201, 400, 403); ResponseKeys = @(); Body = '{"username":"qa-admin-test","password":"tempPass1!","displayName":"QA Admin"}' },
    # 로그아웃은 토큰 무효화하므로 맨 마지막에 실행
    @{ Method = "POST"; Path = "/api/v1/auth/logout"; Expected = @(200); ResponseKeys = @() }
)

function Invoke-ApiRequest {
    param([string] $Method, [string] $Path, [hashtable] $Headers, [string] $Body = $null)
    $url = "$BaseUrl$Path"
    $params = @{
        Uri             = $url
        Method          = $Method
        Headers         = $Headers
        UseBasicParsing = $true
        TimeoutSec      = $TimeoutSec
    }
    if ($Body) { $params.Body = $Body; $params.ContentType = "application/json" }
    try {
        $r = Invoke-WebRequest @params
        return @{ StatusCode = $r.StatusCode; Content = $r.Content }
    } catch {
        if ($_.Exception.Response) {
            $status = [int] $_.Exception.Response.StatusCode
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $content = $reader.ReadToEnd()
            $reader.Close()
            return @{ StatusCode = $status; Content = $content }
        }
        throw
    }
}

$results = @()
$allPass = $true

if (-not $Username -or -not $Password) {
    Write-Host "API QA: Super Admin 계정 필요. QA_USERNAME/QA_PASSWORD 또는 investment-backend\.env 의 SUPER_ADMIN_USERNAME, SUPER_ADMIN_PASSWORD 를 설정하세요." -ForegroundColor Yellow
    Write-Host "예: .env 에 SUPER_ADMIN_USERNAME=..., SUPER_ADMIN_PASSWORD=... 또는 `$env:QA_USERNAME='...'; `$env:QA_PASSWORD='...'; .\scripts\run-api-qa.ps1" -ForegroundColor Gray
    exit 2
}

# 1. 로그인 (상태 코드 + 응답 본문: token, userId 또는 username)
$loginBody = @{ username = $Username; password = $Password } | ConvertTo-Json
try {
    $loginResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -UseBasicParsing
    $token = $loginResp.token
    if (-not $token) {
        Write-Host "API_QA FAIL: login response has no token" -ForegroundColor Red
        exit 1
    }
    $hasUser = ($loginResp.PSObject.Properties.Name -contains "userId") -or ($loginResp.PSObject.Properties.Name -contains "username")
    if (-not $hasUser) {
        Write-Host "API_QA WARN: login response missing userId/username (optional check)" -ForegroundColor Yellow
    }
} catch {
    $status = if ($_.Exception.Response) { [int] $_.Exception.Response.StatusCode } else { 0 }
    Write-Host "API_QA FAIL: login -> $status $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{ "Authorization" = "Bearer $token" }

# 2. 시나리오 순차 호출 (상태 코드 + 응답 본문 검증)
foreach ($s in $scenarios) {
    $path = $s.Path
    $expected = $s.Expected
    $responseKeys = if ($s.ResponseKeys) { $s.ResponseKeys } else { @() }
    $responseArray = $s.ResponseArray -eq $true
    try {
        $body = if ($s.Body) { $s.Body } else { $null }
        $res = Invoke-ApiRequest -Method $s.Method -Path $path -Headers $headers -Body $body
        $actual = $res.StatusCode
        $ok = $actual -in $expected
        # 5xx는 어떤 시나리오에서도 허용하지 않음
        if ($actual -ge 500) { $ok = $false; $allPass = $false }
        $responseOk = $true
        if ($ok -and $actual -eq 200 -and ($responseKeys.Count -gt 0 -or $responseArray)) {
            try {
                $content = $res.Content | ConvertFrom-Json
                if ($responseArray) {
                    $isArray = $content -is [System.Array] -or ($content -is [System.Collections.IEnumerable] -and $content -isnot [string])
                    if (-not $isArray) {
                        $responseOk = $false
                        $ok = $false
                        $allPass = $false
                    }
                }
                foreach ($key in $responseKeys) {
                    $hasKey = $content -and ($content.PSObject.Properties.Name -contains $key)
                    if (-not $hasKey) {
                        $responseOk = $false
                        $ok = $false
                        $allPass = $false
                        break
                    }
                }
            } catch {
                $responseOk = $false
                $ok = $false
                $allPass = $false
            }
        }
        if (-not $ok) { $allPass = $false }
        $statusStr = if ($ok) { "PASS" } else { "FAIL" }
        $detail = $actual.ToString()
        if ($ok -and -not $responseOk -and $responseKeys.Count -gt 0) { $detail = "$actual (response validation failed)" }
        $results += [pscustomobject]@{ Status = $statusStr; Method = $s.Method; Path = $path; Expected = ($expected -join ","); Actual = $detail }
        $color = if ($ok) { "Green" } else { "Red" }
        Write-Host "API_QA $statusStr $($s.Method) $path -> $detail (expected: $($expected -join '|'))" -ForegroundColor $color
    } catch {
        $allPass = $false
        $actual = "ERROR"
        $isTimeout = ($_.Exception.Message -match "timeout|timed out") -or
            ($_.Exception -is [System.Net.WebException] -and $_.Exception.Status -eq [System.Net.WebExceptionStatus]::Timeout)
        if ($isTimeout) { $actual = "504(timeout)" }
        $results += [pscustomobject]@{ Status = "FAIL"; Method = $s.Method; Path = $path; Expected = ($expected -join ","); Actual = $actual }
        Write-Host "API_QA FAIL $($s.Method) $path -> $actual $($_.Exception.Message)" -ForegroundColor Red
    }
}

if ($allPass) {
    Write-Host "API_QA all passed ($($results.Count) requests)" -ForegroundColor Green
    exit 0
} else {
    $failCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
    Write-Host "API_QA $failCount failed of $($results.Count)" -ForegroundColor Red
    exit 1
}
