# Python 서비스 QA: data-collector(8001), prediction-service(8000) HTTP 엔드포인트 및 응답 본문 검증.
# 사용: .\scripts\run-python-qa.ps1
# 환경 변수: QA_DATA_COLLECTOR_URL (기본 http://localhost:8001), QA_PREDICTION_URL (기본 http://localhost:8000)
# 전제: docker-compose.local-full.yml 로 풀스택 기동 시 두 서비스가 8001, 8000에서 동작 중.

param(
    [string] $DataCollectorUrl = $env:QA_DATA_COLLECTOR_URL,
    [string] $PredictionUrl = $env:QA_PREDICTION_URL
)

$ErrorActionPreference = "Stop"
if (-not $DataCollectorUrl) { $DataCollectorUrl = "http://localhost:8001" }
if (-not $PredictionUrl) { $PredictionUrl = "http://localhost:8000" }

$results = @()
$allPass = $true

function Test-PythonEndpoint {
    param(
        [string] $Name,
        [string] $Method,
        [string] $Url,
        [int[]] $ExpectedStatus,
        [hashtable] $Body = $null,
        [string[]] $RequiredKeys = @(),
        [scriptblock] $CustomValidator = $null
    )
    $statusStr = "PASS"
    $detail = ""
    try {
        $params = @{
            Uri             = $Url
            Method          = $Method
            UseBasicParsing  = $true
            TimeoutSec      = 30
        }
        if ($Body) {
            $params.Body = ($Body | ConvertTo-Json -Compress)
            $params.ContentType = "application/json"
        }
        $r = Invoke-WebRequest @params
        $status = $r.StatusCode
        $okStatus = $status -in $ExpectedStatus
        if (-not $okStatus) {
            $script:allPass = $false
            $statusStr = "FAIL"
            $detail = "status $status (expected: $($ExpectedStatus -join '|'))"
        } else {
            $content = $null
            try {
                $content = $r.Content | ConvertFrom-Json
            } catch {
                $content = $r.Content
            }
            foreach ($key in $RequiredKeys) {
                $hasKey = $null -ne $content -and ($content.PSObject.Properties.Name -contains $key)
                if (-not $hasKey) {
                    $script:allPass = $false
                    $statusStr = "FAIL"
                    $detail = "missing key in response: $key"
                    break
                }
            }
            if ($statusStr -eq "PASS" -and $CustomValidator) {
                try {
                    $customOk = & $CustomValidator $content
                    if (-not $customOk) {
                        $script:allPass = $false
                        $statusStr = "FAIL"
                        $detail = "custom validation failed"
                    }
                } catch {
                    $script:allPass = $false
                    $statusStr = "FAIL"
                    $detail = "validator error: $($_.Exception.Message)"
                }
            }
            if ($statusStr -eq "PASS" -and -not $detail) { $detail = "OK" }
        }
    } catch {
        $script:allPass = $false
        $statusStr = "FAIL"
        $status = if ($_.Exception.Response) { [int] $_.Exception.Response.StatusCode } else { 0 }
        $detail = "error: $($_.Exception.Message)"
    }
    $script:results += [pscustomobject]@{ Name = $Name; Status = $statusStr; Detail = $detail }
    $color = if ($statusStr -eq "PASS") { "Green" } else { "Red" }
    Write-Host "PYTHON_QA $statusStr $Name - $detail" -ForegroundColor $color
}

# ---------- Data Collector (8001) ----------
Write-Host "--- Data Collector ($DataCollectorUrl) ---" -ForegroundColor Cyan
$dcHealthCheck = { param($content) $content -and $content.status -eq "ok" }
Test-PythonEndpoint -Name "data-collector GET /health" -Method GET -Url "$DataCollectorUrl/health" -ExpectedStatus @(200) -RequiredKeys @("status") -CustomValidator $dcHealthCheck

# ---------- Prediction Service (8000) ----------
Write-Host "--- Prediction Service ($PredictionUrl) ---" -ForegroundColor Cyan
$rootCheck = { param($content) $content -and $content.service -and $content.version -and ($content.status -eq "running") }
Test-PythonEndpoint -Name "prediction GET /" -Method GET -Url $PredictionUrl -ExpectedStatus @(200) -RequiredKeys @("service", "version", "status") -CustomValidator $rootCheck

