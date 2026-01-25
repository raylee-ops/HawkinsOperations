# Day 353: Community engagement

**Phase:** Phase 4: Job Prep & Mastery
**Focus:** Community engagement

---

## Learning Objectives

- Perfect Community engagement for interview and job success
- Polish portfolio to showcase skills
- Practice technical and behavioral interviewing
- Build professional network

---

## Concepts

- Community engagement demonstrates professionalism and readiness
- Portfolio is your resume in action
- Interviews test both technical skills and culture fit
- Networking opens doors to opportunities
- Teaching solidifies your own understanding

---

## Lab of the Day

**Interview Prep, Portfolio Polish, and Job Applications**

Complete the assigned lab in your HawkinsOps environment. Focus on:
- Hands-on execution
- Understanding the "why" behind each step
- Documenting your process and findings
- Taking screenshots for your portfolio

---

## Hands-On Commands

### Windows (PowerShell/CMD)

```powershell
# Review and document previous Windows investigations
# Create reusable PowerShell scripts for common SOC tasks

# Example: Automated threat hunt for suspicious services
Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -eq 'Running'} | Select-Object Name, DisplayName, Status

# Practice live assessment scenarios under time pressure
# Query recent process creations and network connections
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational'; ID=1,3} -MaxEvents 500
```

### Linux (Bash)

```bash
# Review and document previous Linux investigations
# Create cheat sheets for interview scenarios

# Practice common SOC tasks under time pressure
# Quick SSH brute force check
sudo grep 'Failed password' /var/log/auth.log | awk '{print $11}' | sort | uniq -c | sort -rn | head -n 10

# Quick auditd check for file modifications
sudo ausearch -ts recent -k file_changes
```

### Wazuh SIEM

```bash
# Review Wazuh detection coverage for portfolio
# Document custom rules created during 365-day journey

# Prepare Wazuh demo for interviews
# Show real detection scenarios from HawkinsOps lab

# Update Wazuh rules based on latest threat intelligence
# Review 2025 threat reports and map to Wazuh detections
```

---

## Documentation Prompts

After completing today's work, answer these questions in your learning journal:

- Am I ready to answer interview questions about today's topic?
- Is my portfolio polished and professional?
- Have I networked or engaged with the community today?
- What job applications or interview prep did I complete?
- What am I grateful for in this 365-day journey?

---

## Portfolio Actions

- [ ] Document today's lab in your GitHub repository
- [ ] Add any scripts or detection rules created
- [ ] Update your skills checklist
- [ ] Take screenshots of key findings
- [ ] Write a brief summary of what you learned

---

## Reflection

Day 353 complete. Review your progress and plan for tomorrow.

**Progress:** Day 353 of 365 (96.7% complete)

---

## Resources

- [MITRE ATT&CK](https://attack.mitre.org/)
- [Wazuh Documentation](https://documentation.wazuh.com/)
- [Sysmon Documentation](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon)
- HawkinsOps Runbooks: ~/HAWKINS_OPS/runbooks/

---

**Next:** day-354.md
**Previous:** day-352.md
