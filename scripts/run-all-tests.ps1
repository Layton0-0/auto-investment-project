# Run All Tests: Backend (JUnit) + Frontend (unit) + E2E (Playwright)
# 사용: .\scripts\run-all-tests.ps1
# 전체 QA(API 시나리오, Python QA, 보안 포함)는 .\scripts\run-full-qa.ps1 사용
# Agent 터미널 타임아웃: 300000ms 이상 권장 (.cursor/rules/script-run-timeouts.mdc)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$overallExit = 0

Write-Host "Running backend tests..." -ForegroundColor Cyan
Push-Location (Join-Path $repoRoot "investment-backend")
try {
    & .\gradlew.bat test --no-daemon 2>&1
    if ($LASTEXITCODE -ne 0) { $overallExit = 1 }
} finally { Pop-Location }

Write-Host "Running frontend tests..." -ForegroundColor Cyan
Push-Location (Join-Path $repoRoot "investment-frontend")
try {
    if (Test-Path "package.json") {
        $npmTest = npm test 2>&1
        if ($LASTEXITCODE -ne 0) { $overallExit = 1 }
    } else {
        Write-Host "(npm test not configured, skipping)" -ForegroundColor Yellow
    }
} finally { Pop-Location }

Write-Host "Running e2e tests (Playwright)..." -ForegroundColor Cyan
Push-Location (Join-Path $repoRoot "investment-frontend")
try {
    npx playwright test 2>&1
    if ($LASTEXITCODE -ne 0) { $overallExit = 1 }
} finally { Pop-Location }

if ($overallExit -eq 0) { Write-Host "All tests passed." -ForegroundColor Green }
else { Write-Host "Some tests failed. Fix and rerun." -ForegroundColor Red }
exit $overallExit
