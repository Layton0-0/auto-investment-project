# 전체 자동화 QA: Backend → API 시나리오 → Python 서비스 QA → Python 단위 테스트 → Frontend E2E → 보안 점검 → 통합 리포트
# 사용: .\scripts\run-full-qa.ps1
# 전제: 로컬 풀스택(docker-compose.local-full.yml) 기동 시 Backend 8080, data-collector 8001, prediction-service 8000, Frontend 등 동작.
# 환경 변수: QA_USERNAME, QA_PASSWORD (API 시나리오), QA_DATA_COLLECTOR_URL, QA_PREDICTION_URL (Python QA, 기본 8001/8000)
# Agent 실행 시 터미널 타임아웃 600000ms(10분) 이상 권장. .cursor/rules/script-run-timeouts.mdc

param(
    [switch] $SkipApiScenario,
    [switch] $SkipPythonQA,
    [switch] $SkipPythonTests,
    [switch] $SkipE2e,
    [switch] $SkipSecurity,
    [switch] $BackendNoUniqueDir
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$reportDir = Join-Path $repoRoot "plans\qa\reports"
$timestamp = Get-Date -Format "yyyyMMdd-HHmm"
$reportPath = Join-Path $reportDir "$timestamp-qa-report.md"

if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

$report = @()
$report += "# QA 통합 리포트 — $timestamp"
$report += ""
$report += "## 요약"
$report += ""

$overallExit = 0
$backendExit = 0
$apiExit = 0
$pythonQaExit = 0
$pythonTestExit = 0
$e2eExit = 0
$secExit = 0

# ---------- 1. Backend 테스트 ----------
$report += "### 1. Backend (JUnit)"
Push-Location (Join-Path $repoRoot "investment-backend")
try {
    if ($BackendNoUniqueDir) {
        $backendOut = & .\scripts\run-tests.ps1 -NoUniqueDir 2>&1
    } else {
        $backendOut = & .\scripts\run-tests.ps1 2>&1
    }
    $backendExit = $LASTEXITCODE
    if ($backendExit -eq 0) {
        $report += "- **결과**: 통과"
    } else {
        $report += "- **결과**: 실패 (exit $backendExit)"
        $report += "- **로그**:"
        $report += '```'
        $report += ($backendOut | Out-String)
        $report += '```'
        $overallExit = 1
    }
} finally {
    Pop-Location
}
$report += ""

# ---------- 2. API 시나리오 ----------
if (-not $SkipApiScenario) {
    $report += "### 2. API 시나리오 (run-api-qa.ps1)"
    if ($env:QA_USERNAME -and $env:QA_PASSWORD) {
        Push-Location $repoRoot
        try {
            $apiOut = & .\scripts\run-api-qa.ps1 2>&1
            $apiExit = $LASTEXITCODE
            if ($apiExit -eq 0) {
                $report += "- **결과**: 통과"
            } else {
                $report += "- **결과**: 실패 (exit $apiExit)"
                $report += "- **로그**:"
                $report += '```'
                $report += ($apiOut | Out-String)
                $report += '```'
                $overallExit = 1
            }
        } finally {
            Pop-Location
        }
    } else {
        $report += "- **결과**: 스킵 (QA_USERNAME, QA_PASSWORD 미설정)"
        $report += "- 재실행 시: `$env:QA_USERNAME='...'; `$env:QA_PASSWORD='...'; .\scripts\run-full-qa.ps1"
    }
} else {
    $report += "### 2. API 시나리오 — 스킵 (-SkipApiScenario)"
}
$report += ""

# ---------- 2.5 Python 서비스 QA (data-collector 8001, prediction-service 8000) ----------
if (-not $SkipPythonQA) {
    $report += "### 3. Python 서비스 QA (run-python-qa.ps1)"
    Push-Location $repoRoot
    try {
        $pythonQaOut = & .\scripts\run-python-qa.ps1 2>&1
        $pythonQaExit = $LASTEXITCODE
        if ($pythonQaExit -eq 0) {
            $report += "- **결과**: 통과 (data-collector health, prediction-service root/health/predict/batch 응답 검증)"
        } else {
            $report += "- **결과**: 실패 (exit $pythonQaExit)"
            $report += "- **로그**:"
            $report += '```'
            $report += ($pythonQaOut | Out-String)
            $report += '```'
            $overallExit = 1
        }
    } finally {
        Pop-Location
    }
} else {
    $report += "### 3. Python 서비스 QA — 스킵 (-SkipPythonQA)"
}
$report += ""

# ---------- 2.6 Python 단위 테스트 (prediction-service) ----------
# 전제: pip install -r requirements.txt 완료된 환경 (또는 venv 활성화 후 실행)
if (-not $SkipPythonTests) {
    $report += "### 4. Python 단위 테스트 (investment-prediction-service)"
    $pythonProj = Join-Path $repoRoot "investment-prediction-service"
    Push-Location $pythonProj
    try {
        $pythonTestOut = python -m unittest discover -s tests -p "test_*.py" -v 2>&1
        $pythonTestExit = $LASTEXITCODE
        if ($pythonTestExit -eq 0) {
            $report += "- **결과**: 통과"
        } else {
            $report += "- **결과**: 실패 (exit $pythonTestExit)"
            $report += "- **로그**:"
            $report += '```'
            $report += ($pythonTestOut | Out-String)
            $report += '```'
            $report += "- **의존성**: 해당 디렉터리에서 `pip install -r requirements.txt` 후 재실행"
            $overallExit = 1
        }
    } catch {
        $report += "- **결과**: 실행 오류 — $($_.Exception.Message)"
        $overallExit = 1
    } finally {
        Pop-Location
    }
} else {
    $report += "### 4. Python 단위 테스트 — 스킵 (-SkipPythonTests)"
}
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
            $report += "- **결과**: 통과"
        } else {
            $report += "- **결과**: 실패 (exit $e2eExit)"
            $report += "- **로그**:"
            $report += '```'
            $report += ($e2eOut | Out-String)
            $report += '```'
            $report += "- **스크린샷/트레이스**: investment-frontend/playwright-report/ 또는 test-results/"
            $overallExit = 1
        }
    } finally {
        Pop-Location
    }
} else {
    $report += "### 5. Frontend E2E — 스킵 (-SkipE2e)"
}
$report += ""

