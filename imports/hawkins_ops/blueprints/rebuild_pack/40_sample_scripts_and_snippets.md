# HawkinsOps Sample Scripts and Snippets

## Purpose

This file contains script snippets and command examples for common HawkinsOps operations. These are **examples stored in Markdown format** for reference. The Linux machines will have their own executable scripts in appropriate directories.

**Use these snippets for:**
- Quick copy-paste during rebuild operations
- Reference for creating full scripts
- Training and documentation

---

## Windows PowerShell Scripts

### 1. Wazuh Agent Installation (Windows)

```powershell
# Download and install Wazuh agent on Windows
# Run as Administrator

$WAZUH_MANAGER = "192.168.50.10"  # or wazuh.hawkinsops.local
$AGENT_NAME = "win-powerhouse"    # Change per host

# Download agent
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.7.0-1.msi -OutFile $env:TEMP\wazuh-agent.msi

# Install silently
msiexec.exe /i $env:TEMP\wazuh-agent.msi /q WAZUH_MANAGER="$WAZUH_MANAGER" WAZUH_AGENT_NAME="$AGENT_NAME"

# Start service
NET START WazuhSvc

# Verify
Get-Service WazuhSvc
Get-Content "C:\Program Files (x86)\ossec-agent\ossec.log" -Tail 20

Write-Host "Wazuh agent installed. Verify in dashboard." -ForegroundColor Green
```

### 2. Enable PowerShell Logging

```powershell
# Enable comprehensive PowerShell logging
# Run as Administrator

# Create transcript directory
New-Item -Path "C:\HAWKINS_OPS\logs\powershell_transcripts" -ItemType Directory -Force

# Enable via Group Policy (requires gpedit.msc access)
# Computer Configuration → Administrative Templates → Windows Components → Windows PowerShell

# Or via Registry:
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging" -Name "EnableModuleLogging" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging" -Name "EnableScriptBlockLogging" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "EnableTranscripting" -Value 1 -PropertyType DWord -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription" -Name "OutputDirectory" -Value "C:\HAWKINS_OPS\logs\powershell_transcripts" -PropertyType String -Force

# Restart PowerShell to apply
Write-Host "PowerShell logging enabled. Restart PowerShell." -ForegroundColor Green
```

### 3. Enable Windows Audit Policies

```powershell
# Configure audit policies for security monitoring
# Run as Administrator

# Process Creation
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable

# Logon/Logoff
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Logoff" /success:enable /failure:enable
auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable

# Object Access (File System)
auditpol /set /subcategory:"File System" /success:enable /failure:enable

# Policy Change
auditpol /set /subcategory:"Audit Policy Change" /success:enable /failure:enable
auditpol /set /subcategory:"Authentication Policy Change" /success:enable /failure:enable

# Privilege Use
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable

# Verify
auditpol /get /category:*

Write-Host "Audit policies configured." -ForegroundColor Green
```

### 4. Domain Join Script

```powershell
# Join Windows machine to hawkinsops.local domain
# Run as Administrator

$domain = "hawkinsops.local"
$user = "HAWKINSOPS\Administrator"
$password = Read-Host "Enter domain admin password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($user, $password)

# Join domain
Add-Computer -DomainName $domain -Credential $credential -Restart

# After reboot, verify:
# (Get-WmiObject Win32_ComputerSystem).Domain
```

### 5. Network Configuration (Static IP)

