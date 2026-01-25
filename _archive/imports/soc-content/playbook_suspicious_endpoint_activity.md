# Playbook: Suspicious Endpoint Activity

## Purpose
This playbook provides step-by-step procedures for investigating and responding to suspicious activity detected on Windows or Linux endpoints in the HawkinsOps environment.

**Use When**:
- Wazuh alerts indicate unusual endpoint behavior
- Antivirus/EDR detects threats
- Users report strange system behavior
- System performance degradation suggests compromise
- Unusual processes or network connections observed

---

## Step 1: Initial Assessment

### 1.1 Gather Alert Information

**From Wazuh Alert**:
```
- Alert Rule ID: ______________
- Severity Level: ______________
- Affected Hostname: ______________
- Affected User: ______________
- Alert Description: ______________
- Timestamp: ______________
- Key Indicators: ______________
```

**VERIFY**: Ensure you're investigating the correct system
```bash
# Check hostname matches:
hostname

# Verify IP address:
# Windows:
ipconfig
# Linux:
ip addr show
```

### 1.2 Create Incident Workspace

```bash
# Create incident folder:
mkdir -p ~/HAWKINS_OPS/incidents/$(date +%Y-%m-%d)_suspicious_endpoint_$(hostname)/

# Set variable for easy access:
INCIDENT_DIR=~/HAWKINS_OPS/incidents/$(date +%Y-%m-%d)_suspicious_endpoint_$(hostname)
```

### 1.3 Initial Questions

- [ ] Is the suspicious activity currently ongoing or historical?
- [ ] Is this a known-good system or frequently problematic?
- [ ] Is the affected user currently logged in?
- [ ] Are there other alerts from this system in Wazuh?
- [ ] Does the user report any issues or unusual behavior?

**Decision Point**: If active malicious activity confirmed (ransomware, active exfiltration), proceed immediately to **Step 6: Containment**. Otherwise, continue investigation.

---

## Step 2: Process Investigation

### 2.1 Review Running Processes

**Windows**:
```powershell
# Get all processes sorted by CPU:
Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table

# Get processes with full path:
Get-Process | Where-Object {$_.Path -ne $null} |
  Select-Object Name, Id, Path, StartTime, Company | Format-Table

# Look for unsigned executables:
Get-Process | Where-Object {$_.Path -ne $null} | ForEach-Object {
  [PSCustomObject]@{
    Name = $_.Name
    PID = $_.Id
    Path = $_.Path
    Signed = (Get-AuthenticodeSignature $_.Path).Status
  }
} | Where-Object {$_.Signed -ne 'Valid'} | Format-Table

# Save process list:
Get-Process | Export-Csv "$env:TEMP\processes.csv" -NoTypeInformation
```

**Linux**:
```bash
# Process tree view:
ps auxf | less

# Processes by CPU usage:
ps aux --sort=-%cpu | head -20

# Processes by memory usage:
ps aux --sort=-%mem | head -20

# Processes running from unusual locations (/tmp, /dev/shm):
sudo lsof +D /tmp 2>/dev/null
sudo lsof +D /dev/shm 2>/dev/null

# Save process list:
ps auxf > $INCIDENT_DIR/processes.txt
```

### 2.2 Identify Suspicious Processes

**Red Flags**:
- Running from temp directories (/tmp, C:\Windows\Temp, %APPDATA%)
- Unusual names (random characters, misspelled system processes)
- High CPU/memory usage without clear purpose
- Unknown parent process relationships
- Processes running as unexpected users (especially SYSTEM/root)

**For Each Suspicious Process**:
```powershell
# Windows - detailed process info:
$pid = <suspicious_PID>
Get-Process -Id $pid | Format-List *
Get-WmiObject Win32_Process -Filter "ProcessId = $pid" | Format-List *

# Command line used to launch:
Get-WmiObject Win32_Process -Filter "ProcessId = $pid" |
  Select-Object ProcessId, CommandLine | Format-List

# Network connections from this process:
Get-NetTCPConnection | Where-Object {$_.OwningProcess -eq $pid}
```

```bash
# Linux - detailed process info:
PID=<suspicious_PID>
sudo ls -la /proc/$PID/

# Command line:
cat /proc/$PID/cmdline | tr '\0' ' ' && echo

# Environment variables:
sudo cat /proc/$PID/environ | tr '\0' '\n'

# Open files:
sudo lsof -p $PID

# Network connections:
sudo lsof -p $PID -i
```

### 2.3 Check Process Reputation

