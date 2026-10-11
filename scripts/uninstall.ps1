#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param([ValidateSet('All','Claude','Codex')][string]$Agent = 'All')
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$manifest = Join-Path $repo '.skill-install-state.json'
if (-not (Test-Path -LiteralPath $manifest)) { Write-Host 'Nothing recorded for uninstall.'; exit 0 }
$records = @(Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json)
$remaining = @()
foreach ($entry in $records) {
    $isClaude = $entry.path.StartsWith((Join-Path $HOME '.claude/skills') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
    $isCodex = $entry.path.StartsWith((Join-Path $HOME '.agents/skills') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)
    if (($Agent -eq 'Claude' -and -not $isClaude) -or ($Agent -eq 'Codex' -and -not $isCodex)) { $remaining += $entry; continue }
    $item = Get-Item -LiteralPath $entry.path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { continue }
    if ($entry.mode -ne 'symlink' -or (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq 0)) {
        Write-Warning "Not removing non-symlink entry: $($entry.path) (remove manually if desired)"
        $remaining += $entry
        continue
    }
    $actual = $item.Target
    if ($actual -is [array]) { $actual = $actual[0] }
    if ([string]::IsNullOrWhiteSpace($actual) -or ([IO.Path]::GetFullPath($actual) -ne [IO.Path]::GetFullPath($entry.source))) {
        Write-Warning "Link target changed; not removing: $($entry.path)"
        $remaining += $entry
        continue
    }
    if ($PSCmdlet.ShouldProcess($entry.path, 'Remove recorded symbolic link')) {
        $item.Delete()
        Write-Host "Unlinked $($entry.path)"
    } else { $remaining += $entry }
}
if (-not $WhatIfPreference) { $remaining | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifest -Encoding UTF8 }