# ---------- 6. 보안 점검 ----------
if (-not $SkipSecurity) {
    $report += "### 6. 보안 점검 (npm audit)"
    Push-Location (Join-Path $repoRoot "investment-frontend")
    try {
        $prevErr = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $secOut = cmd /c "npm audit --audit-level=high" 2>&1
        $ErrorActionPreference = $prevErr
        $secExit = $LASTEXITCODE
        if ($secExit -eq 0) {
            $report += "- **결과**: 이상 없음 (high 이상 취약점 없음)"
        } else {
            $report += "- **결과**: high 이상 취약점 발견 (exit $secExit)"
            $report += "- **로그**:"
            $report += '```'
            $report += ($secOut | Out-String)
            $report += '```'
            # 보안은 경고만, 전체 QA 실패로 치지 않을 수 있음. 계획에 따라 실패로 기록.
            $overallExit = 1
        }
    } catch {
        $report += "- **결과**: 실행 오류 — $($_.Exception.Message)"
    } finally {
        Pop-Location
    }
} else {
    $report += "### 6. 보안 점검 — 스킵 (-SkipSecurity)"
}
$report += ""

# ---------- 최종 요약 ----------
$report += "## 최종"
if ($overallExit -eq 0) {
    $report += "- **전체**: 통과"
} else {
    $report += "- **전체**: 실패 (Backend=$backendExit, API=$apiExit, PythonQA=$pythonQaExit, PythonTests=$pythonTestExit, E2E=$e2eExit, Security=$secExit)"
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
