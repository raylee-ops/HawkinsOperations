# HawkinsOps Proof Pack v1.0

**Purpose:** Everything a recruiter needs to evaluate this work in 2 minutes.

---

## ⚡ 30-Second Summary

| What | Count | Evidence |
|------|-------|----------|
| Detection Rules | 200+ | [View Index](../detection-rules/INDEX.md) |
| IR Playbooks | 30 | [View Index](../incident-response/INDEX.md) |
| Threat Hunts | 50 | [View Index](../threat-hunting/INDEX.md) |
| MITRE Techniques | 45+ | Mapped throughout |
| Platforms | 3 | Sigma, Wazuh, Splunk |

---

## 🎯 What This Proves

| Skill | Evidence |
|-------|----------|
| Detection Engineering | 200+ rules across 3 platforms |
| MITRE ATT&CK Fluency | Every rule mapped to techniques |
| Incident Response | 30 structured playbooks |
| Threat Hunting | 50 hypothesis-driven queries |
| Documentation | Consistent structure, navigable |
| Operational Thinking | Runbooks, procedures, workflows |

---

## 📸 Screenshots

| Screenshot | What It Shows | File |
|------------|---------------|------|
| Wazuh Dashboard | Active SIEM with alerts | [View](./SCREENSHOTS/wazuh-dashboard.png) |
| Alert Triggered | Detection rule firing | [View](./SCREENSHOTS/alert-triggered.png) |
| MITRE Coverage | Framework alignment | [View](./DIAGRAMS/mitre-coverage.png) |
| Folder Structure | Organized repository | [View](./SCREENSHOTS/repo-structure.png) |

*Note: Add screenshots to SCREENSHOTS/ folder*

---

## 📁 Sample Files

| Sample | Type | Location |
|--------|------|----------|
| LSASS Detection | Sigma Rule | [View](./SAMPLES/T1003-001-lsass-access.yml) |
| Ransomware Playbook | IR Playbook | [View](./SAMPLES/IR-003-Ransomware.md) |
| PowerShell Hunt | Hunt Query | [View](./SAMPLES/WH-001-powershell-encoded.md) |

*Note: Add sample files to SAMPLES/ folder*

---

## ✅ How to Verify

### Verify Rule Counts
```bash
# Clone the repo
git clone https://github.com/raylee-ops/hawkinsops-soc-content.git
cd hawkinsops-soc-content

# Count Sigma rules
find detection-rules/sigma -name "*.yml" | wc -l

# Count Wazuh rules
grep -c "<rule id=" detection-rules/wazuh/*.xml

# Count Splunk queries
grep -c "index=" detection-rules/splunk/*.spl
```

### Verify Structure
```bash
# View folder tree
tree -L 2
```

---

## 📊 MITRE Coverage Matrix

| Tactic | Techniques | % Coverage |
|--------|------------|------------|
| Initial Access | 4/9 | 44% |
| Execution | 5/12 | 42% |
| Persistence | 6/19 | 32% |
| Privilege Escalation | 5/13 | 38% |
| Defense Evasion | 7/42 | 17% |
| Credential Access | 6/17 | 35% |
| Discovery | 5/31 | 16% |
| Lateral Movement | 4/9 | 44% |
| Collection | 3/17 | 18% |
| Exfiltration | 2/9 | 22% |
| Impact | 3/14 | 21% |

*Note: Coverage prioritizes high-impact, high-frequency techniques*

---

## 🔗 Quick Links

- [Main README](../README.md)
- [Detection Rules](../detection-rules/INDEX.md)
- [Incident Response](../incident-response/INDEX.md)
- [Threat Hunting](../threat-hunting/INDEX.md)
- [GitHub Releases](../../releases) *(for downloadable packages)*

---

## 👤 Contact

**HawkinsOps**  
📍 Relocating to Huntsville, AL (September 2026)  
🌐 [hawkinsops.com](https://hawkinsops.com)

---

*Last updated: January 2026*
