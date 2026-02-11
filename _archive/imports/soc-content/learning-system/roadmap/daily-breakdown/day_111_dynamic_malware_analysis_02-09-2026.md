# Day 111: Dynamic malware analysis

**Phase:** Phase 2: Intermediate
**Focus:** Dynamic malware analysis

---

## Learning Objectives

- Master Dynamic malware analysis for real-world SOC operations
- Apply threat hunting and detection engineering skills
- Build production-ready detection rules
- Prepare for job interview scenarios

---

## Concepts

- Dynamic malware analysis is essential for proactive threat detection
- Threat hunters look for unknown threats, not just known signatures
- High-fidelity detections minimize false positives
- MITRE ATT&CK provides common language for threats
- Documentation demonstrates competency to employers

---

## Lab of the Day

**LAB-26 to LAB-27: Linux Rootkit Hunt and Container Security**

Complete the assigned lab in your HawkinsOps environment. Focus on:
- Hands-on execution
- Understanding the "why" behind each step
- Documenting your process and findings
- Taking screenshots for your portfolio

---

## Hands-On Commands

### Windows (PowerShell/CMD)

```powershell
# Hunt for credential dumping (LSASS access)
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4656} | Where-Object {$_.Message -like '*lsass.exe*'}

# Detect lateral movement via RDP
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} | Where-Object {$_.Properties[8].Value -eq 10}

# Search for PowerShell encoded commands (Sysmon Event ID 1)
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} | Where-Object {$_.Message -like '*-enc*' -or $_.Message -like '*-encodedcommand*'}

# Query Sysmon network connections from suspicious processes
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=3} | Where-Object {$_.Message -like '*powershell*' -or $_.Message -like '*cmd.exe*'}
```

### Linux (Bash)

```bash
# Hunt for suspicious SSH connections
sudo grep 'Accepted publickey' /var/log/auth.log | awk '{print $1, $2, $3, $9, $11}'

# Detect potential rootkit - check for hidden processes
ps aux | wc -l
ls /proc | grep '^[0-9]' | wc -l
# Compare counts - significant difference may indicate hiding

# Search for SUID binaries (privilege escalation risk)
find / -perm -4000 -type f 2>/dev/null

# Check for unauthorized cron jobs
sudo crontab -l
sudo ls -la /etc/cron.*
```

### Wazuh SIEM

```bash
# Create custom detection rule in /var/ossec/etc/rules/local_rules.xml
# Example: Detect PowerShell with encoded commands
# <rule id='100002' level='10'>
#   <if_group>sysmon_event1</if_group>
#   <field name='win.eventdata.commandLine'>\\.-enc|-encodedcommand</field>
#   <description>PowerShell with encoded command detected</description>
# </rule>

# Restart Wazuh to apply rules
sudo systemctl restart wazuh-manager

# Query Wazuh API for threat hunting
curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?q=rule.mitre.technique=T1059.001&pretty'
```

---

## Documentation Prompts

After completing today's work, answer these questions in your learning journal:

- How does today's skill apply to real SOC operations?
- What detection rules or automation did I create?
- How would I explain this in a job interview?
- What MITRE ATT&CK techniques did I learn to detect?
- What portfolio entry can I create from today's work?

---

## Portfolio Actions

- [ ] Document today's lab in your GitHub repository
- [ ] Add any scripts or detection rules created
- [ ] Update your skills checklist
- [ ] Take screenshots of key findings
- [ ] Write a brief summary of what you learned

---

## Reflection

Day 111 complete. Review your progress and plan for tomorrow.

**Progress:** Day 111 of 365 (30.4% complete)

---

## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- HawkinsOps Runbooks: ~/HAWKINS_OPS/runbooks/

---

**Next:** day-112.md
**Previous:** day-110.md
