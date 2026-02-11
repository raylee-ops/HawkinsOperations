# Day 019: Timeline creation

**Phase:** Phase 1: Foundation
**Focus:** Timeline creation

---

## Learning Objectives

- Understand the fundamentals of Timeline creation
- Practice hands-on Timeline creation techniques in HawkinsOps environment
- Document findings and add to portfolio
- Build muscle memory with daily commands

---

## Concepts

- Timeline creation is critical for SOC analysts to detect threats early
- Logs contain evidence of attacker activity
- Correlation across multiple log sources reveals attack patterns
- Documentation ensures reproducibility and knowledge retention
- Automation reduces manual effort and speeds up analysis

---

## Lab of the Day

**LAB-05 to LAB-06: Network Traffic Analysis**

Complete the assigned lab in your HawkinsOps environment. Focus on:
- Hands-on execution
- Understanding the "why" behind each step
- Documenting your process and findings
- Taking screenshots for your portfolio

---

## Hands-On Commands

### Windows (PowerShell/CMD)

```powershell
# Query Security Event Logs for logon events
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4624} -MaxEvents 100

# Search for failed logon attempts
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4625} -MaxEvents 50

# Query Sysmon process creation events
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1} -MaxEvents 100

# Export to CSV for analysis
Get-WinEvent -FilterHashtable @{LogName='Security'; ID=4688} -MaxEvents 1000 | Export-Csv -Path C:\\logs\\process_creation.csv -NoTypeInformation
```

### Linux (Bash)

```bash
# View recent authentication logs
sudo tail -n 100 /var/log/auth.log

# Search for failed SSH attempts
sudo grep 'Failed password' /var/log/auth.log | tail -n 50

# Check auditd logs for file access
sudo ausearch -f /etc/passwd

# Monitor system logs in real-time
sudo journalctl -f

# Search syslog for specific pattern
sudo grep -i 'error' /var/log/syslog | tail -n 50
```

### Wazuh SIEM

```bash
# Query Wazuh for recent alerts
curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?pretty'

# Search for specific rule ID (e.g., SSH authentication)
# In Wazuh dashboard: Discover -> rule.id:5551

# Check agent status
/var/ossec/bin/agent_control -l

# View Wazuh ruleset
cat /var/ossec/ruleset/rules/0095-sshd_rules.xml
```

---

## Documentation Prompts

After completing today's work, answer these questions in your learning journal:

- What did I learn today about logging and detection?
- What commands did I use, and what did they reveal?
- How would I explain today's topic to a non-technical person?
- What should I add to my portfolio based on today's work?
- What was challenging, and how did I overcome it?

---

## Portfolio Actions

- [ ] Document today's lab in your GitHub repository
- [ ] Add any scripts or detection rules created
- [ ] Update your skills checklist
- [ ] Take screenshots of key findings
- [ ] Write a brief summary of what you learned

---

## Reflection

Day 19 complete. Review your progress and plan for tomorrow.

**Progress:** Day 19 of 365 (5.2% complete)

---

## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- HawkinsOps Runbooks: ~/HAWKINS_OPS/runbooks/

---

**Next:** day-020.md
**Previous:** day-018.md
