<#
.SYNOPSIS
    Copies the U.S. Retail Sector Health project files from the local working
    folder into the correct folders of a cloned repository, then stages them.

.DESCRIPTION
    Run this AFTER the GitHub repository has been created and cloned to the
    local machine (document 00, sections 4 and 5).

    The script COPIES. Nothing is moved, renamed or deleted in the working
    folder, so the originals stay exactly where Power BI Desktop and Word
    expect to find them.

    Routing is by an explicit allow-list, not by sweeping the folder. Anything
    the table does not name is reported as unrouted and left alone - which
    matters, because the working folder is also Power BI Desktop's own folder
    and contains 'Custom Connectors' and other files that must never be
    committed.

.PARAMETER RepoRoot
    Full path to the cloned repository, e.g. X:\retail-sector-health. Must contain a
    .git folder; the script refuses to write anywhere that is not a clone.

.PARAMETER StagingPath
    Folder to copy from. Defaults to the Power BI Desktop documents folder.

.PARAMETER Force
    Overwrite a destination file whose content differs, even if the copy in
    the repository is newer than the one in the working folder.

.PARAMETER SkipGitAdd
    Copy only. Do not run 'git add' afterwards.

.PARAMETER Commit
    Commit the staged files. Requires -Message.

.PARAMETER Message
    Commit message, used only with -Commit.

.EXAMPLE
    .\Publish-ToRepo.ps1 -RepoRoot 'X:\retail-sector-health' -WhatIf
    Dry run. Shows every file that would be copied and where, changing nothing.

.EXAMPLE
    .\Publish-ToRepo.ps1 -RepoRoot 'X:\retail-sector-health'
    Copies, stages with git add, prints git status, and stops. Review the
    staged set, then commit and push yourself.

.EXAMPLE
    .\Publish-ToRepo.ps1 -RepoRoot 'X:\retail-sector-health' -Commit -Message 'Add document set v1.0'
    Copies, stages and commits. Does not push.

.NOTES
    Safe to re-run. A file whose content already matches the repository copy
    is reported as identical and skipped.
#>
[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
param(
    [Parameter(Mandatory)]
    [string] $RepoRoot,

    [string] $StagingPath = (Join-Path $env:USERPROFILE 'Documents\Power BI Desktop'),

    [switch] $Force,
    [switch] $SkipGitAdd,
    [switch] $Commit,
    [string] $Message
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------- routing ---
# Each pattern is matched against the file NAME only, top level of the staging
# folder, case-insensitively. Add a row here rather than special-casing below.
$Routes = @(
    [pscustomobject]@{ Pattern = '[0-9][0-9]_*.docx';             Folder = 'docs'       }
    [pscustomobject]@{ Pattern = '[0-9][0-9]_*.xlsx';             Folder = 'docs'       }
    [pscustomobject]@{ Pattern = '[0-9][0-9]_*_Report_Mockup.html';Folder = 'docs'      }
    [pscustomobject]@{ Pattern = 'R[0-9]_*.json';                 Folder = 'theme'      }
    [pscustomobject]@{ Pattern = 'retail_sector_theme.json';      Folder = 'theme'      }
    [pscustomobject]@{ Pattern = 'fig_*.png';                     Folder = 'assets'     }
    [pscustomobject]@{ Pattern = 'r[0-9]_p[0-9]*.png';            Folder = 'assets'     }
    [pscustomobject]@{ Pattern = 'model_view.png';                Folder = 'assets'     }
    [pscustomobject]@{ Pattern = '[0-9][0-9]_*.sql';              Folder = 'sql'        }
    [pscustomobject]@{ Pattern = '*.m';                           Folder = 'powerquery' }
    [pscustomobject]@{ Pattern = '*.dax';                         Folder = 'dax'        }
    [pscustomobject]@{ Pattern = '*.pbix';                        Folder = 'pbix'       }
    [pscustomobject]@{ Pattern = 'RefMappings.xlsx';              Folder = 'reference'  }
    [pscustomobject]@{ Pattern = 'Publish-*.ps1';                 Folder = 'tools'      }
)

# Never considered, whatever the routes say.
$NeverCopy = @(
    '~$*'            # Word lock files
    '*.tmp'
    'Thumbs.db'
    'desktop.ini'
    '*.csv'          # source data is linked, never redistributed
    '*.pbix.tmp'
)

# ------------------------------------------------------------- validation ---
function Stop-With { param([string] $Text) Write-Host ''; Write-Host $Text -ForegroundColor Red; exit 1 }

function Test-FileLocked {
    <# Returns $true when the file cannot be opened for exclusive read, which on
       Windows means another program - Word, Excel, Power BI Desktop - holds it
       open. Copying a file mid-save produces a corrupt destination, so a locked
       file stops the run rather than being copied anyway. #>
    param([Parameter(Mandatory)][string] $Path)
    try {
        $stream = [System.IO.File]::Open($Path, 'Open', 'Read', 'None')
        $stream.Close(); $stream.Dispose()
        return $false
    }
    catch { return $true }
}

if (-not (Test-Path -LiteralPath $StagingPath -PathType Container)) {
    Stop-With "Working folder not found: $StagingPath"
}
if (-not (Test-Path -LiteralPath $RepoRoot -PathType Container)) {
    Stop-With @"
Repository folder not found: $RepoRoot

If the repository has not been created and cloned yet, do that first -
document 00 section 4 creates it on GitHub, section 5 clones it. If it is on a
network or removable drive, check the drive is connected.
"@
}
if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.git'))) {
    Stop-With @"
$RepoRoot is not a git clone - no .git folder.

This script will not copy into a plain folder, because files placed outside a
clone are not version-controlled and have to be relocated later.
"@
}

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git -and -not $SkipGitAdd) {
    Write-Warning 'git not found on PATH. Files will be copied; staging is skipped.'
    $SkipGitAdd = $true
}
if ($Commit -and -not $Message) { Stop-With '-Commit requires -Message.' }

