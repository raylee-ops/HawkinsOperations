# HawkinsOps SOC Runbooks & Playbooks Pack

**Version**: 1.0
**Created**: 2024
**Owner**: Raylee - SOC Analyst
**Environment**: HawkinsOps Personal SOC & Homelab

---

## Welcome

This collection provides **realistic, actionable SOC runbooks and playbooks** designed specifically for the HawkinsOps environment. These documents serve three primary purposes:

1. **Practice**: Walk through realistic incident scenarios to build muscle memory
2. **Reference**: Quick-lookup guides during actual security events
3. **Portfolio**: Demonstrate SOC capabilities to potential employers

**Philosophy**: These runbooks are written for **future-you** — tired, stressed, possibly in the middle of an incident at 2 AM. They provide clear, step-by-step procedures without unnecessary theory.

---

## How to Use This Pack

### During Practice Sessions
1. Select a scenario from the list below
2. Set up the scenario in your lab environment (simulate the attack/event)
3. Follow the runbook step-by-step as if it's a real incident
4. Document your findings and time to resolution
5. Review and identify areas for improvement

### During Real Incidents
1. Use the **General Incident Response Playbook** as your primary guide
2. Reference specific scenarios for detailed investigation steps
3. Consult references for Event IDs, log locations, and command syntax
4. Document everything in `~/HAWKINS_OPS/incidents/YYYY-MM-DD_<type>/`

### For Portfolio & Interviews
- **Demonstrate knowledge**: "Here's how I investigated a brute-force attack..."
- **Show artifacts**: Screenshots, incident reports, timelines from practice sessions
- **Discuss methodology**: Walk through your incident response process
- **Highlight improvements**: "I identified this gap and implemented X control"

---

## Pack Contents

### Core Playbooks (Start Here)

These provide general procedures applicable across many incident types:

| Playbook | Description | Use When |
|----------|-------------|----------|
| **[General Incident Response](playbooks/playbook_general_incident_response.md)** | Complete IR lifecycle (NIST framework) | Any security incident |
| **[Suspicious Endpoint Activity](playbooks/playbook_suspicious_endpoint_activity.md)** | Investigating compromised Windows/Linux endpoints | Wazuh alerts, unusual behavior, malware suspected |
| **[Network Anomalies](playbooks/playbook_network_anomalies.md)** | Network traffic analysis and investigation | Unusual traffic, C2 suspected, port scans |
| **[Account & Auth Anomalies](playbooks/playbook_account_or_auth_anomalies.md)** | Authentication and account security events | Failed logins, brute-force, suspicious admin activity |

### Scenario Runbooks (Detailed Walkthroughs)

Each scenario provides detailed steps for a specific attack type:

| # | Scenario | Severity | Environment Focus | Key Skills |
|---|----------|----------|-------------------|------------|
| **01** | [Suspicious PowerShell Execution](scenarios/scenario_01_suspicious_powershell_wazuh.md) | High | Windows + Wazuh | PowerShell analysis, Sysmon, Windows Event Logs |
| **02** | [SSH Brute-Force Attack](scenarios/scenario_02_bruteforce_ssh_mint_endpoint.md) | High | Linux + Wazuh | Linux auth logs, Fail2Ban, SSH hardening |
| **03** | [DNS Tunneling Suspected](scenarios/scenario_03_outbound_dns_tunnel_suspected.md) | High | Network + pfSense | DNS analysis, packet capture, C2 detection |
| **04** | [Suspicious Admin Logon - Windows](scenarios/scenario_04_suspicious_admin_logon_windows.md) | High | Windows + Wazuh | Windows authentication, Event ID 4624/4672, RDP |
| **05** | [Potential Malware on Endpoint](scenarios/scenario_05_potential_malware_on_endpoint.md) | Critical | Windows/Linux | Malware analysis, forensics, containment |
| **06** | [Unusual Web Traffic - Linux](scenarios/scenario_06_unusual_web_traffic_from_linux.md) | Medium | Linux + Network | Process investigation, network connections, curl/wget analysis |
| **07** | [Data Exfiltration - Windows](scenarios/scenario_07_potential_data_exfiltration_windows.md) | Critical | Windows + Network | DLP, file access auditing, USB monitoring, cloud storage |
| **08** | [Privilege Escalation - Linux](scenarios/scenario_08_privilege_escalation_attempt_linux.md) | High | Linux | sudo/su, SUID/SGID, rootkit detection |
| **09** | [RDP Brute-Force - Windows](scenarios/scenario_09_rdp_bruteforce_windows.md) | High | Windows + Network | RDP security, failed logons, pfSense blocking |
| **10** | [Unauthorized Firewall Change](scenarios/scenario_10_firewall_rule_change_pfsense.md) | Critical | pfSense | Change management, configuration control, admin access |

