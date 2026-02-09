# Windows Powerhouse Rebuild Runbook

## Purpose

This runbook provides detailed steps to rebuild the Windows 11 Powerhouse workstation from bare metal to fully operational HawkinsOps-ready state.

**Role:** Security analyst workstation + administrative console
**OS:** Windows 11 Pro
**Hostname:** `win-powerhouse.hawkinsops.local`
**IP Address:** `192.168.50.101/24`
**Primary Use:** SIEM dashboard access, admin tools, documentation, daily operations

**Estimated Time:** 1-2 hours (excluding Windows updates)

---

## Prerequisites

1. Windows 11 Pro installation media (USB or ISO).
2. Product key (or digital license linked to hardware).
3. Network cable connected to lab network (access to pfSense and internet).
4. Domain Admin credentials for `hawkinsops.local`.
5. KeePassXC database with admin passwords.

---

## Phase 1: Windows 11 Installation

### 1.1 Boot from Installation Media

1. Insert Windows 11 USB installer or mount ISO.
2. Power on machine and enter BIOS/UEFI.
3. Disable Secure Boot (if necessary for compatibility; re-enable post-install).
4. Set boot order: USB/CD first.
5. Save and reboot.

### 1.2 Install Windows 11

1. Windows Setup loads.
2. Language: English (United States).
3. Click "Install now".
4. Enter product key (or select "I don't have a product key" if using digital license).
5. Select: Windows 11 Pro.
6. Accept license terms.
7. Installation type: Custom (advanced).
8. Select target drive (delete existing partitions if clean install).
9. Click Next, wait for installation (~15-20 minutes).
10. Machine reboots automatically.

### 1.3 Initial Windows Setup (OOBE)

1. Region: United States.
2. Keyboard layout: US.
3. Skip additional keyboard layout.
4. Network: Select wired network (should auto-detect).
5. **IMPORTANT:** Bypass Microsoft account requirement:
   - Click "Sign-in options" → "Domain join instead" (or "Offline account" if prompted).
   - **NOTE:** We will join domain later, but create local admin account first.
6. Username: `raylee` (local admin).
7. Password: Set strong password (store in KeePassXC).
8. Security questions: Answer all three.
9. Privacy settings: Disable all telemetry and advertising options.
10. Skip Cortana.
11. Windows completes setup and loads desktop.

**CHECKPOINT:** Windows 11 desktop loaded. Local user `raylee` logged in.

---

## Phase 2: Initial Configuration

### 2.1 Rename Computer

