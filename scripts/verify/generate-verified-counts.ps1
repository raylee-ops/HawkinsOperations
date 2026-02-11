[CmdletBinding()]
param(
    [string]$OutFile = ".\PROOF_PACK\VERIFIED_COUNTS.md"
)

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$sigmaPath = Join-Path $repoRoot "detection-rules\sigma"
$splunkPath = Join-Path $repoRoot "detection-rules\splunk"
$wazuhPath = Join-Path $repoRoot "detection-rules\wazuh\rules"
$playbookPath = Join-Path $repoRoot "incident-response\playbooks"
$outPath = if ([System.IO.Path]::IsPathRooted($OutFile)) { $OutFile } else { Join-Path $repoRoot $OutFile }

$sigma = (Get-ChildItem -Recurse -Filter *.yml -Path $sigmaPath -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path $splunkPath -ErrorAction SilentlyContinue).Count
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path $wazuhPath -ErrorAction SilentlyContinue).Count
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path $wazuhPath -ErrorAction SilentlyContinue |
    Select-String -Pattern "<rule id=" | Measure-Object).Count
$playbooks = (Get-ChildItem -Recurse -Filter *.md -Path $playbookPath -ErrorAction SilentlyContinue).Count

$timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss UTC")
$commit = "UNKNOWN"
$branch = "UNKNOWN"

try {
    $commit = (git -C $repoRoot rev-parse --short HEAD).Trim()
    $branch = (git -C $repoRoot rev-parse --abbrev-ref HEAD).Trim()
} catch {
    # Running outside git-aware context is allowed for local previews.
}

$content = @"
# Verified Detection Counts

**Last Verified:** $timestamp
**Commit:** `$commit`
**Branch:** `$branch`

---

## Detection Rules

| Platform | Count | Location |
|----------|-------|----------|
| **Sigma** (YAML) | **$sigma** rules | `detection-rules/sigma/` |
| **Splunk** (SPL) | **$splunk** queries | `detection-rules/splunk/` |
| **Wazuh** (XML) | **$wazuhXmlFiles** files, **$wazuhRuleBlocks** rule blocks | `detection-rules/wazuh/rules/` |

## Incident Response

| Type | Count | Location |
|------|-------|----------|
| **IR Playbooks** (Markdown) | **$playbooks** playbooks | `incident-response/playbooks/` |

---

## Verification Commands

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
```

## Build Artifact Command

```powershell
pwsh -NoProfile -File ".\scripts\build-wazuh-bundle.ps1"
```

---

_Auto-generated from repository file counts._
"@

$outDir = Split-Path -Parent $outPath
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

Set-Content -LiteralPath $outPath -Value $content -Encoding UTF8
Write-Host "Wrote verified counts: $outPath"
