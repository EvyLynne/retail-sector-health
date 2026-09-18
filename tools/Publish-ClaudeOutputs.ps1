<#
.SYNOPSIS
    Publishes everything in the "Claude outputs" drop folder into the repository.

.DESCRIPTION
    A convenience wrapper over Publish-ToRepo.ps1 with both paths already set,
    for the recurring loop: Claude delivers a file -> you save it into
    "Claude outputs" -> you run this -> it lands in the right repo folder and
    is staged in git.

    It deliberately does NOT carry its own routing table. Publish-ToRepo.ps1
    owns that, and this script calls it, so the two can never disagree about
    where a file belongs. Add a new file type there, not here.

    Copies by default. Nothing in the drop folder is moved or deleted unless
    you ask for -Archive.

.PARAMETER RepoRoot
    The cloned repository. Defaults to X:\retail-sector-health.

.PARAMETER StagingPath
    The drop folder. Defaults to the "Claude outputs" folder under Documents.

.PARAMETER Archive
    After a successful copy, move the published files into a dated subfolder
    (_published\yyyy-MM-dd) so the drop folder is empty for the next batch.
    Nothing is deleted - the files are moved, not removed.

.PARAMETER Force
    Overwrite a repository copy that is newer than the drop-folder copy.

.PARAMETER Commit
    Commit the staged files. Requires -Message.

.PARAMETER Message
    Commit message, used only with -Commit.

.EXAMPLE
    .\Publish-ClaudeOutputs.ps1 -WhatIf
    Dry run: shows what would be copied where, changes nothing.

.EXAMPLE
    .\Publish-ClaudeOutputs.ps1
    Copies, stages with git add, prints git status, stops.

.EXAMPLE
    .\Publish-ClaudeOutputs.ps1 -Archive
    Same, then clears the drop folder into _published\2026-09-18.

.NOTES
    Both scripts must sit in the same folder - this one calls the other by a
    path relative to itself.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [string] $RepoRoot    = 'X:\retail-sector-health',
    [string] $StagingPath = (Join-Path $env:USERPROFILE 'Documents\Power BI Desktop\Claude outputs'),
    [switch] $Archive,
    [switch] $Force,
    [switch] $Commit,
    [string] $Message
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$worker = Join-Path $PSScriptRoot 'Publish-ToRepo.ps1'
if (-not (Test-Path -LiteralPath $worker)) {
    Write-Host ''
    Write-Host "Publish-ToRepo.ps1 not found beside this script." -ForegroundColor Red
    Write-Host "Expected: $worker" -ForegroundColor Red
    Write-Host "This script is a wrapper - it needs the other one for the routing table."
    exit 1
}
if (-not (Test-Path -LiteralPath $StagingPath -PathType Container)) {
    Write-Host ''
    Write-Host "Drop folder not found: $StagingPath" -ForegroundColor Red
    exit 1
}

$before = @(Get-ChildItem -LiteralPath $StagingPath -File | Where-Object { $_.Name -notlike '~$*' })
if ($before.Count -eq 0) {
    Write-Host ''
    Write-Host "Drop folder is empty - nothing to publish." -ForegroundColor Yellow
    Write-Host "  $StagingPath"
    return
}

Write-Host ''
Write-Host "Publishing the Claude outputs drop folder" -ForegroundColor Cyan
Write-Host ("  {0} file(s) waiting" -f $before.Count)

# Pass through only the switches the user actually supplied.
$params = @{ RepoRoot = $RepoRoot; StagingPath = $StagingPath }
if ($Force)   { $params.Force   = $true }
if ($Commit)  { $params.Commit  = $true; $params.Message = $Message }
if ($WhatIfPreference) { $params.WhatIf = $true }

& $worker @params
$code = $LASTEXITCODE
if ($code) { exit $code }

# ------------------------------------------------------------------ archive ---
if (-not $Archive -or $WhatIfPreference) { return }

$dest = Join-Path $StagingPath ('_published\' + (Get-Date -Format 'yyyy-MM-dd'))
$moved = 0
foreach ($f in $before) {
    # Only archive what actually reached the repository.
    $landed = Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter $f.Name -ErrorAction SilentlyContinue |
              Where-Object { $_.FullName -notlike '*\.git\*' } | Select-Object -First 1
    if (-not $landed) {
        Write-Warning ("{0} was not found in the repository - left in the drop folder." -f $f.Name)
        continue
    }
    if (-not (Test-Path -LiteralPath $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
    if ($PSCmdlet.ShouldProcess($f.FullName, 'Move to archive')) {
        Move-Item -LiteralPath $f.FullName -Destination (Join-Path $dest $f.Name) -Force
        $moved++
    }
}
Write-Host ''
Write-Host ("Archived {0} file(s) to {1}" -f $moved, $dest) -ForegroundColor Green
Write-Host 'Nothing was deleted - the files were moved, not removed.' -ForegroundColor DarkGray