```bash
# On PRIMARY_OS or online:

# Calculate hash of suspicious binary:
# Windows:
Get-FileHash -Path "C:\path\to\suspicious.exe" -Algorithm SHA256

# Linux:
sha256sum /path/to/suspicious_binary

# Check hash on VirusTotal:
# https://www.virustotal.com/gui/file/<hash>

# Check process name in threat intelligence:
# Search for process name in AlienVault OTX, abuse.ch, etc.
```

**Document Findings**:
```
Process Name: ________________
PID: ________________
Path: ________________
Hash: ________________
VirusTotal Detections: ___/___
Parent Process: ________________
Command Line: ________________
Network Connections: ________________
Assessment: [ ] Benign [ ] Suspicious [ ] Malicious
```

---

## Step 3: File System Investigation

### 3.1 Check Recently Modified Files

**Windows**:
```powershell
# Files created/modified in last 24 hours:
$timeframe = (Get-Date).AddDays(-1)

# Executables:
Get-ChildItem -Path C:\ -Include *.exe,*.dll,*.bat,*.ps1,*.vbs -Recurse -ErrorAction SilentlyContinue |
  Where-Object {$_.CreationTime -gt $timeframe -or $_.LastWriteTime -gt $timeframe} |
  Select-Object FullName, CreationTime, LastWriteTime, Length |
  Export-Csv $env:TEMP\recent_files.csv

# Files in temp directories:
Get-ChildItem -Path C:\Windows\Temp,C:\Users\*\AppData\Local\Temp -Recurse -ErrorAction SilentlyContinue |
  Where-Object {$_.CreationTime -gt $timeframe} |
  Select-Object FullName, CreationTime, Length
```

**Linux**:
```bash
# Files modified in last 24 hours:
sudo find / -type f -mtime -1 2>/dev/null | tee $INCIDENT_DIR/recent_files.txt

# Focus on suspicious locations:
sudo find /tmp /var/tmp /dev/shm -type f -mtime -1 -ls 2>/dev/null

# Hidden files in unusual places:
sudo find /tmp /var/tmp /dev/shm -name ".*" -type f -ls 2>/dev/null

# Recently modified binaries:
sudo find /usr/bin /usr/sbin /bin /sbin -type f -mtime -7 -ls 2>/dev/null
```

### 3.2 Check Wazuh FIM Alerts

```
In Wazuh Dashboard:
- Navigate to Security Events
- Filter by agent: <affected_hostname>
- Filter by rule.groups: "syscheck" or "ossec"
- Review file integrity monitoring alerts

Look for:
- Critical system files modified
- Unexpected changes in monitored directories
- New files in monitored locations
```

### 3.3 Examine Suspicious Files

```bash
# Get file metadata:
# Windows:
Get-Item "C:\path\to\file" | Format-List *
Get-AuthenticodeSignature "C:\path\to\file.exe"

# Linux:
stat /path/to/file
file /path/to/file

# Calculate hash:
# Windows:
Get-FileHash -Path "C:\path\to\file" -Algorithm SHA256

# Linux:
sha256sum /path/to/file

# Check with VirusTotal, Hybrid Analysis, or ANY.RUN
```

**Quarantine suspicious files**:
```powershell
# Windows:
New-Item -Path C:\Quarantine -ItemType Directory -Force -ErrorAction SilentlyContinue
Move-Item -Path "C:\path\to\suspicious.exe" -Destination C:\Quarantine\
```

```bash
# Linux:
sudo mkdir -p /quarantine
sudo mv /path/to/suspicious_file /quarantine/
sudo chmod 000 /quarantine/*
```

---

## Step 4: Network Activity Investigation

### 4.1 Active Network Connections

**Windows**:
```powershell
# All established connections:
Get-NetTCPConnection -State Established |
  Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, OwningProcess,
  @{Name='ProcessName';Expression={(Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name}} |
  Format-Table

# Connections to unusual ports:
Get-NetTCPConnection -State Established |
  Where-Object {$_.RemotePort -notin @(80,443,53,22,3389) -and $_.RemoteAddress -notlike '10.*' -and $_.RemoteAddress -notlike '192.168.*'} |
  Format-Table

# Save connections:
Get-NetTCPConnection | Export-Csv $env:TEMP\network_connections.csv
```

