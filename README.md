# HawkinsOps SOC Content Library

**Portfolio-ready security operations content with verifiable detection rules and production deployment capability.**

> 🎯 **For Recruiters & Hiring Managers:** [START_HERE.md](START_HERE.md) provides a 90-second validation path
> 🔍 **For Technical Reviewers:** Run `.\\_verify_counts.ps1` to reproduce all artifact counts

---

## What This Repository Demonstrates

✅ **Multi-Platform Detection Engineering** - Sigma, Splunk, and Wazuh rule development
✅ **Incident Response Frameworks** - Structured 7-step IR playbooks with MITRE ATT&CK mapping
✅ **Production Deployment Knowledge** - Buildable, deployable Wazuh bundles with real deployment paths
✅ **Verifiable Claims** - All counts derived from file system, reproducible by anyone

---

## Quick Navigation

| Audience | Start Here | Time |
|----------|-----------|------|
| **Recruiters / Hiring Managers** | [START_HERE.md](START_HERE.md) | 90 seconds |
| **Technical Interviewers** | [PROOF_PACK/ARCHITECTURE.md](PROOF_PACK/ARCHITECTURE.md) | 5 minutes |
| **Security Engineers** | [detection-rules/INDEX.md](detection-rules/INDEX.md) | Browse rules |
| **Verification** | [PROOF_PACK/VERIFIED_COUNTS.md](PROOF_PACK/VERIFIED_COUNTS.md) | See counts |

---

## Detection Content Overview

This repository contains production-ready security detection content across multiple platforms:

### Platform-Specific Detection Rules

| Platform | Description | Location | Format |
|----------|-------------|----------|--------|
| **Sigma** | Platform-agnostic YAML rules organized by MITRE ATT&CK tactics | `detection-rules/sigma/` | YAML |
| **Splunk** | SPL-based detection queries for Splunk Enterprise Security | `detection-rules/splunk/` | SPL |
| **Wazuh** | XML rule modules for open-source SIEM deployment | `detection-rules/wazuh/rules/` | XML |

### Incident Response & Operations

| Type | Description | Location | Format |
|------|-------------|----------|--------|
| **IR Playbooks** | 7-step incident response procedures with time-boxed phases | `incident-response/playbooks/` | Markdown |
| **Threat Hunting** | Hypothesis-driven hunt queries (in progress) | `threat-hunting/` | Various |
| **Runbooks** | Operational procedures (in progress) | `runbooks/` | Markdown |

---

## Verification & Proof

**Verification Philosophy:** Counts are never hard-coded. All numbers are derived from the file system and reproducible.

### Quick Verification (PowerShell)

Run from repo root to see actual counts:

```powershell
.\\_verify_counts.ps1
```

**Example output:**
```
Sigma (.yml files):       105
Splunk (.spl files):      8
Wazuh XML files:          25
Wazuh <rule id=> blocks:  29
IR Playbooks (.md files): 12
```

### Detailed Verification

See [docs/VERIFY_COMMANDS_POWERSHELL.md](docs/VERIFY_COMMANDS_POWERSHELL.md) for individual platform commands.

---

## Production Deployment Example (Wazuh)

**Demonstrates:** Repository → Production deployment workflow

### Build Deployable Bundle

**PowerShell (Windows):**
```powershell
.\scripts\build-wazuh-bundle.ps1
```

**Bash (Linux/WSL):**
```bash
bash ./scripts/build-wazuh-bundle.sh
```

**Output:** `dist/wazuh/local_rules.xml` (single deployable file containing all rules)

### Deploy to Wazuh Manager

```bash
sudo cp dist/wazuh/local_rules.xml /var/ossec/etc/rules/local_rules.xml
sudo systemctl restart wazuh-manager
sudo tail -n 80 /var/ossec/logs/ossec.log | grep -i rule
```

**Full deployment guide:** [docs/wazuh/DEPLOYMENT_REALITY.md](docs/wazuh/DEPLOYMENT_REALITY.md)

---

## Security & Privacy

✅ **No sensitive data** - All content is sanitized for public sharing
✅ **No secrets** - No API keys, tokens, or credentials
✅ **No internal information** - Generic IPs (10.x.x.x), hostnames (WORKSTATION-01), usernames (analyst01)

**Sanitization checklist:** [PROOF_PACK/EVIDENCE_CHECKLIST.md](PROOF_PACK/EVIDENCE_CHECKLIST.md)
**Security policy:** [SECURITY.md](SECURITY.md)

---

## License & Attribution

This repository is licensed under the MIT License. See [LICENSE](LICENSE) for details.

**Author:** Ray Lee (HawkinsOps)
**Purpose:** Security operations portfolio demonstrating multi-platform detection engineering and incident response capabilities.
