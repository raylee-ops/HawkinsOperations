# HawkinsOps Incident Response Playbook Index

**Version:** 1.0
**Last Updated:** 2025-01-15
**Total Playbooks:** 30+
**Author:** HawkinsOps SOC Team

---

## Playbook Catalog

### Credential Access
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-001 | Suspicious LSASS Process Access | Critical | T1003.001 | Windows |
| IR-004 | Mimikatz/Credential Dumping Tool | Critical | T1003 | Windows |
| IR-005 | Pass-the-Hash Attack | High | T1550.002 | Windows |
| IR-006 | Kerberoasting Attack | Medium | T1558.003 | Windows |
| IR-007 | DCSync Attack Detected | Critical | T1003.006 | Windows |

### Execution
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-002 | Suspicious PowerShell Execution | High | T1059.001 | Windows |
| IR-008 | Malicious Macro Execution | High | T1204.002 | Windows |
| IR-009 | MSHTA/Regsvr32 Abuse | High | T1218 | Windows |
| IR-010 | Suspicious Script Execution | Medium | T1059.005 | Windows |

### Persistence
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-011 | Unauthorized Scheduled Task | Medium | T1053.005 | Windows |
| IR-012 | Registry Run Key Modification | High | T1547.001 | Windows |
| IR-013 | New Service Installation | Medium | T1543.003 | Windows |
| IR-014 | WMI Persistence | High | T1546.003 | Windows |

### Lateral Movement
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-015 | Suspicious RDP Activity | Medium | T1021.001 | Windows |
| IR-016 | PsExec Lateral Movement | Medium | T1021.002 | Windows |
| IR-017 | WMI Remote Execution | Medium | T1047 | Windows |
| IR-018 | SMB/Admin Share Abuse | Medium | T1021.002 | Windows |

### Defense Evasion
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-019 | Event Log Clearing | High | T1070.001 | Windows |
| IR-020 | Security Software Disabled | High | T1562.001 | Windows |
| IR-021 | Process Injection Detected | High | T1055 | Windows |
| IR-022 | Suspicious Driver Load | Critical | T1014 | Windows |

### Impact
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-003 | Ransomware Detected | Critical | T1486 | Windows/Linux |
| IR-023 | Data Destruction Activity | Critical | T1485 | Windows/Linux |
| IR-024 | Cryptocurrency Mining | High | T1496 | Windows/Linux |
| IR-025 | DDoS Attack Response | High | T1498 | Network |

### Initial Access
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-026 | Phishing Email Response | High | T1566 | Email |
| IR-027 | Web Application Exploit | High | T1190 | Web |
| IR-028 | Brute Force Attack | Medium | T1110 | Windows/Linux |
| IR-029 | Web Shell Detected | Critical | T1505.003 | Web |

### Collection & Exfiltration
| ID | Playbook Name | Severity | MITRE | Platforms |
|----|---------------|----------|-------|-----------|
| IR-030 | Data Exfiltration Detected | High | T1041 | Windows/Linux |

---

## Quick Reference Guide

### Response Time Objectives
- **Critical:** Triage in 5 min, Contain in 15 min
- **High:** Triage in 10 min, Contain in 30 min
- **Medium:** Triage in 15 min, Contain in 1 hour
- **Low:** Triage in 30 min, Contain in 4 hours

### Escalation Matrix
| Severity | Escalate To | Timeframe |
|----------|-------------|-----------|
| Critical | Incident Commander + Management | Immediate |
| High | Senior Analyst + Team Lead | 15 minutes |
| Medium | Team Lead | 30 minutes |
| Low | Document, no escalation | N/A |

### Common Tools Referenced
- **Forensics:** FTK Imager, Volatility, Autopsy
- **Analysis:** Sysinternals Suite, Process Hacker, Wireshark
- **Remediation:** PowerShell, Windows built-ins
- **Threat Intel:** VirusTotal, Hybrid Analysis, ANY.RUN

---

## Using These Playbooks

1. **Detection Phase:** Identify relevant playbook from SIEM alert
2. **Follow Steps:** Execute triage → investigation → containment
3. **Document:** Use timeline templates provided
4. **Adapt:** Customize to your environment
5. **Improve:** Update based on lessons learned

---

## Maintenance

**Review Schedule:**
- Quarterly playbook review
- Update after major incidents
- Incorporate new TTPs
- Test procedures annually
- Gather analyst feedback

**Version Control:**
- Track changes in Git
- Document major revisions
- Maintain changelog
- Archive deprecated playbooks
