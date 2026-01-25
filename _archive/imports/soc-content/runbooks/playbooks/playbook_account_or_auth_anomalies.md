# Playbook: Account & Authentication Anomalies

## Purpose
This playbook provides procedures for investigating and responding to suspicious authentication activity and account-related security events in the HawkinsOps environment, covering both Windows and Linux systems.

**Use When**:
- Multiple failed login attempts detected
- Successful login from unusual location or time
- Brute-force attack alerts
- Account lockouts
- Privilege escalation attempts
- New account creation without authorization
- Suspicious use of administrative privileges
- Password spray attacks
- Credential stuffing indicators

---

## Step 1: Alert Triage & Classification

### 1.1 Gather Alert Details

**From Wazuh or System Logs**:
```
Alert Type: [ ] Failed login [ ] Successful login [ ] Account locked [ ] Privilege change [ ] New account
System Type: [ ] Windows [ ] Linux [ ] pfSense [ ] Other: ________
Hostname/IP: ________________
Account Name: ________________
Source IP: ________________ (where login attempted from)
Timestamp: ________________
Number of Attempts: ________________
Wazuh Rule ID: ________________
```

### 1.2 Quick Classification

**Attack Type Identification**:

| Pattern | Attack Type | Severity |
|---------|------------|----------|
| Many attempts, one account | **Brute-force** | High |
| Few attempts, many accounts | **Password spray** | High |
| Successful login after many failures | **Successful brute-force** | Critical |
| Login from unusual location/time | **Compromised account** | High |
| sudo/admin escalation attempts | **Privilege escalation** | High |
| New accounts created | **Persistence/backdoor** | Critical |
| Multiple accounts locked | **Denial of service** | Medium |

### 1.3 Initial Questions

- [ ] Is the authentication activity still ongoing?
- [ ] Is this a known user account or system account?
- [ ] Is the source IP internal or external?
- [ ] Are there successful authentications in this pattern?
- [ ] Are multiple systems affected (coordinated attack)?
- [ ] Is this account critical (admin, service account)?
- [ ] Does timing suggest automated attack (rapid attempts)?

**Decision Point**: If critical account compromised (admin, root), proceed immediately to **Step 6: Containment**.

---

## Step 2: Windows Authentication Investigation

### 2.1 Failed Login Analysis

```powershell
# On Windows endpoint:

# Failed login attempts (Event ID 4625):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} -MaxEvents 500 |
  Select-Object TimeCreated,
  @{Name='Account';Expression={$_.Properties[5].Value}},
  @{Name='SourceIP';Expression={$_.Properties[19].Value}},
  @{Name='LogonType';Expression={$_.Properties[10].Value}},
  @{Name='FailureReason';Expression={$_.Properties[8].Value}} |
  Sort-Object TimeCreated -Descending |
  Format-Table -AutoSize

# Count failures per source IP:
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
  Group-Object @{Expression={$_.Properties[19].Value}} |
  Select-Object Count, Name |
  Sort-Object Count -Descending

# Count failures per account:
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
  Group-Object @{Expression={$_.Properties[5].Value}} |
  Select-Object Count, Name |
  Sort-Object Count -Descending

# Identify password spray (few attempts across many accounts):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
  Where-Object {$_.Properties[19].Value -eq '<attacker_IP>'} |
  Group-Object @{Expression={$_.Properties[5].Value}} |
  Select-Object Count, Name |
  Sort-Object Count
```

**Logon Types** (Event 4624/4625):
- **2**: Interactive (console login)
- **3**: Network (SMB, mapped drives)
- **4**: Batch (scheduled task)
- **5**: Service
- **7**: Unlock (workstation unlock)
- **10**: RemoteInteractive (RDP)
- **11**: CachedInteractive (offline login)

### 2.2 Successful Login Analysis

