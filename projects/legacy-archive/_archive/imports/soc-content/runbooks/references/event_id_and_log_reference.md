# Event ID & Log Reference

## Purpose
This reference document provides a quick lookup table for common Windows Event IDs, Linux log files, and Wazuh rule categories relevant to SOC operations in the HawkinsOps environment.

---

## Windows Security Event IDs

### Authentication & Account Management

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4624** | Successful logon | Info | Check logon type, source IP, unusual timing |
| **4625** | Failed logon | Warning | Multiple failures = brute-force |
| **4634** | Logoff | Info | Correlate with 4624 for session duration |
| **4647** | User-initiated logoff | Info | Normal logoff activity |
| **4648** | Logon with explicit credentials (RunAs) | Medium | Lateral movement indicator |
| **4672** | Special privileges assigned (admin) | Medium | Admin activity, verify authorization |
| **4720** | User account created | High | Verify authorized account creation |
| **4722** | User account enabled | Medium | Check if expected |
| **4723** | User attempted to change password | Info | Failed attempts may indicate attack |
| **4724** | Password reset attempt | Medium | Verify authorized reset |
| **4725** | User account disabled | Medium | Containment action or routine admin |
| **4726** | User account deleted | High | Verify authorized deletion |
| **4728** | Member added to security-enabled global group | High | Privilege escalation, verify authorized |
| **4732** | Member added to security-enabled local group | High | Local admin added, verify authorized |
| **4735** | Security-enabled local group changed | Medium | Group policy change |
| **4738** | User account changed | Medium | Account properties modified |
| **4740** | User account locked out | High | Investigate brute-force attack |
| **4756** | Member added to security-enabled universal group | High | Domain privilege escalation |
| **4767** | User account unlocked | Info | Check who unlocked and why |
| **4776** | Domain controller validated credentials | Info | DC authentication, check for failures |
| **4794** | Directory Services Restore Mode password set | Critical | Rarely used, investigate immediately |

### Process & Service Activity

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4688** | Process creation | Info | Review command line for suspicious activity |
| **4689** | Process termination | Info | Correlate with 4688 |
| **7034** | Service crashed unexpectedly | Medium | May indicate attack or system issue |
| **7035** | Service sent start/stop control | Info | Check for unexpected service changes |
| **7036** | Service started or stopped | Info | Unexpected services = suspicious |
| **7040** | Service start type changed | Medium | Persistence mechanism |
| **7045** | New service installed | High | Malware persistence, verify legitimate |

### Object Access & File System

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4656** | Handle to object requested | Info | Requires object auditing enabled |
| **4658** | Handle to object closed | Info | End of object access |
| **4660** | Object deleted | Medium | Check for data destruction |
| **4663** | Object access attempted | Info | File access, check for sensitive data |
| **4670** | Permissions on object changed | Medium | Privilege escalation via ACL |
| **5140** | Network share accessed | Info | Check for unusual share access |
| **5142** | Network share created | Medium | Verify authorized share |
| **5143** | Network share modified | Medium | Check what was changed |
| **5144** | Network share deleted | Medium | Verify authorized deletion |
| **5145** | Network share checked for access | Info | Enumeration activity if excessive |

### Policy & Configuration Changes

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4719** | System audit policy changed | High | Attacker may disable logging |
| **4739** | Domain policy changed | High | Verify authorized change |
| **4946** | Windows Firewall rule added | Medium | Check for unauthorized allow rules |
| **4947** | Windows Firewall rule modified | Medium | Verify change |
| **4950** | Windows Firewall setting changed | High | Firewall disabled = critical |

### Scheduled Tasks

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4698** | Scheduled task created | High | Malware persistence, verify legitimate |
| **4699** | Scheduled task deleted | Medium | Cleanup or malicious |
| **4700** | Scheduled task enabled | Medium | Check task actions |
| **4701** | Scheduled task disabled | Medium | Verify authorized |
| **4702** | Scheduled task updated | Medium | Check what changed |

### Windows Defender

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **1116** | Malware detected | High | Investigate immediately |
| **1117** | Malware action taken | High | Check if quarantined successfully |
| **1118** | Malware blocked | High | Verify block, check for persistence |
| **5001** | Real-time protection disabled | Critical | Attacker disabling defenses |
| **5007** | Configuration changed | Medium | Check for unauthorized changes |
| **5010** | Scanning for malware disabled | Critical | Attacker disabling defenses |

