# Phase 1: Foundation
## Days 1-90 (Months 1-3)

**Goal:** Build unshakable SOC fundamentals
**Job Readiness at End:** 25%

---

## Phase Overview

Phase 1 establishes the critical foundation for SOC work. You'll master:

- Windows and Linux logging systems
- Basic security event analysis
- SIEM fundamentals (Wazuh)
- Network traffic basics
- Documentation and methodology
- HawkinsOps environment proficiency

**By Day 90, you will:**
- Analyze Windows Event Logs confidently
- Parse Linux system logs (syslog, auditd)
- Query Wazuh for basic threat detection
- Understand Sysmon telemetry
- Document findings professionally
- Execute 15 core SOC labs

---

## Month 1: Core Logging & Environment Setup (Days 1-30)

### Week 1 (Days 1-7): Environment & Windows Basics
**Theme:** Get hands dirty immediately

- Day 1-2: HawkinsOps environment familiarization
- Day 3-5: Windows Event Logs (Security, System, Application)
- Day 6-7: PowerShell for log collection

**Key Labs:**
- LAB-01: Windows Event Log Basics
- LAB-02: Security Event Correlation

**Skills Acquired:**
- Navigate Event Viewer
- Filter logs with PowerShell
- Identify common event IDs (4624, 4625, 4688)

---

### Week 2 (Days 8-14): Linux Logging Fundamentals
**Theme:** Linux is everywhere in SOC

- Day 8-10: Syslog, journalctl, /var/log/
- Day 11-12: Bash scripting for log parsing
- Day 13-14: Auditd basics

**Key Labs:**
- LAB-03: Linux Syslog Analysis
- LAB-04: Auditd Configuration

**Skills Acquired:**
- Read /var/log/auth.log, syslog, secure
- Use grep, awk, cut for log analysis
- Configure basic auditd rules

---

### Week 3 (Days 15-21): Network Fundamentals
**Theme:** SOC analysts need network skills

- Day 15-17: TCP/IP, OSI model (practical focus)
- Day 18-19: Wireshark basics
- Day 20-21: pfSense firewall logs

**Key Labs:**
- LAB-05: Network Traffic Analysis Basics
- LAB-06: Firewall Log Review

**Skills Acquired:**
- Analyze PCAP files
- Identify suspicious network patterns
- Read firewall logs

---

### Week 4 (Days 22-30): Intro to SIEM (Wazuh)
**Theme:** SIEM is your best friend

- Day 22-24: Wazuh architecture and setup
- Day 25-27: Wazuh queries and filters
- Day 28-30: Basic alerting and rules

**Key Labs:**
- LAB-07: Wazuh Basics
- LAB-08: Creating First Detection Rule

**Skills Acquired:**
- Query Wazuh API
- Write basic detection rules
- Understand SIEM alert lifecycle

**Month 1 Deliverable:** Portfolio entry #1 - "First 30 Days in SOC"

---

## Month 2: Detection & Sysmon Mastery (Days 31-60)

### Week 5 (Days 31-37): Sysmon Deep Dive
**Theme:** Sysmon is gold for Windows detection

- Day 31-33: Sysmon installation and configuration
- Day 34-36: Process creation monitoring (Event ID 1)
- Day 37: Network connections (Event ID 3)

**Key Labs:**
- LAB-09: Sysmon Deployment
- LAB-10: Process Monitoring & Anomaly Detection

**Skills Acquired:**
- Deploy Sysmon with SwiftOnSecurity config
- Analyze process trees
- Detect suspicious PowerShell

---

### Week 6 (Days 38-44): Threat Detection Basics
**Theme:** Spot the bad guys

- Day 38-40: Common attack patterns (phishing, malware)
- Day 41-43: Indicators of Compromise (IOCs)
- Day 44: Building detection logic

**Key Labs:**
- LAB-11: Malicious Process Detection
- LAB-12: Phishing Email Analysis (headers, links)