Write-Host ''
Write-Host 'Publish to repository' -ForegroundColor Cyan
Write-Host ("  from : {0}" -f $StagingPath)
Write-Host ("  to   : {0}" -f $RepoRoot)
Write-Host ''

# --------------------------------------------------------------- planning ---
$plan    = [System.Collections.Generic.List[object]]::new()
$unrouted = [System.Collections.Generic.List[string]]::new()

foreach ($file in Get-ChildItem -LiteralPath $StagingPath -File) {

    if ($NeverCopy | Where-Object { $file.Name -like $_ }) { continue }

    $hits = @($Routes | Where-Object { $file.Name -like $_.Pattern })

    if ($hits.Count -eq 0) { $unrouted.Add($file.Name); continue }
    if ($hits.Count -gt 1) {
        Stop-With ("'{0}' matches more than one route ({1}). Fix the routing table." -f
                   $file.Name, ($hits.Folder -join ', '))
    }

    $destDir  = Join-Path $RepoRoot $hits[0].Folder
    $destFile = Join-Path $destDir $file.Name
    $status   = 'New'

    if (Test-FileLocked -Path $file.FullName) {
        $status = 'LOCKED'
    }
    elseif (Test-Path -LiteralPath $destFile) {
        $srcHash = (Get-FileHash -LiteralPath $file.FullName  -Algorithm SHA256).Hash
        $dstHash = (Get-FileHash -LiteralPath $destFile       -Algorithm SHA256).Hash
        if ($srcHash -eq $dstHash) {
            $status = 'Identical'
        }
        elseif ((Get-Item -LiteralPath $destFile).LastWriteTime -gt $file.LastWriteTime -and -not $Force) {
            $status = 'NEWER-IN-REPO'
        }
        else {
            $status = 'Update'
        }
    }

    $plan.Add([pscustomobject]@{
        Name   = $file.Name
        Folder = $hits[0].Folder
        Size   = '{0:N0}' -f $file.Length
        Action = $status
        Source = $file.FullName
        Dest   = $destFile
        DestDir= $destDir
    })
}

if ($plan.Count -eq 0) { Stop-With "Nothing to copy - no file in $StagingPath matched a route." }

# Rendered by hand rather than with Format-Table -AutoSize, which emits nothing
# when PowerShell runs without a console host (a scheduled task, a CI step).
$w1 = 13
$w2 = ($plan.Folder      | Measure-Object -Maximum -Property Length).Maximum
$w3 = ($plan.Name        | Measure-Object -Maximum -Property Length).Maximum
$w2 = [Math]::Max($w2, 6); $w3 = [Math]::Max($w3, 4)
$fmt = "  {0,-$w1} {1,-$w2} {2,-$w3} {3,9}"
Write-Host ($fmt -f 'ACTION', 'FOLDER', 'FILE', 'BYTES')
Write-Host ($fmt -f ('-' * $w1), ('-' * $w2), ('-' * $w3), '-----')
foreach ($row in ($plan | Sort-Object Folder, Name)) {
    $colour = switch ($row.Action) {
        'New'           { 'Green'  }
        'Update'        { 'Green'  }
        'Identical'     { 'DarkGray' }
        'LOCKED'        { 'Red'    }
        'NEWER-IN-REPO' { 'Yellow' }
        default         { 'Gray'   }
    }
    Write-Host ($fmt -f $row.Action, $row.Folder, $row.Name, $row.Size) -ForegroundColor $colour
}
Write-Host ''