```powershell
# Set static IP address on Windows
# Run as Administrator

$InterfaceAlias = "Ethernet"  # Change to your adapter name (Get-NetAdapter to list)
$IPAddress = "192.168.50.101"
$PrefixLength = 24
$Gateway = "192.168.50.1"
$DNS = @("192.168.50.20", "192.168.50.1")

# Remove existing IP
Remove-NetIPAddress -InterfaceAlias $InterfaceAlias -Confirm:$false -ErrorAction SilentlyContinue
Remove-NetRoute -InterfaceAlias $InterfaceAlias -Confirm:$false -ErrorAction SilentlyContinue

# Set new IP
New-NetIPAddress -InterfaceAlias $InterfaceAlias -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway

# Set DNS
Set-DnsClientServerAddress -InterfaceAlias $InterfaceAlias -ServerAddresses $DNS

# Verify
Get-NetIPAddress -InterfaceAlias $InterfaceAlias
Get-DnsClientServerAddress -InterfaceAlias $InterfaceAlias

Write-Host "Network configured. Test with: Test-NetConnection 192.168.50.1" -ForegroundColor Green
```

### 6. Install Sysmon

```powershell
# Download and install Sysmon with SwiftOnSecurity config
# Run as Administrator

# Download Sysmon
Invoke-WebRequest -Uri https://download.sysinternals.com/files/Sysmon.zip -OutFile $env:TEMP\Sysmon.zip
Expand-Archive -Path $env:TEMP\Sysmon.zip -DestinationPath $env:TEMP\Sysmon -Force

# Download SwiftOnSecurity config
Invoke-WebRequest -Uri https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml -OutFile $env:TEMP\sysmonconfig.xml

# Install Sysmon
& "$env:TEMP\Sysmon\Sysmon64.exe" -accepteula -i $env:TEMP\sysmonconfig.xml

# Verify
Get-Service Sysmon64
Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" -MaxEvents 10

Write-Host "Sysmon installed. Configure Wazuh to ingest Sysmon logs." -ForegroundColor Green
```

### 7. Firewall Rules for Wazuh Agent

```powershell
# Allow Wazuh agent outbound traffic
# Run as Administrator

New-NetFirewallRule -DisplayName "Wazuh Agent - Outbound to Manager" `
    -Direction Outbound `
    -RemoteAddress 192.168.50.10 `
    -RemotePort 1514,1515 `
    -Protocol TCP `
    -Action Allow

Write-Host "Firewall rule created for Wazuh agent." -ForegroundColor Green
```

### 8. Sync Files to PRIMARY_OS

```powershell
# Robocopy script to sync C:\HAWKINS_OPS to PRIMARY_OS
# Run as regular user (ensure network share is accessible)

$source = "C:\HAWKINS_OPS\"
$destination = "\\192.168.50.100\HAWKINS_OPS\"
$logFile = "C:\HAWKINS_OPS\logs\sync_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Mirror sync (be careful - this deletes files in destination not in source)
robocopy $source $destination /MIR /Z /R:3 /W:5 /LOG:$logFile /NP /NDL

Write-Host "Sync complete. Log: $logFile" -ForegroundColor Green
```

### 9. Check Wazuh Agents (from Manager)

```powershell
# Query Wazuh API for agent status
# Requires Wazuh API credentials

$WAZUH_API = "https://192.168.50.10:55000"
$USERNAME = "wazuh"
$PASSWORD = "YourPasswordHere"

# Authenticate
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($USERNAME):$($PASSWORD)"))
$headers = @{
    Authorization = "Basic $base64Auth"
}

# Get agents
$response = Invoke-RestMethod -Uri "$WAZUH_API/agents?pretty=true" -Method Get -Headers $headers -SkipCertificateCheck

$response.data.affected_items | Select-Object id, name, ip, status | Format-Table

Write-Host "Agent status retrieved." -ForegroundColor Green
```

---

## Linux Bash Scripts

### 10. Wazuh Agent Installation (Ubuntu/Debian)

```bash
#!/bin/bash
# Install Wazuh agent on Ubuntu/Debian Linux

WAZUH_MANAGER="192.168.50.10"
AGENT_NAME="primary-os"  # Change per host

# Add Wazuh repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
sudo chmod 644 /usr/share/keyrings/wazuh.gpg
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list

# Update and install
sudo apt update
sudo apt install wazuh-agent -y

