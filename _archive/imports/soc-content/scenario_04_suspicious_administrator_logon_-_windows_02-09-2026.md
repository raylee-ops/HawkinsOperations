# Scenario 04: Suspicious Administrator Logon - Windows

## Environment Context
- **Primary Detection**: Wazuh SIEM monitoring Windows Security logs
- **Affected System**: Windows Powerhouse endpoint
- **HawkinsOps Components Involved**:
  - Windows endpoint with Wazuh agent
  - Wazuh server (correlation/alerting)
  - pfSense (network context - source IP validation)
  - PRIMARY_OS (investigation workstation)

## Detection

### Wazuh Alert Details
- **Rule ID**: 60122 (Windows: User logon with administrator privileges)
- **Rule ID**: 60103 (Windows: Successful logon from unusual location/time)
- **Rule Level**: 7-10
- **Event Source**: Windows Security Event Log

### Windows Event IDs
- **4624**: Successful logon
  - Logon Type 2: Interactive (console)
  - Logon Type 3: Network (SMB, RPC)
  - Logon Type 10: Remote Interactive (RDP)
- **4672**: Special privileges assigned to new logon (admin rights)
- **4648**: Logon attempted with explicit credentials (RunAs)
- **4776**: Domain controller authentication (if domain-joined)

### Suspicious Indicators
- Logon from unusual workstation/IP
- Logon during non-business hours
- Admin account used for routine tasks (should use least privilege)
- Multiple failed attempts followed by success
- Geographic impossibility (if tracking locations)
- Service account interactive logon

## Triage Steps

1. **Extract Alert Details from Wazuh**
   ```
   - Timestamp: _______________
   - Account name: _______________
   - Logon type: _______________
   - Source IP/workstation: _______________
   - Logon ID: _______________ (for tracking session)
   ```

2. **Query Windows Security Log for Logon Details**
   ```powershell
   # On Windows endpoint:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} -MaxEvents 100 |
     Where-Object {$_.Properties[5].Value -eq '<username>'} |
     Select-Object TimeCreated,
     @{Name='LogonType';Expression={$_.Properties[8].Value}},
     @{Name='User';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={$_.Properties[18].Value}},
     @{Name='LogonID';Expression={$_.Properties[7].Value}} |
     Format-Table -AutoSize
   ```

3. **Check for Privilege Assignment**
   ```powershell
   # Event ID 4672 indicates admin privileges assigned:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4672} -MaxEvents 50 |
     Where-Object {$_.Properties[1].Value -eq '<username>'} |
     Select-Object TimeCreated, @{Name='User';Expression={$_.Properties[1].Value}}
   ```

4. **Validate Source of Logon**
   ```powershell
   # For RDP (Logon Type 10):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
     Where-Object {$_.Properties[8].Value -eq 10} |
     Select-Object TimeCreated, @{Name='User';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={$_.Properties[18].Value}}

   # Check RDP connection logs:
   Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' |
     Select-Object TimeCreated, Message | Format-List
   ```

5. **Check Account Recent Activity**
   ```powershell
   # All recent logons for this user:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
     Where-Object {$_.Properties[5].Value -eq '<username>'} |
     Select-Object TimeCreated, @{Name='LogonType';Expression={$_.Properties[8].Value}}} |
     Sort-Object TimeCreated -Descending | Select-Object -First 20

   # Recent failed logons (Event 4625):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[5].Value -eq '<username>'} |
     Select-Object TimeCreated, @{Name='FailureReason';Expression={$_.Properties[8].Value}}
   ```

6. **Identify Actions Taken During Session**
   ```powershell
   # Use Logon ID from step 1 to track session activity:
   $LogonID = '<LogonID from alert>'

   # Process creation during this session (Event 4688):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4688} |
     Where-Object {$_.Properties[10].Value -eq $LogonID} |
     Select-Object TimeCreated, @{Name='Process';Expression={$_.Properties[5].Value}},
     @{Name='CommandLine';Expression={$_.Properties[8].Value}}

   # File access during session (Event 4663 - requires object auditing):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4663} |
     Where-Object {$_.Properties[1].Value -eq $LogonID}
   ```

7. **Check Network Activity from Source IP**
   ```bash
   # On pfSense or via Wazuh:
   # Review firewall logs for source IP
   # Check for port scanning, lateral movement attempts
   # Validate IP is expected location for user
   ```

8. **Verify User Authorization**
   - Contact user directly (via separate channel, not email)
   - Confirm they initiated the logon
   - Ask about location, device used
   - Verify business justification for admin access

## Investigation Checklist

- [ ] Logon occurred during user's normal working hours?
- [ ] Source IP matches known user locations?
- [ ] Logon type appropriate for user role? (RDP vs console vs network)
- [ ] Admin account used for admin task, or routine work?
- [ ] Failed attempts preceded success? (credential stuffing/brute-force)
- [ ] User confirms they initiated logon?
- [ ] Session activity aligns with user's job function?
- [ ] Suspicious processes launched during session?
- [ ] Sensitive files accessed inappropriately?
- [ ] Account shows signs of compromise (password spray, ticket manipulation)?
- [ ] Lateral movement from source system?
- [ ] Service account used interactively (should be non-interactive only)?

## Containment Actions

### If Unauthorized Access Confirmed:

1. **Disable Compromised Account**
   ```powershell
   # Local account:
   Disable-LocalUser -Name "<username>"

   # Domain account (if domain-joined):
   Disable-ADAccount -Identity "<username>"
   ```

