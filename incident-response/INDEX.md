# Incident Response Index

This folder contains incident response playbooks in Markdown.

## Quick Stats (repo-verified)
| Metric | Value |
|--------|-------|
| **Playbooks present** | 10 |
| **Templates/References** | 2 |
| **Format** | Markdown |

---

## Playbook Structure

Every playbook follows a 7-step structure:

1. **Detection** - What triggered the alert  
2. **Triage** (5 min) - Initial assessment  
3. **Investigation** (30 min) - Deep dive  
4. **Containment** (15 min) - Stop the spread  
5. **Eradication** - Remove the threat  
6. **Recovery** - Restore operations  
7. **Documentation** - Lessons learned  

---

## Featured Playbooks

### Critical Priority

| ID | Name | MITRE | Location |
|----|------|-------|----------|
| IR-001 | LSASS Process Access | T1003.001 | [View](./playbooks/IR-001-LSASS-Access.md) |
| IR-003 | Ransomware Detected | T1486 | [View](./playbooks/IR-003-Ransomware-Detected.md) |
| IR-007 | Active Directory Compromise | T1003.006 | [View](./playbooks/IR-007-AD-Compromise.md) |
| IR-015 | Data Exfiltration | T1041 | [View](./playbooks/IR-015-Exfiltration.md) |
| IR-022 | Supply Chain Attack | T1195 | [View](./playbooks/IR-022-Supply-Chain.md) |

### High Priority

| ID | Name | MITRE | Location |
|----|------|-------|----------|
| IR-002 | Suspicious PowerShell | T1059.001 | [View](./playbooks/IR-002-Suspicious-PowerShell.md) |
| IR-004 | Brute Force Attack | T1110 | [View](./playbooks/IR-004-Brute-Force.md) |
| IR-005 | Malware Execution | T1204 | [View](./playbooks/IR-005-Malware.md) |
| IR-006 | Privilege Escalation | T1068 | [View](./playbooks/IR-006-Priv-Esc.md) |
| IR-008 | Lateral Movement | T1021 | [View](./playbooks/IR-008-Lateral-Movement.md) |

---

## Templates / References

- [IR Playbook Template](./playbooks/IR-Template.md)
- [IR Quick Reference](./playbooks/IR-004-to-030-Quick-Reference.md)
