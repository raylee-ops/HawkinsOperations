# General Incident Response Playbook

## Overview
This playbook provides a structured approach to handling security incidents in the HawkinsOps environment. It follows the NIST incident response lifecycle and is tailored for a small SOC/homelab environment.

**Scope**: All security incidents affecting HawkinsOps infrastructure (Wazuh, pfSense, Windows endpoints, Linux endpoints)

**Owner**: SOC Analyst (Raylee)

**Last Updated**: 2024

---

## Incident Response Lifecycle

```
[Preparation] → [Detection & Analysis] → [Containment] → [Eradication] → [Recovery] → [Post-Incident]
       ↑                                                                                      ↓
       └──────────────────────────────────────────────────────────────────────────────────────┘
                                    (Lessons Learned Feed Back)
```

---

## Phase 1: Preparation

### Before an Incident Occurs

**Objective**: Establish capabilities to respond effectively to security incidents

#### 1.1 Tools & Resources Ready
- [ ] Wazuh SIEM operational and monitored regularly
- [ ] pfSense logs being collected and reviewed
- [ ] Incident response toolkit available:
  - Forensic tools (memory dump, disk imaging)
  - Analysis workstation (PRIMARY_OS)
  - Network capture tools (tcpdump, Wireshark)
  - Offline malware analysis environment
- [ ] Evidence storage location prepared: `~/HAWKINS_OPS/incidents/`
- [ ] Backups verified and tested (systems can be restored)
- [ ] Documentation templates ready (incident report, timeline, etc.)

#### 1.2 Baselines Established
- [ ] Network traffic baselines (normal traffic patterns)
- [ ] User behavior baselines (typical login times, accessed systems)
- [ ] Process baselines (known-good running processes)
- [ ] File integrity baselines (critical system files)

#### 1.3 Policies & Procedures
- [ ] Incident classification criteria defined (severity levels)
- [ ] Escalation procedures documented
- [ ] Communication plan (who to notify, when, how)
- [ ] Legal/regulatory requirements understood (data breach notification laws)

#### 1.4 Training & Awareness
- [ ] SOC analyst trained on incident response procedures
- [ ] Users aware of how to report suspicious activity
- [ ] Incident response playbooks reviewed quarterly
- [ ] Tabletop exercises conducted periodically

---

## Phase 2: Detection & Analysis

### Identifying and Understanding the Incident

**Objective**: Detect security incidents promptly and determine scope and severity

### 2.1 Initial Detection

**Detection Sources**:
- Wazuh SIEM alerts
- pfSense firewall/IDS logs
- Antivirus/EDR alerts (Windows Defender, ClamAV)
- User reports
- Anomaly detection (unusual network traffic, system behavior)
- External notifications (ISP, vendor, security researcher)

**Upon Detection**:
1. **Document initial alert**:
   - Timestamp of detection
   - Detection source (Wazuh rule ID, user report, etc.)
   - Affected system(s)
   - Initial indicators (IP, file hash, process name, etc.)

2. **Create incident folder**:
   ```bash
   mkdir -p ~/HAWKINS_OPS/incidents/YYYY-MM-DD_<incident_type>_<hostname>/
   ```

3. **Begin incident log/timeline**:
   - Use incident template from HawkinsOps autologging system
   - Document all actions taken with timestamps

### 2.2 Initial Triage

**Questions to Answer**:
- [ ] What type of incident is this? (malware, unauthorized access, data exfiltration, DoS, etc.)
- [ ] What systems/data are affected?
- [ ] Is the incident still active/ongoing?
- [ ] What is the potential impact? (data, systems, operations, reputation)
- [ ] What is the severity level? (Critical, High, Medium, Low)

**Quick Triage Actions**:
1. Check Wazuh for correlated events
2. Review firewall logs for network context
3. Check affected system(s) for obvious signs of compromise
4. Determine if immediate containment needed (see Phase 3)

### 2.3 Incident Classification

**Severity Levels**:

| Level | Criteria | Response Time | Examples |
|-------|----------|---------------|----------|
| **Critical** | Active data breach, ransomware encryption, complete system compromise, critical service down | Immediate (< 15 min) | Ransomware outbreak, root-level compromise, active data exfiltration |
| **High** | Confirmed malware, unauthorized access to sensitive data, service degradation | 1 hour | Malware detected but contained, brute-force success, privilege escalation |
| **Medium** | Suspected malware, policy violations, security control failures | 4 hours | Failed brute-force attempts, suspicious but unconfirmed activity, missing patches |
| **Low** | Security anomalies, informational alerts, minor policy violations | 24 hours | Single failed login, port scan from external IP, user policy violation |

**Classification Determines**:
- Response priority
- Escalation requirements
- Notification requirements
- Resource allocation

### 2.4 Scope Determination

**Investigate**:
1. **Timeline**: When did the incident start? How long has it been ongoing?
2. **Entry Point**: How did the attacker gain access? (phishing, exploit, brute-force, etc.)
3. **Affected Systems**: Which systems are compromised or at risk?
   - Check Wazuh for alerts from other systems
   - Review network traffic for lateral movement
   - Check for similar IOCs across all endpoints
4. **Data Involved**: What data has been accessed, modified, or exfiltrated?
5. **Attacker Actions**: What has the attacker done?
   - Privilege escalation
   - Persistence mechanisms
   - Data staging/exfiltration
   - Lateral movement
   - System manipulation

**VERIFY All Findings**:
- Confirm indicators are true positives, not false alarms
- Validate affected systems list is complete
- Cross-reference multiple data sources (logs, alerts, network traffic)

---

## Phase 3: Containment

### Limiting Damage and Preventing Spread

**Objective**: Stop the incident from spreading while preserving evidence for investigation

### 3.1 Short-Term Containment (Immediate)

**Purpose**: Quickly limit immediate damage

**Actions** (based on incident type):

1. **Network Isolation**:
   ```bash
   # At pfSense: Block affected host IP
   # On endpoint (Windows):
   Disable-NetAdapter -Name "Ethernet" -Confirm:$false

   # On endpoint (Linux):
   sudo ip link set eth0 down
   ```

2. **Block Malicious IPs/Domains**:
   - Add to pfSense firewall block rules
   - Update DNS resolver to sinkhole malicious domains

3. **Disable Compromised Accounts**:
   ```powershell
   # Windows:
   Disable-LocalUser -Name "<username>"

   # Linux:
   sudo passwd -l <username>
   ```

4. **Kill Malicious Processes**:
   ```powershell
   # Windows:
   Stop-Process -Id <PID> -Force

   # Linux:
   sudo kill -9 <PID>
   ```

5. **Segment Network** (if spread risk):
   - Isolate affected network segment at pfSense
   - Prevent lateral movement

**CRITICAL**: Preserve evidence BEFORE taking containment actions when possible
- Memory dumps before killing processes
- Disk images before cleanup
- Log exports before isolation

### 3.2 Long-Term Containment

**Purpose**: Establish more permanent containment while preparing for eradication

**Actions**:
1. **Apply security patches** to prevent re-infection
2. **Implement additional monitoring** on affected systems
3. **Deploy compensating controls**:
   - Enhanced firewall rules
   - Additional logging
   - MFA enforcement
4. **Change credentials** for potentially compromised accounts
5. **Backup affected systems** (in quarantined state) for forensics

### 3.3 Evidence Preservation

**Throughout Containment, Collect**:
- Memory dumps
- Disk images or snapshots
- Log files (system, security, application)
- Network captures
- Screenshots
- Process listings
- Network connection states
- Configuration files
- Malware samples (safely quarantined)

**Chain of Custody**:
- Document who collected evidence, when, from where
- Hash all evidence files (SHA256)
- Store in secure location: `~/HAWKINS_OPS/incidents/<incident_folder>/`

---

## Phase 4: Eradication

### Removing the Threat

**Objective**: Eliminate the root cause and all artifacts of the incident

### 4.1 Remove Malware & Artifacts

1. **Delete malicious files**:
   ```bash
   # Ensure files are in quarantine first
   sudo rm /quarantine/<malware_file>
   ```

2. **Remove persistence mechanisms**:
   - Delete malicious scheduled tasks/cron jobs
   - Remove unauthorized services
   - Clean registry Run keys (Windows)
   - Remove unauthorized user accounts
   - Delete malicious startup items

