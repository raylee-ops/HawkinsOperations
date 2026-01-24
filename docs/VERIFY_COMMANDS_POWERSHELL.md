# Verification Commands (PowerShell)

Run these from **repo root** (Windows PowerShell). These commands are designed to be **copy/paste safe** and to return **reproducible counts** you can quote in README/Release notes.

> Rule of thumb: if you can’t verify it with one command, don’t claim it.

---

## 1) Detection content counts (repo-verified)

```powershell
# Detection rules (counts are 0 if a folder doesn't exist)
$sigma  = (Get-ChildItem -Recurse -Filter *.yml -Path ".\detection-rules\sigma" -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path ".\detection-rules\splunk" -ErrorAction SilentlyContinue).Count

# Wazuh:
# - XML file modules present
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\_incoming\WAZUH_RULES_PRIMARY" -ErrorAction SilentlyContinue).Count
# - Individual <rule id="..."> blocks (what actually matters)
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\_incoming\WAZUH_RULES_PRIMARY" -ErrorAction SilentlyContinue |
    Select-String -Pattern "<rule id=" | Measure-Object).Count

Write-Host "Sigma (.yml): $sigma | Splunk (.spl): $splunk | Wazuh XML files: $wazuhXmlFiles | Wazuh <rule id=> blocks: $wazuhRuleBlocks"
```

---

## 2) IR playbook counts (repo-verified)

```powershell
$playbooks = (Get-ChildItem -Recurse -Filter *.md -Path ".\incident-response\playbooks" -ErrorAction SilentlyContinue).Count
Write-Host "IR playbooks (.md): $playbooks"
```

---

## 3) Link/name integrity check (legacy repo name purge)

```powershell
Get-ChildItem -Recurse -File | Where-Object {
  $_.Extension -in ".md",".html",".yml",".yaml",".xml",".js",".json",".txt"
} | Select-String -Pattern "HawkinsOperations" -SimpleMatch | Select-Object Path, LineNumber, Line
```

If this returns any hits in your canonical repo, fix them before tagging a release.