# Configure manager
sudo sed -i "s/<address>.*<\/address>/<address>$WAZUH_MANAGER<\/address>/" /var/ossec/etc/ossec.conf

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Verify
sudo systemctl status wazuh-agent

echo "Wazuh agent installed. Verify in dashboard."
```

### 11. Configure Static IP (Linux Mint / Ubuntu with NetworkManager)

```bash
#!/bin/bash
# Configure static IP via nmcli (NetworkManager)

INTERFACE="Wired connection 1"  # Change to your connection name (nmcli con show)
IP_ADDRESS="192.168.50.100"
GATEWAY="192.168.50.1"
DNS="192.168.50.20 192.168.50.1"

# Set static IP
sudo nmcli con mod "$INTERFACE" ipv4.addresses "$IP_ADDRESS/24"
sudo nmcli con mod "$INTERFACE" ipv4.gateway "$GATEWAY"
sudo nmcli con mod "$INTERFACE" ipv4.dns "$DNS"
sudo nmcli con mod "$INTERFACE" ipv4.method manual

# Restart connection
sudo nmcli con down "$INTERFACE"
sudo nmcli con up "$INTERFACE"

# Verify
ip addr show
ip route
cat /etc/resolv.conf

echo "Static IP configured."
```

### 12. Harden SSH

```bash
#!/bin/bash
# Harden SSH configuration

SSHD_CONFIG="/etc/ssh/sshd_config"

# Backup original config
sudo cp $SSHD_CONFIG ${SSHD_CONFIG}.bak

# Apply hardening
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' $SSHD_CONFIG
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' $SSHD_CONFIG  # Change to 'no' after SSH key setup
sudo sed -i 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' $SSHD_CONFIG
sudo sed -i 's/^#\?Protocol.*/Protocol 2/' $SSHD_CONFIG

# Restart SSH
sudo systemctl restart ssh

echo "SSH hardened. Test login before closing this session!"
```

### 13. Configure UFW Firewall

```bash
#!/bin/bash
# Configure UFW firewall for HawkinsOps

# Reset UFW (careful - this clears all rules)
sudo ufw --force reset

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH from lab network only
sudo ufw allow from 192.168.50.0/24 to any port 22 proto tcp

# Allow Samba (if file server)
sudo ufw allow samba

# Allow Wazuh agent to manager
sudo ufw allow out to 192.168.50.10 port 1514 proto tcp
sudo ufw allow out to 192.168.50.10 port 1515 proto tcp

# Enable firewall
sudo ufw --force enable

# Verify
sudo ufw status verbose

echo "UFW configured."
```

### 14. Setup Samba Share

```bash
#!/bin/bash
# Configure Samba share for HAWKINS_OPS directory

SHARE_PATH="/home/raylee/HAWKINS_OPS"
SHARE_NAME="HAWKINS_OPS"
SAMBA_USER="raylee"

# Install Samba
sudo apt install samba -y

# Create directory if not exists
mkdir -p $SHARE_PATH

# Backup smb.conf
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

# Add share configuration
cat << EOF | sudo tee -a /etc/samba/smb.conf

[$SHARE_NAME]
path = $SHARE_PATH
browseable = yes
read only = no
valid users = $SAMBA_USER
create mask = 0755
directory mask = 0755
EOF

# Set Samba password
echo "Set Samba password for user $SAMBA_USER:"
sudo smbpasswd -a $SAMBA_USER

# Restart Samba
sudo systemctl restart smbd
sudo systemctl enable smbd

# Verify
testparm -s

echo "Samba share configured. Access from Windows: \\\\$(hostname -I | awk '{print $1}')\\$SHARE_NAME"
```

### 15. Install and Configure Auditd

```bash
#!/bin/bash
# Install and configure auditd for enhanced logging

# Install
sudo apt install auditd audispd-plugins -y

# Enable and start
sudo systemctl enable auditd
sudo systemctl start auditd

