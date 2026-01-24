# Incident Response Index

## Quick Stats

| Metric | Value |
|--------|-------|
| **Total Playbooks** | 30 |
| **Critical Severity** | 5 |
| **High Severity** | 12 |
| **Medium Severity** | 13 |
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

## Playbook Index (Full List)

| ID | Name | Severity | MITRE |
|----|------|----------|-------|
| IR-001 | LSASS Process Access | Critical | T1003.001 |
| IR-002 | Suspicious PowerShell | High | T1059.001 |
| IR-003 | Ransomware Detected | Critical | T1486 |
| IR-004 | Brute Force Attack | High | T1110 |
| IR-005 | Malware Execution | High | T1204 |
| IR-006 | Privilege Escalation | High | T1068 |
| IR-007 | AD Compromise | Critical | T1003.006 |
| IR-008 | Lateral Movement | High | T1021 |
| IR-009 | Persistence Mechanism | Medium | T1547 |
| IR-010 | Scheduled Task Creation | Medium | T1053.005 |
| IR-011 | Service Installation | Medium | T1543.003 |
| IR-012 | Registry Modification | Medium | T1112 |
| IR-013 | Account Creation | Medium | T1136 |
| IR-014 | Account Modification | Medium | T1098 |
| IR-015 | Data Exfiltration | Critical | T1041 |
| IR-016 | C2 Communication | High | T1071 |
| IR-017 | DNS Tunneling | High | T1071.004 |
| IR-018 | Web Shell | High | T1505.003 |
| IR-019 | Process Injection | High | T1055 |
| IR-020 | DLL Hijacking | Medium | T1574.001 |
| IR-021 | Timestomping | Medium | T1070.006 |
| IR-022 | Supply Chain Attack | Critical | T1195 |
| IR-023 | Phishing Response | High | T1566 |
| IR-024 | Insider Threat | High | T1078 |
| IR-025 | Cloud Compromise | High | T1078.004 |
| IR-026 | Mobile Device Compromise | Medium | T1437 |
| IR-027 | Physical Access Incident | Medium | T1200 |
| IR-028 | Social Engineering | Medium | T1598 |
| IR-029 | Third Party Breach | Medium | T1199 |
| IR-030 | Unknown Malware | High | T1204 |

---

## Resources

- [IR Template](./playbooks/IR-Template.md) - Blank template for new playbooks
- [Quick Reference](./playbooks/IR-004-to-030-Quick-Reference.md) - Condensed procedures

---

## Response Time Targets

| Severity | Triage | Containment | Resolution |
|----------|--------|-------------|------------|
| Critical | 5 min | 30 min | 4 hours |
| High | 15 min | 1 hour | 8 hours |
| Medium | 30 min | 4 hours | 24 hours |

---

[← Back to Main README](../README.md)
