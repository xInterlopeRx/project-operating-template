<#
.SYNOPSIS
  Sync a repository's eligible Markdown to SharePoint under a per-project folder.

.DESCRIPTION
  Portable, project-neutral documentation sync (delegated Microsoft Graph).
  Each project writes to "<RootFolder>/<ProjectSlug>/<repo-relative-path>" in the
  configured drive; the project folder is created on first sync. Files are
  skipped when the remote size and modified time already match the local file
  (use -Force to re-upload). Runs read-only with -DryRun.

.PARAMETER ConfigPath
  Path to the project config (.opencode/sharepoint-sync.json). Defaults to
  "<SourceRoot>/.opencode/sharepoint-sync.json".

.PARAMETER SourceRoot
  Repository root to sync. Defaults to the git top-level of the current directory.

.EXAMPLE
  pwsh -File sync-docs.ps1 -DryRun
  pwsh -File sync-docs.ps1
#>
[CmdletBinding()]
param(
  [string]$ConfigPath,
  [string]$SourceRoot,
  [switch]$DryRun,
  [switch]$Force
)

$ErrorActionPreference = 'Stop'

function Fail([string]$message) { Write-Error $message; exit 2 }

# --- resolve source root -----------------------------------------------------
if (-not $SourceRoot) {
  try { $SourceRoot = (git rev-parse --show-toplevel 2>$null) } catch { $SourceRoot = $null }
  if (-not $SourceRoot) { $SourceRoot = (Get-Location).Path }
}
$SourceRoot = (Resolve-Path $SourceRoot).Path

if (-not $ConfigPath) { $ConfigPath = Join-Path $SourceRoot '.opencode/sharepoint-sync.json' }
if (-not (Test-Path $ConfigPath)) { Fail "Config not found: $ConfigPath" }

$config = Get-Content $ConfigPath -Raw | ConvertFrom-Json
foreach ($key in @('projectSlug', 'rootFolder', 'siteId', 'driveId')) {
  if (-not $config.$key) { Fail "Config is missing '$key': $ConfigPath" }
}

$slug         = $config.projectSlug
$rootFolder   = $config.rootFolder
$siteId       = $config.siteId
$driveId      = $config.driveId
$includeGlobs = if ($config.include) { $config.include } else { @('**/*.md') }
$excludeDirs  = if ($config.excludeDirectories) { $config.excludeDirectories } else {
  @('.git','.idea','.vscode','.agents','.claude','node_modules','vendor','storage','reference',
    'coverage','dist','build','target','.phpunit.cache','.venv','__pycache__')
}
$excludeFiles = if ($config.excludeFiles) { $config.excludeFiles } else { @('AGENTS.md','CLAUDE.md') }

if (-not (Get-MgContext)) {
  try { Connect-MgGraph -ContextScope CurrentUser -NoWelcome -ErrorAction Stop } catch { }
}
if (-not (Get-MgContext)) {
  Fail "No Graph session. Run: Connect-MgGraph -Scopes 'Sites.ReadWrite.All' -UseDeviceCode -ContextScope CurrentUser, then re-run."
}

# Least privilege: warn (do not fail) if the session carries over-broad grants.
$broad = (Get-MgContext).Scopes | Where-Object { $_ -in @('Sites.FullControl.All') }
if ($broad) {
  Write-Warning ("Graph session carries over-broad scope(s): " + ($broad -join ', ') + ". Prefer Sites.ReadWrite.All (delegated) or an app-only Sites.Selected grant; do not rely on full-control consent.")
}

