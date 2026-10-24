<#
.SYNOPSIS
  Sync a repository's eligible Markdown to SharePoint under a per-project folder.

.DESCRIPTION
  Portable, project-neutral documentation sync. Each project writes to
  "<RootFolder>/<ProjectSlug>/<repo-relative-path>" in the configured drive; the
  project folder is created on first sync. Files are skipped when the remote size
  and modified time already match the local file (use -Force to re-upload).

  Authentication (least privilege first):
    * App-only Sites.Selected (preferred): supply -TenantId/-ClientId and a
      client secret (via -ClientSecret or the SHAREPOINT_SYNC_CLIENT_SECRET
      environment variable, ideally sourced from a secret manager). The Entra app
      must hold the Sites.Selected application permission and an explicit write
      grant on the target site.
    * Delegated Graph PowerShell session (interactive fallback): a persisted
      Connect-MgGraph -Scopes 'Sites.ReadWrite.All' -ContextScope CurrentUser
      session is reused silently. Over-broad scopes (e.g. Sites.FullControl.All)
      are warned about, not used to justify the sync.

.PARAMETER ConfigPath
  Project config (.opencode/sharepoint-sync.json). Defaults to
  "<SourceRoot>/.opencode/sharepoint-sync.json".

.PARAMETER SourceRoot
  Repository root to sync. Defaults to the git top-level of the current directory.

.EXAMPLE
  pwsh -File sync-docs.ps1 -DryRun
  pwsh -File sync-docs.ps1 -TenantId <id> -ClientId <id> -ClientSecret (Get-Secret)
