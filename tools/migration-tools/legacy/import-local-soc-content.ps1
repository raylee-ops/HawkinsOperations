# ============================================================================
# WIP / NOT RELIABLE
# ============================================================================
# This script was used for one-time content migration and is not maintained.
# It may have path/encoding issues and should not be relied upon.
# Kept for reference only - DO NOT USE in production workflows.
# ============================================================================

# tools/import/import-local-soc-content.ps1
[CmdletBinding()]
param(
  [string]$SourceRoot = "C:\2026\OPS\GITHUB\hawkinsops-soc-content",
  [string]$RepoRoot   = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
  [switch]$PlanOnly,
  [switch]$Force
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

function Get-SigmaTacticFolder([string]$filePath) {
  # Try to infer tactic from Sigma tags: attack.execution, attack.credential_access, etc.
  $tactics = @(
    "collection","command-and-control","credential-access","defense-evasion","discovery","execution",
    "exfiltration","impact","initial-access","lateral-movement","persistence","privilege-escalation"
  )
  $content = Get-Content -LiteralPath $filePath -ErrorAction SilentlyContinue
  if (-not $content) { return "misc" }

  $tags = @()
  $inTags = $false
  foreach ($line in $content) {
    if ($line -match '^\s*tags\s*:\s*$') { $inTags = $true; continue }
    if ($inTags -and $line -match '^\s*-\s*(.+)\s*$') {
      $tags += $Matches[1].Trim()
      continue
    }
    if ($inTags -and $line -match '^\S') { break } # end of tags block
  }

  foreach ($t in $tactics) {
    if ($tags -contains ("attack.$($t -replace "-","_")")) { return $t }
    if ($tags -contains ("attack.$t")) { return $t }
  }
  return "misc"
}

function Get-SplunkFolder([string]$filePath) {
  $name = [IO.Path]::GetFileName($filePath).ToLowerInvariant()
  if ($name -match "credential|lsass|mimikatz|dump") { return "credential-access" }
  if ($name -match "persistence") { return "persistence" }
  if ($name -match "lateral|remote") { return "lateral-movement" }
  if ($name -match "powershell|cmd|wmi") { return "execution" }
  return "misc"
}

function Ensure-Dir([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { New-Item -ItemType Directory -Path $path | Out-Null }
}

if (-not (Test-Path -LiteralPath $SourceRoot)) {
  throw "SourceRoot not found: $SourceRoot"
}

$files = Get-ChildItem -LiteralPath $SourceRoot -File -Recurse |
  Where-Object { $_.Name -notmatch '^\.' } # ignore dotfiles

$plan = New-Object System.Collections.Generic.List[object]

foreach ($f in $files) {
  $ext = $f.Extension.ToLowerInvariant()
  $destRel = $null

  switch ($ext) {
    ".yml" { 
      # Assume Sigma unless proven otherwise
      $tactic = Get-SigmaTacticFolder $f.FullName
      $destRel = Join-Path "detection-rules\sigma\$tactic" $f.Name
    }
    ".yaml" {
      $tactic = Get-SigmaTacticFolder $f.FullName
      $destRel = Join-Path "detection-rules\sigma\$tactic" $f.Name
    }
    ".spl" {
      $bucket = Get-SplunkFolder $f.FullName
      $destRel = Join-Path "detection-rules\splunk\$bucket" $f.Name
    }
    ".xml" {
      # Wazuh modules only
      $destRel = Join-Path "detection-rules\wazuh\rules" $f.Name
    }
    ".md" {
      # Prefer IR playbooks by filename convention
      if ($f.Name -match '^IR-\d{3}-') {
        $destRel = Join-Path "incident-response\playbooks" $f.Name
      } elseif ($f.Name -match '^00-.*(Playbook|Hunt|Rule).*\.md$') {
        $destRel = Join-Path "_archive\legacy-soc-content" $f.Name
      } else {
        # keep other legacy docs out of the “main story” but still preserved
        $destRel = Join-Path "_archive\legacy-soc-content" $f.Name
      }
    }
    default { continue }
  }

  $destAbs = Join-Path $RepoRoot $destRel
  $action = "COPY"
  if (Test-Path -LiteralPath $destAbs) { $action = "SKIP_EXISTS" }

  $plan.Add([pscustomobject]@{
    Source   = $f.FullName
    Dest     = $destAbs
    Action   = $action
  })
}

# Write plan report
$reportDir = Join-Path $RepoRoot "_ops"
Ensure-Dir $reportDir
$report = Join-Path $reportDir ("import-plan-{0}.csv" -f (Get-Date -Format "yyyyMMdd-HHmmss"))
$plan | Export-Csv -NoTypeInformation -Path $report -Encoding UTF8

Write-Host "Import plan written: $report"
Write-Host ("Planned copies: {0} | Skips (already exist): {1}" -f
  (($plan | Where-Object Action -eq "COPY").Count),
  (($plan | Where-Object Action -eq "SKIP_EXISTS").Count)
)

if ($PlanOnly) {
  Write-Host "PlanOnly set. No files copied."
  exit 0
}

foreach ($p in ($plan | Where-Object Action -eq "COPY")) {
  $destDir = Split-Path -Parent $p.Dest
  Ensure-Dir $destDir
  if ($Force) {
    Copy-Item -LiteralPath $p.Source -Destination $p.Dest -Force
  } else {
    Copy-Item -LiteralPath $p.Source -Destination $p.Dest
  }
}

Write-Host "✅ Import complete."
