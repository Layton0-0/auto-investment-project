<#
.SYNOPSIS
  Moves eligible entries from docs/program/progress.md Session log into monthly archive + progress-index.jsonl.
.DESCRIPTION
  Rolls up bullets under ## Session log when entry date is older than 7 days OR line length > 300 chars.
  Skips lines already containing [archived].
.PARAMETER WhatIf
  If set, only reports actions without writing files.
#>
param(
    [switch]$WhatIf
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Utf8NoBom = New-Object System.Text.UTF8Encoding $false
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$progressPath = Join-Path $root 'docs/program/progress.md'
$archiveDir = Join-Path $root 'docs/program/archive'
$indexPath = Join-Path $archiveDir 'progress-index.jsonl'
$marker = '## Session log (rollup processes below)'

if (-not (Test-Path -LiteralPath $progressPath)) {
    Write-Error "Missing $progressPath"
}

New-Item -ItemType Directory -Force -Path $archiveDir | Out-Null

$lines = [System.Collections.Generic.List[string]]::new()
$lines.AddRange([string[]](Get-Content -LiteralPath $progressPath -Encoding utf8))

$markerIdx = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -eq $marker) {
        $markerIdx = $i
        break
    }
}
if ($markerIdx -lt 0) {
    Write-Error "Marker line not found: $marker"
}

$today = (Get-Date).Date
$cutoff = $today.AddDays(-7)

function Get-ArchiveMonthFile {
    param([string]$DateStr)
    $d = [datetime]::ParseExact($DateStr, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
    Join-Path $archiveDir ("progress-{0:yyyy-MM}.md" -f $d)
}

function Append-ArchiveEntry {
    param(
        [string]$ArchiveFile,
        [string]$Anchor,
        [string]$Body,
        [hashtable]$Meta,
        [string]$IndexPath,
        [bool]$Dry
    )
    $block = "`n### $Anchor`n$Body`n"
    if ($Dry) {
        Write-Host "[WhatIf] Append to $ArchiveFile : $Anchor"
    }
    else {
        if (-not (Test-Path -LiteralPath $ArchiveFile)) {
            $header = "# Progress archive — $(Split-Path $ArchiveFile -Leaf)`n`n"
            [System.IO.File]::WriteAllText($ArchiveFile, $header, $Utf8NoBom)
        }
        [System.IO.File]::AppendAllText($ArchiveFile, $block, $Utf8NoBom)
    }

    $relArchive = "docs/program/archive/" + (Split-Path $ArchiveFile -Leaf)
    $obj = [ordered]@{
        ts        = (Get-Date).ToString('o')
        archiveFile = $relArchive.Replace('\', '/')
        anchor    = $Anchor
        files     = $Meta.files
        scope     = $Meta.scope
        actor     = $Meta.actor
    }
    $json = ($obj | ConvertTo-Json -Compress)
    if ($Dry) {
        Write-Host "[WhatIf] JSONL: $json"
    }
    else {
        [System.IO.File]::AppendAllText($IndexPath, $json + "`n", $Utf8NoBom)
    }
}

$currentDateStr = $null
$newAfter = [System.Collections.Generic.List[string]]::new()
$i = $markerIdx + 1

while ($i -lt $lines.Count) {
    $line = $lines[$i]

    if ($line -match '^### (\d{4}-\d{2}-\d{2})\s*$') {
        $currentDateStr = $Matches[1]
        $newAfter.Add($line)
        $i++
        continue
    }

    if ($line -match '^\s*$') {
        $newAfter.Add($line)
        $i++
        continue
    }

    if ($line -match '^\[archived\]' -or $line -match '\[archived\]') {
        $newAfter.Add($line)
        $i++
        continue
    }

    if ($line -match '^-\s+\[') {
        if (-not $currentDateStr) {
            $newAfter.Add($line)
            $i++
            continue
        }

        $entryDate = [datetime]::ParseExact($currentDateStr, 'yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
        $tooOld = ($entryDate -lt $cutoff)
        $tooLong = ($line.Length -gt 300)

        if (-not $tooOld -and -not $tooLong) {
            $newAfter.Add($line)
            $i++
            continue
        }

        $timePart = '0000'
        $actor = 'unknown'
        if ($line -match '^\-\s+\[([^\]]+)\]\s+([^|]+)\|') {
            $timePart = $Matches[1].Trim() -replace ':', ''
            $actor = $Matches[2].Trim()
        }
        $ds = $currentDateStr.Replace('-', '')
        $anchor = "entry-$ds-$timePart"
        $summary = if ($line.Length -gt 80) { $line.Substring(0, 77) + '...' } else { $line }
        $summary = $summary -replace '^\-\s+', ''

        $scope = $summary
        if ($line -match '\|\s*scope:\s*([^|]+)') {
            $scope = $Matches[1].Trim()
        }
        $files = ''
        if ($line -match '\|\s*files:\s*([^|]+)') {
            $files = $Matches[1].Trim()
        }

        $archiveFile = Get-ArchiveMonthFile -DateStr $currentDateStr
        Append-ArchiveEntry -ArchiveFile $archiveFile -Anchor $anchor -Body $line -Meta @{
            files = $files
            scope = $scope
            actor = $actor
        } -IndexPath $indexPath -Dry:$WhatIf

        $pointer = "- [archived] $currentDateStr → $(Split-Path $archiveFile -Leaf)#$anchor — $summary"
        $newAfter.Add($pointer)
        $i++
        continue
    }

    $newAfter.Add($line)
    $i++
}

# Trim duplicate blank lines before ### and collapse empty date sections (optional minimal)
$final = [System.Collections.Generic.List[string]]::new()
for ($j = 0; $j -le $markerIdx; $j++) {
    $final.Add($lines[$j])
}
foreach ($l in $newAfter) {
    $final.Add($l)
}

$outText = ($final -join "`n") + "`n"
if ($WhatIf) {
    Write-Host 'WhatIf complete (no files written).'
    exit 0
}

[System.IO.File]::WriteAllText($progressPath, $outText, $Utf8NoBom)
Write-Host "rollup-progress: updated $progressPath"
