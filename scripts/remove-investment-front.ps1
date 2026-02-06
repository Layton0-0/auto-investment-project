# investment-front 폴더 삭제 (다른 프로세스가 잡고 있으면 실패할 수 있음)
# 사용: Cursor를 완전히 종료한 뒤, 탐색기에서 이 스크립트 우클릭 → "PowerShell에서 실행"
# 또는: PowerShell(새 창)에서 .\scripts\remove-investment-front.ps1
$path = Join-Path (Split-Path $PSScriptRoot -Parent) "investment-front"
if (Test-Path $path) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction Stop
    Write-Host "Deleted: $path" -ForegroundColor Green
} else {
    Write-Host "Not found: $path" -ForegroundColor Yellow
}
