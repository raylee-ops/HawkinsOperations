# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

HawkinsOps SOC Content Library - A recruiter-friendly portfolio of security operations content including detection rules, incident response playbooks, threat hunting queries, and operational runbooks. This is a **Wazuh-first** release with verifiable artifact counts.

## Repository Structure

```
detection-rules/
├── wazuh/rules/                          # Individual XML rule modules (source of truth)
├── sigma/                                 # YAML-based detection rules (planned)
└── splunk/                                # SPL queries (planned)

incident-response/
├── playbooks/                            # IR playbooks following 7-step structure
├── IR-Template.md                        # Template for new playbooks
└── 00-Playbook-Index.md                 # Playbook catalog

threat-hunting/
├── windows/                              # Windows-focused hunt queries
├── linux/                                # Linux-focused hunt queries
└── 00-Hunt-Matrix.md                    # Hunt coverage matrix

runbooks/                                 # Operational procedures (scaffolded)

PROOF_PACK/                              # Evidence for portfolio validation
├── SCREENSHOTS/                          # Sanitized UI captures
├── DIAGRAMS/                             # Architecture/coverage diagrams
├── SAMPLES/                              # Sample artifacts
└── EVIDENCE_CHECKLIST.md                # Pre-publication sanitization guide

_archive/                                 # Imported legacy content from previous repos
```

## Key Architecture Principles

### Detection Rule Management

**Wazuh Rules:**
- Individual XML rule modules stored in `detection-rules/wazuh/rules/`
- Each XML file may contain **multiple `<rule id="...">` blocks**
- Rules follow Wazuh XML schema with MITRE ATT&CK tags
- Rules are **not** directly deployable from repo - must be bundled first

**Bundle Build Process:**
- Individual XML modules → Single deployable file (`dist/wazuh/local_rules.xml`)
- Build script concatenates all XML files, strips BOMs and XML declarations
- Target deployment location: `/var/ossec/etc/rules/local_rules.xml` on Wazuh manager

### Incident Response Playbooks

All playbooks follow a **7-step structure**:
1. Detection - What triggered the alert
2. Triage (5 min) - Initial assessment
3. Investigation (30 min) - Deep dive
4. Containment (15 min) - Stop the spread
5. Eradication - Remove the threat
6. Recovery - Restore operations
7. Documentation - Lessons learned

### Content Verification Philosophy

**Never hard-code counts in documentation.** All artifact counts must be derived from verification commands to ensure accuracy.

## Commands

### Verify Detection Rule Counts (PowerShell)

From repo root (Windows):

```powershell
# Count detection rules by type
$sigma  = (Get-ChildItem -Recurse -Filter *.yml -Path ".\detection-rules\sigma" -ErrorAction SilentlyContinue).Count
$splunk = (Get-ChildItem -Recurse -Filter *.spl -Path ".\detection-rules\splunk" -ErrorAction SilentlyContinue).Count

# Wazuh: Count XML files AND individual rule blocks
$wazuhXmlFiles = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue).Count
$wazuhRuleBlocks = (Get-ChildItem -Recurse -Filter *.xml -Path ".\detection-rules\wazuh\rules" -ErrorAction SilentlyContinue |
    Select-String -Pattern "<rule id=" | Measure-Object).Count

Write-Host "Sigma (.yml): $sigma | Splunk (.spl): $splunk | Wazuh XML files: $wazuhXmlFiles | Wazuh <rule id=> blocks: $wazuhRuleBlocks"
```

### Verify IR Playbook Counts (PowerShell)

```powershell
$playbooks = (Get-ChildItem -Recurse -Filter *.md -Path ".\incident-response\playbooks" -ErrorAction SilentlyContinue).Count
Write-Host "IR playbooks (.md): $playbooks"
```

### Build Deployable Wazuh Bundle

From repo root:

**PowerShell (Windows):**
```powershell
.\scripts\build-wazuh-bundle.ps1
```

**Bash (Linux/WSL):**
```bash
bash ./scripts/build-wazuh-bundle.sh
```

**Output:** `dist/wazuh/local_rules.xml`

### Deploy to Wazuh Manager (Example)

```bash
# Copy bundle to manager
sudo cp dist/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml

# Restart Wazuh manager
sudo systemctl restart wazuh-manager

# Verify rules loaded
sudo tail -n 120 /var/ossec/logs/ossec.log | grep -i -E 'rule|local_rules'
```

### Pre-Commit Security Scan (Bash)

Before publishing screenshots or artifacts, run sanitization checks:

```bash
# Scan for real IP addresses
grep -r -E "([0-9]{1,3}\.){3}[0-9]{1,3}" --include="*.md" --include="*.xml" --include="*.yml"

# Scan for Windows paths with usernames
grep -r -E "C:\\\\Users\\\\" --include="*.md" --include="*.xml" --include="*.yml"

# Scan for secrets
grep -r -E "(password|api_key|token|secret)" --include="*.md" --include="*.xml" --include="*.yml"

# Scan for email addresses
grep -r -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" --include="*.md"
```

**If ANY results appear: STOP. Review. Sanitize before committing.**

### Check for Legacy Repo Name References (PowerShell)

```powershell
Get-ChildItem -Recurse -File | Where-Object {
  $_.Extension -in ".md",".html",".yml",".yaml",".xml",".js",".json",".txt"
} | Select-String -Pattern "HawkinsOperations" -SimpleMatch | Select-Object Path, LineNumber, Line
```

Should return no results in the canonical repo.

## Important References

- Main entry point: `START_HERE.md`
- Wazuh deployment guide: `docs/wazuh/DEPLOYMENT_REALITY.md`
- Verification commands: `docs/VERIFY_COMMANDS_POWERSHELL.md`
- Evidence sanitization: `PROOF_PACK/EVIDENCE_CHECKLIST.md`
- Security policy: `SECURITY.md`

## Content Standards

### When Adding Wazuh Rules

- Store as individual XML files in `detection-rules/wazuh/rules/`
- Include embedded comments with: Description, Author, Date, Summary, Fields Used, False Positives, MITRE ATT&CK mapping, Log Sources, Test Examples, Tuning Notes
- Use MITRE ATT&CK technique IDs in `<mitre><id>` tags
- Set appropriate severity level (1-15)

### When Adding IR Playbooks

- Follow the 7-step structure template in `incident-response/IR-Template.md`
- Include MITRE ATT&CK technique mapping
- Provide time estimates for each phase
- List required tools and access levels
- Include detection criteria and false positive scenarios

### When Adding Screenshots/Evidence

**Critical:** All evidence must be sanitized per `PROOF_PACK/EVIDENCE_CHECKLIST.md`

Never include:
- Real IP addresses (use 10.x.x.x or 192.168.x.x)
- Real hostnames (use generic names like "WORKSTATION-01")
- Real usernames/emails
- API keys, tokens, passwords
- Internal company names
- File paths containing usernames

## Security Notes

This repository is designed for **public portfolio use**. All content must be sanitized before publication. The `_archive/` directory contains imported legacy content that should not be modified directly - canonical content lives in the root-level directories.
