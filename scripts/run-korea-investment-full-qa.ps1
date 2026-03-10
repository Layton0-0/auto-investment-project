# 한국투자증권 API 포함 전체 QA: 백엔드 단위/통합 테스트 후 API 시나리오(실제 한투 API 경유) 실행
# 사용: .\scripts\run-korea-investment-full-qa.ps1
# 전제:
#   - 백엔드 단위 테스트: 항상 실행
#   - 실제 한투 API 통합 테스트: RUN_KOREA_INVESTMENT_INTEGRATION=true 및 KOREA_INVESTMENT_TEST_APP_KEY, _APP_SECRET, _ACCOUNT_NO 설정 시에만 실행
#   - API 시나리오(계좌 잔고/보유종목/자산 등): 백엔드가 8080에서 기동 중이고, 로그인 계정·한투 API 키가 DB에 있으면 실제 한투 API 호출
# 실행 순서: 1) Backend JUnit 2) (선택) 한투 통합 테스트 3) Backend 8080 도달 시 run-api-qa.ps1

param(
    [switch]$SkipApiScenario,
    [switch]$AccountTestsOnly,
    [int]$TestTimeoutMs = 300000
)
# AccountTestsOnly: 계좌·AccountController 테스트만 실행 (전체 테스트 중 일부 실패 시에도 한투 API 연동 검증용으로 사용)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendDir = Join-Path $repoRoot "investment-backend"

Write-Host "=== 1. Backend JUnit (단위 + 통합, 한투 통합은 RUN_KOREA_INVESTMENT_INTEGRATION=true 시 실행) ===" -ForegroundColor Cyan
if ($env:RUN_KOREA_INVESTMENT_INTEGRATION -eq "true") {
    Write-Host "RUN_KOREA_INVESTMENT_INTEGRATION=true: 한투 실제 API 통합 테스트 포함" -ForegroundColor Yellow
    if (-not $env:KOREA_INVESTMENT_TEST_APP_KEY -or -not $env:KOREA_INVESTMENT_TEST_APP_SECRET -or -not $env:KOREA_INVESTMENT_TEST_ACCOUNT_NO) {
        Write-Host "WARN: KOREA_INVESTMENT_TEST_APP_KEY, _APP_SECRET, _ACCOUNT_NO 를 설정하면 주식잔고조회 실제 호출 테스트가 실행됩니다." -ForegroundColor Yellow
    }
} else {
    Write-Host "한투 실제 API 통합 테스트 스킵 (설정 시 실행: RUN_KOREA_INVESTMENT_INTEGRATION=true, KOREA_INVESTMENT_TEST_APP_KEY, _APP_SECRET, _ACCOUNT_NO)" -ForegroundColor Gray
}

Push-Location $backendDir
try {
    if ($AccountTestsOnly) {
        Write-Host "AccountTestsOnly: 계좌·AccountController·한투 통합 테스트만 실행" -ForegroundColor Gray
        $testResult = & .\gradlew test --no-daemon -q --tests "com.investment.account.*" --tests "com.investment.api.controller.AccountControllerTest" 2>&1
    } else {
        $testResult = & .\gradlew test --no-daemon -q 2>&1
    }
    $testExit = $LASTEXITCODE
    if ($testExit -ne 0) {
        Write-Host $testResult
        Write-Host "Backend tests FAILED (exit $testExit)" -ForegroundColor Red
        exit $testExit
    }
    Write-Host "Backend tests PASSED" -ForegroundColor Green
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "=== 2. API 시나리오 (백엔드 8080 기동 중일 때, 계좌 API 등 실제 한투 경유) ===" -ForegroundColor Cyan
if ($SkipApiScenario) {
    Write-Host "SkipApiScenario: API 시나리오 스킵" -ForegroundColor Gray
    exit 0
}

# Backend 8080 도달 여부 확인
$backendReachable = $false
try {
    $r = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
    $backendReachable = ($r.StatusCode -eq 200)
} catch {}

if (-not $backendReachable) {
    Write-Host "Backend 8080 미도달: API 시나리오 스킵. (풀스택 기동 후 다시 실행: investment-infra\scripts\local-up.ps1 또는 백엔드 bootRun)" -ForegroundColor Yellow
    exit 0
}

# QA_USERNAME/QA_PASSWORD 로드 (backend .env)
$backendEnvPath = Join-Path $backendDir ".env"
if (-not $env:QA_USERNAME -or -not $env:QA_PASSWORD) {
    if (Test-Path $backendEnvPath) {
        Get-Content $backendEnvPath -Encoding UTF8 -ErrorAction SilentlyContinue | ForEach-Object {
            $line = $_.Trim()
            if ($line -match '^\s*SUPER_ADMIN_USERNAME=(.+)$') { $env:QA_USERNAME = $Matches[1].Trim().Trim('"') }
            if ($line -match '^\s*SUPER_ADMIN_PASSWORD=(.+)$') { $env:QA_PASSWORD = $Matches[1].Trim().Trim('"') }
        }
    }
}

if (-not $env:QA_USERNAME -or -not $env:QA_PASSWORD) {
    Write-Host "QA_USERNAME/QA_PASSWORD 또는 investment-backend\.env 의 SUPER_ADMIN_* 미설정: API 시나리오 스킵" -ForegroundColor Yellow
    exit 0
}

Push-Location $repoRoot
try {
    $apiResult = & .\scripts\run-api-qa.ps1 2>&1
    $apiExit = $LASTEXITCODE
    if ($apiExit -eq 0) {
        Write-Host "API 시나리오 PASSED (계좌/잔고/자산 등 엔드포인트가 백엔드 경유로 한투 API 호출됨)" -ForegroundColor Green
    } else {
        Write-Host $apiResult
        Write-Host "API 시나리오 FAILED (exit $apiExit)" -ForegroundColor Red
        exit $apiExit
    }
} finally {
    Pop-Location
}

exit 0
