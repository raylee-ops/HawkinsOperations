# PRIMARY_OS Linux Rebuild Overview

## Purpose

This document provides a Windows-side perspective on rebuilding the PRIMARY_OS Linux Mint server. The Linux machine will have its own detailed scripts and runbooks, but this overview ensures the Windows environment understands what PRIMARY_OS must provide and how to verify integration.

**Role:** Source-of-truth server, daily driver, operations hub
**OS:** Linux Mint 21.x (Cinnamon or MATE)
**Hostname:** `primary-os.hawkinsops.local`
**IP Address:** `192.168.50.100/24`
**Primary Use:** File storage, automation scripts, development, centralized operations

**Estimated Time:** 1-2 hours (excluding updates)

---

## What PRIMARY_OS Must Provide

### 1. Core Services

PRIMARY_OS serves as the central operations hub for HawkinsOps. It must provide:

| Service | Description | Port/Protocol | Critical for: |
|---------|-------------|---------------|---------------|
| SSH Server | Remote administration | 22/TCP | Remote access from Windows Powerhouse |
| File Server (SMB) | Shared file storage | 445/TCP | Sync C:\HAWKINS_OPS with Linux /home/raylee/HAWKINS_OPS |
| NFS (optional) | Linux file sharing | 2049/TCP | Share files with other Linux endpoints |
| Automation Engine | Cron jobs, Ansible | N/A | Scheduled tasks, automated deployments |
| Development Environment | Python, Git, editors | N/A | Script development, version control |
| Wazuh Agent | Security monitoring | 1514-1515/TCP outbound | SIEM integration |
| Log Repository | Centralized log storage | N/A | Backup for critical logs |

### 2. Directory Structure

PRIMARY_OS must maintain a mirrored directory structure to Windows Powerhouse:

```
/home/raylee/HAWKINS_OPS/
├── blueprints/
│   ├── rebuild_pack/          (synced from Windows)
│   └── diagrams/
├── scripts/
│   ├── automation/
│   ├── hardening/
│   └── deployment/
├── logs/
│   ├── wazuh_backups/
│   ├── pfsense_logs/
│   └── system_logs/
├── docs/
│   ├── runbooks/
│   └── procedures/
├── secure/
│   └── credentials/           (encrypted, restricted access)
├── backups/
│   ├── configs/
│   └── databases/
└── tools/
    ├── forensics/
    └── monitoring/
```

### 3. Network Configuration

PRIMARY_OS network requirements:

- **IP Address:** `192.168.50.100/24` (static)
- **Gateway:** `192.168.50.1` (pfSense)
- **DNS:** `192.168.50.20` (AD DC), fallback `192.168.50.1`
- **Domain:** `hawkinsops.local` (DNS resolution only; domain join is optional)
- **Firewall:** UFW enabled, rules for SSH, SMB, Wazuh agent
- **Time Sync:** NTP configured (synced with DC or internet time servers)

---

## Rebuild Process Summary

### Phase 1: Linux Mint Installation

1. Boot from Linux Mint 21.x USB installer.
2. Select "Install Linux Mint".
3. Language: English.
4. Keyboard: US.
5. Install multimedia codecs: Yes.
6. Installation type: Erase disk and install (or manual partitioning if dual-boot).
7. Timezone: Select appropriate (e.g., America/Chicago).
8. User account:
   - Name: `raylee`
   - Computer name: `primary-os`
   - Username: `raylee`
   - Password: (set strong password, store in KeePassXC)
   - Require password to login: Yes.
9. Install.
10. Reboot, remove installation media.

**CHECKPOINT:** Linux Mint desktop loads, user `raylee` logged in.

### Phase 2: Initial Configuration