#>
[CmdletBinding()]
param(
  [string]$ConfigPath,
  [string]$SourceRoot,
  [string]$TenantId,
  [string]$ClientId,
  [string]$ClientSecret,
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
$excludeDirs  = if ($config.excludeDirectories) { $config.excludeDirectories } else {
  @('.git','.idea','.vscode','.agents','.claude','node_modules','vendor','storage','reference',
    'coverage','dist','build','target','.phpunit.cache','.venv','__pycache__')
}
$excludeFiles = if ($config.excludeFiles) { $config.excludeFiles } else { @('AGENTS.md','CLAUDE.md') }

if (-not $ClientSecret) { $ClientSecret = $env:SHAREPOINT_SYNC_CLIENT_SECRET }
$appOnly = ($TenantId -and $ClientId -and $ClientSecret)

$script:bearer = $null

if ($appOnly) {
  $tokenBody = @{
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = 'https://graph.microsoft.com/.default'
    grant_type    = 'client_credentials'
  }
  try {
    $token = Invoke-RestMethod -Method POST -Body $tokenBody `
      -Uri ('https://login.microsoftonline.com/' + $TenantId + '/oauth2/v2.0/token') `
      -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
  } catch {
    Fail 'App-only token acquisition failed. Check tenant/client/secret and the Sites.Selected grant.'
  }
  if (-not $token.access_token) { Fail 'App-only token acquisition returned no token.' }
  $script:bearer = $token.access_token
  Write-Output 'Auth   : app-only (Sites.Selected)'
} else {
  if (-not (Get-MgContext)) {
    try { Connect-MgGraph -ContextScope CurrentUser -NoWelcome -ErrorAction Stop } catch { }
  }
  if (-not (Get-MgContext)) {
    Fail "No Graph session. Run: Connect-MgGraph -Scopes 'Sites.ReadWrite.All' -ContextScope CurrentUser, then re-run."
  }
  $broad = (Get-MgContext).Scopes | Where-Object { $_ -in @('Sites.FullControl.All') }
  if ($broad) {
    Write-Warning ("Graph session carries over-broad scope(s): " + ($broad -join ', ') + ". Prefer an app-only Sites.Selected grant; do not rely on full-control consent.")
  }
  Write-Output 'Auth   : delegated Graph session'
}

function Invoke-Graph {
  param(
    [Parameter(Mandatory)][string]$Method,
    [Parameter(Mandatory)][string]$Uri,
    $Body,
    [string]$ContentType
  )
  if ($script:bearer) {
    $headers = @{ Authorization = ('Bearer ' + $script:bearer) }
    if ($null -ne $Body) {
      return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers -Body $Body -ContentType $ContentType
    }
    return Invoke-RestMethod -Method $Method -Uri $Uri -Headers $headers
  }
  if ($null -ne $Body) {
    return Invoke-MgGraphRequest -Method $Method -Uri $Uri -Body $Body -ContentType $ContentType
  }
  return Invoke-MgGraphRequest -Method $Method -Uri $Uri
}

# --- enumerate eligible files ------------------------------------------------
$absoluteRoot = (Resolve-Path $SourceRoot).Path
$includes = if ($config.include) { @($config.include) } else { @('**/*.md') }

# Segment-wise glob matcher: '*' and '?' match inside a segment, '**' matches
# across directories (so '**/*.md' also matches a file at the repository root).
function Test-GlobMatch([string]$relativePath, [string]$pattern) {
  $pathParts = @((($relativePath -replace '\\','/') -split '/') | Where-Object { $_ -ne '' })
  $patParts  = @((($pattern -replace '\\','/') -split '/') | Where-Object { $_ -ne '' })
  $pi = 0; $si = 0; $starPi = -1; $starSi = -1
  while ($si -lt $pathParts.Count) {
    if ($pi -lt $patParts.Count -and ($patParts[$pi] -eq '**' -or $pathParts[$si] -like $patParts[$pi])) {
      if ($patParts[$pi] -eq '**') { $starPi = $pi; $starSi = $si; $pi++ } else { $pi++; $si++ }
    } elseif ($starPi -ge 0) { $starSi++; $si = $starSi; $pi = $starPi + 1 }
    else { return $false }
  }
  while ($pi -lt $patParts.Count -and $patParts[$pi] -eq '**') { $pi++ }
  return ($pi -eq $patParts.Count)
}

# Content type per extension: a Markdown type on a binary file is wrong.
function Get-ContentTypeForName([string]$name) {
  switch ([System.IO.Path]::GetExtension($name).ToLowerInvariant()) {
    '.md'   { 'text/markdown' }
    '.txt'  { 'text/plain' }
    '.csv'  { 'text/csv' }
    '.json' { 'application/json' }
    '.xlsx' { 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' }
    '.xls'  { 'application/vnd.ms-excel' }
    '.pdf'  { 'application/pdf' }
    '.png'  { 'image/png' }
    '.jpg'  { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.gif'  { 'image/gif' }
    '.svg'  { 'image/svg+xml' }
    '.zip'  { 'application/zip' }
    default { 'application/octet-stream' }
  }
}

# Hard safety rule, deliberately not configurable: never upload dotfiles or
# secret/editor artefacts even when an include pattern asks for them.
$neverSyncNamePatterns = @('.env', '.env.*', '*.swp', '*.swo', '*.pem', '*.key', '*.pfx', '*.p12', '*:Zone.Identifier')

$files = Get-ChildItem -Path $absoluteRoot -Recurse -File | Where-Object {
  $rel = $_.FullName.Substring($absoluteRoot.Length).TrimStart('\','/')
  $relPosix = $rel -replace '\\','/'
  $name = $_.Name
  $segments = $relPosix -split '/'

  $dirOk = -not ($segments[0..([Math]::Max($segments.Count - 2, 0))] | Where-Object { $excludeDirs -contains $_ })
  $fileOk = -not ($excludeFiles -contains $name)
  $included = @($includes | Where-Object { Test-GlobMatch -relativePath $relPosix -pattern $_ }).Count -gt 0
  $nameIsSafe = @($neverSyncNamePatterns | Where-Object { $name -like $_ }).Count -eq 0

  $dirOk -and $fileOk -and $included -and $nameIsSafe
} | Sort-Object FullName

if (-not $files) { Write-Output "No eligible files found under $absoluteRoot"; exit 0 }

$projectRoot = ($rootFolder + '/' + $slug)

function New-ChildFolder([string]$parentPath, [string]$name) {
  $uri = if ($parentPath) {
    'https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $parentPath + ':/children'
  } else {
    'https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root/children'
  }
  $body = @{ name = $name; folder = @{}; '@microsoft.graph.conflictBehavior' = 'fail' } | ConvertTo-Json -Depth 5
  try { Invoke-Graph -Method POST -Uri $uri -Body $body -ContentType 'application/json' | Out-Null }
  catch { if ($_.Exception.Response.StatusCode.value__ -ne 409) { throw } }
}

function Ensure-Folder([string]$relativeFolder) {
  if (-not $relativeFolder) { return }
  $current = ''
  foreach ($segment in ($relativeFolder -split '/')) {
    if ($segment -eq '') { continue }
    if (-not $DryRun) { New-ChildFolder -parentPath $current -name $segment }
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
    $item = Invoke-Graph -Method GET -Uri ('https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $remotePath)
    $sizeOk = ($item.size -eq $file.Length)
    $timeOk = $false
    if ($item.lastModifiedDateTime) { $timeOk = ([datetime]$item.lastModifiedDateTime).ToUniversalTime() -ge $file.LastWriteTimeUtc }
    if ($sizeOk -and $timeOk -and -not $Force) { $status = 'skipped'; $webUrl = $item.webUrl }
  } catch { $status = 'uploaded' }

  if ($status -eq 'uploaded' -and -not $DryRun) {
    Ensure-Folder -relativeFolder ($remotePath -replace '/[^/]+$','')
    $content = [System.IO.File]::ReadAllBytes($file.FullName)
    $uploaded = Invoke-Graph -Method PUT -Uri ('https://graph.microsoft.com/v1.0/drives/' + $driveId + '/root:/' + $remotePath + ':/content') -Body $content -ContentType (Get-ContentTypeForName $file.Name)
    $webUrl = $uploaded.webUrl
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