1. Right-click Start → System.
2. Click "Rename this PC".
3. New name: `WIN-POWERHOUSE`
4. Restart now: No (we'll restart after network config).

### 2.2 Configure Static IP Address

1. Right-click Start → Network Connections.
2. Click "Change adapter options".
3. Right-click Ethernet adapter → Properties.
4. Select "Internet Protocol Version 4 (TCP/IPv4)" → Properties.
5. Select "Use the following IP address":
   - IP address: `192.168.50.101`
   - Subnet mask: `255.255.255.0`
   - Default gateway: `192.168.50.1`
6. Select "Use the following DNS server addresses":
   - Preferred DNS: `192.168.50.20` (AD DC)
   - Alternate DNS: `192.168.50.1` (pfSense)
7. Click OK, Close.

**VERIFY:**
- Open Command Prompt: `ipconfig /all`
- Verify IP: `192.168.50.101`
- Verify DNS: `192.168.50.20`
- Test connectivity: `ping 192.168.50.1` (pfSense)
- Test DNS: `nslookup hawkinsops.local` (should resolve)

### 2.3 Disable IPv6 (Optional)

If not using IPv6 in lab:

1. Network adapter properties → Uncheck "Internet Protocol Version 6 (TCP/IPv6)".
2. Click OK.

### 2.4 Set Time Zone and Time Sync

1. Right-click Start → Settings → Time & Language → Date & Time.
2. Set time zone: (your timezone, e.g., America/Chicago for Central Time).
3. Set time automatically: On.
4. Sync now: Click "Sync now".

**IMPORTANT:** Time sync is critical for domain join (must be within 5 minutes of DC).

### 2.5 Reboot

1. Restart computer.
2. Login as `raylee`.

**CHECKPOINT:** Machine named `WIN-POWERHOUSE`, static IP configured, time synced.

---

## Phase 3: Windows Updates and Drivers

### 3.1 Install Windows Updates

1. Settings → Windows Update.
2. Click "Check for updates".
3. Install all available updates (may require multiple reboots).
4. Repeat until "You're up to date" appears.

**NOTE:** This can take 30-60 minutes. Continue with other tasks during restarts.

### 3.2 Install Hardware Drivers

1. Check Device Manager for missing drivers (Right-click Start → Device Manager).
2. Install manufacturer-provided drivers:
   - GPU drivers (NVIDIA/AMD)
   - Chipset drivers
   - Network adapter drivers (if not auto-installed)
   - Audio drivers
3. Reboot if required.

**CHECKPOINT:** All drivers installed, no yellow exclamation marks in Device Manager.

---

## Phase 4: Install Essential Software

### 4.1 Install PowerShell 7

1. Open PowerShell 5 as Administrator (search "PowerShell", right-click, "Run as administrator").
2. Install PowerShell 7:
   ```powershell
   winget install --id Microsoft.Powershell --source winget
   ```
3. Close PowerShell 5.
4. Open PowerShell 7 as Administrator (search "pwsh").

**VERIFY:** `$PSVersionTable.PSVersion` shows version 7.x.

### 4.2 Install Windows Terminal (if not already installed)

1. Open Microsoft Store.
2. Search "Windows Terminal".
3. Install.

**VERIFY:** Launch Windows Terminal, confirm PowerShell 7 profile available.

### 4.3 Install Browser (if needed)

1. Install Firefox or Chrome (if Edge is insufficient):
   ```powershell
   winget install --id Mozilla.Firefox
   ```

### 4.4 Install Code Editor

1. Install VS Code (or preferred editor):
   ```powershell
   winget install --id Microsoft.VisualStudioCode
   ```

### 4.5 Install KeePassXC (Password Manager)

1. Download from https://keepassxc.org/download/.
2. Install.
3. Create or restore password database: `C:\HAWKINS_OPS\secure\hawkinsops.kdbx`.

**CHECKPOINT:** Essential software installed.

---

## Phase 5: Create HAWKINS_OPS Directory Structure

### 5.1 Create Base Directory

1. Open PowerShell 7 as Administrator.
2. Create directory:
   ```powershell
   New-Item -Path "C:\HAWKINS_OPS" -ItemType Directory -Force
   ```

### 5.2 Create Subdirectories

```powershell
$dirs = @(
    "C:\HAWKINS_OPS\blueprints",
    "C:\HAWKINS_OPS\blueprints\rebuild_pack",
    "C:\HAWKINS_OPS\scripts",
    "C:\HAWKINS_OPS\scripts\automation",
    "C:\HAWKINS_OPS\scripts\hardening",
    "C:\HAWKINS_OPS\logs",
    "C:\HAWKINS_OPS\docs",
    "C:\HAWKINS_OPS\secure",
    "C:\HAWKINS_OPS\backups",
    "C:\HAWKINS_OPS\tools"
)

foreach ($dir in $dirs) {
    New-Item -Path $dir -ItemType Directory -Force
    Write-Host "Created: $dir" -ForegroundColor Green
}
```

### 5.3 Set Permissions (Restrict Access)

1. Right-click `C:\HAWKINS_OPS\secure` → Properties → Security.
2. Advanced → Disable inheritance → "Convert inherited permissions into explicit permissions".
3. Remove all users except:
   - `SYSTEM` (Full Control)
   - `Administrators` (Full Control)
   - `raylee` (Full Control)
4. Apply.

**CHECKPOINT:** `C:\HAWKINS_OPS\` directory structure created, secure folder protected.

---

## Phase 6: Domain Join

### 6.1 Verify Domain Connectivity

1. Open Command Prompt or PowerShell.
2. Test DNS resolution:
   ```cmd
   nslookup hawkinsops.local
   nslookup dc01.hawkinsops.local
   ```
   - Both should resolve to `192.168.50.20`.
3. Test connectivity:
   ```cmd
   ping dc01.hawkinsops.local
   ```
   - Should reply successfully.

### 6.2 Join Domain

1. Right-click Start → System.
2. Click "Rename this PC (advanced)".
3. Click "Change" (under "To rename this computer or change its domain...").
4. Select "Domain".
5. Enter: `hawkinsops.local`
6. Click OK.
7. Enter credentials:
   - Username: `Administrator` (or domain admin account)
   - Password: (from KeePassXC)
8. Click OK.
9. **Success message:** "Welcome to the hawkinsops.local domain".
10. Click OK.
11. Restart now: Yes.

### 6.3 Login as Domain User

1. After reboot, login screen shows "Other user".
2. Username: `HAWKINSOPS\raylee` (or `raylee@hawkinsops.local`)
3. Password: (domain user password, if created; otherwise use `HAWKINSOPS\Administrator`).

**NOTE:** If domain user `raylee` does not exist, login as `HAWKINSOPS\Administrator` and create domain user account in Active Directory.

**CHECKPOINT:** Machine domain-joined, domain user can login.

---

## Phase 7: Install Wazuh Agent

### 7.1 Download Wazuh Agent

1. Open browser, navigate to Wazuh dashboard: `https://wazuh.hawkinsops.local`.
2. Login as `admin`.
3. Navigate to Agents → Deploy new agent.
4. Select Windows.
5. Server address: `192.168.50.10` (or `wazuh.hawkinsops.local`).
6. Agent name: `win-powerhouse`.
7. Copy installation command.

**Example command:**
```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile $env:TEMP\wazuh-agent.msi
msiexec.exe /i $env:TEMP\wazuh-agent.msi /q WAZUH_MANAGER='192.168.50.10' WAZUH_AGENT_NAME='win-powerhouse'
```

### 7.2 Install Wazuh Agent

1. Open PowerShell 7 as Administrator.
2. Paste installation command.
3. Wait for installation to complete.
4. Start Wazuh service:
   ```powershell
   NET START WazuhSvc
   ```

### 7.3 Verify Agent Enrollment

1. Check agent status:
   ```powershell
   & "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -m 192.168.50.10
   ```
2. Verify logs:
   ```powershell
   Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 20
   ```
   - Should show successful connection to manager.

3. Check Wazuh dashboard:
   - Agents → Search for `win-powerhouse`.
   - Status should show "Active" (may take 1-2 minutes).

**CHECKPOINT:** Wazuh agent installed, reporting as "Active".

---

## Phase 8: Hardening and Security Configuration

### 8.1 Enable Windows Defender

1. Settings → Privacy & Security → Windows Security → Virus & threat protection.
2. Ensure Real-time protection: On.
3. Ensure Cloud-delivered protection: On.
4. Run quick scan.

### 8.2 Enable Windows Firewall

1. Control Panel → System and Security → Windows Defender Firewall.
2. Click "Turn Windows Defender Firewall on or off".
3. Enable for Domain, Private, and Public networks.
4. Click OK.

### 8.3 Configure Firewall Rules for HawkinsOps

1. Open PowerShell 7 as Administrator.
2. Allow Wazuh agent:
   ```powershell
   New-NetFirewallRule -DisplayName "Wazuh Agent" -Direction Outbound -RemoteAddress 192.168.50.10 -RemotePort 1514,1515 -Protocol TCP -Action Allow
   ```
3. Allow RDP (if remote access needed):
   ```powershell
   Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
   ```
4. Allow domain traffic:
   ```powershell
   # Domain traffic is usually auto-allowed when domain-joined
   ```

### 8.4 Disable Unnecessary Services

```powershell
$servicesToDisable = @(
    "Fax",
    "RemoteRegistry",
    "XblAuthManager",
    "XblGameSave",
    "XboxGipSvc",
    "XboxNetApiSvc"
)

foreach ($service in $servicesToDisable) {
    try {
        Set-Service -Name $service -StartupType Disabled
        Write-Host "Disabled: $service" -ForegroundColor Green
    } catch {
        Write-Host "Could not disable $service (may not exist): $_" -ForegroundColor Yellow
    }
}
```

### 8.5 Enable Audit Policies

1. Open Group Policy Editor: `gpedit.msc`
2. Computer Configuration → Windows Settings → Security Settings → Advanced Audit Policy Configuration → Audit Policies.
3. Enable the following (Success and Failure):
   - **Account Logon:**
     - Audit Credential Validation
   - **Logon/Logoff:**
     - Audit Logon
     - Audit Logoff
     - Audit Account Lockout
   - **Object Access:**
     - Audit File System (set on critical directories)
     - Audit Registry (set on critical keys)
   - **Policy Change:**
     - Audit Audit Policy Change
     - Audit Authentication Policy Change
   - **Privilege Use:**
     - Audit Sensitive Privilege Use
   - **Detailed Tracking:**
     - Audit Process Creation
   - **System:**
     - Audit Security State Change
     - Audit System Integrity

4. Apply: `gpupdate /force`

### 8.6 Enable PowerShell Logging

1. `gpedit.msc` → Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell.
2. **Turn on Module Logging:**
   - Enabled.
   - Click "Show", add `*`.
3. **Turn on PowerShell Script Block Logging:**
   - Enabled.
   - Log script block invocation start/stop events: Checked (optional, verbose).
4. **Turn on PowerShell Transcription:**
   - Enabled.
   - Transcript output directory: `C:\HAWKINS_OPS\logs\powershell_transcripts`
   - Include invocation headers: Checked.

5. Create transcript directory:
   ```powershell
   New-Item -Path "C:\HAWKINS_OPS\logs\powershell_transcripts" -ItemType Directory -Force
   ```

6. Apply: `gpupdate /force`

### 8.7 Enable Sysmon (Optional, Recommended)

1. Download Sysmon from https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon.
2. Download SwiftOnSecurity Sysmon config: https://github.com/SwiftOnSecurity/sysmon-config.
3. Install Sysmon:
   ```powershell
   .\Sysmon64.exe -accepteula -i sysmonconfig-export.xml
   ```
4. Verify:
   - Event Viewer → Applications and Services Logs → Microsoft → Windows → Sysmon → Operational.
   - Should see Sysmon events.

5. Configure Wazuh to ingest Sysmon logs:
   - Edit `C:\Program Files (x86)\ossec-agent\ossec.conf`
   - Add:
     ```xml
     <localfile>
       <location>Microsoft-Windows-Sysmon/Operational</location>
       <log_format>eventchannel</log_format>
     </localfile>
     ```
   - Restart Wazuh agent: `NET STOP WazuhSvc && NET START WazuhSvc`

**CHECKPOINT:** Hardening applied, audit logging enabled, Sysmon installed.

---

## Phase 9: Install Administrative Tools

### 9.1 Install Remote Server Administration Tools (RSAT)

1. Settings → Apps → Optional features → Add a feature.
2. Search and install:
   - RSAT: Active Directory Domain Services and Lightweight Directory Services Tools
   - RSAT: DNS Server Tools
   - RSAT: Group Policy Management Tools
3. Click Install.

**VERIFY:** Start → Windows Administrative Tools → Active Directory Users and Computers (should open).

### 9.2 Install Sysinternals Suite

1. Download Sysinternals Suite from https://docs.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite.
2. Extract to `C:\HAWKINS_OPS\tools\sysinternals\`.
3. Add to PATH (optional):
   ```powershell
   $env:Path += ";C:\HAWKINS_OPS\tools\sysinternals"
   [Environment]::SetEnvironmentVariable("Path", $env:Path, [EnvironmentVariableTarget]::Machine)
   ```

### 9.3 Install Additional Tools

```powershell
# Wireshark (network analysis)
winget install --id WiresharkFoundation.Wireshark

# 7-Zip (compression)
winget install --id 7zip.7zip

# Notepad++ (text editor)
winget install --id Notepad++.Notepad++
```

**CHECKPOINT:** Administrative tools installed.

---

## Phase 10: Verification and Testing

### 10.1 Verify Network Connectivity

```powershell
# Test pfSense
Test-Connection 192.168.50.1 -Count 4

# Test AD DC
Test-Connection dc01.hawkinsops.local -Count 4

# Test Wazuh
Test-Connection wazuh.hawkinsops.local -Count 4

# Test PRIMARY_OS
Test-Connection primary-os.hawkinsops.local -Count 4

# Test Internet
Test-Connection 8.8.8.8 -Count 4
```

### 10.2 Verify Domain Membership

```powershell
# Check domain membership
(Get-WmiObject -Class Win32_ComputerSystem).Domain
# Should return: hawkinsops.local

# Check domain connectivity
nltest /dsgetdc:hawkinsops.local
# Should return DC details
```

### 10.3 Verify Wazuh Agent

1. Wazuh Dashboard → Agents → `win-powerhouse`.
2. Status: Active.
3. Last keep alive: Within last 60 seconds.
4. Click agent → Security Events → Should see events flowing in.

### 10.4 Verify Services

```powershell
# Check Wazuh service
Get-Service -Name WazuhSvc
# Status should be: Running

# Check Windows Defender
Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled
# Both should be: True
```

### 10.5 Generate Test Events

1. Failed login attempt:
   - Lock screen, enter wrong password 3 times.
   - Check Wazuh Dashboard for failed authentication alerts.

2. PowerShell execution:
   - Run a benign command: `Get-Process`
   - Check Wazuh for PowerShell script block logs.

3. Process creation:
   - Open Calculator (`calc.exe`).
   - Check Wazuh for process creation event (if Sysmon installed).

**CHECKPOINT:** All tests passing, events flowing to Wazuh.

---

## Phase 11: Final Documentation

### 11.1 Document System Configuration

Create file: `C:\HAWKINS_OPS\docs\win-powerhouse-config.txt`

```
Windows Powerhouse Configuration
=================================
Hostname: WIN-POWERHOUSE
FQDN: win-powerhouse.hawkinsops.local
IP Address: 192.168.50.101/24
Gateway: 192.168.50.1
DNS: 192.168.50.20
Domain: hawkinsops.local

Installed Software:
- Windows 11 Pro (version: [run 'winver' to check])
- PowerShell 7.x
- Wazuh Agent 4.x
- Sysmon (with SwiftOnSecurity config)
- RSAT Tools
- Sysinternals Suite
- VS Code
- KeePassXC
- Wireshark
- Firefox/Chrome

Security Configurations:
- Windows Defender: Enabled
- Windows Firewall: Enabled
- Audit Policies: Configured (see gpedit.msc)
- PowerShell Logging: Enabled (module, script block, transcription)
- Sysmon: Enabled

Wazuh Agent:
- Manager: 192.168.50.10 (wazuh.hawkinsops.local)
- Agent Name: win-powerhouse
- Status: Active

Last Updated: [DATE]
```

### 11.2 Create Maintenance Checklist

Create file: `C:\HAWKINS_OPS\docs\win-powerhouse-maintenance.md`

```markdown
# Windows Powerhouse Maintenance Checklist

## Weekly
- [ ] Check Windows Update (Settings → Windows Update)
- [ ] Verify Wazuh agent status (Dashboard)
- [ ] Review Security Event Logs (Event Viewer → Security)
- [ ] Review Wazuh alerts for anomalies

## Monthly
- [ ] Update all software via winget: `winget upgrade --all`
- [ ] Backup C:\HAWKINS_OPS to external drive
- [ ] Review and prune old logs in C:\HAWKINS_OPS\logs
- [ ] Check disk space (C:\ should have >20% free)
- [ ] Test RDP connectivity (if enabled)
- [ ] Verify KeePassXC database backed up

## Quarterly
- [ ] Review installed software, remove unused applications
- [ ] Review firewall rules, remove obsolete rules
- [ ] Test disaster recovery: restore KeePassXC database from backup
- [ ] Review and update documentation in C:\HAWKINS_OPS\docs

## Annually
- [ ] Conduct full rebuild test using this runbook
- [ ] Update Windows 11 to latest feature release (if applicable)
- [ ] Review Group Policy settings, adjust as needed
```

### 11.3 Take System Snapshot (if VM)

**If this is a VM (Proxmox, VMware, Hyper-V):**
1. Shut down VM.
2. Take snapshot: "WIN-POWERHOUSE-CLEAN-POST-REBUILD-[DATE]".
3. Start VM.

**If bare metal:**
- Document current state.
- Consider disk imaging with Macrium Reflect or similar (optional).

**CHECKPOINT:** Documentation complete, system ready for production use.

---

## Troubleshooting

### Issue: Cannot join domain

**Error:** "The specified domain either does not exist or could not be contacted."

**Solution:**
1. Verify DNS is set to `192.168.50.20`.
2. Verify DC is reachable: `ping dc01.hawkinsops.local`.
3. Verify time sync: `w32tm /query /status` (time must be within 5 minutes of DC).
4. Flush DNS: `ipconfig /flushdns`, retry.

### Issue: Wazuh agent shows "Disconnected"

**Solution:**
1. Check Wazuh service: `Get-Service WazuhSvc` (should be Running).
2. Restart service: `Restart-Service WazuhSvc`.
3. Check firewall: `Test-NetConnection -ComputerName 192.168.50.10 -Port 1514`.
4. Review agent logs: `Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 50`.

### Issue: Group Policy not applying

**Solution:**
1. Force update: `gpupdate /force`.
2. Check Group Policy Results: `gpresult /r`.
3. Verify domain connectivity: `nltest /dsgetdc:hawkinsops.local`.

---

## Post-Rebuild Next Steps

1. **Create domain user account** for daily use (avoid using Administrator account).
2. **Install additional software** specific to analyst workflows (e.g., Python, Git, Docker).
3. **Configure browser security** (uBlock Origin, HTTPS Everywhere, certificate store).
4. **Setup automated backups** for `C:\HAWKINS_OPS\`.
5. **Integrate with PRIMARY_OS** for file sync between Windows and Linux environments.
6. **Test incident response workflows** (e.g., isolate endpoint, capture memory dump).

---

## Completion Checklist

- [ ] Windows 11 installed
- [ ] Static IP configured (192.168.50.101)
- [ ] Machine renamed to WIN-POWERHOUSE
- [ ] Domain-joined to hawkinsops.local
- [ ] PowerShell 7 installed
- [ ] C:\HAWKINS_OPS directory structure created
- [ ] Wazuh agent installed and Active
- [ ] Hardening applied (firewall, audit policies, PowerShell logging)
- [ ] Sysmon installed (optional but recommended)
- [ ] RSAT tools installed
- [ ] Administrative tools installed
- [ ] All verification tests passed
- [ ] Documentation created
- [ ] System snapshot/backup taken

**Rebuild Status:** ☐ Not Started | ☐ In Progress | ☐ Complete

**Completion Date:** ___________

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