```powershell
# Successful logons (Event ID 4624):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents 200 |
  Select-Object TimeCreated,
  @{Name='Account';Expression={$_.Properties[5].Value}},
  @{Name='LogonType';Expression={$_.Properties[8].Value}},
  @{Name='SourceIP';Expression={$_.Properties[18].Value}},
  @{Name='LogonID';Expression={$_.Properties[7].Value}} |
  Format-Table -AutoSize

# Check for successful login from suspicious IP:
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
  Where-Object {$_.Properties[18].Value -eq '<suspicious_IP>'} |
  Select-Object TimeCreated, @{Name='Account';Expression={$_.Properties[5].Value}}

# Admin privilege assignment (Event 4672):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4672} -MaxEvents 100 |
  Select-Object TimeCreated, @{Name='Account';Expression={$_.Properties[1].Value}}
```

### 2.3 Account Changes

```powershell
# Account creation (Event 4720):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4720} |
  Select-Object TimeCreated,
  @{Name='NewAccount';Expression={$_.Properties[0].Value}},
  @{Name='Creator';Expression={$_.Properties[4].Value}}

# Account enabled/disabled (Event 4722/4725):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4722,4725} |
  Select-Object TimeCreated, Id, Message

# Account added to group (Event 4728, 4732, 4756):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4728,4732,4756} |
  Select-Object TimeCreated,
  @{Name='Account';Expression={$_.Properties[0].Value}},
  @{Name='Group';Expression={$_.Properties[2].Value}}

# Password changes (Event 4724):
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4724} |
  Select-Object TimeCreated, @{Name='Account';Expression={$_.Properties[0].Value}}
```

### 2.4 RDP-Specific Investigation

```powershell
# RDP connection attempts:
Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' |
  Select-Object TimeCreated, Id, Message | Format-List | more

# Event 1149 - RDP authentication failures:
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational';ID=1149} |
  Select-Object TimeCreated, Message
```

---

## Step 3: Linux Authentication Investigation

### 3.1 Failed Login Analysis

```bash
# On Linux endpoint:

# Recent failed login attempts (auth.log):
sudo grep "Failed password" /var/log/auth.log | tail -50

# Failed attempts per IP:
sudo grep "Failed password" /var/log/auth.log |
  awk '{print $(NF-3)}' |
  sort | uniq -c | sort -rn

# Failed attempts per username:
sudo grep "Failed password" /var/log/auth.log |
  awk '{print $11}' |
  sort | uniq -c | sort -rn

# Failed attempts for specific IP:
sudo grep "Failed password" /var/log/auth.log |
  grep <attacker_IP>

# Identify password spray (low count per user from same IP):
sudo grep "Failed password" /var/log/auth.log |
  grep <attacker_IP> |
  awk '{print $11}' |
  sort | uniq -c

# Invalid user attempts (account enumeration):
sudo grep "Invalid user" /var/log/auth.log | tail -30
```

### 3.2 Successful Login Analysis

```bash
# Successful SSH logins:
sudo grep "Accepted password" /var/log/auth.log | tail -30

# Successful logins from specific IP:
sudo grep "Accepted password" /var/log/auth.log |
  grep <suspicious_IP>

# Recent logins (last command):
last -n 50

# Recent logins for specific user:
last <username>

# Currently logged-in users:
who
w

# Failed and successful sudo attempts:
sudo grep "sudo:" /var/log/auth.log | tail -50

# Successful sudo commands:
sudo grep "sudo:.*COMMAND" /var/log/auth.log |
  grep -v "NOT" | tail -30

# Failed sudo attempts:
sudo grep "sudo:.*NOT" /var/log/auth.log | tail -20
```

### 3.3 Account Changes

```bash
# User account creation:
sudo grep "useradd\|adduser" /var/log/auth.log

# User account modifications:
sudo grep "usermod" /var/log/auth.log

# Password changes:
sudo grep "passwd" /var/log/auth.log

# Group membership changes:
sudo grep "group.*added\|group.*removed" /var/log/auth.log

# Check /etc/passwd for recent account additions:
sudo tail -20 /etc/passwd

# Check for accounts with UID 0 (root equivalent):
sudo awk -F: '($3 == 0) {print}' /etc/passwd

# Check sudo group members:
grep sudo /etc/group
```

