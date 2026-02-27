# 평일 18:00(KST)에 실행되는 일일 GitHub 동기화.
# 전체 레포(루트) 및 .gitmodules에 등록된 모든 서브모듈에 대해 변경사항 커밋·푸시.
# 주말(토·일)에는 실행해도 아무 작업하지 않고 종료.
# 사용: .\scripts\daily-git-sync.ps1 (작업 스케줄러에서 호출 시 프로젝트 루트를 WorkingDirectory로 지정)

# git 경고/서브모듈 fatal이 스크립트 중단을 유발하지 않도록 Continue 사용
$ErrorActionPreference = "Continue"
$RepoRoot = if ($PSScriptRoot) { Split-Path -Parent $PSScriptRoot } else { Get-Location }
Set-Location $RepoRoot

# 평일만 실행 (월=1 ~ 금=5). 토(6), 일(0)은 스킵
$dayOfWeek = [int](Get-Date).DayOfWeek  # 0=Sunday, 1=Monday, ..., 6=Saturday
if ($dayOfWeek -eq 0 -or $dayOfWeek -eq 6) {
    Write-Host "Daily git sync skipped (weekend). DayOfWeek=$dayOfWeek"
    exit 0
}

$dateStr = Get-Date -Format "yyyy-MM-dd HH:mm"
$commitMsg = "Daily sync $dateStr"

function Sync-Submodule {
    param([string]$Path, [string]$Name)
    $fullPath = Join-Path $RepoRoot $Path
    if (-not (Test-Path $fullPath)) { return }
    # 미초기화/미채워진 서브모듈 스킵 (.git 없거나 비어 있음)
    $gitDir = Join-Path $fullPath ".git"
    if (-not (Test-Path $gitDir)) { Write-Host "Skip (not populated): $Name"; return }
    Push-Location $fullPath
    try {
        git add -A 2>$null
        git diff --staged --quiet 2>$null
        if ($LASTEXITCODE -ne 0) {
            git commit -m $commitMsg 2>&1
            git push 2>&1
            Write-Host "Pushed submodule: $Name"
        }
    } catch {
        Write-Warning "Submodule $Name : $_"
    } finally {
        Pop-Location
    }
}

# .gitmodules에 있는 서브모듈만 순서대로 처리 (git config로 path 목록 조회)
$submodulePaths = git config --file (Join-Path $RepoRoot ".gitmodules") --get-regexp path | ForEach-Object { ($_ -split " ", 2)[1] }
foreach ($path in $submodulePaths) {
    $name = Split-Path -Leaf $path
    Sync-Submodule -Path $path -Name $name
}

# 루트 레포: 서브모듈 포인터 변경 + 루트 내 파일 변경 (add 실패 시에도 스크립트는 계속)
try { git add -A 2>$null } catch { }
git diff --staged --quiet 2>$null
if ($LASTEXITCODE -ne 0) {
    git commit -m $commitMsg 2>&1
    git push 2>&1
    Write-Host "Pushed root repo."
}

Write-Host "Daily git sync finished: $dateStr"
