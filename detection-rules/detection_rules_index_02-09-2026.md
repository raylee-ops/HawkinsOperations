# Detection Rules Index

This repo is the canonical SOC content library. Counts should be taken from the verification commands:

- `docs/VERIFY_COMMANDS_POWERSHELL.md`

---

## What's in this repo right now (repo-verified)

### Sigma (YAML)
- Folder: `detection-rules/sigma/`
- Organized by MITRE ATT&CK tactics (credential-access, defense-evasion, discovery, execution, etc.)
- Format: Standard Sigma YAML detection rules
- Count verification: use `docs/VERIFY_COMMANDS_POWERSHELL.md`

### Splunk (SPL)
- Folder: `detection-rules/splunk/`
- Organized by MITRE ATT&CK tactics with SPL search queries
- Format: Splunk Search Processing Language (.spl files)
- Count verification: use `docs/VERIFY_COMMANDS_POWERSHELL.md`

### Wazuh (XML)
- Stored as individual XML modules here:
  - `detection-rules/wazuh/rules/*.xml`
- **Important:** Some XML files contain multiple `<rule id="...">` blocks.
  - Quote **rule block count**, not just file count.
- Count verification: use `docs/VERIFY_COMMANDS_POWERSHELL.md`
