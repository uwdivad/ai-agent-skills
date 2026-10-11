#requires -Version 5.1
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('All','Claude','Codex')][string]$Agent = 'All',
    [switch]$Force,
    [switch]$CopyFallback
)
$ErrorActionPreference = 'Stop'
$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$source = Join-Path $repo 'skills'
$destinations = @()
if ($Agent -in @('All','Claude')) { $destinations += (Join-Path $HOME '.claude/skills') }
if ($Agent -in @('All','Codex')) { $destinations += (Join-Path $HOME '.agents/skills') }
$manifest = Join-Path $repo '.skill-install-state.json'
$records = @()
if (Test-Path -LiteralPath $manifest) {
    $loaded = Get-Content -LiteralPath $manifest -Raw | ConvertFrom-Json
    $records = @($loaded | Where-Object { $null -ne $_ })
}
foreach ($dest in $destinations) {
    if (-not (Test-Path -LiteralPath $dest) -and $PSCmdlet.ShouldProcess($dest, 'Create directory')) {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
    foreach ($skill in (Get-ChildItem -LiteralPath $source -Directory)) {
        if (-not (Test-Path -LiteralPath (Join-Path $skill.FullName 'SKILL.md'))) { throw "Missing SKILL.md: $($skill.FullName)" }
        $target = Join-Path $dest $skill.Name
        $existing = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
        if ($null -ne $existing) {
            if (-not $Force) { Write-Warning "Skipping occupied path (use -Force to replace): $target"; continue }
            if ($PSCmdlet.ShouldProcess($target, 'Remove existing entry')) {
                if (($existing.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
                    $existing.Delete() # Removes the link, NEVER its target
                } else {
                    # Refuse to delete existing real directories, even with -Force
                    Write-Warning "Refusing to replace a real directory: $target (move it manually)"
                    continue
                }
            } else { continue }
        }
        if (-not $PSCmdlet.ShouldProcess($target, "Link skill to $($skill.FullName)")) { continue }
        $mode = 'symlink'
        try { New-Item -ItemType SymbolicLink -Path $target -Target $skill.FullName -ErrorAction Stop | Out-Null }
        catch {
            if (-not $CopyFallback) { throw "Cannot create symlink at $target. Enable Windows Developer Mode or run elevated, or pass -CopyFallback. Details: $_" }
            Copy-Item -LiteralPath $skill.FullName -Destination $target -Recurse -Force
            $mode = 'copy'
            Write-Warning "Installed copy at $target. Copies do not update automatically; re-run installer after changes."
        }
        $records = @($records | Where-Object { $_.path -ne $target })
        $records += [pscustomobject]@{ path = $target; source = $skill.FullName; mode = $mode }
        Write-Host "Installed $($skill.Name) -> $target ($mode)"
    }
}
if (-not $WhatIfPreference) { $records | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $manifest -Encoding UTF8 }
Write-Host 'Restart Claude Code and Codex to refresh skill discovery.'
