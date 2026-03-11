# 백테스트 자동 실행 스크립트
# 사용: .\scripts\run-backtest.ps1 [-StartDate "2024-01-01"] [-EndDate "2024-12-31"] [-Market "KR"] [-StrategyType "SHORT_TERM"] [-InitialCapital 100000000]
# Backend가 http://localhost:8080 (또는 E2E_API_PORT)에서 동작 중이어야 함.
# CI/스케줄에서 백테스트만 실행할 때 사용. 전체 QA는 run-full-qa.ps1.

param(
    [string]$StartDate = (Get-Date).AddMonths(-12).ToString("yyyy-MM-dd"),
    [string]$EndDate = (Get-Date).ToString("yyyy-MM-dd"),
    [string]$Market = "KR",
    [string]$StrategyType = "SHORT_TERM",
    [decimal]$InitialCapital = 100000000,
    [string]$BaseUrl = "http://localhost:8080"
)

$ErrorActionPreference = "Stop"
$body = @{
    startDate     = $StartDate
    endDate       = $EndDate
    market        = $Market
    strategyType  = $StrategyType
    initialCapital = $InitialCapital
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/v1/backtest" -Method Post -Body $body -ContentType "application/json" -TimeoutSec 120
    Write-Host "Backtest completed. CAGR: $($response.cagr), MDD: $($response.mddPct), Sharpe: $($response.sharpeRatio)" -ForegroundColor Green
    $response
} catch {
    Write-Host "Backtest request failed: $_" -ForegroundColor Red
    exit 1
}
