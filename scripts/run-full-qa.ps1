# Full QA: Backend, API scenario, Python QA, Python unit tests, Frontend E2E, Security, report
# 사용: .\scripts\run-full-qa.ps1
# 전제: 로컬 풀스택(docker-compose.local-full.yml) 기동 시 Backend 8080, data-collector 8001, prediction-service 8000, Frontend 등 동작.
# 환경 변수: QA_USERNAME, QA_PASSWORD (API 시나리오), QA_DATA_COLLECTOR_URL, QA_PREDICTION_URL (Python QA, 기본 8001/8000)
# Agent 실행 시 터미널 타임아웃 600000ms(10분) 이상 권장. .cursor/rules/script-run-timeouts.mdc

param([switch]$SkipApiScenario,[switch]$SkipPythonQA,[switch]$SkipPythonTests,[switch]$SkipE2e,[switch]$SkipSecurity,[switch]$BackendNoUniqueDir)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$reportDir = Join-Path $repoRoot "plans\qa\reports"
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$reportPath = Join-Path $reportDir "$timestamp-qa-report.md"

New-Item -ItemType Directory -Path $reportDir -Force -ErrorAction SilentlyContinue | Out-Null
$report = @()
$report += "# QA Report - $timestamp"
$report += ""
$report += "## Summary"
$report += ""

$overallExit = 0
$backendExit = 0
$apiExit = 0
$pythonQaExit = 0
$pythonTestExit = 0
$e2eExit = 0
$secExit = 0

# ---------- 1. Backend ----------
$report += "### 1. Backend (JUnit)"
Push-Location (Join-Path $repoRoot "investment-backend")
if ($BackendNoUniqueDir) { $backendOut = & .\scripts\run-tests.ps1 -NoUniqueDir 2>&1 } else { $backendOut = & .\scripts\run-tests.ps1 2>&1 }
$backendExit = $LASTEXITCODE
if ($backendExit -eq 0) { $report += "- [OK] Pass" } else {
    $report += "- [FAIL] exit " + $backendExit
    $report += "- [log]:"; $report += ([char]96 + [char]96 + [char]96); $report += ($backendOut | Out-String); $report += ([char]96 + [char]96 + [char]96)
    $overallExit = 1
}
Pop-Location
$report += ""

# ---- 2. API (Super Admin: load from backend .env if QA_* not set) ----
$backendEnvPath = Join-Path (Join-Path $repoRoot "investment-backend") ".env"
if ((-not $env:QA_USERNAME -or -not $env:QA_PASSWORD) -and (Test-Path $backendEnvPath)) {
    $lines = Get-Content $backendEnvPath -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        $ln = $line.Trim()
        if ($ln -match '^\s*SUPER_ADMIN_USERNAME=(.+)$') { $env:QA_USERNAME = $Matches[1].Trim().Trim('"') }
        if ($ln -match '^\s*SUPER_ADMIN_PASSWORD=(.+)$') { $env:QA_PASSWORD = $Matches[1].Trim().Trim('"') }
    }
}
# API 단계 전에 Backend 8080 도달 가능 여부 확인 (미도달 시 SKIP으로 명확히 표시)
$qaPrepOk = $false
Push-Location $repoRoot
try {
    & .\scripts\verify-qa-prep.ps1 2>&1 | Out-Null
    $qaPrepOk = ($LASTEXITCODE -eq 0)
} finally { Pop-Location }

if (-not $SkipApiScenario) {
    $report += "### 2. API scenario (run-api-qa.ps1)"
    if ($env:QA_USERNAME -and $env:QA_PASSWORD) {
        if ($qaPrepOk) {
            Push-Location $repoRoot
            try {
                $apiOut = & .\scripts\run-api-qa.ps1 2>&1
                $apiExit = $LASTEXITCODE
                if ($apiExit -eq 0) { $report += "- [OK] Pass" } else {
                    $report += "- [FAIL] exit " + $apiExit
                    $report += "- [log]:"; $report += ([char]96 + [char]96 + [char]96); $report += ($apiOut | Out-String); $report += ([char]96 + [char]96 + [char]96)
                    $overallExit = 1
                }
            } finally { Pop-Location }
        } else {
            $report += "- [SKIP] Backend not reachable on 8080 (run .\scripts\verify-qa-prep.ps1; start full stack: investment-infra\scripts\local-up.ps1)"
        }
    } else {
        $report += "- [SKIP] QA_USERNAME/QA_PASSWORD or backend .env SUPER_ADMIN_* not set"
        $report += "- Set SUPER_ADMIN_USERNAME, SUPER_ADMIN_PASSWORD in investment-backend/.env then re-run"
    }
} else { $report += "### 2. API scenario - Skipped (-SkipApiScenario)" }
$report += ""