### 3.4 SSH-Specific Investigation

```bash
# SSH authentication methods used:
sudo grep "sshd.*Accepted" /var/log/auth.log

# SSH key-based authentications:
sudo grep "Accepted publickey" /var/log/auth.log

# Check for unauthorized SSH keys:
cat ~/.ssh/authorized_keys
sudo cat /root/.ssh/authorized_keys

# Review SSH configuration for weaknesses:
sudo cat /etc/ssh/sshd_config | grep -v "^#" | grep -v "^$"
```

---

## Step 4: Cross-Platform Analysis

### 4.1 Pattern Recognition

**Brute-Force Indicators**:
- High volume (>20) failed attempts for single account
- Rapid succession (seconds between attempts)
- Single source IP
- Often targets common accounts (admin, administrator, root, user)

**Password Spray Indicators**:
- Low count (1-3) failed attempts per account
- Many different accounts targeted
- Single or few source IPs
- Attempts often use common passwords ("Password123", "Winter2024", etc.)
- Slower pace to avoid detection/lockout

**Credential Stuffing Indicators**:
- Mix of usernames (not common names)
- From multiple source IPs (botnet)
- Some successes expected (using leaked credentials)
- Username/password pairs appear pre-tested

**Compromised Account Indicators**:
- Successful login from:
  - Unexpected geographic location
  - Unusual time (3 AM for 9-5 user)
  - New/unknown IP address
- Successful login after multiple failed attempts
- User reports they didn't log in

### 4.2 Wazuh Correlation

```
In Wazuh Dashboard:
- Navigate to Security Events
- Filter by agent: <affected_hostname>
- Search for authentication-related rule IDs:
  - 5503, 5551 (Linux failed login)
  - 5712, 5720 (SSH brute-force)
  - 60122, 60204 (Windows authentication)
  - 5402, 5403 (sudo attempts)

- Check for correlation across multiple agents (coordinated attack)
- Review rule.level >=10 for high-severity auth events
```

### 4.3 pfSense Context

```
At pfSense:
Status → System Logs → Firewall

- Check source IP of authentication attempts
- Is IP already blocked or should it be?
- Is source IP attempting access to other systems?
- Geographic origin (if GeoIP available)

For RDP/SSH attacks:
- Filter by destination port 3389 (RDP) or 22 (SSH)
- Review blocked vs allowed traffic from attacker IP
```

---

## Step 5: Account & Attacker Validation

### 5.1 Verify Account Legitimacy

```powershell
# Windows - account details:
Get-LocalUser -Name "<username>" | Format-List

# When was account created:
Get-LocalUser -Name "<username>" | Select-Object Name, Enabled, LastLogon, PasswordLastSet

# Account group memberships:
Get-LocalGroup | ForEach-Object {
  $group = $_
  Get-LocalGroupMember $group -ErrorAction SilentlyContinue |
    Where-Object {$_.Name -like "*<username>*"} |
    Select-Object @{Name='Group';Expression={$group.Name}}, Name
}
```

```bash
# Linux - account details:
id <username>
sudo grep "^<username>:" /etc/passwd

# When account was created (approximation from passwd modification):
sudo stat /etc/passwd | grep Modify

# Account group memberships:
groups <username>

# Sudo privileges:
sudo grep "^<username>" /etc/sudoers
sudo ls /etc/sudoers.d/ && sudo cat /etc/sudoers.d/*
```

**Questions**:
- [ ] Is this a known, authorized account?
- [ ] When was account created? (recently = suspicious)
- [ ] Does account have appropriate privileges?
- [ ] Is account a service account being used interactively?
- [ ] Has account been dormant then suddenly active?

### 5.2 Contact Account Owner

**If investigating successful login to user account**:
1. Contact user via secure channel (phone, in-person, Signal)
2. Verify they initiated the login
3. Ask about:
   - Time of login (does it match their activity?)
   - Location (were they at source IP location?)
   - Device used (does it match?)
   - Any suspicious emails or links clicked recently?

