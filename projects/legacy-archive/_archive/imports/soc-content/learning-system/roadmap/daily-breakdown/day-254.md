# Day 254: Reverse engineering

**Phase:** Phase 3: Advanced
**Focus:** Reverse engineering

---

## Learning Objectives

- Develop advanced expertise in Reverse engineering
- Conduct forensic-level investigations
- Build SOC automation and orchestration
- Specialize in high-demand areas

---

## Concepts

- Reverse engineering sets you apart from typical L1 analysts
- Forensics provides definitive evidence for investigations
- Automation and orchestration are force multipliers
- Purple team exercises improve detection coverage
- Specialization creates career opportunities

---

## Lab of the Day

**Purple Team and Phase 3 Capstone**

Complete the assigned lab in your HawkinsOps environment. Focus on:
- Hands-on execution
- Understanding the "why" behind each step
- Documenting your process and findings
- Taking screenshots for your portfolio

---

## Hands-On Commands

### Windows (PowerShell/CMD)

```powershell
# Forensic collection: Export Registry hives
reg export HKLM\\SOFTWARE C:\\forensics\\software.reg
reg export HKLM\\SYSTEM C:\\forensics\\system.reg

# Memory dump with built-in tools (requires admin)
# Use Sysinternals ProcDump for live processes
procdump.exe -ma <PID> C:\\forensics\\process.dmp

# Query Prefetch files for execution history
Get-ChildItem C:\\Windows\\Prefetch\\*.pf | Select-Object Name, LastWriteTime

# Analyze Windows Event Logs forensically
Get-WinEvent -Path C:\\forensics\\Security.evtx -Oldest | Export-Csv C:\\forensics\\security_timeline.csv
```

### Linux (Bash)

```bash
# Forensic timeline creation with timestamps
find /var/log -type f -printf '%T+ %p\\n' | sort

# Extract bash history for all users (forensics)
sudo find /home -name '.bash_history' -exec cat {} \\;

# Check for persistence mechanisms
sudo cat /etc/rc.local
sudo ls -la /etc/systemd/system/*.service

# Memory forensics - capture process memory (if LiME installed)
# sudo insmod lime.ko 'path=/forensics/memory.lime format=lime'

# Network connection forensics
sudo netstat -antp | grep ESTABLISHED
```

### Wazuh SIEM

```bash
# Advanced Wazuh automation - integrate with Python
# Use Wazuh API to enrich alerts automatically

# Create custom decoder in /var/ossec/etc/decoders/local_decoder.xml
# for parsing custom application logs

# Build Wazuh dashboard for forensic investigations
# Visualize timelines, MITRE ATT&CK coverage

# Query Wazuh for IOCs from threat intel feeds
curl -u <user>:<pass> -k -X GET 'https://localhost:55000/alerts?q=data.win.eventdata.hashes=<SHA256>&pretty'
```

---

## Documentation Prompts

After completing today's work, answer these questions in your learning journal:

- How does today's advanced skill set me apart from other candidates?
- What forensic artifacts or automation did I create?
- How can I demonstrate this skill in my portfolio?
- What specialization area am I developing?
- How would I teach this concept to a junior analyst?

---

## Portfolio Actions

- [ ] Document today's lab in your GitHub repository
- [ ] Add any scripts or detection rules created
- [ ] Update your skills checklist
- [ ] Take screenshots of key findings
- [ ] Write a brief summary of what you learned

---

## Reflection

Day 254 complete. Review your progress and plan for tomorrow.

**Progress:** Day 254 of 365 (69.6% complete)

---

## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- HawkinsOps Runbooks: ~/HAWKINS_OPS/runbooks/

---

**Next:** day-255.md
**Previous:** day-253.md
