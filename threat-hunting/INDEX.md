# Threat Hunting Index

## Quick Stats

| Platform | Count | Location |
|----------|-------|----------|
| Windows Hunts | 30 | `./windows/` |
| Linux Hunts | 20 | `./linux/` |
| **Total** | **50** | |

---

## Hunt Methodology

Each hunt follows a hypothesis-driven approach:

1. **Hypothesis** - What are we looking for?
2. **Data Sources** - What logs/telemetry needed?
3. **Query** - The actual hunt query
4. **Expected Results** - What normal looks like
5. **Indicators** - What malicious looks like
6. **Escalation** - When to create an incident

---

## Windows Hunts (30)

### By Attack Phase

| Phase | Count | Key Hunts |
|-------|-------|-----------|
| Initial Access | 4 | Phishing artifacts, suspicious downloads |
| Execution | 6 | PowerShell, WMI, Scheduled Tasks |
| Persistence | 5 | Registry, Services, Startup |
| Privilege Escalation | 4 | UAC bypass, Token manipulation |
| Defense Evasion | 5 | Process injection, Log tampering |
| Credential Access | 4 | LSASS, SAM, Cached creds |
| Lateral Movement | 2 | RDP, SMB, PsExec |

### Featured Windows Hunts

| Hunt ID | Name | Technique | Data Source |
|---------|------|-----------|-------------|
| WH-001 | PowerShell Encoded Commands | T1059.001 | PowerShell Logs |
| WH-002 | LSASS Access Patterns | T1003.001 | Sysmon Event 10 |
| WH-003 | Suspicious Service Creation | T1543.003 | System Event 7045 |
| WH-004 | Registry Run Key Additions | T1547.001 | Sysmon Event 13 |
| WH-005 | Scheduled Task Anomalies | T1053.005 | Security Event 4698 |
| WH-006 | Parent-Child Process Anomalies | T1055 | Sysmon Event 1 |
| WH-007 | Network Connections from LOLBins | T1218 | Sysmon Event 3 |
| WH-008 | Unsigned DLL Loading | T1574.001 | Sysmon Event 7 |
| WH-009 | Credential Dumping Tools | T1003 | Multiple |
| WH-010 | Kerberoasting Activity | T1558.003 | Security Event 4769 |

---

## Linux Hunts (20)

### By Attack Phase

| Phase | Count | Key Hunts |
|-------|-------|-----------|
| Initial Access | 3 | SSH anomalies, Web shells |
| Execution | 4 | Cron jobs, Shell scripts |
| Persistence | 4 | SSH keys, Cron, Services |
| Privilege Escalation | 3 | SUID, Sudo abuse |
| Defense Evasion | 3 | Log deletion, Timestomping |
| Credential Access | 3 | /etc/shadow, SSH keys |

### Featured Linux Hunts

| Hunt ID | Name | Technique | Data Source |
|---------|------|-----------|-------------|
| LH-001 | SSH Brute Force Patterns | T1110.001 | auth.log |
| LH-002 | Suspicious Cron Additions | T1053.003 | auditd |
| LH-003 | SUID Binary Anomalies | T1548.001 | auditd |
| LH-004 | Reverse Shell Indicators | T1059.004 | auditd, netstat |
| LH-005 | Unauthorized SSH Key Addition | T1098.004 | auditd |
| LH-006 | Web Shell Detection | T1505.003 | Web logs |
| LH-007 | Privilege Escalation via Sudo | T1548.003 | auth.log |
| LH-008 | Log Tampering Detection | T1070.002 | auditd |
| LH-009 | Container Escape Attempts | T1611 | auditd |
| LH-010 | Cryptominer Indicators | T1496 | process, network |

---

## Hunt Matrix

Quick reference for scheduling hunts:

| Frequency | Hunt Types |
|-----------|------------|
| Daily | Authentication anomalies, New services |
| Weekly | Persistence mechanisms, Lateral movement |
| Monthly | Full credential access review, Baseline updates |
| Quarterly | Complete hunt cycle, Detection gap analysis |

---

## Data Source Requirements

### Windows

| Source | Required For | Configuration |
|--------|--------------|---------------|
| Sysmon | Process, Network, Registry | SwiftOnSecurity config |
| PowerShell Logging | Script execution | Enable ScriptBlock logging |
| Security Events | Authentication, Privilege use | Advanced Audit Policy |
| Windows Defender | Malware detections | Enable cloud protection |

### Linux

| Source | Required For | Configuration |
|--------|--------------|---------------|
| auditd | File, Process, Network | Custom audit.rules |
| auth.log | Authentication | Default syslog |
| syslog | System events | Default |
| Web server logs | Web attacks | Enable access logging |

---

## Hunt Execution Tracking

| Status | Description |
|--------|-------------|
| 🟢 Active | Currently running on schedule |
| 🟡 Pending | Query ready, not yet deployed |
| 🔴 Disabled | Temporarily disabled (tuning) |
| ⚪ Planned | In development |

---

[← Back to Main README](../README.md)