### PowerShell Logging

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **4103** | Module logging | Info | PowerShell activity |
| **4104** | Script block logging | Medium | Full PowerShell command/script content |
| **4105** | Script start | Info | PowerShell script execution began |
| **4106** | Script stop | Info | PowerShell script execution ended |

**Location**: `Microsoft-Windows-PowerShell/Operational`

### Sysmon Events

| Event ID | Description | Severity | Investigation Priority |
|----------|-------------|----------|----------------------|
| **1** | Process creation | Info | Command line, hashes, parent process |
| **2** | File creation time changed | Medium | Timestomping - anti-forensics |
| **3** | Network connection | Info | Process making connections |
| **5** | Process terminated | Info | Correlate with Event ID 1 |
| **6** | Driver loaded | Medium | Rootkit or legitimate driver |
| **7** | Image loaded (DLL) | Info | DLL injection detection |
| **8** | CreateRemoteThread | High | Code injection technique |
| **9** | RawAccessRead | Medium | Direct disk access - forensics or malware |
| **10** | ProcessAccess | Medium | Process memory access |
| **11** | FileCreate | Info | File creation monitoring |
| **12** | RegistryEvent (Object create/delete) | Info | Registry key creation |
| **13** | RegistryEvent (Value set) | Info | Registry value modification |
| **14** | RegistryEvent (Key/Value rename) | Info | Registry rename |
| **15** | FileCreateStreamHash | Medium | Alternate data stream created |
| **17** | PipeEvent (Pipe created) | Info | Named pipe creation |
| **18** | PipeEvent (Pipe connected) | Info | Named pipe connection |
| **19** | WmiEvent (Filter activity) | High | WMI persistence |
| **20** | WmiEvent (Consumer activity) | High | WMI persistence |
| **21** | WmiEvent (Filter to consumer binding) | High | WMI persistence |
| **22** | DNSEvent (DNS query) | Info | DNS resolution by process |
| **23** | FileDelete | Medium | File deletion (archived in Sysmon folder) |
| **24** | ClipboardChange | Info | Clipboard content monitoring |
| **25** | ProcessTampering | High | Process hollowing or tampering |
| **26** | FileDeleteDetected | Medium | File delete operation detected |

**Location**: `Microsoft-Windows-Sysmon/Operational`

### RDP-Specific Events

| Event ID | Description | Log Location | Investigation Priority |
|----------|-------------|--------------|----------------------|
| **1149** | RDP authentication failed | TerminalServices-RemoteConnectionManager/Operational | Brute-force attempts |
| **1158** | RDP connection attempt | TerminalServices-RemoteConnectionManager/Operational | Connection attempts |
| **21** | RDP logon successful | TerminalServices-LocalSessionManager/Operational | Successful RDP session |
| **22** | RDP shell start | TerminalServices-LocalSessionManager/Operational | User shell launched |
| **23** | RDP logoff | TerminalServices-LocalSessionManager/Operational | Session ended |
| **24** | RDP disconnected | TerminalServices-LocalSessionManager/Operational | Session disconnected |
| **25** | RDP reconnection successful | TerminalServices-LocalSessionManager/Operational | Session reconnected |

---

## Linux Log Files

### Authentication & Authorization

| Log File | Description | Common Events | Investigation Use |
|----------|-------------|---------------|-------------------|
| **/var/log/auth.log** | Authentication events (Debian/Ubuntu) | SSH logins, sudo usage, su attempts | Brute-force, privilege escalation |
| **/var/log/secure** | Authentication events (RHEL/CentOS) | Same as auth.log | Same as auth.log |
| **/var/log/faillog** | Failed login attempts | Login failures by user | Account enumeration, brute-force |
| **/var/log/lastlog** | Last login for all users | Last login per user | Account activity timeline |

**Key Patterns in auth.log**:
- `Failed password for <user>` - Failed SSH login
- `Accepted password for <user>` - Successful SSH password auth
- `Accepted publickey for <user>` - Successful SSH key auth
- `Invalid user <user>` - Login attempt with non-existent user
- `sudo: <user> : COMMAND` - Successful sudo command
- `sudo: <user> : NOT in sudoers` - Failed sudo attempt
- `session opened for user <user>` - Session started
- `session closed for user <user>` - Session ended
- `useradd` or `adduser` - New user created
- `usermod` - User modified

### System Activity

