# Detection Rules Index

This repo is the canonical SOC content library. Counts should be taken from the verification commands:

- `docs/VERIFY_COMMANDS_POWERSHELL.md`

---

## What’s in this repo right now (repo-verified)

### Wazuh (XML)
- Stored as individual XML modules here:
  - `detection-rules/wazuh/_incoming/WAZUH_RULES_PRIMARY/*.xml`
- **Important:** Some XML files contain multiple `<rule id="...">` blocks.
  - Quote **rule block count**, not just file count.

### Sigma (YAML) — planned
- Folder: `detection-rules/sigma/`
- Status: scaffolded for future additions

### Splunk (SPL) — planned
- Folder: `detection-rules/splunk/`
- Status: scaffolded for future additions
