# HawkinsOps SOC Content Library

Production-ready detection rules, incident response playbooks, and threat hunting queries for Security Operations Centers.

---

## 📊 Content Metrics

| Category | Count | Formats |
|----------|-------|---------|
| **Detection Rules** | 200+ | Sigma (104), Wazuh (52), Splunk (60+) |
| **IR Playbooks** | 30 | Markdown, structured triage→recovery |
| **Threat Hunts** | 50 | Windows (30), Linux (20) |
| **MITRE Coverage** | 11 tactics | 45+ techniques mapped |

---

## 🔗 Quick Navigation

| Section | Description | Link |
|---------|-------------|------|
| Detection Rules | Sigma, Wazuh XML, Splunk SPL | [INDEX](./detection-rules/INDEX.md) |
| Incident Response | 30 playbooks, templates | [INDEX](./incident-response/INDEX.md) |
| Threat Hunting | Hypothesis-driven queries | [INDEX](./threat-hunting/INDEX.md) |
| Runbooks | Operational procedures | [INDEX](./runbooks/INDEX.md) |
| **Proof Pack** | Recruiter download package | [VIEW](./PROOF_PACK/PROOF_INDEX.md) |

---

## 🎯 MITRE ATT&CK Coverage

| Tactic | Techniques | Key Detections |
|--------|------------|----------------|
| Initial Access | 4 | Phishing, Valid Accounts |
| Execution | 5 | PowerShell, Command Line |
| Persistence | 6 | Registry, Scheduled Tasks, Services |
| Privilege Escalation | 5 | UAC Bypass, Token Manipulation |
| Defense Evasion | 7 | Process Injection, Timestomp, Log Clear |
| Credential Access | 6 | LSASS, Kerberoasting, DCSync |
| Discovery | 5 | Network Scan, Account Enumeration |
| Lateral Movement | 4 | RDP, SMB, WinRM |
| Collection | 3 | Clipboard, Screen Capture |
| Exfiltration | 2 | DNS, HTTP |
| Impact | 3 | Ransomware, Data Destruction |

---

## 📁 Repository Structure

```
hawkinsops-soc-content/
├── detection-rules/
│   ├── INDEX.md
│   ├── sigma/           # 104 platform-agnostic rules
│   │   ├── credential-access/
│   │   ├── persistence/
│   │   ├── privilege-escalation/
│   │   └── [8 more tactic folders]
│   ├── wazuh/           # 52 XML rules (deployable)
│   └── splunk/          # 60+ SPL queries
├── incident-response/
│   ├── INDEX.md
│   └── playbooks/       # 30 structured playbooks
├── threat-hunting/
│   ├── INDEX.md
│   ├── windows/         # 30 hunt queries
│   └── linux/           # 20 hunt queries
├── runbooks/
│   └── INDEX.md
├── learning-system/
│   └── INDEX.md
├── PROOF_PACK/          # Downloadable evidence
│   ├── PROOF_INDEX.md
│   ├── SCREENSHOTS/
│   ├── DIAGRAMS/
│   └── SAMPLES/
└── README.md
```

---

## 🚀 Quick Start

**For SOC Analysts:**
1. Browse [Detection Rules INDEX](./detection-rules/INDEX.md)
2. Deploy Wazuh rules to `/var/ossec/etc/rules/local_rules.xml`
3. Use Sigma rules with your preferred converter

**For Recruiters:**
1. View the [Proof Pack](./PROOF_PACK/PROOF_INDEX.md)
2. Check [Releases](../../releases) for downloadable samples

---

## ✅ Validation

All detection rules include:
- MITRE ATT&CK technique mapping
- Test case with reproduction steps
- False positive documentation
- Severity rating and tuning guidance

---

## 👤 Author

**HawkinsOps**  
Detection Engineering | Security Automation | SOC Operations

📍 Gadsden, AL → Huntsville, AL (September 2026)  
🌐 [hawkinsops.com](https://hawkinsops.com)

---

## 📋 Version

**v1.0** | January 2026  
Initial release: Full SOC content library

---

*This library contains production-ready security content. Test in non-production environments before deployment.*
# HawkinsOperations