| Log File | Description | Common Events | Investigation Use |
|----------|-------------|---------------|-------------------|
| **/var/log/syslog** | General system messages (Debian/Ubuntu) | All system events | Broad system activity |
| **/var/log/messages** | General system messages (RHEL/CentOS) | Same as syslog | Same as syslog |
| **/var/log/kern.log** | Kernel messages | Kernel errors, hardware issues, module loading | Rootkit detection, driver issues |
| **/var/log/dmesg** | Kernel ring buffer | Boot messages, hardware detection | System startup issues, hardware |
| **/var/log/boot.log** | System boot messages | Services started at boot | Persistence mechanisms |

### Services & Applications

| Log File | Description | Common Events | Investigation Use |
|----------|-------------|---------------|-------------------|
| **/var/log/daemon.log** | Background service messages | Service activity | Service-related issues |
| **/var/log/cron.log** | Cron job execution | Scheduled task execution | Malicious cron jobs |
| **/var/log/mail.log** | Mail server logs | Email sent/received | Email-based attacks, spam |
| **/var/log/apache2/** | Apache web server logs | Web requests | Web attacks, access patterns |
| **/var/log/nginx/** | Nginx web server logs | Web requests | Same as Apache |

### Package Management

| Log File | Description | Common Events | Investigation Use |
|----------|-------------|---------------|-------------------|
| **/var/log/dpkg.log** | Package installation (Debian/Ubuntu) | Packages installed/removed | Malicious packages, software changes |
| **/var/log/apt/** | APT package manager (Debian/Ubuntu) | Package operations | Same as dpkg.log |
| **/var/log/yum.log** | YUM package manager (RHEL/CentOS) | Package operations | Same as dpkg.log |

### User Activity

| File/Command | Description | Investigation Use |
|--------------|-------------|-------------------|
| **~/.bash_history** | User command history | User actions, attack commands |
| **last** | Last logged-in users | User login history |
| **who** | Currently logged-in users | Active sessions |
| **w** | Who is logged in and what they're doing | Current user activity |
| **lastb** | Failed login attempts | Brute-force attempts |

### Wazuh Agent (Linux)