# Add basic audit rules (monitor sensitive files)
sudo tee -a /etc/audit/rules.d/hawkinsops.rules > /dev/null << 'EOF'
# Monitor authentication files
-w /etc/passwd -p wa -k passwd_changes
-w /etc/group -p wa -k group_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes

# Monitor SSH
-w /etc/ssh/sshd_config -p wa -k sshd_config_changes

# Monitor cron
-w /etc/crontab -p wa -k crontab_changes

# Monitor system calls (execve for process execution)
-a always,exit -F arch=b64 -S execve -k process_execution
EOF

# Load rules
sudo augenrules --load

# Verify
sudo auditctl -l

echo "Auditd configured."
```

### 16. Join Linux to Active Directory (Optional)

```bash
#!/bin/bash
# Join Linux machine to Active Directory domain using realmd

DOMAIN="hawkinsops.local"
DOMAIN_ADMIN="Administrator"

# Install required packages
sudo apt install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin -y

# Discover domain
sudo realm discover $DOMAIN

# Join domain (will prompt for password)
echo "Enter password for $DOMAIN_ADMIN@$DOMAIN:"
sudo realm join --user=$DOMAIN_ADMIN $DOMAIN

# Verify
realm list
id $DOMAIN_ADMIN@$DOMAIN

# Allow all domain users to login (optional, adjust as needed)
sudo realm permit --all

echo "Domain join complete. Test with: su - $DOMAIN_ADMIN@$DOMAIN"
```

### 17. Backup HawkinsOps Configs

```bash
#!/bin/bash
# Backup critical HawkinsOps configuration files

BACKUP_DIR="/home/raylee/HAWKINS_OPS/backups/configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/hawkinsops_backup_$TIMESTAMP.tar.gz"

mkdir -p $BACKUP_DIR

# Create backup archive
tar -czf $BACKUP_FILE \
    /var/ossec/etc/ossec.conf \
    /etc/ssh/sshd_config \
    /etc/samba/smb.conf \
    /etc/ufw/ufw.conf \
    /home/raylee/.ssh/authorized_keys \
    2>/dev/null

echo "Backup created: $BACKUP_FILE"

# Optional: Copy to external drive or remote location
# rsync -avz $BACKUP_FILE /mnt/external_backup/

# Cleanup old backups (keep last 10)
ls -t $BACKUP_DIR/hawkinsops_backup_*.tar.gz | tail -n +11 | xargs -r rm

echo "Backup complete."
```

### 18. Health Check Script (Linux)

```bash
#!/bin/bash
# HawkinsOps health check for Linux hosts

echo "=== HawkinsOps Linux Health Check ==="
echo ""

# Check critical services
services=("ssh" "wazuh-agent" "ufw" "auditd")
echo "[1] Service Status:"
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "  [OK] $service is running"
    else
        echo "  [FAIL] $service is NOT running"
    fi
done

echo ""
echo "[2] Network Connectivity:"
hosts=("192.168.50.1:pfSense" "192.168.50.10:Wazuh" "192.168.50.20:DC01")
for host in "${hosts[@]}"; do
    ip="${host%%:*}"
    name="${host##*:}"
    if ping -c 2 -W 2 "$ip" > /dev/null 2>&1; then
        echo "  [OK] Can reach $name ($ip)"
    else
        echo "  [FAIL] Cannot reach $name ($ip)"
    fi
done

echo ""
echo "[3] Disk Space:"
df -h / | tail -1

echo ""
echo "[4] Wazuh Agent:"
if systemctl is-active --quiet wazuh-agent; then
    echo "  [OK] Wazuh agent running"
    echo "  Last log entries:"
    sudo tail -n 5 /var/ossec/logs/ossec.log | sed 's/^/    /'
else
    echo "  [FAIL] Wazuh agent not running"
fi

