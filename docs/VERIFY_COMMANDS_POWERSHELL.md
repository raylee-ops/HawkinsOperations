# Verification Commands (PowerShell)

Run from repo root.

## Preferred (scripted) commands

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
```

## Raw counting commands (manual)

```powershell
$sigma  = (Get-ChildItem -Recurse -Filter *.yml -Path ".\detection-rules\sigma" -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path ".\detection-rules\splunk" -ErrorAction SilentlyContinue).Count
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue).Count
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue |
  Select-String -Pattern "<rule id=" | Measure-Object).Count
$playbooks = (Get-ChildItem -Recurse -Filter *.md -Path ".\incident-response\playbooks" -ErrorAction SilentlyContinue).Count

Write-Host "Sigma (.yml): $sigma"
Write-Host "Splunk (.spl): $splunk"
Write-Host "Wazuh XML files: $wazuhXmlFiles"
Write-Host "Wazuh <rule id=> blocks: $wazuhRuleBlocks"
Write-Host "IR playbooks (.md): $playbooks"
```
