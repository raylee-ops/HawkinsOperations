# Scenario 09: RDP Brute-Force Attack - Windows

## Environment Context
- **Primary Detection**: Wazuh SIEM, Windows Security logs, pfSense
- **Affected System**: Windows Powerhouse endpoint
- **HawkinsOps Components Involved**:
  - Windows endpoint with Wazuh agent
  - Wazuh server (correlation/alerting)
  - pfSense (network-level blocking, traffic analysis)

## Detection

### Detection Indicators

**Wazuh Alerts:**
- **Rule ID**: 60122 (Multiple failed Windows logon attempts)
- **Rule ID**: 60204 (Windows RDP connection attempt)
- **Rule ID**: Custom correlation rule for RDP brute-force pattern

**Windows Event IDs:**
- **4625**: Failed logon attempt
  - Look for Logon Type 10 (RemoteInteractive/RDP)
  - Failure Reason code 0xC000006D (bad username) or 0xC000006A (bad password)
- **4624**: Successful logon (Logon Type 10) - especially after multiple failures
- **4648**: Logon attempted with explicit credentials
- **4776**: Domain controller attempted to validate credentials
- **EventID 1149** (TerminalServices-RemoteConnectionManager/Operational): User authentication failed

**pfSense Indicators:**
- Multiple connections to port 3389 from single source IP
- Traffic spike to Windows endpoint RDP port
- Connections from unusual geographic locations

**Network Indicators:**
- High volume of traffic on port 3389
- Connections from multiple IPs (distributed attack)
- Non-standard RDP client behavior

## Triage Steps

1. **Review Wazuh Alert**
   - Source IP of attacker
   - Target username(s) attempted
   - Number of failed attempts
   - Timeframe and attack duration
   - Any successful authentications

2. **Query Windows Security Log**
   ```powershell
   # On Windows endpoint:
   # Failed RDP logon attempts (Event 4625, Logon Type 10):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[10].Value -eq 10} |
     Select-Object TimeCreated,
     @{Name='Username';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={$_.Properties[19].Value}},
     @{Name='FailureReason';Expression={$_.Properties[8].Value}} |
     Sort-Object TimeCreated -Descending | Format-Table -AutoSize

   # Count failed attempts per source IP:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[10].Value -eq 10} |
     Group-Object @{Expression={$_.Properties[19].Value}} |
     Select-Object Count, Name | Sort-Object Count -Descending

   # Failed attempts per username:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[10].Value -eq 10} |
     Group-Object @{Expression={$_.Properties[5].Value}} |
     Select-Object Count, Name | Sort-Object Count -Descending
   ```

3. **Check for Successful RDP Logins**
   ```powershell
   # Successful RDP logons (Event 4624, Logon Type 10):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
     Where-Object {$_.Properties[8].Value -eq 10} |
     Select-Object TimeCreated,
     @{Name='Username';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={$_.Properties[18].Value}},
     @{Name='LogonID';Expression={$_.Properties[7].Value}} |
     Sort-Object TimeCreated -Descending | Select-Object -First 20

   # Check if attacker IP succeeded:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4624} |
     Where-Object {$_.Properties[8].Value -eq 10 -and $_.Properties[18].Value -eq '<attacker_IP>'} |
     Select-Object TimeCreated, @{Name='Username';Expression={$_.Properties[5].Value}}
   ```

4. **Review RDP-Specific Logs**
   ```powershell
   # Terminal Services logs:
   Get-WinEvent -LogName 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational' |
     Select-Object TimeCreated, Id, Message | Format-List | more

   # Event ID 1149 - Authentication failures:
   Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational';ID=1149} |
     Select-Object TimeCreated, Message | Format-List

   # Event ID 1158 - Connection attempts:
   Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational';ID=1158} |
     Select-Object TimeCreated, Message
   ```

5. **Analyze Attack Pattern**
   ```powershell
   # Timeline of attack:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[19].Value -eq '<attacker_IP>'} |
     Select-Object TimeCreated, @{Name='Username';Expression={$_.Properties[5].Value}} |
     Sort-Object TimeCreated

   # Identify if it's dictionary attack (many usernames) or password spray (few usernames):
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[19].Value -eq '<attacker_IP>'} |
     Group-Object @{Expression={$_.Properties[5].Value}} |
     Measure-Object
   ```

6. **Check pfSense Firewall Logs**
   ```
   Status → System Logs → Firewall
   Filter: destination port 3389
   Look for:
   - Source IPs attempting connection
   - Frequency of attempts
   - Geographic origin (if GeoIP enabled)
   - Blocked vs allowed connections
   ```

7. **Investigate Attacker IP**
   ```bash
   # On PRIMARY_OS:
   # WHOIS lookup:
   whois <attacker_IP>

   # Check IP reputation:
   # AbuseIPDB: https://www.abuseipdb.com/check/<IP>
   # GreyNoise: https://viz.greynoise.io/ip/<IP>

   # Check for known malicious activity:
   # Talos Intelligence, AlienVault OTX
   ```