**Document conversation**:
```
User Name: ________________
Contact Time: ________________
Contact Method: ________________
User Confirms Login: [ ] Yes [ ] No [ ] Uncertain
User Location at Time: ________________
Device Used: ________________
Notes: ________________
```

### 5.3 Investigate Attacker IP

```bash
# WHOIS:
whois <attacker_IP>

# Reverse DNS:
dig -x <attacker_IP>

# IP Reputation:
# - AbuseIPDB: https://www.abuseipdb.com/check/<IP>
# - GreyNoise: https://viz.greynoise.io/ip/<IP>
# - AlienVault OTX

# Check if IP is TOR exit node, VPN, proxy

# Geographic location
# GeoIP lookup tools
```

**Assess**:
- [ ] Is IP on known-bad lists (compromised, botnet, etc.)?
- [ ] Is IP residential, datacenter, VPN/proxy, or TOR?
- [ ] Does geographic location align with user's expected location?
- [ ] Is same IP attacking multiple systems in HawkinsOps?

---

## Step 6: Containment

### 6.1 Block Attacker IP

**At pfSense (preferred)**:
```
Firewall → Rules → WAN
Add Rule:
  - Action: Block
  - Source: <attacker_IP>
  - Description: "Block authentication attack - Incident YYYY-MM-DD"
Apply Changes
```

**On Windows Endpoint**:
```powershell
New-NetFirewallRule -DisplayName "Block Brute-Force IP" `
  -Direction Inbound `
  -Action Block `
  -RemoteAddress <attacker_IP>
```

**On Linux Endpoint**:
```bash
# UFW:
sudo ufw deny from <attacker_IP>

# Or iptables:
sudo iptables -A INPUT -s <attacker_IP> -j DROP
```

### 6.2 Disable Compromised Account (if confirmed)

```powershell
# Windows:
Disable-LocalUser -Name "<username>"

# Or for domain:
Disable-ADAccount -Identity "<username>"
```

```bash
# Linux:
sudo passwd -l <username>
sudo usermod -L <username>
sudo usermod -e 1 <username>  # Expire account
```

### 6.3 Kill Active Sessions

```powershell
# Windows:
query user
logoff <session_id>
```

```bash
# Linux:
who  # or w
sudo pkill -9 -u <username>  # Kill all user's processes
# Or kill specific session:
sudo pkill -9 -t pts/X
```

### 6.4 Reset Password

**If account compromised or credentials suspected leaked**:

```powershell
# Windows:
$NewPassword = Read-Host -AsSecureString "Enter new password"
Set-LocalUser -Name "<username>" -Password $NewPassword

# Force change at next logon:
Set-LocalUser -Name "<username>" -PasswordNeverExpires $false
```

```bash
# Linux:
sudo passwd <username>

# Force password change at next login:
sudo passwd -e <username>
```

### 6.5 Enable Account Lockout (if not configured)

**Windows**:
```
Run: secpol.msc
Navigate to: Account Policies → Account Lockout Policy
Configure:
  - Account lockout threshold: 5 invalid attempts
  - Account lockout duration: 30 minutes
  - Reset account lockout counter after: 30 minutes

Or via PowerShell (requires additional configuration):
net accounts /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
```

**Linux (configure Fail2Ban)**:
```bash
# Install Fail2Ban:
sudo apt update
sudo apt install fail2ban

# Configure SSH jail:
sudo nano /etc/fail2ban/jail.local

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600
findtime = 600

# Start service:
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status:
sudo fail2ban-client status sshd
```

---

## Step 7: Evidence Collection

### 7.1 Authentication Logs

**Windows**:
```powershell
# Export Security log:
wevtutil epl Security C:\Forensics\Security_Auth_Investigation.evtx

# Export RDP logs:
wevtutil epl "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" `
  C:\Forensics\RDP_Logs.evtx

# Export filtered auth events to CSV:
Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624,4625,4648,4672} |
  Export-Csv C:\Forensics\Auth_Events.csv -NoTypeInformation
```

