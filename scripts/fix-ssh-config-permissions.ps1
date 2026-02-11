# SSH config 및 키 파일 권한 수정 (OpenSSH "Bad owner or permissions" 해결)
# **관리자 권한 PowerShell**에서 실행 시 실행 정책 오류가 나면:
#   방법 A) 이 세션만 Bypass 후 스크립트 실행:
#     Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process
#     & "C:\Users\layton\Desktop\studyCode\Project\auto-investment-project\scripts\fix-ssh-config-permissions.ps1"
#   방법 B) fix-ssh-config-permissions.cmd 를 "관리자 권한으로 실행"
# 참고: investment-backend/docs/06-deployment/05-multi-vps-oracle-aws-cicd.md §9.6

$ErrorActionPreference = "Stop"
$me = $env:USERNAME

$sshDir = "$env:USERPROFILE\.ssh"
$configPath = "$sshDir\config"
$keyOsaka = "C:\Users\layton\OneDrive - HKNC\study\cloud\key\neekly\layton\e2\ssh-key-2025-07-22.key"
$keyKorea = "C:\Users\layton\OneDrive - HKNC\study\cloud\key\neekly\db\ssh-key-2025-07-20.key"

Write-Host "User: $me" -ForegroundColor Cyan
Write-Host ""

# 0) 소유권 획득 (takeown) — 액세스 거부 시 반드시 먼저 실행. 관리자 권한 필요.
Write-Host "[0] Taking ownership of .ssh and keys..." -ForegroundColor Yellow
takeown /f $sshDir /r /d y 2>$null
takeown /f $configPath 2>$null
takeown /f $keyOsaka 2>$null
takeown /f $keyKorea 2>$null
Write-Host "  OK" -ForegroundColor Green

# 1) .ssh 폴더
Write-Host "[1/4] .ssh folder..." -ForegroundColor Yellow
icacls $sshDir /inheritance:r
icacls $sshDir /grant "${me}:(OI)(CI)F"
Write-Host "  OK" -ForegroundColor Green

# 2) config 파일
Write-Host "[2/4] config file..." -ForegroundColor Yellow
if (Test-Path $configPath) {
    icacls $configPath /inheritance:r
    icacls $configPath /grant "${me}:F"
    Write-Host "  OK" -ForegroundColor Green
} else {
    Write-Host "  Skip (file not found)" -ForegroundColor Gray
}

# 3) Osaka 키
Write-Host "[3/4] Key (Osaka)..." -ForegroundColor Yellow
if (Test-Path $keyOsaka) {
    icacls $keyOsaka /inheritance:r
    icacls $keyOsaka /grant "${me}:F"
    Write-Host "  OK" -ForegroundColor Green
} else {
    Write-Host "  Skip (not found: $keyOsaka)" -ForegroundColor Gray
}

# 4) Korea 키
Write-Host "[4/4] Key (Korea)..." -ForegroundColor Yellow
if (Test-Path $keyKorea) {
    icacls $keyKorea /inheritance:r
    icacls $keyKorea /grant "${me}:F"
    Write-Host "  OK" -ForegroundColor Green
} else {
    Write-Host "  Skip (not found: $keyKorea)" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Done. Test: ssh -T oci-osaka-yoon" -ForegroundColor Cyan