8. **Verify RDP Exposure**
   ```powershell
   # On Windows endpoint:
   # Check if RDP is enabled:
   Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections"
   # 0 = RDP enabled, 1 = RDP disabled

   # Check RDP port:
   Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "PortNumber"

   # Check Windows Firewall RDP rules:
   Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Select-Object DisplayName, Enabled, Direction
   ```

   ```
   At pfSense:
   Check firewall rules allowing port 3389 from WAN/Internet
   Verify if RDP should be Internet-accessible
   ```

## Investigation Checklist

- [ ] Attack from single IP or distributed (multiple IPs)?
- [ ] Source IP geographic location makes sense?
- [ ] Targeted specific account or multiple usernames?
- [ ] Attack still ongoing or historical?
- [ ] Any successful authentication from attacker IP?
- [ ] RDP intentionally exposed to Internet or misconfigured?
- [ ] Attack volume (attempts per minute)?
- [ ] Attack duration (minutes, hours, days)?
- [ ] Same IP attacking other HawkinsOps systems?
- [ ] Account lockout policy in place and triggered?
- [ ] Users notified of failed login attempts?
- [ ] Legitimate user could be source (forgotten password)?

## Containment Actions

### IMMEDIATE ACTIONS:

1. **Block Attacker IP at pfSense** (preferred - network-wide)
   ```
   Firewall → Rules → WAN
   Add rule at top: Action=Block, Source=<attacker_IP>, Protocol=Any
   Apply changes

   OR

   Firewall → Aliases → Create "RDP_Blocklist"
   Add attacker IPs to alias
   Create firewall rule blocking alias
   ```

2. **Block IP on Windows Firewall** (endpoint-level backup)
   ```powershell
   # Create Windows Firewall rule to block IP:
   New-NetFirewallRule -DisplayName "Block RDP Attack IP" `
     -Direction Inbound `
     -Action Block `
     -RemoteAddress <attacker_IP> `
     -Protocol TCP `
     -LocalPort 3389

   # Or block IP entirely:
   New-NetFirewallRule -DisplayName "Block Malicious IP" `
     -Direction Inbound `
     -Action Block `
     -RemoteAddress <attacker_IP>
   ```