3. **Restore modified system files**:
   ```powershell
   # Windows - SFC scan:
   sfc /scannow

   # Linux - verify package integrity:
   sudo debsums -c  # Debian/Ubuntu
   ```

4. **Remove unauthorized access**:
   - Delete SSH keys from authorized_keys
   - Remove unauthorized firewall rules
   - Close unnecessary open ports
   - Remove unauthorized VPN users

### 4.2 Patch Vulnerabilities

1. **Apply security updates**:
   ```bash
   # Windows:
   # Install-WindowsUpdate (or Windows Update GUI)

   # Linux:
   sudo apt update && sudo apt upgrade -y
   ```

2. **Fix configuration issues**:
   - Correct weak password policies
   - Disable unnecessary services
   - Harden firewall rules
   - Enable security controls that were bypassed

3. **Update security tools**:
   - Antivirus signatures
   - Wazuh rules and decoders
   - IDS/IPS signatures (if deployed)
   - Threat intelligence feeds

### 4.3 Verify Eradication

**VERIFY** the threat is fully removed:
- [ ] Re-scan systems with updated antivirus
- [ ] Check for indicators of compromise (IOCs) across all systems
- [ ] Verify no persistence mechanisms remain
- [ ] Confirm no unauthorized accounts/access
- [ ] Review logs for continued suspicious activity
- [ ] Test affected services/systems

**Do NOT proceed to Recovery until eradication is verified**

---

## Phase 5: Recovery

### Restoring Normal Operations

**Objective**: Safely restore systems to normal production state

### 5.1 System Restoration

**Options** (choose based on incident severity):

1. **Clean and Restore** (preferred for critical compromises):
   - Rebuild system from known-good media
   - Restore data from clean backups (pre-infection)
   - Reinstall applications
   - Apply all patches before connecting to network

2. **Remediate in Place** (for less severe incidents):
   - Verify eradication complete
   - Apply all security updates
   - Restore any corrupted/deleted files from backup
   - Reconfigure security settings

### 5.2 Credential Reset

**Reset all potentially compromised credentials**:
```powershell
# Windows:
Set-LocalUser -Name "<username>" -Password $NewSecurePassword

# Linux:
sudo passwd <username>
```

**Scope**:
- Affected user accounts
- Service accounts used on compromised systems
- Admin accounts used during incident
- API keys/tokens if exposed

### 5.3 Monitoring & Verification

**Before declaring "all clear"**:
1. **Enhanced monitoring** of recovered systems (24-48 hours minimum):
   - Watch for indicators of re-infection
   - Monitor for unusual behavior
   - Review logs hourly initially, then tapering off

2. **Validation tests**:
   - Verify services function correctly
   - Test security controls are active
   - Confirm logs are being generated and collected
   - Scan for vulnerabilities

3. **User validation**:
   - Confirm users can access necessary resources
   - Test authentication (new passwords working)
   - Verify no unexpected impact to operations

### 5.4 Gradual Return to Service

**Phased approach**:
1. Start with limited connectivity (internal only)
2. Monitor for 24 hours
3. Expand connectivity gradually
4. Full production access only after verification period

**Document**:
- When system returned to service
- What was restored
- Any limitations or ongoing monitoring
- Follow-up actions required

---

## Phase 6: Post-Incident Activities

### Learning and Improving

**Objective**: Document lessons learned and improve defenses

### 6.1 Incident Documentation

**Complete Incident Report** including:
1. **Executive Summary**:
   - What happened (non-technical overview)
   - Impact (systems, data, downtime)
   - Resolution summary
   - Recommendations

2. **Technical Details**:
   - Timeline of events (detection through recovery)
   - IOCs (IP addresses, file hashes, domains, etc.)
   - Attack vector and techniques (MITRE ATT&CK mapping)
   - Affected systems and data
   - Remediation actions taken

3. **Evidence Inventory**:
   - List all evidence collected
   - Storage location
   - Chain of custody documentation

4. **Costs**:
   - Time spent (analyst hours)
   - Systems downtime
   - Data loss
   - Recovery costs

### 6.2 Lessons Learned Meeting

**Hold review session** within 1 week of incident closure:

