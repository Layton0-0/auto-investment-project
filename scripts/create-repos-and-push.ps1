# GitHub 레포 생성 및 푸시 (investment- 접두사)
# 사전: gh auth login 완료 후 실행
# 사용: .\scripts\create-repos-and-push.ps1

$ErrorActionPreference = "Stop"
$owner = "Layton0-0"
$repos = @(
    @{ Name = "investment-infra"; Path = "investment-infra" },
    @{ Name = "investment-backend"; Path = "investment-backend" },
    @{ Name = "investment-prediction-service"; Path = "investment-prediction-service" },
    @{ Name = "investment-data-collector"; Path = "investment-data-collector" },
    @{ Name = "investment-frontend"; Path = "investment-frontend" }
)

$baseDir = Split-Path $PSScriptRoot -Parent
if (-not (Test-Path (Join-Path $baseDir "investment-infra"))) {
    $baseDir = $PSScriptRoot
}
$baseDir = (Resolve-Path $baseDir).Path

# gh 로그인 확인 (또는 GITHUB_TOKEN으로 로그인)
Write-Host "Checking gh auth..."
$authOk = $false
try {
    gh auth status 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) { $authOk = $true }
} catch {}
if (-not $authOk -and $env:GITHUB_TOKEN) {
    Write-Host "Logging in with GITHUB_TOKEN..."
    $env:GITHUB_TOKEN | gh auth login --with-token
    $authOk = $true
}
if (-not $authOk) {
    Write-Host "ERROR: Run 'gh auth login' and complete the browser step, or set GITHUB_TOKEN and run again." -ForegroundColor Red
    exit 1
}

foreach ($r in $repos) {
    $name = $r.Name
    $relPath = $r.Path
    $dir = Join-Path $baseDir $relPath
    if (-not (Test-Path $dir)) {
        Write-Host "Skip $name (path not found: $dir)"
        continue
    }
    Push-Location $dir
    try {
        # 레포 존재 여부 확인 후 없으면 생성
        $exists = $false
        try {
            gh repo view "$owner/$name" 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { $exists = $true }
        } catch {}
        if (-not $exists) {
            Write-Host "Creating repo $name..."
            git remote remove origin 2>$null
            gh repo create $name --public --source=. --remote=origin --push
            git push origin develop 2>$null
        } else {
            if (-not (git remote get-url origin 2>$null)) {
                git remote add origin "https://github.com/$owner/$name.git"
            }
            Write-Host "Pushing $name..."
            git push -u origin main 2>&1
            git push origin develop 2>$null
        }
        Write-Host "OK: $name" -ForegroundColor Green
    } finally {
        Pop-Location
    }
}
Write-Host "Done."