echo ""
echo "=== Health Check Complete ==="
```

---

## Wazuh Configuration Snippets

### 19. Wazuh Agent Config - Enable Sysmon Ingestion (Windows)

```xml
<!-- Add to C:\Program Files (x86)\ossec-agent\ossec.conf -->
<!-- Inside <ossec_config> block -->

<localfile>
  <location>Microsoft-Windows-Sysmon/Operational</location>
  <log_format>eventchannel</log_format>
</localfile>
```

### 20. Wazuh Agent Config - Monitor Custom Log File (Linux)

```xml
<!-- Add to /var/ossec/etc/ossec.conf -->
<!-- Inside <ossec_config> block -->

<localfile>
  <log_format>syslog</log_format>
  <location>/var/log/custom_app.log</location>
</localfile>
```

### 21. Wazuh Manager - Custom Detection Rule

```xml
<!-- Add to /var/ossec/etc/rules/local_rules.xml on Wazuh Manager -->

<group name="local,">
  <!-- Detect 5 failed SSH logins within 120 seconds -->
  <rule id="100100" level="10" frequency="5" timeframe="120">
    <if_matched_sid>5710</if_matched_sid>
    <description>Multiple failed SSH login attempts (possible brute force)</description>
    <mitre>
      <id>T1110.001</id>
    </mitre>
  </rule>

  <!-- Detect suspicious PowerShell execution -->
  <rule id="100101" level="7">
    <if_sid>91816</if_sid>
    <field name="win.eventdata.commandLine">\.downloadstring|iex|invoke-expression|bypass</field>
    <description>Suspicious PowerShell command detected</description>
    <mitre>
      <id>T1059.001</id>
    </mitre>
  </rule>
</group>
```

---

## pfSense Configuration Snippets

### 22. pfSense Firewall Rule (via SSH/Console)

```bash
# pfSense uses a web UI for firewall rules, but rules can be viewed via pfctl

# View current firewall rules
pfctl -sr

# View blocked connections
pfctl -ss | grep BLOCK

# Flush all states (use with caution)
pfctl -F states

# Note: Prefer using web UI for rule creation/modification
```

### 23. pfSense Backup via Command Line

```bash
# SSH to pfSense, then download config backup via SCP

# On pfSense console/SSH:
# Config is stored in /cf/conf/config.xml

# From Windows Powerhouse (download via SCP):
scp admin@192.168.50.1:/cf/conf/config.xml C:\HAWKINS_OPS\backups\configs\pfsense_config_$(Get-Date -Format 'yyyyMMdd').xml

# Or use web UI: Diagnostics → Backup & Restore → Download configuration as XML
```

---

## Active Directory / Domain Controller Snippets

### 24. Create Domain User (PowerShell on DC)

```powershell
# Create new domain user
# Run on DC01

$UserName = "raylee"
$Password = ConvertTo-SecureString "SecurePassword123!" -AsPlainText -Force

New-ADUser -Name "$UserName" `
    -SamAccountName $UserName `
    -UserPrincipalName "$UserName@hawkinsops.local" `
    -AccountPassword $Password `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -ChangePasswordAtLogon $false

# Add to Domain Admins (optional, use sparingly)
Add-ADGroupMember -Identity "Domain Admins" -Members $UserName

Write-Host "User $UserName created." -ForegroundColor Green
```

### 25. Force Group Policy Update (All Domain Machines)

```powershell
# Run on DC01 to push GPO update to all machines

# Using PowerShell
Invoke-GPUpdate -Computer "win-powerhouse" -Force
Invoke-GPUpdate -Computer "win-endpoint-01" -Force

# Or use gpupdate on individual machines
# On client: gpupdate /force
```

### 26. Export AD Users List

```powershell
# Export list of all domain users
# Run on DC01

Get-ADUser -Filter * -Properties DisplayName, EmailAddress, LastLogonDate |
    Select-Object Name, SamAccountName, EmailAddress, LastLogonDate |
    Export-Csv -Path C:\HAWKINS_OPS\backups\AD_Users_Export_$(Get-Date -Format 'yyyyMMdd').csv -NoTypeInformation