**Participants**: All responders, management (if significant incident)

**Topics**:
- What went well?
- What could be improved?
- Were procedures followed? Were they effective?
- Were tools adequate?
- Was timeline acceptable?
- What would we do differently?

**Focus on**:
- Process improvements (not blame)
- Gaps in detection/prevention
- Training needs identified
- Tool/technology gaps

### 6.3 Actionable Improvements

**Based on lessons learned, implement**:

1. **Detection Enhancements**:
   - New Wazuh rules for this attack type
   - Additional log sources
   - Tuned alert thresholds
   - Threat intelligence updates

2. **Prevention Controls**:
   - Security patches deployed
   - Configuration hardening
   - New firewall rules
   - Additional authentication requirements (MFA)
   - User awareness training updates

3. **Response Improvements**:
   - Update runbooks/playbooks
   - Add new tools to IR toolkit
   - Update contact lists
   - Improve documentation templates
   - Schedule additional training

4. **Architecture Changes** (if needed):
   - Network segmentation
   - System re-architecture
   - Backup improvements
   - Redundancy enhancements

### 6.4 Follow-Up Actions

**Track and complete**:
- [ ] All improvement actions assigned and scheduled
- [ ] Playbooks updated with new information
- [ ] IOCs added to threat intelligence feeds
- [ ] Similar vulnerabilities patched across environment
- [ ] Monitoring validated for this attack type
- [ ] Compliance reporting completed (if required)

---

## HawkinsOps-Specific Considerations

### Environment Components
- **Wazuh**: Primary SIEM and detection platform
- **pfSense**: Network security and traffic monitoring
- **Windows Powerhouse**: Main Windows endpoint
- **PRIMARY_OS**: Primary Linux workstation (Mint)
- **MINT-3**: Secondary Linux endpoint
- **Future**: Active Directory domain environment

### Key Contacts
- **Primary SOC Analyst**: Raylee
- **Escalation**: (Define as environment grows)
- **Technical Support**: Self-managed (document external resources)

### Evidence Storage
- **Primary**: `~/HAWKINS_OPS/incidents/YYYY-MM-DD_<type>_<host>/`
- **Backup**: (Define backup location for incident data)

### Communication
- **Internal**: Document incidents in HawkinsOps log
- **External**: (Define when/how to report externally - ISP, vendors, etc.)

---

## Quick Reference: Incident Handling Checklist

### Upon Detection:
- [ ] Create incident folder
- [ ] Start incident timeline/log
- [ ] Classify incident severity
- [ ] Determine if immediate containment needed

### During Response:
- [ ] Preserve evidence BEFORE taking action
- [ ] Document all commands/actions taken
- [ ] Take screenshots of key findings
- [ ] Hash all evidence files
- [ ] Maintain chain of custody

### Before Closure:
- [ ] Verify threat eradicated
- [ ] Confirm systems restored and validated
- [ ] Evidence archived securely
- [ ] Incident report completed
- [ ] Lessons learned documented
- [ ] Improvements identified and assigned

---

## Appendices

### A. Incident Severity Matrix

Use scenario runbooks for specific incident types:
- Scenario 01: Suspicious PowerShell
- Scenario 02: SSH Brute-Force
- Scenario 03: DNS Tunneling
- Scenario 04: Suspicious Admin Logon
- Scenario 05: Malware Detection
- Scenario 06: Unusual Web Traffic
- Scenario 07: Data Exfiltration
- Scenario 08: Privilege Escalation
- Scenario 09: RDP Brute-Force
- Scenario 10: Firewall Rule Change

### B. Evidence Collection Commands

See scenario runbooks for platform-specific commands.

### C. MITRE ATT&CK Mapping

Map incident techniques to MITRE ATT&CK framework for:
- Standardized documentation
- Threat intelligence sharing
- Detection gap analysis
- Training scenarios

**Example Mapping**:
- Brute-force attacks: T1110 (Brute Force)
- PowerShell execution: T1059.001 (Command and Scripting Interpreter: PowerShell)
- Data exfiltration: T1041 (Exfiltration Over C2 Channel)

---

**Remember**: Every incident is an opportunity to improve your defenses and skills. Document thoroughly, learn continuously, and iterate on your processes.
