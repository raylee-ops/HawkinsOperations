# Verified Detection Counts

**Last Verified:** 2026-02-11 09:24:51 UTC
**Commit:** $commit
**Branch:** $branch

---

## Detection Rules

| Platform | Count | Location |
|----------|-------|----------|
| **Sigma** (YAML) | **105** rules | detection-rules/sigma/ |
| **Splunk** (SPL) | **8** queries | detection-rules/splunk/ |
| **Wazuh** (XML) | **25** files, **29** rule blocks | detection-rules/wazuh/rules/ |

## Incident Response

| Type | Count | Location |
|------|-------|----------|
| **IR Playbooks** (Markdown) | **10** playbooks | incident-response/playbooks/ |

---

## Verification Commands

`powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
`

## Build Artifact Command

`powershell
pwsh -NoProfile -File ".\scripts\build-wazuh-bundle.ps1"
`

---

_Auto-generated from repository file counts._
