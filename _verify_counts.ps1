# Verification script - counts all detection content
$sigma = (Get-ChildItem -Recurse -Filter *.yml -Path ".\detection-rules\sigma" -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path ".\detection-rules\splunk" -ErrorAction SilentlyContinue).Count
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue).Count
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue |
    Select-String -Pattern "<rule id=" | Measure-Object).Count
$playbooks = (Get-ChildItem -Recurse -Filter *.md -Path ".\incident-response\playbooks" -ErrorAction SilentlyContinue).Count

Write-Host "======================================"
Write-Host "HawkinsOps Detection Content Counts"
Write-Host "======================================"
Write-Host ""
Write-Host "Sigma (.yml files):       $sigma"
Write-Host "Splunk (.spl files):      $splunk"
Write-Host "Wazuh XML files:          $wazuhXmlFiles"
Write-Host "Wazuh <rule id=> blocks:  $wazuhRuleBlocks"
Write-Host "IR Playbooks (.md files): $playbooks"
Write-Host ""
Write-Host "======================================"