Write-Host "AD users exported." -ForegroundColor Green
```

---

## Proxmox Management Snippets

### 27. List All VMs (Proxmox CLI)

```bash
# SSH to Proxmox host

# List all VMs
qm list

# Start VM
qm start 100  # VM ID 100 (pfSense)

# Stop VM
qm stop 100

# VM status
qm status 100
```

### 28. Create VM Snapshot

```bash
# Create snapshot of VM (for backup/rollback)
# SSH to Proxmox

VM_ID=100
SNAPSHOT_NAME="pre-update-$(date +%Y%m%d)"

qm snapshot $VM_ID $SNAPSHOT_NAME

echo "Snapshot $SNAPSHOT_NAME created for VM $VM_ID"

# List snapshots
qm listsnapshot $VM_ID

# Rollback to snapshot
# qm rollback $VM_ID $SNAPSHOT_NAME
```

---

## Git / Version Control Snippets

### 29. Initialize Git Repo for HawkinsOps

```bash
# Initialize Git repository for version control of scripts/configs
# Run on PRIMARY_OS

cd /home/raylee/HAWKINS_OPS

# Initialize repo
git init

# Create .gitignore
cat << 'EOF' > .gitignore
# Ignore sensitive files
secure/
*.kdbx
*.key
*.pem
*.log
backups/
EOF

# Initial commit
git add .
git commit -m "Initial commit - HawkinsOps rebuild pack"

echo "Git repository initialized."
```

### 30. Git Commit and Push (Example Workflow)

```bash
# After making changes to scripts/docs

cd /home/raylee/HAWKINS_OPS

git add .
git commit -m "Updated Wazuh detection rules"

# If remote repo exists (GitHub, GitLab, etc.):
# git push origin main

echo "Changes committed."
```

---

## Miscellaneous Snippets

### 31. Test Network Connectivity (Cross-Platform)

**Windows:**
```powershell
Test-Connection -ComputerName 192.168.50.10 -Count 4
Test-NetConnection -ComputerName wazuh.hawkinsops.local -Port 443
```

**Linux:**
```bash
ping -c 4 192.168.50.10
nc -zv wazuh.hawkinsops.local 443
```

### 32. DNS Lookup (Cross-Platform)

**Windows:**
```powershell
nslookup hawkinsops.local 192.168.50.20
Resolve-DnsName -Name wazuh.hawkinsops.local
```

**Linux:**
```bash
nslookup hawkinsops.local 192.168.50.20
dig @192.168.50.20 hawkinsops.local
host wazuh.hawkinsops.local 192.168.50.20
```

### 33. Check Open Ports (Cross-Platform)

**Windows:**
```powershell
# Check listening ports
Get-NetTCPConnection -State Listen | Select-Object LocalAddress, LocalPort, OwningProcess | Sort-Object LocalPort
```

**Linux:**
```bash
# Check listening ports
sudo netstat -tulpn | grep LISTEN
sudo ss -tulpn | grep LISTEN
```

### 34. Time Sync Verification

**Windows:**
```powershell
w32tm /query /status
w32tm /resync
```

**Linux:**
```bash
timedatectl status
sudo ntpdate -q 192.168.50.20  # Query only (no sync)
sudo ntpdate 192.168.50.20     # Force sync
```

---

## Usage Notes

**These snippets are EXAMPLES.**
- Always test in a safe environment before running in production.
- Adjust IP addresses, hostnames, and paths to match your environment.
- Store executable versions of these scripts in appropriate directories:
  - Windows: `C:\HAWKINS_OPS\scripts\`
  - Linux: `/home/raylee/HAWKINS_OPS/scripts/`

**For production scripts:**
- Add error handling (`try/catch` in PowerShell, `set -e` in Bash).
- Add logging to files.
- Add input validation.
- Test thoroughly before deploying.

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