1. **Update System:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   sudo reboot
   ```

2. **Configure Static IP:**
   - Open Network Manager (system tray → network icon → Edit Connections).
   - Select wired connection → Edit.
   - IPv4 Settings → Method: Manual.
   - Address: `192.168.50.100`
   - Netmask: `255.255.255.0` (or /24)
   - Gateway: `192.168.50.1`
   - DNS: `192.168.50.20, 192.168.50.1`
   - Save, reconnect.

3. **Verify Connectivity:**
   ```bash
   ping -c 4 192.168.50.1        # pfSense
   ping -c 4 dc01.hawkinsops.local   # AD DC
   ping -c 4 wazuh.hawkinsops.local  # Wazuh
   ping -c 4 8.8.8.8             # Internet
   ```

4. **Set Hostname:**
   ```bash
   sudo hostnamectl set-hostname primary-os
   sudo nano /etc/hosts
   # Add: 192.168.50.100 primary-os.hawkinsops.local primary-os
   ```

**CHECKPOINT:** Network configured, hostname set, connectivity verified.

### Phase 3: Install Essential Packages

```bash
sudo apt install -y \
    openssh-server \
    samba \
    nfs-kernel-server \
    git \
    python3 \
    python3-pip \
    ansible \
    vim \
    htop \
    net-tools \
    nmap \
    curl \
    wget \
    ufw \
    auditd \
    fail2ban \
    keepassxc \
    remmina \
    wireshark
```

**CHECKPOINT:** Essential packages installed.

### Phase 4: Configure SSH Server

1. **Enable and start SSH:**
   ```bash
   sudo systemctl enable ssh
   sudo systemctl start ssh
   ```

2. **Harden SSH:**
   ```bash
   sudo nano /etc/ssh/sshd_config
   ```
   - Set:
     ```
     PermitRootLogin no
     PasswordAuthentication yes  # Change to 'no' after SSH key setup
     PubkeyAuthentication yes
     Protocol 2
     ```
   - Restart SSH:
     ```bash
     sudo systemctl restart ssh
     ```

3. **Setup SSH keys (optional but recommended):**
   - On Windows Powerhouse, generate SSH key:
     ```powershell
     ssh-keygen -t ed25519 -C "raylee@win-powerhouse"
     ```
   - Copy public key to PRIMARY_OS:
     ```powershell
     type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh raylee@192.168.50.100 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
     ```
   - Test: `ssh raylee@192.168.50.100` (should connect without password).

**CHECKPOINT:** SSH accessible from Windows Powerhouse.

### Phase 5: Configure Samba File Sharing

1. **Install Samba:**
   ```bash
   sudo apt install samba -y
   ```

2. **Create Samba share for HAWKINS_OPS:**
   ```bash
   sudo nano /etc/samba/smb.conf
   ```
   - Add at end:
     ```ini
     [HAWKINS_OPS]
     path = /home/raylee/HAWKINS_OPS
     browseable = yes
     read only = no
     valid users = raylee
     create mask = 0755
     directory mask = 0755
     ```

3. **Set Samba password:**
   ```bash
   sudo smbpasswd -a raylee
   ```

4. **Restart Samba:**
   ```bash
   sudo systemctl restart smbd
   sudo systemctl enable smbd
   ```

5. **Test from Windows Powerhouse:**
   - File Explorer → `\\192.168.50.100\HAWKINS_OPS`
   - Enter credentials: `raylee` / (Samba password)
   - Should access shared folder.

**CHECKPOINT:** Samba share accessible from Windows.

### Phase 6: Create Directory Structure

```bash
mkdir -p ~/HAWKINS_OPS/{blueprints/{rebuild_pack,diagrams},scripts/{automation,hardening,deployment},logs/{wazuh_backups,pfsense_logs,system_logs},docs/{runbooks,procedures},secure/credentials,backups/{configs,databases},tools/{forensics,monitoring}}
```

**CHECKPOINT:** Directory structure created.

### Phase 7: Install Wazuh Agent

1. **Add Wazuh repository:**
   ```bash
   curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import
   sudo chmod 644 /usr/share/keyrings/wazuh.gpg
   echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee -a /etc/apt/sources.list.d/wazuh.list
   sudo apt update
   ```

2. **Install Wazuh agent:**
   ```bash
   sudo apt install wazuh-agent -y
   ```

3. **Configure Wazuh manager:**
   ```bash
   sudo nano /var/ossec/etc/ossec.conf
   ```
   - Set:
     ```xml
     <address>192.168.50.10</address>
     ```

4. **Start Wazuh agent:**
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable wazuh-agent
   sudo systemctl start wazuh-agent
   ```

5. **Verify status:**
   ```bash
   sudo systemctl status wazuh-agent
   ```

**CHECKPOINT:** Wazuh agent installed and running.

### Phase 8: Hardening