**Linux**:
```bash
# Copy auth logs:
INCIDENT_DIR=~/HAWKINS_OPS/incidents/$(date +%Y-%m-%d)_auth_anomaly
mkdir -p $INCIDENT_DIR

sudo cp /var/log/auth.log $INCIDENT_DIR/
sudo cp /var/log/auth.log.1 $INCIDENT_DIR/ 2>/dev/null

# Extract failed attempts:
sudo grep "Failed password" /var/log/auth.log > $INCIDENT_DIR/failed_attempts.log

# Extract successful logins:
sudo grep "Accepted" /var/log/auth.log > $INCIDENT_DIR/successful_logins.log
```

### 7.2 Account State

**Windows**:
```powershell
# Current users and groups:
Get-LocalUser | Export-Csv C:\Forensics\Local_Users.csv
Get-LocalGroup | ForEach-Object {
  Get-LocalGroupMember $_ -ErrorAction SilentlyContinue
} | Export-Csv C:\Forensics\Group_Memberships.csv
```

**Linux**:
```bash
# Copy user/group files:
sudo cp /etc/passwd $INCIDENT_DIR/passwd.backup
sudo cp /etc/group $INCIDENT_DIR/group.backup
sudo cp /etc/shadow $INCIDENT_DIR/shadow.backup  # Sensitive!

# List sudo users:
grep sudo /etc/group > $INCIDENT_DIR/sudo_users.txt
```

### 7.3 Wazuh Alerts

```
From Wazuh Dashboard:
- Export all authentication-related alerts for affected agent
- Export as JSON or CSV
- Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_auth_anomaly/wazuh_alerts.json
```

### 7.4 Network Context

```
From pfSense:
- Export firewall logs showing attacker IP attempts
- Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_auth_anomaly/pfsense_logs.txt

From affected endpoint:
- Current network connections (may show attacker session if still active)
```

### 7.5 Timeline

```
Create timeline document:

[YYYY-MM-DD HH:MM:SS] First failed login attempt detected
[YYYY-MM-DD HH:MM:SS] Failed attempts reached X count
[YYYY-MM-DD HH:MM:SS] Account locked (if applicable)
[YYYY-MM-DD HH:MM:SS] Successful login (if occurred)
[YYYY-MM-DD HH:MM:SS] Alert generated
[YYYY-MM-DD HH:MM:SS] Investigation began
[YYYY-MM-DD HH:MM:SS] Containment applied (IP blocked, account disabled)
[YYYY-MM-DD HH:MM:SS] Password reset
[YYYY-MM-DD HH:MM:SS] Incident resolved

Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_auth_anomaly/timeline.md
```

---

## Step 8: Post-Incident Hardening

### 8.1 Authentication Security

**Windows**:
- [ ] Enable account lockout policy (5 attempts)
- [ ] Implement password complexity requirements
- [ ] Deploy MFA for admin accounts (Windows Hello, Azure MFA)
- [ ] Disable local admin account (rename or disable)
- [ ] Enable Network Level Authentication (NLA) for RDP
- [ ] Restrict RDP access to specific IPs (pfSense rules)
- [ ] Change RDP to non-standard port
- [ ] Deploy LAPS for local admin password management

**Linux**:
- [ ] Deploy and configure Fail2Ban
- [ ] Disable password authentication (SSH keys only)
  ```bash
  sudo nano /etc/ssh/sshd_config
  # Set: PasswordAuthentication no
  sudo systemctl restart sshd
  ```
- [ ] Disable root SSH login
  ```bash
  # In /etc/ssh/sshd_config:
  PermitRootLogin no
  ```
- [ ] Change SSH to non-standard port
- [ ] Implement two-factor authentication (Google Authenticator PAM)
- [ ] Use AllowUsers/AllowGroups in sshd_config to restrict access
- [ ] Enable detailed authentication logging

**pfSense**:
- [ ] Restrict admin access to specific IPs
- [ ] Enable MFA for pfSense admin accounts
- [ ] Change default admin ports
- [ ] Disable admin access from WAN

### 8.2 Monitoring Enhancements