# ------------------------------------------------------------ blocked set ---
$locked = @($plan | Where-Object Action -eq 'LOCKED')
if ($locked.Count -gt 0) {
    Write-Host 'These files are open in another program and cannot be copied:' -ForegroundColor Yellow
    $locked | ForEach-Object { Write-Host ("  {0}" -f $_.Name) -ForegroundColor Yellow }
    Write-Host ''
    Write-Host 'Close them in Word, Excel or Power BI Desktop, then run this script again.' -ForegroundColor Yellow
    Write-Host 'Nothing has been copied.' -ForegroundColor Yellow
    exit 2
}

$newer = @($plan | Where-Object Action -eq 'NEWER-IN-REPO')
if ($newer.Count -gt 0) {
    Write-Host 'The copy already in the repository is NEWER than the working-folder copy:' -ForegroundColor Yellow
    $newer | ForEach-Object { Write-Host ("  {0}\{1}" -f $_.Folder, $_.Name) -ForegroundColor Yellow }
    Write-Host 'Left untouched. Re-run with -Force to overwrite them.' -ForegroundColor Yellow
    Write-Host ''
}

if ($unrouted.Count -gt 0) {
    Write-Host 'Not copied - no route for these (left alone, by design):' -ForegroundColor DarkGray
    $unrouted | ForEach-Object { Write-Host ("  {0}" -f $_) -ForegroundColor DarkGray }
    Write-Host ''
}

# ----------------------------------------------------------------- copying ---
$work = @($plan | Where-Object Action -in 'New', 'Update')
if ($work.Count -eq 0) {
    Write-Host 'Every routed file already matches the repository. Nothing to do.' -ForegroundColor Green
    return
}

$copied = [System.Collections.Generic.List[string]]::new()

foreach ($dir in ($work.DestDir | Sort-Object -Unique)) {
    if (-not (Test-Path -LiteralPath $dir)) {
        if ($PSCmdlet.ShouldProcess($dir, 'Create folder')) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
}

foreach ($item in $work) {
    if ($PSCmdlet.ShouldProcess($item.Dest, ('Copy ({0})' -f $item.Action))) {
        Copy-Item -LiteralPath $item.Source -Destination $item.Dest -Force
        $copied.Add(('{0}/{1}' -f $item.Folder, $item.Name))
        Write-Host ("  {0,-10} {1}" -f $item.Action, ('{0}\{1}' -f $item.Folder, $item.Name)) -ForegroundColor Green
    }
}

if ($WhatIfPreference) { Write-Host ''; Write-Host 'Dry run - nothing was changed.' -ForegroundColor Cyan; return }

Write-Host ''
Write-Host ("{0} file(s) copied. Originals left in place." -f $copied.Count) -ForegroundColor Green

# --------------------------------------------------------------------- git ---
if ($SkipGitAdd) { return }

# git is called with -C rather than by changing directory. A native process
# cannot hold a UNC path as its working directory, so Push-Location into a
# mapped or UNC repo silently runs git against C:\Windows instead. -C has no
# such problem and behaves identically on a local disk.
$g = @('-C', $RepoRoot)

try {
    # A copied file that .gitignore blocks would never commit. Say so, and leave
    # it out of the add - passing an ignored path makes git fail the whole call.
    $addable = [System.Collections.Generic.List[string]]::new()
    foreach ($rel in $copied) {
        & git @g check-ignore --quiet -- $rel 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Warning ("{0} is blocked by .gitignore and will NOT be committed. It was still copied into the working tree." -f $rel)
        }
        else { $addable.Add($rel) }
    }

    if ($addable.Count -eq 0) {
        Write-Warning 'Every copied file is blocked by .gitignore. Nothing staged.'
        return
    }

    if ($PSCmdlet.ShouldProcess($RepoRoot, 'git add')) {
        & git @g add -- $addable
        if ($LASTEXITCODE -ne 0) {
            Stop-With @"
git add failed.

If the message mentions 'dubious ownership', git is refusing a repository whose
owner it does not recognise - normal on a network or mapped drive. Trust it once:

  git config --global --add safe.directory '$RepoRoot'

then run this script again.
"@
        }
    }

    Write-Host ''
    & git @g status --short
    Write-Host ''

    if ($Commit) {
        if ($PSCmdlet.ShouldProcess($RepoRoot, 'git commit')) {
            & git @g commit -m $Message
            if ($LASTEXITCODE -ne 0) { Stop-With 'git commit failed.' }
            Write-Host ''
            Write-Host 'Committed. Push when you are ready:  git push' -ForegroundColor Green
        }
    }
    else {
        Write-Host 'Staged. Review the list above, then:' -ForegroundColor Cyan
        Write-Host '  git commit -m "Add document set v1.0"'
        Write-Host '  git push'
    }
}
finally { }