**Skills Acquired:**
- Identify malicious executables
- Analyze email headers
- Create IOC lists

---

### Week 7 (Days 45-51): PowerShell for SOC
**Theme:** Automate early, automate often

- Day 45-47: PowerShell scripting for logs
- Day 48-50: Automating log collection
- Day 51: Building first SOC tool

**Key Labs:**
- LAB-13: PowerShell Log Parser
- LAB-14: Automated Event Log Collector

**Skills Acquired:**
- Write PowerShell scripts for log queries
- Schedule tasks
- Export results to CSV/JSON

---

### Week 8 (Days 52-60): Linux Security Monitoring
**Theme:** Defend Linux like a pro

- Day 52-54: SSH attack detection
- Day 55-57: File integrity monitoring (AIDE, Tripwire)
- Day 58-60: Linux persistence mechanisms

**Key Labs:**
- LAB-15: SSH Brute Force Detection

**Skills Acquired:**
- Detect SSH attacks
- Monitor file changes
- Identify Linux backdoors

**Month 2 Deliverable:** 3 custom detection rules (Wazuh)

---

## Month 3: Integration & Real Scenarios (Days 61-90)

### Week 9 (Days 61-67): End-to-End Investigations
**Theme:** Connect the dots

- Day 61-63: Investigation methodology
- Day 64-66: Timeline creation
- Day 67: Evidence documentation

**Key Labs:**
- LAB-16: Multi-Source Event Correlation
- LAB-17: Investigation Timeline Project

**Skills Acquired:**
- Correlate Windows + Linux + Network logs
- Build attack timelines
- Document findings

---

### Week 10 (Days 68-74): MITRE ATT&CK Intro
**Theme:** Speak the industry language

- Day 68-70: ATT&CK framework overview
- Day 71-73: Mapping events to tactics/techniques
- Day 74: Creating ATT&CK-based detections

**Key Labs:**
- LAB-18: ATT&CK Mapping Exercise

**Skills Acquired:**
- Navigate ATT&CK framework
- Map logs to TTPs
- Communicate using ATT&CK language

---

### Week 11 (Days 75-81): Python for SOC (Basics)
**Theme:** Python is your Swiss Army knife

- Day 75-77: Python basics review
- Day 78-80: Log parsing with Python
- Day 81: First Python SOC script

**Key Labs:**
- LAB-19: Python Log Parser
- LAB-20: JSON Event Analyzer

**Skills Acquired:**
- Parse logs with Python
- Use regex for pattern matching
- Output structured data

---

### Week 12-13 (Days 82-90): Phase 1 Capstone
**Theme:** Prove you learned it

- Day 82-84: Simulated incident (planned scenario)
- Day 85-87: Full investigation and writeup
- Day 88-90: Portfolio update and Phase 1 review

**Key Labs:**
- LAB-21: Phase 1 Capstone Incident

**Phase 1 Deliverable:**
- Full incident investigation report
- Updated GitHub portfolio
- 15 labs completed and documented

---

## Phase 1 Skills Checklist

By Day 90, you should be able to:

- ✅ Analyze Windows Event Logs (Security, System, Application)
- ✅ Parse Linux logs (syslog, auth.log, auditd)
- ✅ Query Wazuh SIEM effectively
- ✅ Understand Sysmon telemetry
- ✅ Write basic detection rules
- ✅ Identify common attack patterns
- ✅ Create investigation timelines
- ✅ Map events to MITRE ATT&CK
- ✅ Script basic automation (PowerShell & Python)
- ✅ Document findings professionally

---

## Transition to Phase 2

**You're ready for Phase 2 when:**
- All 21 labs completed
- Comfortable with daily log analysis
- Can investigate basic incidents independently
- Portfolio has 5+ documented investigations

**Phase 2 Preview:**
Threat hunting, advanced detection engineering, incident response procedures, and job interview preparation.
