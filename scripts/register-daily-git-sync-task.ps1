# Windows 작업 스케줄러에 "일일 GitHub 동기화" 등록
# 평일(월~금) 오후 6시(한국시간 18:00)에 실행. PC 재시작 후에도 작업 유지.
# 실행: PowerShell에서 프로젝트 루트로 이동 후 .\scripts\register-daily-git-sync-task.ps1
# (관리자 권한 불필요. 현재 사용자로 작업 등록)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$SyncScript = Join-Path $ScriptDir "daily-git-sync.ps1"

if (-not (Test-Path $SyncScript)) {
    Write-Error "Sync script not found: $SyncScript"
    exit 1
}

$TaskName = "Investment-Daily-Git-Sync"
# 평일 18:00 (시스템 로컬 시간. 한국 시간 사용 시 PC 시간대를 (UTC+09:00) 서울로 설정)
$Action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$SyncScript`"" `
    -WorkingDirectory $RepoRoot
$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday, Tuesday, Wednesday, Thursday, Friday -At "18:00"
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$Principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Limited

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Force | Out-Null
Write-Host "Registered scheduled task: $TaskName"
Write-Host "  Run on weekdays (Mon-Fri) at 18:00 local time. Script: $SyncScript"
Write-Host "  For 18:00 KST, set Windows timezone to (UTC+09:00) Seoul."
Write-Host "  To remove: Unregister-ScheduledTask -TaskName $TaskName"
