# Copy SSH keys to %USERPROFILE%\.ssh\ with names that have no spaces,
# so Cursor SSH MCP can resolve the path without ENOENT.
# Usage:
#   .\scripts\setup-ssh-keys-for-mcp.ps1 -OsakaKey "D:\path\to\osaka.key" -KoreaKey "D:\path\to\korea.key" -MumbaiKey "D:\path\to\mumbai.key"
# Then use the printed paths in your .cursor\mcp.json (--key=...).
param(
    [string]$OsakaKey,
    [string]$KoreaKey,
    [string]$MumbaiKey
)

$sshDir = Join-Path $env:USERPROFILE ".ssh"
if (-not (Test-Path $sshDir)) {
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}

$userName = $env:USERNAME
$basePath = "C:/Users/$userName/.ssh"

function Copy-KeyIfGiven {
    param([string]$Source, [string]$DestName)
    if ([string]::IsNullOrWhiteSpace($Source)) { return $null }
    if (-not (Test-Path $Source)) {
        Write-Warning "Not found: $Source"
        return $null
    }
    $dest = Join-Path $sshDir $DestName
    Copy-Item -Path $Source -Destination $dest -Force
    Write-Host "Copied to $dest"
    return "$basePath/$DestName"
}

$osakaDest  = Copy-KeyIfGiven -Source $OsakaKey  -DestName "oci_osaka.key"
$koreaDest  = Copy-KeyIfGiven -Source $KoreaKey  -DestName "oci_korea.key"
$mumbaiDest = Copy-KeyIfGiven -Source $MumbaiKey -DestName "oci_mumbai.key"

Write-Host ""
Write-Host "Use these --key= values in C:\Users\$userName\.cursor\mcp.json (no quotes around path):"
if ($osakaDest)  { Write-Host "  Osaka:  --key=$osakaDest" }
if ($koreaDest)  { Write-Host "  Korea:  --key=$koreaDest" }
if ($mumbaiDest) { Write-Host "  Mumbai: --key=$mumbaiDest" }