**Create Wazuh custom rules**:
```xml
<!-- Example: Alert on 5 failed logins in 5 minutes -->
<rule id="100010" level="10" frequency="5" timeframe="300">
  <if_matched_sid>5503</if_matched_sid>
  <description>Multiple failed SSH login attempts</description>
  <group>authentication_failed,brute_force,</group>
</rule>
```

**Deploy active response** (auto-block on Wazuh):
```xml
<!-- In /var/ossec/etc/ossec.conf on Wazuh server -->
<active-response>
  <command>firewall-drop</command>
  <location>local</location>
  <rules_id>100010</rules_id>
  <timeout>3600</timeout>
</active-response>
```

**Dashboard creation**:
- Authentication attempts dashboard in Wazuh
- Failed login trending
- Account creation/modification alerts

### 8.3 Regular Audits

**Schedule recurring tasks**:
- [ ] Weekly review of authentication logs
- [ ] Monthly audit of user accounts (remove unused)
- [ ] Quarterly review of privileged account usage
- [ ] Regular review of pfSense blocked IPs (identify patterns)
- [ ] Periodic password expiration enforcement
- [ ] Annual penetration testing (auth mechanisms)

---

## Step 9: Documentation & Closure

### 9.1 Incident Report

**Include**:
- Attack type (brute-force, password spray, etc.)
- Affected accounts and systems
- Attacker IPs and methods
- Timeline of attack and response
- Whether account was compromised
- Containment actions taken
- Evidence collected
- Hardening implemented
- Lessons learned

**Save to**: `~/HAWKINS_OPS/incidents/YYYY-MM-DD_auth_anomaly/incident_report.md`

### 9.2 Update Threat Intelligence

- Add attacker IPs to blocklist
- Update Wazuh rules based on attack pattern
- Share IOCs with threat intelligence community (if appropriate)
- Document attack techniques (MITRE ATT&CK mapping)

### 9.3 User Notification

**If user account involved**:
- Notify user of incident
- Explain what happened
- Confirm new password
- Security awareness reminder (phishing, password hygiene)
- Instructions for monitoring their account

---

## VERIFY Checklist

Before closing incident:
- [ ] Attacker IP(s) blocked at firewall
- [ ] Compromised accounts disabled/secured
- [ ] Passwords reset for affected accounts
- [ ] Account lockout policies in place
- [ ] Fail2Ban (Linux) or equivalent configured
- [ ] No active unauthorized sessions
- [ ] Evidence collected and archived
- [ ] Wazuh alerts updated/closed
- [ ] Hardening measures implemented
- [ ] Monitoring validated for this attack type
- [ ] User(s) notified if applicable
- [ ] Incident documented thoroughly

---

## Quick Reference: Authentication Event IDs

### Windows Security Log
| Event ID | Description |
|----------|-------------|
| 4624 | Successful logon |
| 4625 | Failed logon |
| 4634 | Logoff |
| 4648 | Logon with explicit credentials (RunAs) |
| 4672 | Special privileges assigned (admin) |
| 4720 | User account created |
| 4722 | User account enabled |
| 4724 | Password reset |
| 4725 | User account disabled |
| 4728 | Member added to security-enabled global group |
| 4732 | Member added to security-enabled local group |
| 4756 | Member added to security-enabled universal group |
| 4776 | Domain controller validated credentials |

### Linux Auth Log Patterns
| Pattern | Description |
|---------|-------------|
| `Failed password` | Failed login attempt |
| `Accepted password` | Successful password authentication |
| `Accepted publickey` | Successful SSH key authentication |
| `Invalid user` | Login attempt with non-existent user |
| `sudo.*COMMAND` | Successful sudo command |
| `sudo.*NOT` | Failed sudo attempt |
| `useradd\|adduser` | User account created |
| `usermod` | User account modified |

---

## Related Scenarios

- Scenario 02: SSH Brute-Force Attack
- Scenario 04: Suspicious Administrator Logon
- Scenario 08: Privilege Escalation Attempt
- Scenario 09: RDP Brute-Force Attack
- Playbook: General Incident Response
- Playbook: Suspicious Endpoint Activity