2. **Kill Active Sessions**
   ```powershell
   # Find session ID:
   query user

   # Logoff user:
   logoff <session_id>
   ```

3. **Reset Account Password**
   ```powershell
   # Force password change:
   Set-LocalUser -Name "<username>" -PasswordNeverExpires $false
   $NewPassword = Read-Host -AsSecureString "Enter new password"
   Set-LocalUser -Name "<username>" -Password $NewPassword

   # Domain account:
   Set-ADAccountPassword -Identity "<username>" -Reset
   Set-ADUser -Identity "<username>" -ChangePasswordAtLogon $true
   ```

4. **Block Source IP at pfSense**
   - Add IP to firewall block rule
   - Review other traffic from same IP

5. **Check for Persistence Mechanisms**
   ```powershell
   # Scheduled tasks created during session:
   Get-ScheduledTask | Where-Object {$_.Principal.UserId -eq '<username>'} |
     Select-Object TaskName, TaskPath, State

   # Services created/modified:
   Get-WinEvent -FilterHashtable @{LogName='System';ID=7045} |
     Select-Object TimeCreated, Message

   # Registry Run keys:
   Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
   Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'

   # Startup folder:
   Get-ChildItem -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup'
   ```

6. **Review Admin Group Membership**
   ```powershell
   # Check if unauthorized users added to admin groups:
   Get-LocalGroupMember -Group "Administrators"

   # Domain admins (if applicable):
   Get-ADGroupMember -Identity "Domain Admins"
   ```

### If Authorized but Risky:

1. Document business justification
2. Recommend least-privilege alternatives (standard user account + UAC)
3. Enable additional logging for this account
4. Set up Wazuh alert suppression if recurring legitimate activity

## Evidence to Capture

1. **Wazuh Alert Export**
   - Full alert JSON
   - Save to: `~/HAWKINS_OPS/incidents/YYYY-MM-DD_suspicious_admin_logon/`

2. **Windows Security Event Logs**
   ```powershell
   # Export relevant time window:
   $StartTime = (Get-Date).AddHours(-2)
   $EndTime = Get-Date

   Get-WinEvent -FilterHashtable @{LogName='Security';StartTime=$StartTime;EndTime=$EndTime} |
     Where-Object {$_.Id -in @(4624,4625,4672,4648,4688)} |
     Export-Csv C:\temp\security_events.csv -NoTypeInformation

   # Export full Security log for deep analysis:
   wevtutil epl Security C:\temp\security.evtx "/q:*[System[TimeCreated[@SystemTime>='<start_time>']]]"
   ```

3. **RDP Connection Logs**
   ```powershell
   Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' |
     Export-Csv C:\temp\rdp_connections.csv
   ```

4. **Process Execution Log**
   ```powershell
   # Processes created during suspicious session:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4688;StartTime=$StartTime} |
     Select-Object TimeCreated, @{Name='User';Expression={$_.Properties[1].Value}},
     @{Name='Process';Expression={$_.Properties[5].Value}},
     @{Name='CommandLine';Expression={$_.Properties[8].Value}} |
     Export-Csv C:\temp\process_execution.csv
   ```

5. **Account Activity Timeline**
   ```powershell
   # Create timeline of all account actions:
   Get-WinEvent -FilterHashtable @{LogName='Security';StartTime=$StartTime} |
     Where-Object {$_.Message -like '*<username>*'} |
     Select-Object TimeCreated, Id, Message |
     Export-Csv C:\temp\account_timeline.csv
   ```

6. **Network Context**
   - pfSense logs for source IP
   - Wazuh network events correlation

7. **Screenshots**
   - Wazuh alert dashboard
   - Event Viewer showing logon events
   - Timeline visualization

8. **User Interview Notes**
   - Document conversation with user
   - Confirm/deny authorization

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Document determination (authorized/unauthorized/false positive)
2. If unauthorized, verify account secured and persistence removed
3. Update Wazuh alert with resolution details
4. Archive evidence to incidents folder
5. Update user account notes in asset inventory
6. Create change ticket if new controls needed

### Hardening Recommendations:
- **Implement Just-In-Time (JIT) admin access** - temp elevation only when needed
- **Separate admin accounts from standard accounts** (user-admin vs user-standard)
- **Disable local admin accounts** where not needed
- **Enable Windows Defender Credential Guard** to protect credentials in memory
- **Deploy LAPS** (Local Administrator Password Solution) for unique local admin passwords
- **Restrict RDP access** to specific IPs/subnets via pfSense
- **Enable Network Level Authentication (NLA)** for RDP
- **Configure account lockout policies** to prevent brute-force
- **Implement MFA for admin accounts** (Windows Hello for Business, Azure MFA)
- **Enable Advanced Audit Policy** for enhanced logging:
  ```powershell
  # Audit logon events:
  auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
  # Audit privilege use:
  auditpol /set /category:"Privilege Use" /success:enable /failure:enable
  ```
- **Create Wazuh correlation rules** for anomalous admin logons:
  - Off-hours admin logons
  - Admin logons from unexpected IPs
  - Service account interactive logons
- **Regular review of admin group membership**
- **User awareness training** on credential protection

### Portfolio Notes:
- Demonstrates Windows security event analysis
- Shows understanding of authentication mechanisms and logon types
- Highlights identity and access management (IAM) principles
- Emphasizes least-privilege and Zero Trust concepts
