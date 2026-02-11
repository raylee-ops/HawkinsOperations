# Scenario 01: Suspicious PowerShell Execution Detected

## Environment Context
- **Primary Detection**: Wazuh SIEM
- **Affected System**: Windows Powerhouse endpoint
- **HawkinsOps Components Involved**:
  - Wazuh server (monitoring/alerting)
  - Windows endpoint with Wazuh agent
  - PRIMARY_OS (analyst workstation for investigation)

## Detection

### Wazuh Alert Details
- **Rule ID**: 91816 (Windows PowerShell: Suspicious command line)
- **Rule Level**: 7-12 (depending on command content)
- **Event Source**: Windows Security/Sysmon logs
- **Common Triggers**:
  - Encoded commands (`-EncodedCommand`, `-enc`)
  - Download cradles (`IEX`, `Invoke-WebRequest`, `downloadstring`)
  - Bypass flags (`-ExecutionPolicy Bypass`, `-WindowStyle Hidden`)
  - Obfuscation patterns

### Windows Event IDs
- **4688**: Process creation with command line
- **4104**: PowerShell script block logging
- **4103**: PowerShell module logging
- **Sysmon Event 1**: Process creation (if Sysmon deployed)

## Triage Steps

1. **Access Wazuh Dashboard**
   - Navigate to Security Events
   - Filter by Rule ID 91816 or search "PowerShell"
   - Note: timestamp, source IP, username, full command line

2. **Extract Key Alert Details**
   ```
   - Alert timestamp: _______________
   - Hostname: _______________
   - Username: _______________
   - Full command line: _______________
   - Parent process: _______________
   ```

3. **Retrieve Full PowerShell Command**
   - On Windows endpoint, open Event Viewer
   - Navigate to: Applications and Services Logs → Microsoft → Windows → PowerShell → Operational
   - Filter Event ID 4104 around alert timestamp
   - Copy full script block content

4. **Check User Context**
   ```powershell
   # On Windows endpoint:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4688} -MaxEvents 50 |
     Where-Object {$_.Properties[5].Value -like '*powershell*'} |
     Select-Object TimeCreated, @{Name='User';Expression={$_.Properties[1].Value}},
     @{Name='CommandLine';Expression={$_.Properties[8].Value}}
   ```

5. **Identify Parent Process**
   ```powershell
   # Check what spawned PowerShell:
   Get-WinEvent -FilterHashtable @{LogName='Security';ID=4688} |
     Where-Object {$_.Properties[8].Value -like '*powershell*'} |
     Select-Object TimeCreated, @{Name='ParentProcess';Expression={$_.Properties[13].Value}}
   ```

6. **Check for Network Connections**
   ```powershell
   # If PowerShell is still running:
   Get-NetTCPConnection | Where-Object {$_.OwningProcess -eq <PID>}

   # Historical connections (requires Sysmon):
   Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';ID=3} |
     Where-Object {$_.Properties[0].Value -like '*powershell*'}
   ```

## Investigation Checklist

- [ ] Command line contains encoded/obfuscated content?
- [ ] Download attempt from external IP/domain?
- [ ] User account matches typical working hours/behavior?
- [ ] Parent process is expected? (explorer.exe = user action, wmiprvse.exe/svchost.exe = potential lateral movement)
- [ ] Other unusual processes spawned around same time?
- [ ] Endpoint shows signs of compromise (new scheduled tasks, registry changes, new services)?
- [ ] Similar activity on other endpoints (lateral movement)?
- [ ] External network connections to known-bad IPs/domains?
- [ ] PowerShell history shows additional suspicious commands?

## Containment Actions

### If Confirmed Malicious:

1. **Immediate Isolation** (if active infection suspected)
   ```powershell
   # Disable network adapter (run as admin):
   Disable-NetAdapter -Name "Ethernet" -Confirm:$false
   ```

2. **Kill Suspicious Processes**
   ```powershell
   Stop-Process -Id <PID> -Force
   ```

3. **Disable Compromised Account** (if credentials suspected compromised)
   ```powershell
   Disable-LocalUser -Name "<username>"
   # OR for domain account: Disable-ADAccount -Identity "<username>"
   ```

4. **Block External IP at pfSense**
   - Log into pfSense
   - Firewall → Rules → Add block rule for malicious IP
   - Or add to Alias list for bulk blocking

5. **Create Wazuh Active Response** (if configured)
   - Block IP address via firewall-drop command
   - Isolate agent temporarily

### If False Positive/Authorized:

1. Document business justification
2. Create Wazuh exception if recurring legitimate activity
3. Update playbook with known-good patterns

## Evidence to Capture

1. **Wazuh Alert Export**
   - Full alert JSON from Wazuh dashboard
   - Save to: `~/HAWKINS_OPS/incidents/YYYY-MM-DD_suspicious_powershell/wazuh_alert.json`

2. **Windows Event Logs**
   ```powershell
   # Export PowerShell operational log:
   wevtutil epl "Microsoft-Windows-PowerShell/Operational" C:\temp\ps_operational.evtx

   # Export Security log (filtered):
   wevtutil epl Security C:\temp\security.evtx "/q:*[System[(EventID=4688)]]"
   ```

3. **PowerShell History**
   ```powershell
   Copy-Item $env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt `
     C:\temp\ps_history.txt
   ```

4. **Process List Snapshot**
   ```powershell
   Get-Process | Select-Object Name, Id, Path, StartTime |
     Export-Csv C:\temp\processes.csv -NoTypeInformation
   ```

5. **Network Connections**
   ```powershell
   Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress,
     RemotePort, State, OwningProcess | Export-Csv C:\temp\network_connections.csv
   ```

6. **Screenshots**
   - Wazuh alert details
   - Event Viewer entries
   - Process tree (if using Process Explorer)

7. **Incident Report**
   - Use HawkinsOps incident template
   - Document timeline, actions taken, outcome

## Closure & Lessons Learned

### Ticket Closure Steps:
1. Document final determination (malicious/benign/false positive)
2. Verify containment actions were effective
3. Confirm no persistence mechanisms remain
4. Update asset inventory if system was reimaged
5. Close Wazuh alert with notes
6. Archive all evidence to HawkinsOps incidents folder

### Hardening Recommendations:
- **Enable PowerShell Constrained Language Mode** in high-security environments
- **Configure AppLocker/WDAC** to restrict script execution
- **Enable PowerShell logging** (Script Block + Module logging) if not already enabled
- **Deploy Sysmon** for enhanced process monitoring
- **Regular review** of scheduled tasks and startup items
- **User training** on phishing and social engineering
- **Baseline normal PowerShell usage** per role to improve detection accuracy

### Documentation:
- Update `assumptions_and_placeholders.md` with actual rule IDs encountered
- Add any newly discovered IOCs to threat intelligence feed
- Update playbooks if new techniques observed
