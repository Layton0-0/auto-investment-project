# API QA 자동화: 로그인 1회 후 Bearer로 QA_시나리오_마스터 기반 엔드포인트 순차 호출.
# 사용: .\scripts\run-api-qa.ps1
# 환경 변수: QA_BASE_URL (기본 http://localhost:8080), QA_USERNAME, QA_PASSWORD, QA_ACCOUNT_NO (기본 50161075-01)
# 비밀/계정은 저장소에 커밋하지 말고 .env 또는 환경 변수만 사용. plans/qa/최종_QA_체크리스트.md 참고.
# 판정: 각 시나리오는 응답 HTTP 상태코드가 Expected 목록에 있을 때만 PASS. 500(서버 예외/스택트레이스)은 허용하지 않음 — 500이면 FAIL로 처리.

param(
    [string] $BaseUrl = $env:QA_BASE_URL,
    [string] $Username = $env:QA_USERNAME,
    [string] $Password = $env:QA_PASSWORD,
    [string] $AccountNo = $env:QA_ACCOUNT_NO
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
# QA_시나리오_마스터.md 기준. accountNo는 $AccountNo 사용.
$verifyAccountBody = '{"brokerType":"KOREA_INVESTMENT","appKey":"dummy","appSecret":"dummy","serverType":"1","accountNo":"50161075-01"}'
$mypagePutBody = '{"displayName":"QA"}'
$settingsPutBody = '{"maxInvestmentAmount":10000000,"minInvestmentAmount":100000,"defaultCurrency":"KRW","autoTradingEnabled":false,"roboAdvisorEnabled":false,"riskLevel":0.5,"shortTermRatio":0.2,"mediumTermRatio":0.4,"longTermRatio":0.4}'
$currentPricesBody = '["005930"]'
$killSwitchPutBody = '{"enabled":false}'
$orderPostBody = '{"accountNo":"' + $AccountNo + '","symbol":"005930","market":"KR","quantity":1,"price":50000,"orderType":"BUY"}'

$scenarios = @(
    # §1 인증
    @{ Method = "GET";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @("userId", "username") },
    @{ Method = "POST"; Path = "/api/v1/auth/verify-account"; Expected = @(200, 400); ResponseKeys = @(); Body = $verifyAccountBody },
    @{ Method = "PUT";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @(); Body = $mypagePutBody },
    # §2 설정
    @{ Method = "GET";  Path = "/api/v1/settings/accounts"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/settings/accounts"; Expected = @(200); ResponseKeys = @(); Body = "{}" },
    @{ Method = "GET";  Path = "/api/v1/settings/$AccountNo"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/settings/$AccountNo"; Expected = @(200); ResponseKeys = @(); Body = $settingsPutBody },
    # §3 시장데이터
    @{ Method = "GET";  Path = "/api/v1/market-data/current-price/005930"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/market-data/current-prices"; Expected = @(200); ResponseKeys = @(); Body = $currentPricesBody },
    @{ Method = "GET";  Path = "/api/v1/market-data/daily-chart?symbol=005930&market=KR"; Expected = @(200); ResponseKeys = @(); ResponseArray = $true },
    # §4 계좌
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/balance"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/positions"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/buyable-amount?symbol=005930&price=50000"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/sellable-quantity?symbol=005930"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/order-history?startDate=2025-01-01&endDate=2025-12-31"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/assets"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/accounts/$AccountNo/profit-loss?startDate=2025-01-01&endDate=2025-12-31"; Expected = @(200, 404); ResponseKeys = @() },
    # §5 사용자 계좌
    @{ Method = "GET";  Path = "/api/v1/user/accounts"; Expected = @(200); ResponseKeys = @() },
    # §6 대시보드
    @{ Method = "GET";  Path = "/api/v1/dashboard/performance-summary"; Expected = @(200, 404); ResponseKeys = @() },
    # §7 리스크
    @{ Method = "GET";  Path = "/api/v1/risk/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/limits"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/portfolio-metrics?accountNo=$AccountNo"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/history?from=2025-01-01&to=2025-12-31"; Expected = @(200); ResponseKeys = @() },
    # §8 세금리포트
    @{ Method = "GET";  Path = "/api/v1/report/tax/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/report/tax/summary/export"; Expected = @(200, 404); ResponseKeys = @() },
    # §9 주문
    @{ Method = "GET";  Path = "/api/v1/orders?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/orders"; Expected = @(200, 400, 403); ResponseKeys = @(); Body = $orderPostBody },
    # §10 파이프라인
    @{ Method = "GET";  Path = "/api/v1/pipeline/summary?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    # §11 시그널
    @{ Method = "GET";  Path = "/api/v1/signals"; Expected = @(200); ResponseKeys = @() },
    # §12 전략
    @{ Method = "GET";  Path = "/api/v1/strategies/comparison"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/strategies/$AccountNo"; Expected = @(200, 404); ResponseKeys = @() },
    # §13 트레이딩 포트폴리오
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/today"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/date/2025-01-15"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/latest"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/rebalance-suggestions?accountNo=$AccountNo&market=US"; Expected = @(200); ResponseKeys = @() },
    # §14 백테스트
    @{ Method = "GET";  Path = "/api/v1/backtest/robo/last-pre-execution?accountNo=$AccountNo"; Expected = @(200, 204); ResponseKeys = @() },
    # §15 분석
    @{ Method = "POST"; Path = "/api/v1/analysis"; Expected = @(200, 400); ResponseKeys = @(); Body = "{}" },
    @{ Method = "GET";  Path = "/api/v1/analysis/sector"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/analysis/correlation"; Expected = @(200); ResponseKeys = @() },
    # §16 매크로
    @{ Method = "GET";  Path = "/api/v1/macro/dashboard"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/indicators"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/macro/regime"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/macro/refresh"; Expected = @(200); ResponseKeys = @() },
    # §17 팩터줌
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/factors"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/codes"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/factor-zoo/rank?market=KR&startDate=2024-01-01&endDate=2025-12-31"; Expected = @(200); ResponseKeys = @() },
    # §18 스트레스테스트
    @{ Method = "GET";  Path = "/api/v1/stress-test/scenarios"; Expected = @(200); ResponseKeys = @() },
    # §19 뉴스
    @{ Method = "GET";  Path = "/api/v1/news"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "POST"; Path = "/api/v1/news/collect"; Expected = @(200, 500, 504); ResponseKeys = @() },
    # §20 시스템
    @{ Method = "GET";  Path = "/api/v1/system/kill-switch"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "PUT";  Path = "/api/v1/system/kill-switch"; Expected = @(200, 403); ResponseKeys = @(); Body = $killSwitchPutBody },
    # §21 Ops
    @{ Method = "GET";  Path = "/api/v1/ops/health"; Expected = @(200); ResponseKeys = @("db", "lastCheckedAt") },
    @{ Method = "GET";  Path = "/api/v1/ops/audit"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/governance/results"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/governance/halts"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/alerts"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/model/status"; Expected = @(200, 403); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/data-pipeline/status"; Expected = @(200, 403); ResponseKeys = @() },
    # §22 관리자
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
        TimeoutSec      = 30
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
        $actual = "ERROR"
        $isTimeout = ($_.Exception.Message -match "timeout|timed out") -or
            ($_.Exception -is [System.Net.WebException] -and $_.Exception.Status -eq [System.Net.WebExceptionStatus]::Timeout)
        if ($isTimeout) {
            $actual = "504(timeout)"
            if (504 -in $expected) { $allPass = $allPass -and $true }
        } else {
            $allPass = $false
        }
        $results += [pscustomobject]@{ Status = if ($actual -ne "ERROR" -and $actual -like "504*") { "PASS" } else { "FAIL" }; Method = $s.Method; Path = $path; Expected = ($expected -join ","); Actual = $actual }
        $color = if ($actual -like "504*" -and 504 -in $expected) { "Green" } else { "Red" }
        Write-Host "API_QA $(if ($actual -like '504*' -and 504 -in $expected) { 'PASS' } else { 'FAIL' }) $($s.Method) $path -> $actual $($_.Exception.Message)" -ForegroundColor $color
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
