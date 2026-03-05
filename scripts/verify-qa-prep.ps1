# QA-Prep: Full stack and QA environment verification
# 사용: .\scripts\verify-qa-prep.ps1
# 전제: run-full-qa.ps1 실행 전 로컬 풀스택 기동 및 인증 정보 설정 여부 검사.
# 검사 항목: Backend 8080, data-collector 8001, prediction 8000 응답, QA_USERNAME/QA_PASSWORD 또는 SUPER_ADMIN_* in backend .env

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir
$backendEnvPath = Join-Path (Join-Path $repoRoot "investment-backend") ".env"

$allOk = $true
$report = @()

function Test-PortListening {
    param([int]$Port, [string]$Label)
    try {
        $conn = New-Object System.Net.Sockets.TcpClient
        $async = $conn.ConnectAsync("127.0.0.1", $Port)
        $completed = $async.Wait(3000)
        $conn.Close()
        if ($completed -and $conn.Connected) {
            $script:report += "[OK] $Label port $Port responding"
            return $true
        }
    } catch {}
    $script:report += "[FAIL] $Label port $Port not responding (start stack: investment-infra\scripts\local-up.ps1)"
    $script:allOk = $false
    return $false
}

# 1. Backend 8080
Test-PortListening -Port 8080 -Label "Backend" | Out-Null

# 2. data-collector 8001
Test-PortListening -Port 8001 -Label "data-collector" | Out-Null

# 3. prediction-service 8000
Test-PortListening -Port 8000 -Label "prediction-service" | Out-Null

# 4. Auth credentials for API scenario
$authOk = $false
if ($env:QA_USERNAME -and $env:QA_PASSWORD) {
    $report += "[OK] QA_USERNAME and QA_PASSWORD set (API scenario)"
    $authOk = $true
}
if (-not $authOk -and (Test-Path $backendEnvPath)) {
    $lines = Get-Content $backendEnvPath -Raw -ErrorAction SilentlyContinue
    $hasUser = $lines -and ($lines -match 'SUPER_ADMIN_USERNAME=\s*\S+')
    $hasPass = $lines -and ($lines -match 'SUPER_ADMIN_PASSWORD=\s*\S+')
    if ($hasUser -and $hasPass) {
        $report += "[OK] investment-backend/.env has SUPER_ADMIN_USERNAME and SUPER_ADMIN_PASSWORD (run-full-qa will load for API scenario)"
        $authOk = $true
    }
}
if (-not $authOk) {
    $report += "[FAIL] Set QA_USERNAME and QA_PASSWORD, or SUPER_ADMIN_USERNAME and SUPER_ADMIN_PASSWORD in investment-backend/.env"
    $allOk = $false
}

# 5. Python QA URLs (optional; run-python-qa defaults to 8001/8000)
$dcUrl = if ($env:QA_DATA_COLLECTOR_URL) { $env:QA_DATA_COLLECTOR_URL } else { "http://localhost:8001 (default)" }
$predUrl = if ($env:QA_PREDICTION_URL) { $env:QA_PREDICTION_URL } else { "http://localhost:8000 (default)" }
$report += "[INFO] QA_DATA_COLLECTOR_URL=$dcUrl, QA_PREDICTION_URL=$predUrl"

$report | ForEach-Object { Write-Host $_ }
if ($allOk) {
    Write-Host ""
    Write-Host "QA-Prep passed. You can run .\scripts\run-full-qa.ps1"
    exit 0
} else {
    Write-Host ""
    Write-Host "QA-Prep failed. Fix the items above then re-run."
    exit 1
}