# --- enumerate eligible files ------------------------------------------------
$absoluteRoot = (Resolve-Path $SourceRoot).Path
$files = Get-ChildItem -Path $absoluteRoot -Recurse -File -Include '*.md' | Where-Object {
  $rel = $_.FullName.Substring($absoluteRoot.Length).TrimStart('\','/')
  $segments = $rel -split '[\\/]'
  $dirOk = -not ($segments[0..([Math]::Max($segments.Count - 2, 0))] | Where-Object { $excludeDirs -contains $_ })
  $fileOk = -not ($excludeFiles -contains $segments[-1])
  $dirOk -and $fileOk
} | Sort-Object FullName

if (-not $files) { Write-Output "No eligible Markdown found under $absoluteRoot"; exit 0 }

$projectRoot = ($rootFolder + '/' + $slug)

function Invoke-GraphChild([string]$parentPath, [string]$name) {
  $uri = if ($parentPath) {
    'https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $parentPath + ':/children'
  } else {
    'https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root/children'
  }
  $body = @{ name = $name; folder = @{}; '@microsoft.graph.conflictBehavior' = 'fail' } | ConvertTo-Json -Depth 5
  try { Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body -ContentType 'application/json' -ErrorAction Stop }
  catch { if ($_.Exception.Response.StatusCode.value__ -ne 409) { throw } }
}

function Ensure-Folder([string]$relativeFolder) {
  if (-not $relativeFolder) { return }
  $segments = $relativeFolder -split '/'
  $current = ''
  foreach ($segment in $segments) {
    if ($segment -eq '') { continue }
    if (-not $DryRun) { Invoke-GraphChild -parentPath $current -name $segment | Out-Null }
    $current = if ($current) { $current + '/' + $segment } else { $segment }
  }
}

# --- sync --------------------------------------------------------------------
Write-Output ("Source : " + $absoluteRoot)
Write-Output ("Target : drive " + $driveId)
Write-Output ("Folder : /" + $projectRoot)
Write-Output ("Mode   : " + ($(if ($DryRun) { 'DRY RUN (no writes)' } else { 'APPLY' })))
Write-Output ''

Ensure-Folder -relativeFolder $projectRoot

$results = @()
foreach ($file in $files) {
  $rel = $file.FullName.Substring($absoluteRoot.Length).TrimStart('\','/') -replace '\\','/'
  $remotePath = $projectRoot + '/' + $rel
  $status = 'uploaded'
  $webUrl = ''

  try {
    $item = Invoke-MgGraphRequest -Method GET -Uri ('https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $remotePath) -ErrorAction Stop
    $sizeOk = ($item.size -eq $file.Length)
    $timeOk = $false
    if ($item.lastModifiedDateTime) { $timeOk = ([datetime]$item.lastModifiedDateTime).ToUniversalTime() -ge $file.LastWriteTimeUtc }
    if ($sizeOk -and $timeOk -and -not $Force) { $status = 'skipped'; $webUrl = $item.webUrl }
  } catch { $status = 'uploaded' }

  if ($status -eq 'uploaded') {
    if (-not $DryRun) {
      $parent = ($remotePath -replace '/[^/]+$','')
      Ensure-Folder -relativeFolder $parent
      $content = [System.IO.File]::ReadAllBytes($file.FullName)
      $uploaded = Invoke-MgGraphRequest -Method PUT -Uri ('https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $remotePath + ':/content') -Body $content -ContentType 'text/markdown' -ErrorAction Stop
      $webUrl = $uploaded.webUrl
    }
  }

  $results += [pscustomobject]@{
    Path   = $rel
    Status = $(if ($DryRun -and $status -eq 'uploaded') { 'would-upload' } else { $status })
    Bytes  = $file.Length
    Url    = $webUrl
  }
}

foreach ($r in $results) {
  Write-Output ("{0,-13} {1,8}  {2}" -f $r.Status, $r.Bytes, $r.Path)
}
$counts = $results | Group-Object Status | ForEach-Object { $_.Name + '=' + $_.Count }
Write-Output ''
Write-Output ('Total: ' + $results.Count + ' (' + ($counts -join ', ') + ')')
if ($DryRun) { Write-Output 'Dry run only. No files were written to SharePoint.' }