# ---- 2.5 Python QA ----
if (-not $SkipPythonQA) {
    $report += "### 3. Python QA (run-python-qa.ps1)"
    Push-Location $repoRoot
    try {
        $pythonQaOut = & .\scripts\run-python-qa.ps1 2>&1
        $pythonQaExit = $LASTEXITCODE
        if ($pythonQaExit -eq 0) { $report += "- [OK] Pass" } else {
            $report += "- [FAIL] exit " + $pythonQaExit
            $report += "- [log]:"
            $report += ([char]96 + [char]96 + [char]96)
            $report += ($pythonQaOut | Out-String)
            $report += ([char]96 + [char]96 + [char]96)
            $overallExit = 1
        }
    } finally { Pop-Location }
} else { $report += "### 3. Python QA - Skipped" }
$report += ""

# ---- 2.6 Python unit tests ----
if (-not $SkipPythonTests) {
    $report += "### 4. Python unit tests (prediction-service)"
    $pythonProj = Join-Path $repoRoot "investment-prediction-service"
    Push-Location $pythonProj
    $prevErr = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $pythonTestOut = python -m unittest discover -s tests -p "test_*.py" -v 2>&1
    $pythonTestExit = $LASTEXITCODE
    if ($pythonTestExit -eq 9009) {
        $pythonTestOut = py -m unittest discover -s tests -p "test_*.py" -v 2>&1
        $pythonTestExit = $LASTEXITCODE
    }
    $ErrorActionPreference = $prevErr
    $pythonOutStr = $pythonTestOut | Out-String
    if ($pythonTestExit -eq 0) { $report += "- [OK] Pass" } elseif ($pythonTestExit -eq 9009) {
        $report += "- [SKIP] python/py not in PATH (install Python or set PATH)"
    } elseif ($pythonTestExit -eq 1 -and $pythonOutStr -match "ModuleNotFoundError") {
        $report += "- [SKIP] Python deps missing (pip install -r requirements.txt in investment-prediction-service)"
    } else {
        $report += "- [FAIL] exit " + $pythonTestExit
        $report += "- [log]:"
        $report += ([char]96 + [char]96 + [char]96)
        $report += $pythonOutStr
        $report += ([char]96 + [char]96 + [char]96)
        $overallExit = 1
    }
    Pop-Location
} else { $report += "### 4. Python unit tests - Skipped" }
$report += ""

# ---------- 5. Frontend E2E ----------
if (-not $SkipE2e) {
    $report += "### 5. Frontend E2E (Playwright)"
    $frontendDir = Join-Path $repoRoot "investment-frontend"
    $playwrightBrowsers = Join-Path $frontendDir ".playwright-browsers"
    Push-Location $frontendDir
    try {
        $prevErr = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $env:PLAYWRIGHT_BROWSERS_PATH = $playwrightBrowsers
        $e2eOut = cmd /c "npm run e2e" 2>&1
        Remove-Item Env:\PLAYWRIGHT_BROWSERS_PATH -ErrorAction SilentlyContinue
        $ErrorActionPreference = $prevErr
        $e2eExit = $LASTEXITCODE
        if ($e2eExit -eq 0) {
            $report += "- [결과]: 통과"
        } else {
            $report += "- [결과]: 실패 (exit $e2eExit)"
            $report += "- [로그]:"
            $report += '```'
            $report += ($e2eOut | Out-String)
            $report += '```'
            $report += "- [스크린샷/트레이스]: investment-frontend/playwright-report/ 또는 test-results/"
            $overallExit = 1
        }
    } finally {
        Pop-Location
    }
} else {
    $report += "### 5. Frontend E2E - 스킵 (-SkipE2e)"
}
$report += ""

# ---------- 6. 보안 점검 ----------
if (-not $SkipSecurity) {
    $report += "### 6. 보안 점검 (npm audit)"
    Push-Location (Join-Path $repoRoot "investment-frontend")
    $prevErr = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $secOut = cmd /c "npm audit --audit-level=high" 2>&1
    $ErrorActionPreference = $prevErr
    $secExit = $LASTEXITCODE
    if ($secExit -eq 0) {
        $report += "- [결과]: 이상 없음 (high 이상 취약점 없음)"
    } else {
        $report += "- [결과]: high 이상 취약점 발견 (exit $secExit)"
        $report += "- [로그]:"
        $report += '```'
        $report += ($secOut | Out-String)
        $report += '```'
        $overallExit = 1
    }
    Pop-Location
} else {
    $report += "### 6. Security check - Skipped (-SkipSecurity)"
}
$report += ""

# ---------- 최종 요약 ----------
$report += "## 최종"
if ($overallExit -eq 0) {
    $report += "- [전체]: 통과"
} else {
    $report += "- [전체]: 실패 (Backend=$backendExit, API=$apiExit, PythonQA=$pythonQaExit, PythonTests=$pythonTestExit, E2E=$e2eExit, Security=$secExit)"
    $report += "- 실패 시: 5단계(실패 원인 분석) → 6단계(코드 수정·PR) → 7단계(재테스트) 루프. qa-automation-flow.mdc 참고."
}
$report += ""
$report += "---"
$report += "리포트 경로: $reportPath"

$reportText = $report -join "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($reportPath, $reportText, $utf8NoBom)
Write-Host $reportText

exit $overallExit