$predHealthCheck = { param($content) $content -and $content.status -eq "ok" -and $content.service -eq "ai-prediction-service" }
Test-PythonEndpoint -Name "prediction GET /api/v1/health" -Method GET -Url "$PredictionUrl/api/v1/health" -ExpectedStatus @(200) -RequiredKeys @("status", "service", "timestamp") -CustomValidator $predHealthCheck

# POST /api/v1/predict (minimal body) — 응답 스키마 검증
$predictBody = @{ symbol = "005930"; predictionMinutes = 60 }
try {
    $predResp = Invoke-RestMethod -Uri "$PredictionUrl/api/v1/predict" -Method Post -Body ($predictBody | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    $required = @("symbol", "currentPrice", "predictedPrice", "confidence", "direction", "modelType", "predictionMinutes")
    $missing = $required | Where-Object { $predResp.PSObject.Properties.Name -notcontains $_ }
    if ($missing.Count -gt 0) {
        $allPass = $false
        $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict response keys"; Status = "FAIL"; Detail = "missing: $($missing -join ', ')" }
        Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict — missing keys: $($missing -join ', ')" -ForegroundColor Red
    } else {
        $symbolOk = $predResp.symbol -eq "005930"
        $minsOk = $predResp.predictionMinutes -eq 60
        if (-not $symbolOk -or -not $minsOk) {
            $allPass = $false
            $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict values"; Status = "FAIL"; Detail = "symbol or predictionMinutes mismatch" }
            Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict — symbol/predictionMinutes mismatch" -ForegroundColor Red
        } else {
            $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict"; Status = "PASS"; Detail = "OK" }
            Write-Host "PYTHON_QA PASS prediction POST /api/v1/predict — symbol=$($predResp.symbol), direction=$($predResp.direction)" -ForegroundColor Green
        }
    }
} catch {
    $allPass = $false
    $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict"; Status = "FAIL"; Detail = $_.Exception.Message }
    Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict — $($_.Exception.Message)" -ForegroundColor Red
}

# POST /api/v1/predict/batch — 배열 반환 및 길이·요소 검증
$batchBody = @(
    @{ symbol = "005930"; predictionMinutes = 60 },
    @{ symbol = "000660"; predictionMinutes = 30 }
)
try {
    $batchResp = Invoke-RestMethod -Uri "$PredictionUrl/api/v1/predict/batch" -Method Post -Body ($batchBody | ConvertTo-Json) -ContentType "application/json" -UseBasicParsing
    if (-not ($batchResp -is [Array]) -or $batchResp.Count -ne 2) {
        $allPass = $false
        $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict/batch"; Status = "FAIL"; Detail = "expected array length 2, got $($batchResp.Count)" }
        Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict/batch — expected length 2" -ForegroundColor Red
    } elseif ($batchResp[0].symbol -ne "005930" -or $batchResp[1].symbol -ne "000660") {
        $allPass = $false
        $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict/batch"; Status = "FAIL"; Detail = "symbol order mismatch" }
        Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict/batch — symbol order mismatch" -ForegroundColor Red
    } else {
        $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict/batch"; Status = "PASS"; Detail = "OK" }
        Write-Host "PYTHON_QA PASS prediction POST /api/v1/predict/batch" -ForegroundColor Green
    }
} catch {
    $allPass = $false
    $results += [pscustomobject]@{ Name = "prediction POST /api/v1/predict/batch"; Status = "FAIL"; Detail = $_.Exception.Message }
    Write-Host "PYTHON_QA FAIL prediction POST /api/v1/predict/batch — $($_.Exception.Message)" -ForegroundColor Red
}

if ($allPass) {
    Write-Host "PYTHON_QA all passed ($($results.Count) checks)" -ForegroundColor Green
    exit 0
} else {
    $failCount = ($results | Where-Object { $_.Status -eq "FAIL" }).Count
    Write-Host "PYTHON_QA $failCount failed of $($results.Count)" -ForegroundColor Red
    exit 1
}