### Reference Documents (Quick Lookup)

| Reference | Contents |
|-----------|----------|
| **[Event ID & Log Reference](references/event_id_and_log_reference.md)** | Windows Event IDs, Linux log locations, Wazuh rule IDs, common log patterns |
| **[HawkinsOps Environment Mapping](references/hawk_ops_env_mapping.md)** | System inventory, IP addresses, hostnames, log flows, Wazuh integration |
| **[Assumptions & Placeholders](references/assumptions_and_placeholders.md)** | What needs to be customized for your specific environment, setup tasks |

---

## Quick Start Guide

### First Time Setup

1. **Read This File** ✓ (you're here)
2. **Review Environment Mapping**:
   - Open `references/hawk_ops_env_mapping.md`
   - Update with your actual IPs, hostnames, configurations
3. **Check Assumptions**:
   - Open `references/assumptions_and_placeholders.md`
   - Complete the checklist to ensure your environment is ready
4. **Familiarize with References**:
   - Bookmark `references/event_id_and_log_reference.md` for quick lookups
5. **Practice Your First Scenario**:
   - Start with **Scenario 02: SSH Brute-Force** (easy to simulate)
   - Follow the runbook step-by-step
   - Document your findings

### Suggested Practice Order

**Week 1-2: Authentication & Access**
- Scenario 02: SSH Brute-Force (Linux)
- Scenario 09: RDP Brute-Force (Windows)
- Scenario 04: Suspicious Admin Logon

**Week 3-4: Endpoint Investigation**
- Scenario 01: Suspicious PowerShell
- Scenario 05: Potential Malware
- Scenario 08: Privilege Escalation (Linux)

**Week 5-6: Network & Data**
- Scenario 06: Unusual Web Traffic
- Scenario 03: DNS Tunneling
- Scenario 07: Data Exfiltration

**Week 7-8: Infrastructure & Advanced**
- Scenario 10: Firewall Rule Change
- Conduct full incident response drill (combine multiple scenarios)
- Create custom scenario based on latest threat intelligence

---

## Scenario Difficulty Ratings

### Beginner-Friendly (Start Here)
- ⭐ **Scenario 02**: SSH Brute-Force - straightforward log analysis
- ⭐ **Scenario 09**: RDP Brute-Force - similar to SSH, Windows context
- ⭐ **Scenario 04**: Suspicious Admin Logon - basic Windows Event Log investigation

### Intermediate
- ⭐⭐ **Scenario 01**: Suspicious PowerShell - requires PowerShell log interpretation
- ⭐⭐ **Scenario 06**: Unusual Web Traffic - process and network analysis
- ⭐⭐ **Scenario 08**: Privilege Escalation - Linux system internals
- ⭐⭐ **Scenario 10**: Firewall Rule Change - configuration management

### Advanced
- ⭐⭐⭐ **Scenario 03**: DNS Tunneling - network traffic analysis, packet captures
- ⭐⭐⭐ **Scenario 05**: Potential Malware - full forensic investigation
- ⭐⭐⭐ **Scenario 07**: Data Exfiltration - multi-faceted investigation, legal considerations

---

## Integration with HawkinsOps

### Incident Folder Structure

All investigations should follow this structure:

```
~/HAWKINS_OPS/incidents/
├── 2024-11-18_ssh_bruteforce_mint3/
│   ├── incident_report.md
│   ├── timeline.md
│   ├── evidence/
│   │   ├── auth.log
│   │   ├── wazuh_alerts.json
│   │   ├── pfsense_logs.txt
│   │   └── screenshots/
│   └── iocs.txt
├── 2024-11-19_suspicious_powershell_powerhouse/
│   └── ...
└── templates/
    └── incident_report_template.md
```

### Wazuh Integration

These runbooks assume:
- Wazuh agents installed on all endpoints
- Wazuh manager receiving and correlating logs
- Dashboard accessible for investigation
- Custom rules may be needed (documented in scenarios)

See: `references/hawk_ops_env_mapping.md` for log flow architecture.

### Evidence Handling

**Chain of Custody**:
- Document who collected evidence, when, from where
- Hash all evidence files (SHA256)
- Store in organized incident folders
- Never modify original evidence (work with copies)

**Evidence Types**:
- Logs (system, security, application)
- Packet captures (pcap files)
- Memory dumps (process or full system)
- Disk images or snapshots
- Screenshots
- Configuration files
- Malware samples (safely quarantined)

---

## Interview Preparation

### Demonstrating Competency

**When discussing these runbooks in interviews**:

1. **Pick Your Best Scenario**: Choose one you've practiced thoroughly
2. **Walk Through Your Process**:
   - "I detected this via Wazuh alert for rule 5712..."
   - "I triaged by checking auth.log and saw X pattern..."
   - "I contained by blocking the IP at pfSense because..."
   - "I hardened by implementing Fail2Ban and disabling password auth..."
3. **Show Artifacts**: Have screenshots, incident report, timeline ready
4. **Discuss Decisions**: Explain why you chose specific actions
5. **Highlight Learning**: "Initially I missed X, so I updated my playbook to include..."

### Common Interview Questions - With Runbook References

| Question | Reference Scenario/Playbook |
|----------|----------------------------|
| "Walk me through investigating a malware infection" | Scenario 05 + Playbook: Suspicious Endpoint Activity |
| "How would you detect and respond to a brute-force attack?" | Scenarios 02 & 09 + Playbook: Account & Auth Anomalies |
| "Describe your incident response process" | Playbook: General Incident Response (6 phases) |
| "How do you investigate unusual network traffic?" | Scenarios 03 & 06 + Playbook: Network Anomalies |
| "What's your approach to privilege escalation attempts?" | Scenario 08 + Playbook: Suspicious Endpoint Activity |
| "How do you handle potential data exfiltration?" | Scenario 07 |
| "Describe Windows vs Linux investigation differences" | Compare any Windows scenario (01, 04, 07, 09) vs Linux scenario (02, 06, 08) |

### Portfolio Artifacts to Prepare

Based on these runbooks, create:
- ✅ **Incident Reports**: 3-5 polished incident reports from practice scenarios
- ✅ **Timeline Visualizations**: Graphical timelines of attack → detection → response
- ✅ **Technical Write-ups**: Blog posts explaining scenarios (demonstrating communication skills)
- ✅ **Detection Rules**: Custom Wazuh rules you created
- ✅ **Hardening Documentation**: Before/after configurations showing security improvements
- ✅ **Metrics Dashboard**: Screenshot of Wazuh dashboard showing alert trends over time

---

## Customization & Extension

### Creating Your Own Scenarios

As you encounter new attack types or techniques:

1. **Research the Technique**: MITRE ATT&CK, recent CVEs, threat reports
2. **Simulate in Lab**: Generate the attack/event safely
3. **Document Detection**: How did Wazuh/pfSense/endpoint detect it?
4. **Write Investigation Steps**: What logs to check, commands to run
5. **Define Containment**: How to stop the attack
6. **Test Hardening**: What controls prevent recurrence
7. **Save as**: `scenarios/scenario_XX_<descriptive_name>.md`

**Suggested Future Scenarios**:
- Web application attack (SQL injection, XSS)
- Ransomware simulation and response
- Lateral movement detection (SMB, RDP, PSExec)
- Supply chain attack (compromised update)
- Cloud service abuse (if you add cloud resources)
- Container escape (if you deploy Docker/Kubernetes)

### Updating Playbooks

After each real or practice incident:
- Add newly discovered commands or techniques
- Update with actual timing (how long each phase takes)
- Incorporate lessons learned
- Fix any errors or unclear instructions
- Version control with Git (track changes over time)

---

## Study & Practice Schedule

### 90-Day SOC Analyst Skill Building Plan

**Month 1: Foundations**
- Week 1-2: Setup and environment validation
  - Complete assumptions checklist
  - Deploy missing tools (Sysmon, Fail2Ban, etc.)
  - Simulate and practice Scenario 02 & 09
- Week 3-4: Windows investigation skills
  - Practice Scenario 01 & 04
  - Master Windows Event Log queries
  - Study PowerShell malicious patterns

**Month 2: Intermediate Investigations**
- Week 5-6: Linux deep dive
  - Practice Scenario 06 & 08
  - Master Linux log analysis
  - Understand privilege escalation techniques
- Week 7-8: Network analysis
  - Practice Scenario 03
  - Learn packet capture and analysis
  - Understand C2 communication patterns

**Month 3: Advanced & Portfolio**
- Week 9-10: Complex scenarios
  - Practice Scenario 05 & 07
  - Full forensic investigations
  - Multi-stage attack chains
- Week 11-12: Portfolio development
  - Write polished incident reports
  - Create presentation materials
  - Practice interview responses
  - Conduct full IR tabletop exercise

---

## Maintenance & Updates

### Regular Review Schedule

**Weekly**:
- Check for new Wazuh alerts requiring rule tuning
- Review any real incidents and update runbooks with findings

**Monthly**:
- Practice at least one scenario
- Update `hawk_ops_env_mapping.md` if environment changes
- Review and test backup/restore procedures

**Quarterly**:
- Full review of all playbooks for accuracy
- Update with new attack techniques from threat intelligence
- Verify all assumptions are still valid
- Test incident response workflow end-to-end

**Annually**:
- Major revision based on cumulative lessons learned
- Align with latest MITRE ATT&CK techniques
- Update to reflect environment evolution (e.g., AD deployment)

### Version Control

**Recommended**:
```bash
cd ~/HAWKINS_OPS/runbooks/
git init
git add .
git commit -m "Initial runbooks pack v1.0"

# After updates:
git add <modified_files>
git commit -m "Updated Scenario 02 based on practice session findings"
git tag -a v1.1 -m "Version 1.1 - Updated SSH brute-force scenario"
```

---

## Additional Resources

### External References

**Incident Response Frameworks**:
- NIST SP 800-61: Computer Security Incident Handling Guide
- SANS Incident Response Process
- CISA Incident Response Resources

**Log Analysis**:
- Ultimate Windows Security Event ID Encyclopedia
- Linux Logging Deep Dive (various resources)
- Wazuh Documentation: https://documentation.wazuh.com/

**Threat Intelligence**:
- MITRE ATT&CK: https://attack.mitre.org/
- AlienVault OTX: https://otx.alienvault.com/
- Abuse.ch: https://abuse.ch/
- SANS Internet Storm Center: https://isc.sans.edu/

**Training**:
- TryHackMe SOC Level 1 Path
- LetsDefend.io SOC Analyst Path
- Blue Team Labs Online
- CyberDefenders (blue team challenges)

### HawkinsOps Community

**Document your journey**:
- Blog about scenarios (technical write-ups)
- Share sanitized incident reports (portfolio)
- Contribute to open-source detection rules
- Engage with cybersecurity communities (Reddit: r/cybersecurity, r/netsec, r/AskNetsec)

---

## Feedback & Improvement

These runbooks are living documents. As you use them:
- Note any unclear instructions
- Identify missing steps or tools
- Suggest improvements
- Add new scenarios based on real threats
- Share your customizations (if comfortable)

**Your feedback makes these runbooks better for future you and others.**

---

## Disclaimer

**Important Notes**:
- These runbooks are designed for the **HawkinsOps lab environment**
- **Authorized testing only**: Only simulate attacks in your own lab
- Some commands are destructive (network isolation, account disabling) - use with care
- Legal and ethical considerations apply to all security activities
- Consult appropriate authorities before investigating real criminal activity
- This is educational material, not legal or professional advice

---

## Summary

**You now have**:
- ✅ 10 detailed scenario runbooks
- ✅ 4 comprehensive playbooks
- ✅ 3 essential reference documents
- ✅ This index for navigation

**Next Steps**:
1. Open `references/assumptions_and_placeholders.md`
2. Work through the setup checklist
3. Choose your first practice scenario
4. Document your findings
5. Build your portfolio

**Remember**: Every great SOC analyst started somewhere. These runbooks give you realistic, hands-on experience. Practice deliberately, document thoroughly, and continuously improve.

**Good hunting!** 🎯🔍🛡️

---

**HawkinsOps SOC Runbooks & Playbooks Pack - v1.0**
*Created for Raylee's journey from factory work to SOC analyst*
*Target: Hire-ready by May 1, 2026*
*Location: Huntsville, AL*

---

## Appendix: File Listing

```
/home/hawkins/HAWKINS_OPS/runbooks/
├── index.md                          (THIS FILE)
├── scenarios/
│   ├── scenario_01_suspicious_powershell_wazuh.md
│   ├── scenario_02_bruteforce_ssh_mint_endpoint.md
│   ├── scenario_03_outbound_dns_tunnel_suspected.md
│   ├── scenario_04_suspicious_admin_logon_windows.md
│   ├── scenario_05_potential_malware_on_endpoint.md
│   ├── scenario_06_unusual_web_traffic_from_linux.md
│   ├── scenario_07_potential_data_exfiltration_windows.md
│   ├── scenario_08_privilege_escalation_attempt_linux.md
│   ├── scenario_09_rdp_bruteforce_windows.md
│   └── scenario_10_firewall_rule_change_pfsense.md
├── playbooks/
│   ├── playbook_general_incident_response.md
│   ├── playbook_suspicious_endpoint_activity.md
│   ├── playbook_network_anomalies.md
│   └── playbook_account_or_auth_anomalies.md
└── references/
    ├── event_id_and_log_reference.md
    ├── hawk_ops_env_mapping.md
    └── assumptions_and_placeholders.md
```

**Total**: 18 files (1 index + 10 scenarios + 4 playbooks + 3 references)

---

**End of Index - Welcome to HawkinsOps SOC Runbooks Pack!**
