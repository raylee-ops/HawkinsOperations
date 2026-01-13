#!/usr/bin/env python3
"""
Generate 365 daily breakdown files for HawkinsOps SOC Learning System
"""

import os

# Day-to-phase mapping
def get_phase_info(day):
    if 1 <= day <= 90:
        return "Phase 1: Foundation", 1
    elif 91 <= day <= 180:
        return "Phase 2: Intermediate", 2
    elif 181 <= day <= 270:
        return "Phase 3: Advanced", 3
    elif 271 <= day <= 365:
        return "Phase 4: Job Prep & Mastery", 4
    return "Unknown", 0

# Lab mapping (simplified - distribute 50 labs across 365 days)
def get_lab_for_day(day):
    # Phase 1 (Days 1-90): LAB-01 to LAB-21
    # Phase 2 (Days 91-180): LAB-22 to LAB-43
    # Phase 3 (Days 181-270): LAB-44 to LAB-50
    # Phase 4 (Days 271-365): Revisit and capstone

    if day <= 7:
        return "LAB-01: Windows Event Log Basics"
    elif day <= 14:
        return "LAB-02 to LAB-04: Windows Event Correlation and Linux Syslog"
    elif day <= 21:
        return "LAB-05 to LAB-06: Network Traffic Analysis"
    elif day <= 30:
        return "LAB-07 to LAB-08: Wazuh Basics and First Detection Rule"
    elif day <= 37:
        return "LAB-09 to LAB-10: Sysmon Deployment and Process Monitoring"
    elif day <= 44:
        return "LAB-11 to LAB-12: Malicious Process and Phishing Email Analysis"
    elif day <= 51:
        return "LAB-13 to LAB-14: PowerShell Log Parser and Automated Collector"
    elif day <= 60:
        return "LAB-15: SSH Brute Force Detection"
    elif day <= 67:
        return "LAB-16 to LAB-17: Multi-Source Event Correlation and Timeline"
    elif day <= 74:
        return "LAB-18: ATT&CK Mapping Exercise"
    elif day <= 81:
        return "LAB-19 to LAB-20: Python Log Parser and JSON Analyzer"
    elif day <= 90:
        return "LAB-21: Phase 1 Capstone Incident"
    elif day <= 97:
        return "LAB-22 to LAB-23: Threat Hunting and Hypothesis Development"
    elif day <= 104:
        return "LAB-24 to LAB-25: Credential Theft and Lateral Movement Detection"
    elif day <= 111:
        return "LAB-26 to LAB-27: Linux Rootkit Hunt and Container Security"
    elif day <= 120:
        return "LAB-28 to LAB-29: Sigma Rule Development and Testing"
    elif day <= 127:
        return "LAB-30 to LAB-31: Incident Triage and IR Documentation"
    elif day <= 134:
        return "LAB-32 to LAB-33: Custom Wazuh Decoder and API Integration"
    elif day <= 141:
        return "LAB-34 to LAB-35: Static Malware Analysis and Sandbox"
    elif day <= 150:
        return "LAB-36 to LAB-37: Zeek Log Analysis and C2 Traffic Hunt"
    elif day <= 157:
        return "LAB-38 to LAB-40: Ransomware, Phishing, Insider Threat"
    elif day <= 164:
        return "Portfolio and Resume Work (No Lab)"
    elif day <= 171:
        return "LAB-41 to LAB-42: Live Investigation and Detection Challenges"
    elif day <= 180:
        return "LAB-43: Phase 2 Capstone - APT Simulation"
    elif day <= 187:
        return "LAB-44 to LAB-45: Windows and Linux Forensics"
    elif day <= 194:
        return "LAB-46: Memory Dump Analysis with Volatility"
    elif day <= 201:
        return "LAB-47: Disk Image Analysis with Autopsy"
    elif day <= 210:
        return "LAB-48 to LAB-49: Advanced PCAP and Email Forensics"
    elif day <= 217:
        return "LAB-50: Advanced Malware Sandbox Analysis"
    elif day <= 240:
        return "Automation and Threat Intelligence Projects"
    elif day <= 270:
        return "Purple Team and Phase 3 Capstone"
    else:
        return "Interview Prep, Portfolio Polish, and Job Applications"

