# 데이터 파이프라인 검증: readiness 조회 → krx-daily, us-daily, factor-calculation 트리거 → readiness 재확인
# 사용: .\plans\qa\scripts\verify-data-pipeline.ps1  (프로젝트 루트에서) 또는 .\verify-data-pipeline.ps1 (plans/qa/scripts에서)
# 환경 변수: QA_BASE_URL (기본 http://localhost:8080), QA_USERNAME, QA_PASSWORD. 미설정 시 investment-backend\.env 의 SUPER_ADMIN_* 사용.
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = (Resolve-Path (Join-Path $ScriptDir "..\..\..")).Path
$BackendEnv = Join-Path $RepoRoot "investment-backend\.env"

$BaseUrl = if ($env:QA_BASE_URL) { $env:QA_BASE_URL } else { "http://localhost:8080" }
$Username = $env:QA_USERNAME
$Password = $env:QA_PASSWORD

if (-not $Username -or -not $Password) {
    if (Test-Path $BackendEnv) {
        Get-Content $BackendEnv -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\s*SUPER_ADMIN_USERNAME=(.+)$') { $script:Username = $Matches[1].Trim().Trim('"') }
            if ($line -match '^\s*SUPER_ADMIN_PASSWORD=(.+)$') { $script:Password = $Matches[1].Trim().Trim('"') }
        }
    }
}

if (-not $Username -or -not $Password) {
    Write-Host "QA_USERNAME/QA_PASSWORD 또는 investment-backend\.env 의 SUPER_ADMIN_USERNAME, SUPER_ADMIN_PASSWORD 를 설정하세요." -ForegroundColor Yellow
    exit 2
}

# Login
$loginBody = @{ username = $Username; password = $Password } | ConvertTo-Json
try {
    $loginResp = Invoke-RestMethod -Uri "$BaseUrl/api/v1/auth/login" -Method Post -Body $loginBody -ContentType "application/json" -UseBasicParsing
    $token = $loginResp.token
    if (-not $token) { Write-Host "Login failed: no token"; exit 1 }
} catch {
    Write-Host "Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{ "Authorization" = "Bearer $token" }

# 1) Readiness before
Write-Host "1) GET /api/v1/ops/auto-trading-readiness (before)..."
try {
    $r = Invoke-RestMethod -Uri "$BaseUrl/api/v1/ops/auto-trading-readiness" -Headers $headers -Method Get -UseBasicParsing
    Write-Host "   dailyStockRowCount=$($r.dailyStockRowCount), signalScoreRowCount=$($r.signalScoreRowCount)"
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# 2) Triggers (order: krx-daily → us-daily → factor-calculation)
foreach ($path in @("/api/v1/trigger/krx-daily", "/api/v1/trigger/us-daily", "/api/v1/trigger/factor-calculation")) {
    Write-Host "2) POST $path..."
    try {
        Invoke-RestMethod -Uri "$BaseUrl$path" -Headers $headers -Method Post -UseBasicParsing | Out-Null
        Write-Host "   OK"
    } catch {
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

# 3) Readiness after
Write-Host "3) GET /api/v1/ops/auto-trading-readiness (after)..."
try {
    $r2 = Invoke-RestMethod -Uri "$BaseUrl/api/v1/ops/auto-trading-readiness" -Headers $headers -Method Get -UseBasicParsing
    Write-Host "   dailyStockRowCount=$($r2.dailyStockRowCount), signalScoreRowCount=$($r2.signalScoreRowCount)"
} catch {
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Done. See 데이터_부재_점검_가이드.md for cause analysis if counts are still 0."