**Linux**:
```bash
# All established connections with process info:
sudo lsof -i -n -P | grep ESTABLISHED | tee $INCIDENT_DIR/network_connections.txt

# Or with netstat/ss:
sudo netstat -antp | grep ESTABLISHED
sudo ss -tnp | grep ESTABLISHED

# Connections to unusual ports:
sudo netstat -antp | grep ESTABLISHED | grep -Ev ':(80|443|22|53) '
```

### 4.2 Check Sysmon Network Events (Windows)

```powershell
# If Sysmon is deployed:
# Network connections (Event ID 3):
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';ID=3} -MaxEvents 100 |
  Select-Object TimeCreated,
  @{Name='Process';Expression={$_.Properties[4].Value}},
  @{Name='User';Expression={$_.Properties[5].Value}},
  @{Name='DestIP';Expression={$_.Properties[14].Value}},
  @{Name='DestPort';Expression={$_.Properties[16].Value}} |
  Format-Table
```

### 4.3 Investigate External IPs

For each suspicious external IP:
```bash
# WHOIS lookup:
whois <IP_address>

# Check reputation:
# - AbuseIPDB: https://www.abuseipdb.com/check/<IP>
# - GreyNoise: https://viz.greynoise.io/ip/<IP>
# - AlienVault OTX: https://otx.alienvault.com/

# Check pfSense logs for this IP:
# Status → System Logs → Firewall (filter by IP)
```

### 4.4 DNS Activity

**Check for suspicious DNS queries** (potential C2, tunneling):

```powershell
# Windows with Sysmon (Event ID 22):
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Sysmon/Operational';ID=22} -MaxEvents 200 |
  Select-Object TimeCreated,
  @{Name='Process';Expression={$_.Properties[3].Value}},
  @{Name='QueryName';Expression={$_.Properties[4].Value}} |
  Format-Table
```

```bash
# Linux - check systemd-resolved stats:
sudo systemd-resolve --statistics

# Review pfSense DNS logs (if pfSense is DNS resolver):
# Status → System Logs → Resolver
```

---

## Step 5: Persistence Mechanisms

### 5.1 Autostart Locations

**Windows**:
```powershell
# Registry Run keys:
Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'

# Startup folders:
Get-ChildItem -Path 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup' -Force
Get-ChildItem -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" -Force

# Scheduled tasks (focus on recently created):
Get-ScheduledTask |
  Where-Object {$_.State -ne 'Disabled'} |
  Select-Object TaskName, TaskPath, State, @{Name='Action';Expression={$_.Actions.Execute}} |
  Format-Table

# Services (focus on recently created or manual start type):
Get-Service |
  Where-Object {$_.StartType -eq 'Automatic'} |
  Select-Object Name, DisplayName, Status, StartType

# WMI event subscriptions (advanced persistence):
Get-WmiObject -Namespace root\subscription -Class __EventFilter
Get-WmiObject -Namespace root\subscription -Class CommandLineEventConsumer
```

**Linux**:
```bash
# Cron jobs:
crontab -l | tee $INCIDENT_DIR/user_crontab.txt
sudo crontab -l | tee $INCIDENT_DIR/root_crontab.txt
sudo cat /etc/crontab | tee $INCIDENT_DIR/system_crontab.txt
sudo ls -laR /etc/cron.* | tee $INCIDENT_DIR/cron_dirs.txt

# Systemd services and timers:
systemctl list-unit-files --type=service --state=enabled
systemctl list-timers --all

# Init scripts (if not systemd):
ls -la /etc/init.d/

# Shell profile files:
cat ~/.bashrc ~/.bash_profile ~/.profile 2>/dev/null
sudo cat /root/.bashrc /root/.bash_profile /root/.profile 2>/dev/null
cat /etc/profile /etc/bash.bashrc 2>/dev/null

# Check for modified system binaries:
sudo debsums -c 2>/dev/null  # Debian/Ubuntu
```

### 5.2 Check for Rootkits/Backdoors

**Linux**:
```bash
# Run rkhunter (if installed):
sudo rkhunter --check --skip-keypress

# Or chkrootkit:
sudo chkrootkit

# Manual checks:
# Kernel modules (potential rootkit):
lsmod | tee $INCIDENT_DIR/kernel_modules.txt

# Hidden processes (compare ps and /proc):
ls /proc | grep -E '^[0-9]+$' | sort -n > /tmp/proc_pids
ps aux | awk '{print $2}' | sort -n > /tmp/ps_pids
diff /tmp/proc_pids /tmp/ps_pids  # Differences may indicate hidden processes
```