# Phase-specific content
def get_phase_content(day, phase_num):
    phase_1_topics = [
        "Windows Event Logs", "PowerShell log queries", "Linux syslog parsing",
        "Auditd configuration", "Network traffic basics", "Wireshark PCAP analysis",
        "pfSense firewall logs", "Wazuh SIEM queries", "Wazuh detection rules",
        "Sysmon installation", "Sysmon Event ID 1 (Process Creation)",
        "Sysmon Event ID 3 (Network Connection)", "Threat detection basics",
        "IOC identification", "PowerShell automation", "SSH attack detection",
        "File integrity monitoring", "Event correlation", "Timeline creation",
        "MITRE ATT&CK framework", "Python log parsing", "Incident investigation"
    ]

    phase_2_topics = [
        "Threat hunting methodology", "Hypothesis development", "Credential dumping detection",
        "Lateral movement (PsExec, WMI)", "Privilege escalation", "Rootkit detection",
        "Container security", "Sigma rule writing", "Detection testing",
        "NIST IR framework", "Incident triage", "Custom Wazuh rules",
        "Wazuh API automation", "Static malware analysis", "Dynamic malware analysis",
        "Zeek log analysis", "DNS tunneling detection", "C2 beacon detection",
        "Ransomware investigation", "Phishing campaign analysis", "Insider threat detection",
        "Resume crafting", "LinkedIn optimization", "Technical interviewing"
    ]

    phase_3_topics = [
        "Forensic methodology", "Chain of custody", "Windows Registry forensics",
        "Linux forensics artifacts", "Memory acquisition", "Volatility framework",
        "Disk forensics", "File carving", "PCAP deep analysis",
        "Email header forensics", "Malware behavior analysis", "API hooking",
        "Assembly language basics", "Reverse engineering", "SOAR concepts",
        "SOC automation", "Threat intelligence platforms", "IOC feed integration",
        "Red team TTPs", "LOLBins", "Purple team methodology",
        "Cloud security (AWS, Azure)", "CloudTrail analysis", "Container security"
    ]

    phase_4_topics = [
        "STAR method interviewing", "Behavioral questions", "Technical deep dives",
        "Live assessment practice", "Company research", "Resume tailoring",
        "GitHub portfolio polish", "Capstone project design", "Project documentation",
        "Technical blogging", "Community engagement", "Threat report analysis",
        "Recent breach analysis", "Mock interviewing", "Interview execution",
        "Mentoring others", "Knowledge sharing", "Career reflection"
    ]

    all_topics = [phase_1_topics, phase_2_topics, phase_3_topics, phase_4_topics]
    topics = all_topics[phase_num - 1]

    # Cycle through topics based on day
    topic_index = (day - 1) % len(topics)
    return topics[topic_index]