| Log File | Description | Investigation Use |
|----------|-------------|-------------------|
| **/var/ossec/logs/ossec.log** | Wazuh agent log | Agent health, connectivity to manager |
| **/var/ossec/queue/diff/** | FIM change snapshots | File integrity monitoring diffs |

---

## Wazuh Rule Categories

### Rule ID Ranges (General)

| Range | Category | Description |
|-------|----------|-------------|
| 1-999 | Wazuh core | Core Wazuh system rules |
| 1000-1999 | Generic | Generic rules for various sources |
| 2000-2999 | Linux | Linux-specific rules |
| 3000-3999 | Windows | Windows-specific rules |
| 5000-5999 | Unix/Linux | Extended Unix/Linux rules |
| 10000-19999 | Application-specific | Rules for specific applications |
| 30000-39999 | Firewalls | Firewall rules (iptables, pfSense, etc.) |
| 40000-49999 | Web | Web server and application rules |
| 50000-59999 | Network | Network device rules |
| 80000-89999 | Compliance | PCI-DSS, HIPAA, etc. |
| 100000+ | Custom | User-defined custom rules |

### Common Wazuh Rule IDs for HawkinsOps

#### Authentication (Linux)

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 5503 | User login failed | 5 |
| 5551 | Multiple authentication failures | 10 |
| 5710 | Attempt to login using non-existent user | 5 |
| 5712 | SSHD brute force trying to get access | 10 |
| 5720 | Multiple SSHD authentication failures | 10 |
| 5402 | Successful sudo execution | 3 |
| 5403 | Failed sudo attempt | 5 |

#### Authentication (Windows)

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 60103 | Windows Logon Success | 3 |
| 60106 | Windows User Logoff | 3 |
| 60122 | Windows: User logon with administrator privileges | 9 |
| 60204 | Windows RDP logon | 3 |
| 60149 | Multiple Windows Logon Failures | 10 |

#### File Integrity Monitoring

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 550 | Integrity checksum changed | 7 |
| 553 | File deleted | 7 |
| 554 | File added to the system | 7 |
| 555 | Integrity checksum changed | 7 |

#### Malware Detection

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 87103 | Windows Defender: Malware detected | 12 |
| 87104 | Windows Defender: Malware detection failed | 7 |
| 554 | File added (may be malware dropper) | 7 |

#### System Configuration

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 2502 | User created | 8 |
| 2550 | Changes to system configuration | 7 |
| 2902 | New dpkg (Debian) package installed | 7 |

#### Web/Network

| Rule ID | Description | Severity |
|---------|-------------|----------|
| 31151 | Firewall drop event | 4 |
| 31101 | Web server attack detected | 10 |
| 31103 | SQL injection attempt | 12 |
| 31106 | Directory traversal attempt | 7 |

### Wazuh Severity Levels

| Level | Classification | Color | Examples |
|-------|---------------|-------|----------|
| 0-3 | **Informational** | Gray | Normal activity, low priority |
| 4-7 | **Low** | Yellow | Errors, minor issues, non-critical alerts |
| 8-11 | **Medium** | Orange | Important events, security relevant |
| 12-15 | **High** | Red | Critical events, immediate attention required |

---

## Common Log Analysis Commands

### Windows (PowerShell)

```powershell
# Query Security log for Event ID 4625 (failed logons):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -MaxEvents 100

# Count events by Event ID:
Get-WinEvent -LogName Security -MaxEvents 1000 |
  Group-Object Id | Sort-Object Count -Descending

# Export events to CSV:
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
  Export-Csv C:\temp\logons.csv -NoTypeInformation
```

### Linux (Bash)

```bash
# Search for failed SSH attempts:
sudo grep "Failed password" /var/log/auth.log

# Count failed attempts per IP:
sudo grep "Failed password" /var/log/auth.log |
  awk '{print $(NF-3)}' | sort | uniq -c | sort -rn

# Recent sudo commands:
sudo grep "sudo:.*COMMAND" /var/log/auth.log | tail -20

# Check for user additions:
sudo grep "useradd\|adduser" /var/log/auth.log
```

### Wazuh (ossec-logtest)

```bash
# Test log against Wazuh rules (on Wazuh server):
/var/ossec/bin/ossec-logtest

# View Wazuh alerts:
tail -f /var/ossec/logs/alerts/alerts.log

# Query Wazuh API for alerts:
curl -u <user>:<password> -k -X GET "https://<wazuh-manager>:55000/security_events?pretty=true"
```

---

## Quick Reference Card

### Top 10 Windows Event IDs for SOC

1. **4688** - Process creation
2. **4624** - Successful logon
3. **4625** - Failed logon
4. **4672** - Admin privileges assigned
5. **7045** - Service installed
6. **4698** - Scheduled task created
7. **4720** - User account created
8. **4732** - User added to local group
9. **5140** - Network share accessed
10. **4663** - Object access attempted

### Top 10 Linux Log Searches for SOC

1. Failed SSH logins: `grep "Failed password" /var/log/auth.log`
2. Successful logins: `grep "Accepted" /var/log/auth.log`
3. Sudo usage: `grep "sudo:.*COMMAND" /var/log/auth.log`
4. User creations: `grep "useradd" /var/log/auth.log`
5. Invalid users: `grep "Invalid user" /var/log/auth.log`
6. Root activity: `grep "root" /var/log/auth.log`
7. Cron job changes: `grep "cron" /var/log/syslog`
8. Package installations: `grep "install" /var/log/dpkg.log`
9. Kernel errors: `grep "error" /var/log/kern.log`
10. Service failures: `grep "failed" /var/log/syslog`

---

## MITRE ATT&CK Technique Mapping

Map Event IDs to MITRE ATT&CK for context:

| Event/Log | MITRE Technique | Tactic |
|-----------|----------------|--------|
| 4625 (failed logon) | T1110 - Brute Force | Credential Access |
| 4688 (process creation) | T1059 - Command/Scripting Interpreter | Execution |
| 4720 (user created) | T1136 - Create Account | Persistence |
| 4698 (scheduled task) | T1053 - Scheduled Task/Job | Persistence, Execution |
| 4663 (file access) | T1005 - Data from Local System | Collection |
| Sysmon 3 (network conn) | T1071 - Application Layer Protocol | Command & Control |
| SSH failed password | T1110 - Brute Force | Credential Access |
| sudo usage | T1548 - Abuse Elevation Control | Privilege Escalation |

---

**Note**: This reference is a living document. Update with actual Rule IDs encountered in HawkinsOps Wazuh deployment and adjust based on enabled Windows Audit Policies and Sysmon configurations.