**Windows**:
```powershell
# Check for kernel-mode drivers (potential rootkit):
Get-WindowsDriver -Online |
  Where-Object {$_.ProviderName -notlike '*Microsoft*'} |
  Select-Object Driver, ClassName, ProviderName, Date

# Services running from unusual locations:
Get-WmiObject Win32_Service |
  Where-Object {$_.PathName -notlike '*system32*' -and $_.PathName -notlike '*Program Files*'} |
  Select-Object Name, PathName, State, StartMode
```

---

## Step 6: Containment

**If malicious activity is confirmed:**

### 6.1 Network Isolation

**Option 1: Firewall-level (preferred)**:
```
At pfSense:
Firewall → Rules → [LAN/Interface]
Add rule blocking affected host IP
Apply changes
```

**Option 2: Endpoint-level**:
```powershell
# Windows:
Disable-NetAdapter -Name "Ethernet" -Confirm:$false
```

```bash
# Linux:
sudo ip link set eth0 down
```

### 6.2 Process Termination

**Capture memory dump FIRST** (if forensics needed):
```powershell
# Windows - using ProcDump:
procdump.exe -ma <PID> C:\Forensics\process_dump.dmp
```

**Then kill**:
```powershell
# Windows:
Stop-Process -Id <PID> -Force
```

```bash
# Linux:
sudo kill -9 <PID>
```

### 6.3 Account Lockout (if compromised)

```powershell
# Windows:
Disable-LocalUser -Name "<username>"
```

```bash
# Linux:
sudo passwd -l <username>
sudo usermod -L <username>
```

---

## Step 7: Evidence Collection

**Collect and preserve** before cleanup:

### 7.1 Memory Dump
```powershell
# Windows - full RAM dump (requires tools like WinPmem, DumpIt, Magnet RAM Capture)
# Or at minimum, process dumps of suspicious processes
```

### 7.2 Logs
```powershell
# Windows:
wevtutil epl Security $env:TEMP\Security.evtx
wevtutil epl System $env:TEMP\System.evtx
wevtutil epl Application $env:TEMP\Application.evtx
wevtutil epl "Microsoft-Windows-Sysmon/Operational" $env:TEMP\Sysmon.evtx -ErrorAction SilentlyContinue
```

```bash
# Linux:
sudo cp -r /var/log $INCIDENT_DIR/logs_backup
sudo dmesg > $INCIDENT_DIR/dmesg.txt
```

### 7.3 System State
```powershell
# Windows:
Get-Process | Export-Csv $env:TEMP\processes.csv
Get-NetTCPConnection | Export-Csv $env:TEMP\network_connections.csv
Get-Service | Export-Csv $env:TEMP\services.csv
Get-ScheduledTask | Export-Csv $env:TEMP\scheduled_tasks.csv
```

```bash
# Linux:
ps auxf > $INCIDENT_DIR/processes.txt
sudo netstat -antp > $INCIDENT_DIR/network_connections.txt
sudo lsof > $INCIDENT_DIR/open_files.txt
systemctl list-units --all > $INCIDENT_DIR/systemd_units.txt
```

### 7.4 Malware Samples
```
Move suspicious files to quarantine/evidence folder
Calculate and document SHA256 hashes
```

---

## Step 8: Eradication & Recovery

See **playbook_general_incident_response.md** Phase 4 & 5 for detailed steps.

**Summary**:
1. Remove malware and persistence mechanisms
2. Patch vulnerabilities
3. Reset compromised credentials
4. Restore from clean backup OR rebuild system (if severe)
5. Apply security hardening
6. Verify eradication with re-scans

---

## Step 9: Documentation

**Complete incident report** with:
- Timeline of events
- Indicators of compromise (IOCs)
- Root cause analysis
- Actions taken
- Evidence inventory
- Lessons learned
- Recommendations

**Save to**: `~/HAWKINS_OPS/incidents/<incident_folder>/incident_report.md`

---

## VERIFY Checklist

Before closing investigation:
- [ ] All suspicious processes identified and assessed
- [ ] File system anomalies investigated
- [ ] Network connections analyzed
- [ ] Persistence mechanisms checked
- [ ] Evidence collected and preserved
- [ ] Containment applied if needed
- [ ] Wazuh alerts reviewed and updated
- [ ] Incident documented thoroughly
- [ ] Follow-up actions identified and assigned

---

## References

- Scenario 05: Potential Malware on Endpoint
- Playbook: General Incident Response
- Wazuh documentation for agent investigation
- MITRE ATT&CK for technique mapping