def generate_daily_file(day):
    phase_name, phase_num = get_phase_info(day)
    lab = get_lab_for_day(day)
    topic = get_phase_content(day, phase_num)

    # Determine learning objectives based on phase
    if phase_num == 1:
        objectives = [
            f"Understand the fundamentals of {topic}",
            f"Practice hands-on {topic} techniques in HawkinsOps environment",
            "Document findings and add to portfolio",
            "Build muscle memory with daily commands"
        ]
        concepts = [
            f"{topic} is critical for SOC analysts to detect threats early",
            "Logs contain evidence of attacker activity",
            "Correlation across multiple log sources reveals attack patterns",
            "Documentation ensures reproducibility and knowledge retention",
            "Automation reduces manual effort and speeds up analysis"
        ]
    elif phase_num == 2:
        objectives = [
            f"Master {topic} for real-world SOC operations",
            "Apply threat hunting and detection engineering skills",
            "Build production-ready detection rules",
            "Prepare for job interview scenarios",
            "Expand portfolio with advanced projects"
        ]
        concepts = [
            f"{topic} is essential for proactive threat detection",
            "Threat hunters look for unknown threats, not just known signatures",
            "High-fidelity detections minimize false positives",
            "MITRE ATT&CK provides common language for threats",
            "Documentation demonstrates competency to employers"
        ]
    elif phase_num == 3:
        objectives = [
            f"Develop advanced expertise in {topic}",
            "Conduct forensic-level investigations",
            "Build SOC automation and orchestration",
            "Specialize in high-demand areas",
            "Position for SOC L2 roles"
        ]
        concepts = [
            f"{topic} sets you apart from typical L1 analysts",
            "Forensics provides definitive evidence for investigations",
            "Automation and orchestration are force multipliers",
            "Purple team exercises improve detection coverage",
            "Specialization creates career opportunities"
        ]
    else:  # Phase 4
        objectives = [
            f"Perfect {topic} for interview and job success",
            "Polish portfolio to showcase skills",
            "Practice technical and behavioral interviewing",
            "Build professional network",
            "Give back to the community"
        ]
        concepts = [
            f"{topic} demonstrates professionalism and readiness",
            "Portfolio is your resume in action",
            "Interviews test both technical skills and culture fit",
            "Networking opens doors to opportunities",
            "Teaching solidifies your own understanding"
        ]

    # Windows commands based on phase
    if phase_num == 1:
        windows_cmds = [
            "# Query Security Event Logs for logon events",
            "Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 100",
            "",
            "# Search for failed logon attempts",
            "Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 50",
            "",
            "# Query Sysmon process creation events",
            "Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} -MaxEvents 100",
            "",
            "# Export to CSV for analysis",
            "Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4688} -MaxEvents 1000 | Export-Csv -Path C:\\\\logs\\\\process_creation.csv -NoTypeInformation"
        ]
    elif phase_num == 2:
        windows_cmds = [
            "# Hunt for credential dumping (LSASS access)",
            "Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4656} | Where-Object {$_.Message -like '*lsass.exe*'}",
            "",
            "# Detect lateral movement via RDP",
            "Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} | Where-Object {$_.Properties[8].Value -eq 10}",
            "",
            "# Search for PowerShell encoded commands (Sysmon Event ID 1)",
            "Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} | Where-Object {$_.Message -like '*-enc*' -or $_.Message -like '*-encodedcommand*'}",
            "",
            "# Query Sysmon network connections from suspicious processes",
            "Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=3} | Where-Object {$_.Message -like '*powershell*' -or $_.Message -like '*cmd.exe*'}"
        ]
    elif phase_num == 3:
        windows_cmds = [
            "# Forensic collection: Export Registry hives",
            "reg export HKLM\\\\SOFTWARE C:\\\\forensics\\\\software.reg",
            "reg export HKLM\\\\SYSTEM C:\\\\forensics\\\\system.reg",
            "",
            "# Memory dump with built-in tools (requires admin)",
            "# Use Sysinternals ProcDump for live processes",
            "procdump.exe -ma <PID> C:\\\\forensics\\\\process.dmp",
            "",
            "# Query Prefetch files for execution history",
            "Get-ChildItem C:\\\\Windows\\\\Prefetch\\\\*.pf | Select-Object Name, LastWriteTime",
            "",
            "# Analyze Windows Event Logs forensically",
            "Get-WinEvent -Path C:\\\\forensics\\\\Security.evtx -Oldest | Export-Csv C:\\\\forensics\\\\security_timeline.csv"
        ]
    else:  # Phase 4
        windows_cmds = [
            "# Review and document previous Windows investigations",
            "# Create reusable PowerShell scripts for common SOC tasks",
            "",
            "# Example: Automated threat hunt for suspicious services",
            "Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Running'} | Select-Object Name, DisplayName, Status",
            "",
            "# Practice live assessment scenarios under time pressure",
            "# Query recent process creations and network connections",
            "Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1,3} -MaxEvents 500"
        ]

    # Linux commands based on phase
    if phase_num == 1:
        linux_cmds = [
            "# View recent authentication logs",
            "sudo tail -n 100 /var/log/auth.log",
            "",
            "# Search for failed SSH attempts",
            "sudo grep 'Failed password' /var/log/auth.log | tail -n 50",
            "",
            "# Check auditd logs for file access",
            "sudo ausearch -f /etc/passwd",
            "",
            "# Monitor system logs in real-time",
            "sudo journalctl -f",
            "",
            "# Search syslog for specific pattern",
            "sudo grep -i 'error' /var/log/syslog | tail -n 50"
        ]
    elif phase_num == 2:
        linux_cmds = [
            "# Hunt for suspicious SSH connections",
            "sudo grep 'Accepted publickey' /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'",
            "",
            "# Detect potential rootkit - check for hidden processes",
            "ps aux | wc -l",
            "ls /proc | grep '^[0-9]' | wc -l",
            "# Compare counts - significant difference may indicate hiding",
            "",
            "# Search for SUID binaries (privilege escalation risk)",
            "find / -perm -4000 -type f 2>/dev/null",
            "",
            "# Check for unauthorized cron jobs",
            "sudo crontab -l",
            "sudo ls -la /etc/cron.*"
        ]
    elif phase_num == 3:
        linux_cmds = [
            "# Forensic timeline creation with timestamps",
            "find /var/log -type f -printf '%T+ %p\\\\n' | sort",
            "",
            "# Extract bash history for all users (forensics)",
            "sudo find /home -name '.bash_history' -exec cat {} \\\\;",
            "",
            "# Check for persistence mechanisms",
            "sudo cat /etc/rc.local",
            "sudo ls -la /etc/systemd/system/*.service",
            "",
            "# Memory forensics - capture process memory (if LiME installed)",
            "# sudo insmod lime.ko 'path=/forensics/memory.lime format=lime'",
            "",
            "# Network connection forensics",
            "sudo netstat -antp | grep ESTABLISHED"
        ]
    else:  # Phase 4
        linux_cmds = [
            "# Review and document previous Linux investigations",
            "# Create cheat sheets for interview scenarios",
            "",
            "# Practice common SOC tasks under time pressure",
            "# Quick SSH brute force check",
            "sudo grep 'Failed password' /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -n 10",
            "",
            "# Quick auditd check for file modifications",
            "sudo ausearch -ts recent -k file_changes"
        ]

    # Wazuh commands based on phase
    if phase_num == 1:
        wazuh_cmds = [
            "# Query Wazuh for recent alerts",
            "curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?pretty'",
            "",
            "# Search for specific rule ID (e.g., SSH authentication)",
            "# In Wazuh dashboard: Discover -> rule.id:5551",
            "",
            "# Check agent status",
            "/var/ossec/bin/agent_control -l",
            "",
            "# View Wazuh ruleset",
            "cat /var/ossec/ruleset/rules/0095-sshd_rules.xml"
        ]
    elif phase_num == 2:
        wazuh_cmds = [
            "# Create custom detection rule in /var/ossec/etc/rules/local_rules.xml",
            "# Example: Detect PowerShell with encoded commands",
            "# <rule id='100002' level='10'>",
            "#   <if_group>sysmon_event1</if_group>",
            "#   <field name='win.eventdata.commandLine'>\\\\.-enc|-encodedcommand</field>",
            "#   <description>PowerShell with encoded command detected</description>",
            "# </rule>",
            "",
            "# Restart Wazuh to apply rules",
            "sudo systemctl restart wazuh-manager",
            "",
            "# Query Wazuh API for threat hunting",
            "curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?q=rule.mitre.technique=T1059.001&pretty'"
        ]
    elif phase_num == 3:
        wazuh_cmds = [
            "# Advanced Wazuh automation - integrate with Python",
            "# Use Wazuh API to enrich alerts automatically",
            "",
            "# Create custom decoder in /var/ossec/etc/decoders/local_decoder.xml",
            "# for parsing custom application logs",
            "",
            "# Build Wazuh dashboard for forensic investigations",
            "# Visualize timelines, MITRE ATT&CK coverage",
            "",
            "# Query Wazuh for IOCs from threat intel feeds",
            "curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?q=data.win.eventdata.hashes=<SHA256>&pretty'"
        ]
    else:  # Phase 4
        wazuh_cmds = [
            "# Review Wazuh detection coverage for portfolio",
            "# Document custom rules created during 365-day journey",
            "",
            "# Prepare Wazuh demo for interviews",
            "# Show real detection scenarios from HawkinsOps lab",
            "",
            "# Update Wazuh rules based on latest threat intelligence",
            "# Review 2025 threat reports and map to Wazuh detections"
        ]

    # Documentation prompts
    if phase_num == 1:
        doc_prompts = [
            "What did I learn today about logging and detection?",
            "What commands did I use, and what did they reveal?",
            "How would I explain today's topic to a non-technical person?",
            "What should I add to my portfolio based on today's work?",
            "What was challenging, and how did I overcome it?"
        ]
    elif phase_num == 2:
        doc_prompts = [
            "How does today's skill apply to real SOC operations?",
            "What detection rules or automation did I create?",
            "How would I explain this in a job interview?",
            "What MITRE ATT&CK techniques did I learn to detect?",
            "What portfolio entry can I create from today's work?"
        ]
    elif phase_num == 3:
        doc_prompts = [
            "How does today's advanced skill set me apart from other candidates?",
            "What forensic artifacts or automation did I create?",
            "How can I demonstrate this skill in my portfolio?",
            "What specialization area am I developing?",
            "How would I teach this concept to a junior analyst?"
        ]
    else:  # Phase 4
        doc_prompts = [
            "Am I ready to answer interview questions about today's topic?",
            "Is my portfolio polished and professional?",
            "Have I networked or engaged with the community today?",
            "What job applications or interview prep did I complete?",
            "What am I grateful for in this 365-day journey?"
        ]

    # Reflection prompt
    reflection = f"Day {day} complete. Review your progress and plan for tomorrow."

    content = f"""# Day {day:03d}: {topic}

**Phase:** {phase_name}
**Focus:** {topic}

---

## Learning Objectives

"""

    for obj in objectives[:4]:  # Limit to 4 objectives
        content += f"- {obj}\n"

    content += "\n---\n\n## Concepts\n\n"

    for concept in concepts[:5]:  # Limit to 5 concepts
        content += f"- {concept}\n"

    content += f"\n---\n\n## Lab of the Day\n\n**{lab}**\n\n"

    content += """Complete the assigned lab in your HawkinsOps environment. Focus on:
- Hands-on execution
- Understanding the "why" behind each step
- Documenting your process and findings
- Taking screenshots for your portfolio

---

## Hands-On Commands

### Windows (PowerShell/CMD)

```powershell
"""

    content += "\n".join(windows_cmds)

    content += """
```

### Linux (Bash)

```bash
"""

    content += "\n".join(linux_cmds)

    content += """
```

### Wazuh SIEM

```bash
"""

    content += "\n".join(wazuh_cmds)

    content += """
```

---

## Documentation Prompts

After completing today's work, answer these questions in your learning journal:

"""

    for prompt in doc_prompts:
        content += f"- {prompt}\n"

    content += f"""
---

## Portfolio Actions

- [ ] Document today's lab in your GitHub repository
- [ ] Add any scripts or detection rules created
- [ ] Update your skills checklist
- [ ] Take screenshots of key findings
- [ ] Write a brief summary of what you learned

---

## Reflection

{reflection}

**Progress:** Day {day} of 365 ({(day/365)*100:.1f}% complete)

---

## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- HawkinsOps Runbooks: ~/HAWKINS_OPS/runbooks/

---

**Next:** day-{day+1:03d}.md
"""

    if day > 1:
        content += f"**Previous:** day-{day-1:03d}.md\n"

    return content

# Generate all 365 files
output_dir = "/home/hawkins/hawkinsops-content/learning-system/roadmap/daily-breakdown"

for day in range(1, 366):
    filename = f"day-{day:03d}.md"
    filepath = os.path.join(output_dir, filename)

    content = generate_daily_file(day)

    with open(filepath, 'w') as f:
        f.write(content)

    if day % 50 == 0:
        print(f"Generated {day} files...")

print(f"Successfully generated all 365 daily breakdown files in {output_dir}")