1. **Configure UFW firewall:**
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow samba
   sudo ufw allow from 192.168.50.0/24 to any port 22      # SSH from lab network only
   sudo ufw allow from 192.168.50.10 to any port 1514      # Wazuh agent
   sudo ufw enable
   ```

2. **Enable auditd:**
   ```bash
   sudo systemctl enable auditd
   sudo systemctl start auditd
   ```

3. **Configure fail2ban:**
   ```bash
   sudo systemctl enable fail2ban
   sudo systemctl start fail2ban
   ```

4. **Disable unnecessary services:**
   ```bash
   sudo systemctl disable bluetooth.service
   sudo systemctl disable cups.service  # If no printing
   ```

5. **Set automatic security updates:**
   ```bash
   sudo apt install unattended-upgrades -y
   sudo dpkg-reconfigure -plow unattended-upgrades
   # Select "Yes" to enable automatic updates
   ```

**CHECKPOINT:** Hardening applied.

---

## Integration with Windows Powerhouse

### File Sync Strategy

**Option 1: Manual Sync (Simple)**
- Periodically copy files from `C:\HAWKINS_OPS\` to `\\192.168.50.100\HAWKINS_OPS` via File Explorer.

**Option 2: Robocopy Script (Automated)**
- Create PowerShell script on Windows Powerhouse:
  ```powershell
  # C:\HAWKINS_OPS\scripts\sync_to_primary_os.ps1
  $source = "C:\HAWKINS_OPS\"
  $destination = "\\192.168.50.100\HAWKINS_OPS\"
  robocopy $source $destination /MIR /Z /R:3 /W:5 /LOG:C:\HAWKINS_OPS\logs\sync.log
  ```
- Run manually or schedule via Task Scheduler.

**Option 3: Sync Tool (e.g., FreeFileSync)**
- Install FreeFileSync on Windows Powerhouse.
- Configure sync profile between `C:\HAWKINS_OPS\` and `\\192.168.50.100\HAWKINS_OPS`.

### SSH Access from Windows

1. Windows 11 includes OpenSSH client by default.
2. Connect:
   ```powershell
   ssh raylee@192.168.50.100
   # or
   ssh raylee@primary-os.hawkinsops.local
   ```
3. Configure SSH config for convenience:
   - File: `C:\Users\raylee\.ssh\config`
   - Content:
     ```
     Host primary-os
         HostName 192.168.50.100
         User raylee
         IdentityFile C:\Users\raylee\.ssh\id_ed25519
     ```
   - Connect: `ssh primary-os`

### Remote Desktop (optional)

If GUI access needed from Windows:

1. **Install xrdp on PRIMARY_OS:**
   ```bash
   sudo apt install xrdp -y
   sudo systemctl enable xrdp
   sudo systemctl start xrdp
   sudo ufw allow 3389/tcp
   ```

2. **Connect from Windows:**
   - Remote Desktop Connection (mstsc.exe)
   - Computer: `192.168.50.100`
   - Username: `raylee`
   - Password: (Linux password)

---

## Verification from Windows Powerhouse

### 1. Network Connectivity

```powershell
# Ping PRIMARY_OS
Test-Connection primary-os.hawkinsops.local -Count 4

# SSH test
ssh raylee@primary-os.hawkinsops.local "hostname && uptime"
```

### 2. File Share Access

```powershell
# Map network drive (PowerShell)
New-PSDrive -Name "P" -PSProvider FileSystem -Root "\\192.168.50.100\HAWKINS_OPS" -Persist

