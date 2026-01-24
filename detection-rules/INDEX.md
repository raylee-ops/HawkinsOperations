# Detection Rules Index

## Quick Stats

| Platform | Count | Format | Location |
|----------|-------|--------|----------|
| Sigma | 104 | YAML | `./sigma/` |
| Wazuh | 52 | XML | `./wazuh/` |
| Splunk | 60+ | SPL | `./splunk/` |
| **Total** | **200+** | | |

---

## Sigma Rules (104)

Platform-agnostic detection rules in YAML format. Compatible with any SIEM via Sigma converters.

### By MITRE Tactic

| Tactic | Count | Folder |
|--------|-------|--------|
| Credential Access | 10 | `sigma/credential-access/` |
| Persistence | 11 | `sigma/persistence/` |
| Privilege Escalation | 10 | `sigma/privilege-escalation/` |
| Defense Evasion | 10 | `sigma/defense-evasion/` |
| Lateral Movement | 10 | `sigma/lateral-movement/` |
| Execution | 10 | `sigma/execution/` |
| Discovery | 10 | `sigma/discovery/` |
| Collection | 10 | `sigma/collection/` |
| Exfiltration | 10 | `sigma/exfiltration/` |
| Impact | 13 | `sigma/impact/` |

### Key Rules

- `T1003.001` - LSASS Memory Dump Detection
- `T1059.001` - Suspicious PowerShell Execution
- `T1486` - Ransomware File Extension Changes
- `T1070.001` - Windows Event Log Clearing

---

## Wazuh Rules (52)

Production-ready XML rules for Wazuh SIEM. Rule IDs: 100001-100200.

### Deployment

```bash
# Copy to Wazuh manager
cp hawkinsops-custom-rules.xml /var/ossec/etc/rules/local_rules.xml

# Restart Wazuh
systemctl restart wazuh-manager
```

### Rule Categories

| Category | Count | Level Range |
|----------|-------|-------------|
| Authentication | 12 | 5-12 |
| Process Monitoring | 15 | 8-14 |
| File Integrity | 10 | 6-10 |
| Network Activity | 8 | 7-12 |
| Privilege Escalation | 7 | 10-15 |

---

## Splunk Queries (60+)

SPL queries organized by MITRE tactic.

### Files

| File | Focus | Query Count |
|------|-------|-------------|
| `credential_access_detections.spl` | Credential theft | 8 |
| `persistence_detections.spl` | Persistence mechanisms | 10 |
| `privilege_escalation_detections.spl` | Priv esc techniques | 8 |
| `defense_evasion_detections.spl` | Evasion tactics | 12 |
| `lateral_movement_detections.spl` | Lateral movement | 8 |
| `execution_detections.spl` | Execution methods | 10 |
| `discovery_detections.spl` | Recon commands | 6 |
| `collection_exfiltration_impact.spl` | Late-stage TTPs | 8 |

---

## Deployment Priority

### Tier 1 - Critical (Deploy First)
1. Ransomware Detection (T1486)
2. LSASS Memory Dumps (T1003.001)
3. DCSync Attacks (T1003.006)
4. Event Log Clearing (T1070.001)
5. AMSI Bypass (T1562.001)

### Tier 2 - High Priority
1. UAC Bypass (T1548.002)
2. Windows Defender Disable (T1562.001)
3. Process Injection (T1055)
4. Kerberoasting (T1558.003)
5. Suspicious PowerShell (T1059.001)

### Tier 3 - Standard
- Persistence mechanisms
- Lateral movement indicators
- Discovery commands

---

## Validation Status

| Status | Count | Percentage |
|--------|-------|------------|
| ✅ Validated | 180+ | 90% |
| 🔄 In Testing | 15 | 7.5% |
| 📝 Documented | 5 | 2.5% |

---

[← Back to Main README](../README.md)
