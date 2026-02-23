# API QA 자동화: 로그인 1회 후 Bearer로 QA_시나리오_마스터 기반 엔드포인트 순차 호출.
# 사용: .\scripts\run-api-qa.ps1
# 환경 변수: QA_BASE_URL (기본 http://localhost:8080), QA_USERNAME, QA_PASSWORD, QA_ACCOUNT_NO (기본 50161075-01)
# 비밀/계정은 저장소에 커밋하지 말고 .env 또는 환경 변수만 사용. plans/qa/최종_QA_체크리스트.md 참고.

param(
    [string] $BaseUrl = $env:QA_BASE_URL,
    [string] $Username = $env:QA_USERNAME,
    [string] $Password = $env:QA_PASSWORD,
    [string] $AccountNo = $env:QA_ACCOUNT_NO
)

$ErrorActionPreference = "Stop"
if (-not $BaseUrl) { $BaseUrl = "http://localhost:8080" }
if (-not $AccountNo) { $AccountNo = "50161075-01" }

# 시나리오: Method, Path, ExpectedStatusCodes, OptionalResponseKeys(200일 때 응답 본문 검증할 필드).
$scenarios = @(
    @{ Method = "GET";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @("userId", "username") },
    @{ Method = "GET";  Path = "/api/v1/market-data/current-price/005930"; Expected = @(200); ResponseKeys = @("symbol") },
    @{ Method = "GET";  Path = "/api/v1/market-data/daily-chart?symbol=005930&market=KR"; Expected = @(200); ResponseKeys = @(); ResponseArray = $true },
    @{ Method = "GET";  Path = "/api/v1/settings/accounts"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/settings/$AccountNo"; Expected = @(200, 400, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/user/accounts"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/dashboard/performance-summary"; Expected = @(200, 404); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/risk/limits"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/report/tax/summary"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/pipeline/summary?accountNo=$AccountNo"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/trading-portfolios/latest"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/ops/health"; Expected = @(200); ResponseKeys = @("db", "lastCheckedAt") },
    @{ Method = "GET";  Path = "/api/v1/ops/audit"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/system/kill-switch"; Expected = @(200); ResponseKeys = @() },
    @{ Method = "GET";  Path = "/api/v1/auth/mypage"; Expected = @(200); ResponseKeys = @("userId", "username") }
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
    Write-Host "QA_USERNAME, QA_PASSWORD 환경 변수를 설정한 뒤 실행하세요. (비밀은 저장소에 커밋하지 마세요.)" -ForegroundColor Yellow
    Write-Host "예: `$env:QA_USERNAME='your_username'; `$env:QA_PASSWORD='your_password'; .\scripts\run-api-qa.ps1" -ForegroundColor Gray
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
        $res = Invoke-ApiRequest -Method $s.Method -Path $path -Headers $headers
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
        $allPass = $false
        $results += [pscustomobject]@{ Status = "FAIL"; Method = $s.Method; Path = $path; Expected = ($expected -join ","); Actual = "ERROR" }
        Write-Host "API_QA FAIL $($s.Method) $path -> $($_.Exception.Message)" -ForegroundColor Red
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
