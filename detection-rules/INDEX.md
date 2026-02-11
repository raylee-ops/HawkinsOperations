# Detection Rules Index

Primary detection content is grouped by platform, with supporting mapping artifacts for implementation contexts.

## Layout

- `detection-rules/sigma/` Sigma YAML rules by ATT&CK tactic
- `detection-rules/splunk/` SPL query packs
- `detection-rules/wazuh/` Wazuh XML modules (`rules/`)
- `detection-rules/mappings/` platform and automation mapping artifacts

## Verification

Use repository scripts:

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
```

`PROOF_PACK/VERIFIED_COUNTS.md` is generated from live file counts.