# Verify access
Test-Path P:\
Get-ChildItem P:\
```

### 3. Wazuh Agent Status

1. Wazuh Dashboard → Agents.
2. Search for `primary-os`.
3. Status: Active.
4. Last keep alive: Within last 60 seconds.

### 4. Service Health Checks

```bash
# Run from Windows PowerShell via SSH
ssh raylee@primary-os.hawkinsops.local "systemctl is-active ssh"
ssh raylee@primary-os.hawkinsops.local "systemctl is-active smbd"
ssh raylee@primary-os.hawkinsops.local "systemctl is-active wazuh-agent"
ssh raylee@primary-os.hawkinsops.local "systemctl is-active ufw"
```

All should return: `active`

---

## What PRIMARY_OS is NOT

**PRIMARY_OS is NOT:**
- A domain controller (that's DC01).
- A SIEM (that's Wazuh Manager).
- A router/firewall (that's pfSense).
- A Windows machine (it's Linux Mint).

**PRIMARY_OS IS:**
- A Linux server for operations and automation.
- A file repository mirroring Windows Powerhouse.
- A development environment for scripts and tools.
- A monitored endpoint for Wazuh SIEM.

---

## Maintenance Tasks

### Daily
- Check Wazuh agent status in dashboard.

### Weekly
- Update packages: `sudo apt update && sudo apt upgrade -y`
- Review SSH login logs: `sudo journalctl -u ssh -f`
- Check disk space: `df -h`

### Monthly
- Backup `/home/raylee/HAWKINS_OPS/` to external drive.
- Review UFW firewall logs: `sudo ufw status verbose`
- Check for failed login attempts: `sudo cat /var/log/auth.log | grep 'Failed password'`

### Quarterly
- Review and prune old logs in `~/HAWKINS_OPS/logs/`.
- Test disaster recovery: restore from backup.

---

## Troubleshooting

### Issue: Cannot SSH from Windows

**Solution:**
1. Verify SSH service running: `sudo systemctl status ssh`
2. Check UFW: `sudo ufw status` (port 22 should be allowed)
3. Test from PRIMARY_OS itself: `ssh localhost`
4. Check Windows SSH client: `ssh -v raylee@192.168.50.100` (verbose output)

### Issue: Cannot access Samba share

**Solution:**
1. Verify Samba running: `sudo systemctl status smbd`
2. Check Samba user: `sudo pdbedit -L` (should list `raylee`)
3. Test locally: `smbclient -L localhost -U raylee`
4. Check firewall: `sudo ufw status | grep 445`
5. From Windows: Test connectivity: `Test-NetConnection -ComputerName 192.168.50.100 -Port 445`

### Issue: Wazuh agent disconnected

**Solution:**
1. Check agent status: `sudo systemctl status wazuh-agent`
2. Restart agent: `sudo systemctl restart wazuh-agent`
3. Check logs: `sudo tail -f /var/ossec/logs/ossec.log`
4. Verify manager IP: `sudo grep '<address>' /var/ossec/etc/ossec.conf`

---

## Linux-Specific Scripts and Automation

PRIMARY_OS will host automation scripts for:
- Automated Wazuh rule deployment
- Log rotation and archival
- Backup automation (configs, databases)
- Security baseline checks
- Ansible playbooks for endpoint configuration

**These scripts are managed on the Linux side** and stored in `/home/raylee/HAWKINS_OPS/scripts/automation/`.

**Windows Powerhouse can:**
- Trigger scripts via SSH: `ssh primary-os "bash ~/HAWKINS_OPS/scripts/automation/deploy_wazuh_rules.sh"`
- Copy scripts for reference (but execution is Linux-side).

---

## Completion Checklist (Windows Perspective)

From Windows Powerhouse, verify:

- [ ] Can ping `primary-os.hawkinsops.local`
- [ ] Can SSH to PRIMARY_OS without errors
- [ ] Can access `\\192.168.50.100\HAWKINS_OPS` via File Explorer
- [ ] Wazuh Dashboard shows `primary-os` agent as "Active"
- [ ] DNS resolves `primary-os.hawkinsops.local` to `192.168.50.100`
- [ ] Time sync verified (within 5 minutes of DC)
- [ ] File sync working (test by creating file on Windows, verify appears on Linux share)

**PRIMARY_OS Rebuild Status (from Windows view):** ☐ Not Started | ☐ In Progress | ☐ Integrated and Verified

---

## Next Steps After PRIMARY_OS Rebuild

1. **Setup automated backup script** on PRIMARY_OS for HawkinsOps configs.
2. **Install Ansible** and create playbooks for endpoint configuration.
3. **Configure log aggregation** from pfSense and other devices to PRIMARY_OS.
4. **Setup Git repository** in `~/HAWKINS_OPS/` for version control of scripts and docs.
5. **Document PRIMARY_OS-specific procedures** in detail (Linux-side runbook, not Windows-side overview).

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
**Perspective:** Windows-side view of PRIMARY_OS Linux rebuild requirements