3. **Disable RDP Temporarily** (if not critical)
   ```powershell
   # Disable RDP:
   Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' `
     -Name "fDenyTSConnections" -Value 1

   # Restart to apply:
   Restart-Service TermService -Force
   ```

4. **Kill Active RDP Sessions** (if breach suspected)
   ```powershell
   # List RDP sessions:
   query user

   # Disconnect specific session:
   logoff <session_id>

   # Or disconnect all non-console sessions:
   query user | Select-String "rdp" | ForEach-Object {
     $sessionId = ($_ -split '\s+')[2]
     logoff $sessionId
   }
   ```

5. **Reset Passwords** (if account compromised)
   ```powershell
   # Force password change:
   $NewPassword = Read-Host -AsSecureString "Enter new password for <username>"
   Set-LocalUser -Name "<username>" -Password $NewPassword

   # Expire password to force change at next logon:
   Set-LocalUser -Name "<username>" -PasswordNeverExpires $false
   ```

6. **Enable Account Lockout** (if not already configured)
   ```powershell
   # Check current lockout policy:
   net accounts

   # Set account lockout (via Local Security Policy GUI):
   # secpol.msc → Account Policies → Account Lockout Policy
   # - Account lockout threshold: 5 invalid attempts
   # - Account lockout duration: 30 minutes
   # - Reset account lockout counter after: 30 minutes

   # Or via PowerShell (requires additional setup):
   net accounts /lockoutthreshold:5
   ```

### LONG-TERM CONTAINMENT:

1. **Restrict RDP Access** (best practice)
   ```
   At pfSense:
   - Remove/modify WAN rule allowing port 3389
   - Create rule allowing only from specific trusted IPs/VPN
   - Implement VPN-only RDP access
   ```

2. **Change RDP Port** (security through obscurity layer)
   ```powershell
   # Change to non-standard port (e.g., 13389):
   Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
     -Name "PortNumber" -Value 13389

   # Update Windows Firewall rule:
   Set-NetFirewallRule -DisplayGroup "Remote Desktop" -NewPort 13389

   # Restart RDP service:
   Restart-Service TermService -Force

   # Update pfSense rules to reflect new port
   ```

3. **Implement Fail2Ban-like Solution for Windows**
   - Configure Windows intrusion detection
   - Use third-party tools (EvtxToElk, NXLog with Wazuh active response)

## Evidence to Capture

1. **Windows Security Event Logs**
   ```powershell
   # Export Security log for analysis:
   wevtutil epl Security C:\Forensics\Security_RDP_Attack.evtx `
     "/q:*[System[(EventID=4625 or EventID=4624 or EventID=4648)]]"

   # Export Terminal Services logs:
   wevtutil epl "Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational" `
     C:\Forensics\TS_RemoteConnectionManager.evtx
   ```

2. **Failed Logon Summary**
   ```powershell
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625} |
     Where-Object {$_.Properties[10].Value -eq 10} |
     Select-Object TimeCreated, @{Name='User';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={$_.Properties[19].Value}} |
     Export-Csv C:\Forensics\failed_rdp_attempts.csv -NoTypeInformation
   ```

3. **pfSense Firewall Logs**
   ```
   Status → System Logs → Firewall
   Filter by port 3389
   Export to file
   Save to: ~/HAWKINS_OPS/incidents/YYYY-MM-DD_rdp_bruteforce/pfsense_logs.txt
   ```

4. **Attack Timeline**
   ```powershell
   # Create timeline CSV:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4625,4624} |
     Where-Object {$_.Properties[10].Value -eq 10 -or $_.Properties[8].Value -eq 10} |
     Select-Object TimeCreated, Id,
     @{Name='EventType';Expression={if($_.Id -eq 4625){'Failed'}else{'Success'}}},
     @{Name='Username';Expression={$_.Properties[5].Value}},
     @{Name='SourceIP';Expression={if($_.Id -eq 4625){$_.Properties[19].Value}else{$_.Properties[18].Value}}} |
     Sort-Object TimeCreated |
     Export-Csv C:\Forensics\rdp_attack_timeline.csv -NoTypeInformation
   ```

5. **Current RDP Configuration**
   ```powershell
   # Document current settings:
   "RDP Enabled: $(Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections)" > C:\Forensics\rdp_config.txt
   "RDP Port: $(Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name PortNumber)" >> C:\Forensics\rdp_config.txt
   Get-NetFirewallRule -DisplayGroup "Remote Desktop" | Out-File C:\Forensics\rdp_firewall_rules.txt
   ```

6. **Wazuh Alerts**
   - Export all related Wazuh alerts (JSON)
   - Include correlation data

7. **Attacker IP Intelligence**
   ```bash
   # On PRIMARY_OS:
   whois <attacker_IP> > ~/HAWKINS_OPS/incidents/YYYY-MM-DD_rdp_bruteforce/attacker_whois.txt

   # Document IP reputation findings
   ```

8. **Screenshots**
   - Event Viewer showing failed attempts
   - Wazuh dashboard with alert volume
   - pfSense firewall logs

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Verify attacker IPs are blocked at firewall
2. Confirm RDP access is restricted (no Internet exposure)
3. Validate account lockout policy is active
4. Update Wazuh alert with resolution
5. Archive evidence to incidents folder
6. Document lessons learned for future

### Hardening Recommendations:

**Immediate:**
- **Disable RDP from Internet** - use VPN for remote access
- **Implement Network Level Authentication (NLA)**:
  ```powershell
  Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' `
    -Name "UserAuthentication" -Value 1
  ```
- **Enable account lockout policy** (see step 6 in Containment)
- **Change RDP to non-standard port** (reduces automated scans)

**Long-term:**
- **Implement Multi-Factor Authentication for RDP**:
  - Azure MFA, Duo, or similar
  - Windows Hello for Business
- **Deploy RDP Gateway** for centralized, authenticated access
- **Use VPN for all remote access**:
  - pfSense OpenVPN
  - WireGuard
  - IPsec
- **IP Whitelisting** at pfSense for RDP (if remote access needed):
  ```
  Only allow RDP from known static IPs or VPN subnet
  ```
- **Enable detailed RDP logging**:
  ```powershell
  # Group Policy: Computer Config → Admin Templates → Windows Components →
  # Remote Desktop Services → Session Time Limits
  ```
- **Deploy fail2ban equivalent for Windows**:
  - Wazuh active response to block IPs
  - Third-party tools (EvlWatcher, etc.)
- **Create Wazuh correlation rules**:
  - 5 failed RDP attempts in 5 minutes = block IP
  - Alert on successful RDP from new IP
  - Alert on RDP connection outside business hours
- **Regular password audits** - ensure strong passwords:
  ```powershell
  # Deploy password complexity requirements
  # Computer Config → Windows Settings → Security Settings →
  # Account Policies → Password Policy
  ```
- **Disable unused accounts**
- **Remove local admin rights** from standard users
- **Implement Privileged Access Workstation (PAW)** for admin access
- **Network segmentation** - isolate admin workstations
- **Deploy Remote Credential Guard** to protect credentials in transit

**Monitoring:**
- **Continuous monitoring of Event IDs 4625, 4624, 4648**
- **Baseline normal RDP usage** (who, when, from where)
- **Alert on anomalies**: new source IPs, off-hours access, unusual users
- **Regular review of allowed IPs** in firewall rules
- **Dashboard for RDP activity** in Wazuh

### Portfolio Notes:
- Demonstrates understanding of RDP attack vectors
- Shows Windows security event log analysis proficiency
- Highlights defense-in-depth approach (network + host + monitoring)
- Emphasizes secure remote access architecture
- Understanding of authentication protocols and hardening
