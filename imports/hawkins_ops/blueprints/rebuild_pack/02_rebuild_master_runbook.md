# HawkinsOps Master Rebuild Runbook

## Purpose

This runbook guides complete reconstruction of HawkinsOps from bare metal after catastrophic failure. Follow steps in exact order. Do not skip steps.

**Estimated Time:** 8-12 hours (depends on download speeds and experience level)

**When to Use:**
- Total infrastructure loss (fire, flood, hardware failure)
- Complete lab relocation
- Major version upgrades requiring clean slate
- Annual "chaos day" rebuild for practice

---

## Pre-Requisites

### Hardware Required

1. **Windows 11 Powerhouse**
   - Minimum: 16GB RAM, 500GB SSD, modern CPU (6+ cores)
   - Network: Gigabit Ethernet connection
   - Peripherals: Monitor, keyboard, mouse

2. **Proxmox Host**
   - Minimum: 32GB RAM, 500GB SSD (1TB preferred), CPU with virtualization extensions (Intel VT-x / AMD-V)
   - Network: Dual NIC preferred (one for management, one for VM traffic)
   - IPMI/iLO/iDRAC access recommended

3. **PRIMARY_OS Linux Machine**
   - Minimum: 8GB RAM, 250GB SSD
   - Network: Gigabit Ethernet

4. **MINT-3 Endpoint**
   - Minimum: 4GB RAM, 100GB SSD
   - Network: Gigabit Ethernet

5. **Network Equipment**
   - Managed switch with VLAN support (or pfSense will handle VLANs in software)
   - ISP modem/router

### Software/ISO Downloads Required

Before starting, download these ISOs to a USB drive:

| Software | Version | Download Source | File Size (Approx) |
|----------|---------|-----------------|-------------------|
| Proxmox VE | 8.x latest | https://www.proxmox.com/en/downloads | 1.2 GB |
| pfSense | 2.7.x latest | https://www.pfsense.org/download/ | 800 MB |
| Windows Server 2022 | Latest | Microsoft Evaluation Center or MSDN | 5.3 GB |
| Windows 11 Pro | 23H2 or latest | https://www.microsoft.com/software-download/windows11 | 6.5 GB |
| Linux Mint | 21.x (Cinnamon or MATE) | https://linuxmint.com/download.php | 2.5 GB |
| Ubuntu Server | 22.04 LTS | https://ubuntu.com/download/server | 1.5 GB |
| Wazuh OVA (optional) | 4.x latest | https://documentation.wazuh.com/current/deployment-options/virtual-machine/virtual-machine.html | 3 GB |

**USB Drive Preparation:**
- 32GB+ USB drive formatted as exFAT or NTFS
- Folder structure: `/ISOs/proxmox/`, `/ISOs/windows/`, `/ISOs/linux/`
- Keep this USB drive in a safe location for future rebuilds

### Account Credentials Needed

Prepare these accounts BEFORE starting:

1. **Local Admin Accounts**
   - Windows local admin username/password (standardize across all Windows hosts)
   - Linux root password (standardize or use unique per-host)
   - Proxmox root password
   - pfSense admin password

2. **Domain Accounts**
   - AD Domain name: `hawkinsops.local`
   - Domain Admin username/password
   - DSRM (Directory Services Restore Mode) password for AD recovery

3. **Service Accounts**
   - Wazuh admin password
   - Wazuh API credentials (generated during install, document immediately)

4. **External Services** (if applicable)
   - Email account for alert notifications
   - Cloud backup credentials

**Store all credentials in KeePassXC database: `C:\HAWKINS_OPS\secure\hawkinsops.kdbx`**

### Network Planning

Confirm these details before starting:

- ISP-assigned WAN IP or DHCP availability
- Lab network subnet: `192.168.50.0/24` (or adjust in `assumptions.md`)
- Static IP assignments documented in `01_hawkinsops_high_level_architecture.md`
- DNS domain name: `hawkinsops.local`

---

## Rebuild Phase Overview

| Phase | Description | Estimated Time | Critical Dependencies |
|-------|-------------|----------------|----------------------|
| 1 | Proxmox installation and base configuration | 1 hour | Proxmox ISO, host hardware |
| 2 | pfSense VM deployment and network setup | 1.5 hours | Proxmox operational |
| 3 | Windows Server AD DC deployment | 1.5 hours | pfSense routing + DNS |
| 4 | Wazuh SIEM deployment | 2 hours | pfSense routing |
| 5 | Windows Powerhouse rebuild | 1 hour | Windows 11 ISO |
| 6 | PRIMARY_OS Linux rebuild | 1 hour | Linux Mint ISO |
| 7 | MINT-3 endpoint rebuild | 45 minutes | Linux Mint ISO |
| 8 | Wazuh agent deployment to all hosts | 1.5 hours | Wazuh Manager operational |
| 9 | Domain joins and AD integration | 1 hour | AD DC operational |
| 10 | Hardening and security configuration | 2 hours | All systems operational |
| 11 | Dashboard configuration and testing | 1 hour | Wazuh agents reporting |
| 12 | Verification and documentation | 45 minutes | All phases complete |

**Total: ~14 hours (with buffer)**

---

## PHASE 1: Proxmox Installation

### 1.1 Prepare Proxmox Host Hardware

1. Connect Proxmox host to network switch.
2. Insert Proxmox VE USB installer (or boot from ISO via IPMI).
3. Power on and enter BIOS/UEFI.
4. Verify virtualization extensions enabled:
   - Intel: VT-x and VT-d enabled
   - AMD: AMD-V and IOMMU enabled
5. Set boot order: USB/CD first, then primary SSD.
6. Save and reboot.

### 1.2 Install Proxmox VE

1. Boot from Proxmox installer USB.
2. Select "Install Proxmox VE (Graphical)".
3. Accept EULA.
4. **Target Disk:** Select primary SSD (all data will be erased).
5. **Location/Timezone:** Select appropriate timezone.
6. **Administrator Password:** Enter strong root password (store in KeePassXC).
7. **Management Network Configuration:**
   - Hostname: `proxmox.hawkinsops.local`
   - IP Address: `192.168.10.10/24` (Management VLAN)
   - Gateway: `192.168.10.1` (this will be pfSense management interface later)
   - DNS Server: `8.8.8.8` (temporary, will change to AD DC later)
8. Confirm installation.
9. Wait for installation to complete (~5-10 minutes).
10. Reboot and remove installation media.

**CHECKPOINT:** Proxmox boots to login prompt showing `https://192.168.10.10:8006`.

### 1.3 Initial Proxmox Configuration

1. From a workstation on the same network, browse to `https://192.168.10.10:8006`.
2. Accept SSL warning (self-signed cert).
3. Login: `root` / password set during install.
4. **Disable Enterprise Repo (if no subscription):**
   - Shell: `nano /etc/apt/sources.list.d/pve-enterprise.list`
   - Comment out the enterprise line: `# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise`
   - Add no-subscription repo: `echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-no-subscription.list`
5. Update packages:
   ```bash
   apt update && apt upgrade -y
   ```
6. Reboot if kernel updated: `reboot`
7. Create directory for ISO storage:
   - Datacenter → Storage → Add → Directory
   - ID: `iso_storage`
   - Directory: `/var/lib/vz/template/iso`
   - Content: ISO image

**CHECKPOINT:** Proxmox web UI accessible, updated, ready for VM creation.

---

## PHASE 2: pfSense VM Deployment and Network Setup

### 2.1 Upload pfSense ISO

1. In Proxmox web UI, go to `local (proxmox)` → ISO Images → Upload.
2. Select pfSense ISO from your workstation.
3. Wait for upload to complete.

### 2.2 Create pfSense VM

1. Click "Create VM" (top right).
2. **General:**
   - Node: `proxmox`
   - VM ID: `100`
   - Name: `pfSense`
3. **OS:**
   - ISO image: Select uploaded pfSense ISO
   - Guest OS Type: Other
4. **System:**
   - BIOS: Default (SeaBIOS)
   - Machine: Default (i440fx)
5. **Disks:**
   - Disk size: 32 GB
   - Bus/Device: VirtIO Block (SCSI)
6. **CPU:**
   - Sockets: 1
   - Cores: 2
7. **Memory:**
   - 2048 MB (2 GB)
8. **Network:**
   - Bridge: `vmbr0`
   - Model: VirtIO (paravirtualized)
   - **Note:** We will add a second NIC for WAN later.
9. Confirm and create VM.

### 2.3 Add WAN Network Interface

1. Select pfSense VM (ID 100) → Hardware → Add → Network Device.
2. Bridge: `vmbr0` (or separate bridge if you have dual NICs on Proxmox host).
3. Model: VirtIO.
4. Click Add.

**Result:** pfSense VM now has two network interfaces (vtnet0 = WAN, vtnet1 = LAN).

### 2.4 Install pfSense

1. Start pfSense VM.
2. Open Console (noVNC).
3. Boot pfSense installer.
4. Accept copyright notice.
5. Select "Install pfSense".
6. Keymap: Select appropriate (default: US).
7. Partitioning: Auto (UFS) - use entire disk.
8. Wait for installation (~2 minutes).
9. Select "No" for manual shell configuration.
10. Reboot.

### 2.5 Initial pfSense Configuration (Console)

1. After reboot, pfSense boots to console menu.
2. **Assign Interfaces:**
   - Option 1: Assign Interfaces
   - Should VLANs be set up now? `n` (we'll do this via web UI)
   - WAN interface: `vtnet0`
   - LAN interface: `vtnet1`
   - Confirm: `y`
3. **Set LAN IP:**
   - Option 2: Set interface(s) IP address
   - Select LAN (usually option 2)
   - IPv4 Address: `192.168.50.1`
   - Subnet mask: `24`
   - IPv4 gateway: (leave blank, press Enter)
   - IPv6: (skip, press Enter for "none")
   - Enable DHCP on LAN? `y`
   - DHCP range start: `192.168.50.200`
   - DHCP range end: `192.168.50.250`
   - Revert to HTTP as webConfigurator protocol? `n` (keep HTTPS)

**CHECKPOINT:** pfSense console shows LAN IP `192.168.50.1`. Web UI available at `https://192.168.50.1`.

### 2.6 pfSense Web UI Setup

1. From a workstation, set static IP `192.168.50.50/24` with gateway `192.168.50.1` (temporarily).
2. Browse to `https://192.168.50.1`.
3. Accept SSL warning.
4. Login: `admin` / `pfsense` (default).
5. **Setup Wizard:**
   - Hostname: `pfsense`
   - Domain: `hawkinsops.local`
   - Primary DNS: `8.8.8.8` (temporary, will change to AD DC)
   - Secondary DNS: `8.8.4.4`
   - Override DNS: Unchecked (for now)
   - Timezone: Select appropriate
   - WAN interface: Configure DHCP or Static (depending on your ISP)
   - LAN interface: Already configured (`192.168.50.1/24`)
   - **Admin password:** Change from default to strong password (store in KeePassXC)
6. Reload pfSense.
7. Login with new admin password.

**CHECKPOINT:** pfSense web UI accessible, WAN connected to internet, LAN serving `192.168.50.0/24`.

### 2.7 Configure VLANs (Optional Advanced Step)

**If using managed switch with VLAN tagging:**

1. Interfaces → Assignments → VLANs → Add.
2. Create VLANs:
   - VLAN 20 (Management): Parent interface `vtnet1`, Tag `20`, Description `MANAGEMENT`
   - VLAN 50 (Lab): Parent interface `vtnet1`, Tag `50`, Description `LAB_NETWORK`
   - VLAN 60 (DMZ): Parent interface `vtnet1`, Tag `60`, Description `DMZ`
3. Interfaces → Assignments → Assign each VLAN to an interface.
4. Configure each interface with static IPs:
   - Management: `192.168.10.1/24`
   - Lab: `192.168.50.1/24`
   - DMZ: `192.168.60.1/24`

**If NOT using managed switch:** Skip VLAN setup. Use single LAN interface `192.168.50.1/24` for all lab traffic.

**CHECKPOINT:** Network routing functional. Workstations on `192.168.50.0/24` can reach internet via pfSense.

---

## PHASE 3: Windows Server AD DC Deployment

### 3.1 Create Windows Server VM in Proxmox

1. Proxmox web UI → Upload Windows Server 2022 ISO.
2. Create VM:
   - VM ID: `200`
   - Name: `WinServer-DC01`
   - OS: Microsoft Windows, Version 2022/2025
   - Disk: 80 GB (VirtIO)
   - CPU: 2 cores
   - Memory: 4096 MB (4 GB)
   - Network: Bridge `vmbr0`, Model VirtIO
3. Start VM.

### 3.2 Install Windows Server

1. Open VM console.
2. Boot from Windows Server ISO.
3. Install: Windows Server 2022 Standard (Desktop Experience).
4. Custom install, select disk, wait for installation.
5. Set Administrator password (store in KeePassXC).
6. Login as Administrator.

### 3.3 Configure Networking

1. Open Server Manager → Local Server → Ethernet adapter.
2. Set static IP:
   - IP: `192.168.50.20`
   - Subnet: `255.255.255.0`
   - Gateway: `192.168.50.1`
   - DNS: `127.0.0.1` (will point to itself after AD DNS installed)
3. Hostname: `DC01`
4. Reboot.

### 3.4 Install Active Directory Domain Services

1. Server Manager → Add Roles and Features.
2. Role-based installation.
3. Select local server.
4. Roles: Check "Active Directory Domain Services".
5. Add features (including management tools).
6. Install.
7. After installation, click "Promote this server to a domain controller".
8. Deployment Configuration:
   - Add a new forest.
   - Root domain name: `hawkinsops.local`
9. Domain Controller Options:
   - Forest/Domain functional level: Windows Server 2016 or higher.
   - DNS server: Checked.
   - Global Catalog: Checked.
   - DSRM password: Set strong password (store in KeePassXC).
10. NetBIOS name: `HAWKINSOPS` (auto-filled).
11. Paths: Default locations.
12. Review, Install.
13. Server will reboot automatically.

**CHECKPOINT:** Server reboots. Login as `HAWKINSOPS\Administrator`.

### 3.5 Verify AD DS and DNS

1. Server Manager → Tools → Active Directory Users and Computers.
2. Verify `hawkinsops.local` domain exists.
3. Server Manager → Tools → DNS.
4. Verify Forward Lookup Zones → `hawkinsops.local` exists.
5. Add A records for infrastructure (or rely on dynamic DNS updates):
   - `pfsense.hawkinsops.local` → `192.168.50.1`
   - `wazuh.hawkinsops.local` → `192.168.50.10` (will create next)
   - `dc01.hawkinsops.local` → `192.168.50.20`

**CHECKPOINT:** AD DS operational. DNS resolving `.hawkinsops.local` names.

### 3.6 Update pfSense DNS Settings

1. pfSense web UI → System → General Setup.
2. DNS Servers:
   - Primary: `192.168.50.20` (AD DC)
   - Secondary: `8.8.8.8` (fallback)
3. Save.
4. Services → DHCP Server → LAN.
5. DNS Servers: `192.168.50.20`
6. Domain name: `hawkinsops.local`
7. Save.

**CHECKPOINT:** DHCP clients will receive `192.168.50.20` as DNS server and can resolve `.hawkinsops.local`.

---

## PHASE 4: Wazuh SIEM Deployment

### 4.1 Create Wazuh Manager VM

**Option A: Use Wazuh OVA (Faster)**
1. Download Wazuh OVA from official site.
2. Import OVA into Proxmox (may require conversion).
3. Set static IP `192.168.50.10`.
4. Skip to 4.3 for initial configuration.

**Option B: Manual Install on Ubuntu 22.04 (Documented Here)**

1. Upload Ubuntu Server 22.04 ISO to Proxmox.
2. Create VM:
   - VM ID: `110`
   - Name: `Wazuh-Manager`
   - OS: Linux, Version 6.x - 2.6 Kernel
   - Disk: 100 GB (VirtIO)
   - CPU: 4 cores
   - Memory: 8192 MB (8 GB)
   - Network: Bridge `vmbr0`, Model VirtIO
3. Start VM, install Ubuntu Server:
   - Hostname: `wazuh`
   - Username: `wazuh-admin`
   - Set password (store in KeePassXC)
   - Install OpenSSH server
   - No additional snaps
4. Boot into Ubuntu.

### 4.2 Install Wazuh Manager (All-in-One)

1. SSH to `192.168.50.10` (assign this IP during Ubuntu install or after via netplan).
2. Update system:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```
3. Download Wazuh installation assistant:
   ```bash
   curl -sO https://packages.wazuh.com/4.x/wazuh-install.sh
   chmod +x wazuh-install.sh
   ```
4. Run all-in-one installation:
   ```bash
   sudo ./wazuh-install.sh -a
   ```
5. **IMPORTANT:** Installation outputs admin password for Wazuh dashboard. **COPY THIS IMMEDIATELY** to KeePassXC.
6. Wait for installation (~10-15 minutes).

**CHECKPOINT:** Installation completes. Output shows Wazuh dashboard URL and credentials.

### 4.3 Access Wazuh Dashboard

1. From Windows Powerhouse or PRIMARY_OS, browse to `https://192.168.50.10`.
2. Accept SSL warning (self-signed cert).
3. Login: `admin` / (password from installation output).
4. Wazuh dashboard loads.

**CHECKPOINT:** Wazuh dashboard accessible. No agents enrolled yet.

### 4.4 Configure DNS for Wazuh

1. AD DC → DNS Manager → Forward Lookup Zones → `hawkinsops.local` → New Host (A).
2. Name: `wazuh`
3. IP: `192.168.50.10`
4. Create PTR record: Checked.
5. Add Host.

**VERIFY:** `nslookup wazuh.hawkinsops.local` from any domain-joined machine resolves to `192.168.50.10`.

---

## PHASE 5: Windows Powerhouse Rebuild

See detailed runbook: `10_windows_powerhouse_rebuild.md`

**Summary Steps:**
1. Install Windows 11 Pro on bare metal.
2. Set static IP `192.168.50.101`, DNS `192.168.50.20`, gateway `192.168.50.1`.
3. Join domain `hawkinsops.local`.
4. Install PowerShell 7.
5. Create `C:\HAWKINS_OPS\` directory structure.
6. Install Wazuh agent (see Phase 8).
7. Harden OS (see Phase 10).

**CHECKPOINT:** Windows Powerhouse domain-joined, accessible via RDP, `C:\HAWKINS_OPS\` exists.

---

## PHASE 6: PRIMARY_OS Linux Rebuild

See detailed runbook: `20_primary_os_rebuild_overview.md`

**Summary Steps:**
1. Install Linux Mint 21.x on bare metal.
2. Set static IP `192.168.50.100`, DNS `192.168.50.20`, gateway `192.168.50.1`.
3. Create `/home/raylee/HAWKINS_OPS/` directory structure.
4. Install Wazuh agent (see Phase 8).
5. Harden OS (see Phase 10).
6. Install automation tools (ansible, scripts).

**CHECKPOINT:** PRIMARY_OS booted, SSH accessible, `/home/raylee/HAWKINS_OPS/` exists.

---

## PHASE 7: MINT-3 Endpoint Rebuild

**Summary Steps:**
1. Install Linux Mint 21.x on bare metal or VM.
2. Set DHCP or static IP `192.168.50.102`.
3. DNS: `192.168.50.20`, gateway `192.168.50.1`.
4. Install Wazuh agent (see Phase 8).
5. Basic hardening (see Phase 10).

**CHECKPOINT:** MINT-3 booted, pingable from network.

---

## PHASE 8: Wazuh Agent Deployment

### 8.1 Generate Agent Deployment Commands

1. Wazuh Dashboard → Agents → Deploy new agent.
2. Select OS (Windows / Linux).
3. **Server address:** `192.168.50.10` (or `wazuh.hawkinsops.local` if DNS working).
4. **Agent name:** Unique per host (e.g., `win-powerhouse`, `primary-os`, `mint-3`, `dc01`).
5. Copy installation command.

### 8.2 Install Agent on Windows Powerhouse

1. Open PowerShell as Administrator.
2. Paste Wazuh agent install command (example):
   ```powershell
   Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.x.x-1.msi -OutFile wazuh-agent.msi
   msiexec.exe /i wazuh-agent.msi /q WAZUH_MANAGER='192.168.50.10' WAZUH_AGENT_NAME='win-powerhouse'
   NET START WazuhSvc
   ```
3. Verify agent status:
   ```powershell
   & "C:\Program Files (x86)\ossec-agent\agent-auth.exe" -m 192.168.50.10
   NET START WazuhSvc
   ```

**VERIFY:** Wazuh Dashboard → Agents → `win-powerhouse` shows "Active".

### 8.3 Install Agent on PRIMARY_OS Linux

1. SSH to PRIMARY_OS.
2. Paste Wazuh agent install command (example):
   ```bash
   curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg
   echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee -a /etc/apt/sources.list.d/wazuh.list
   apt update
   apt install wazuh-agent -y
   ```
3. Configure manager IP:
   ```bash
   sudo nano /var/ossec/etc/ossec.conf
   # Set <address>192.168.50.10</address>
   ```
4. Register and start agent:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable wazuh-agent
   sudo systemctl start wazuh-agent
   ```

**VERIFY:** Wazuh Dashboard → Agents → `primary-os` shows "Active".

### 8.4 Repeat for All Hosts

Deploy Wazuh agent to:
- MINT-3 (Linux agent)
- DC01 (Windows agent)
- All additional Windows/Linux endpoint VMs

**CHECKPOINT:** Wazuh Dashboard shows all agents "Active".

---

## PHASE 9: Domain Joins and AD Integration

### 9.1 Join Windows Powerhouse to Domain

(Already done in Phase 5, verify here)

1. System Properties → Computer Name → Change.
2. Domain: `hawkinsops.local`
3. Provide Domain Admin credentials.
4. Reboot.
5. Login as `HAWKINSOPS\Administrator` or domain user.

### 9.2 Join Additional Windows Endpoints

Repeat for each Windows VM:
1. Set DNS to `192.168.50.20`.
2. Join domain `hawkinsops.local`.
3. Reboot.

### 9.3 Join Linux Machines to Domain (Optional)

**Note:** Linux domain join is optional. If desired, use `realmd` and `sssd`.

1. Install packages:
   ```bash
   sudo apt install realmd sssd sssd-tools libnss-sss libpam-sss adcli samba-common-bin
   ```
2. Discover domain:
   ```bash
   sudo realm discover hawkinsops.local
   ```
3. Join domain:
   ```bash
   sudo realm join --user=Administrator hawkinsops.local
   ```
4. Verify:
   ```bash
   realm list
   ```

**CHECKPOINT:** All Windows machines domain-joined. Linux domain join optional but documented.

---

## PHASE 10: Hardening and Security Configuration

### 10.1 Windows Hardening Baseline

For each Windows host:

1. **Windows Update:**
   - Settings → Windows Update → Check for updates.
   - Install all updates, reboot.

2. **Disable Unnecessary Services:**
   - `services.msc` → Disable:
     - Fax
     - Print Spooler (if not printing)
     - Remote Registry
     - Secondary Logon (if not needed)

3. **Enable Audit Policies:**
   - `gpedit.msc` → Computer Configuration → Windows Settings → Security Settings → Advanced Audit Policy Configuration.
   - Enable:
     - Logon/Logoff events
     - Process Creation
     - Object Access (File System, Registry)
     - Privilege Use

4. **Enable PowerShell Logging:**
   - `gpedit.msc` → Administrative Templates → Windows Components → Windows PowerShell.
   - Enable "Turn on Module Logging" and "Turn on PowerShell Script Block Logging".

5. **Windows Firewall:**
   - Allow: RDP (if needed), Wazuh agent (port 1514/1515), domain traffic.
   - Block: All other inbound by default.

### 10.2 Linux Hardening Baseline

For each Linux host:

1. **Update Packages:**
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

2. **Disable Unnecessary Services:**
   ```bash
   sudo systemctl disable bluetooth.service
   sudo systemctl disable cups.service  # If no printing
   ```

3. **Configure UFW Firewall:**
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   sudo ufw allow ssh
   sudo ufw allow from 192.168.50.10 to any port 1514  # Wazuh agent
   sudo ufw enable
   ```

4. **Enable Auditd:**
   ```bash
   sudo apt install auditd -y
   sudo systemctl enable auditd
   sudo systemctl start auditd
   ```

5. **Harden SSH:**
   - Edit `/etc/ssh/sshd_config`:
     - `PermitRootLogin no`
     - `PasswordAuthentication no` (if using SSH keys)
     - `Protocol 2`
   - Restart SSH: `sudo systemctl restart ssh`

### 10.3 pfSense Hardening

1. System → Advanced → Admin Access:
   - Protocol: HTTPS
   - Disable HTTP redirect: Unchecked
   - Login Protection: Enable
2. Firewall → Rules:
   - Review and restrict WAN rules (block all inbound by default except necessary port forwards).
   - LAN rules: Allow internal traffic, block egress to WAN from untrusted VLANs.
3. Enable logging for all firewall rules.

### 10.4 Wazuh Manager Hardening

1. Change default API credentials:
   ```bash
   sudo /var/ossec/bin/wazuh-keystore -f apiuser -k username -v <new_username>
   sudo /var/ossec/bin/wazuh-keystore -f apiuser -k password -v <new_password>
   ```
2. Restrict dashboard access:
   - Configure reverse proxy with authentication (optional, advanced).
3. Backup `/var/ossec/etc/ossec.conf` and custom rules.

**CHECKPOINT:** All systems hardened according to baseline. Firewall rules documented.

---

## PHASE 11: Dashboard Configuration and Testing

### 11.1 Import Wazuh Detection Rules

1. Wazuh Dashboard → Management → Rules.
2. Review default rules.
3. Upload custom rules (if backed up from previous environment):
   - SSH to Wazuh Manager.
   - Copy custom rules to `/var/ossec/etc/rules/local_rules.xml`.
   - Restart Wazuh Manager: `sudo systemctl restart wazuh-manager`.

### 11.2 Create Custom Dashboards

1. Wazuh Dashboard → Dashboards.
2. Create visualizations for:
   - Top 10 security events
   - Failed login attempts by host
   - Process creation events
   - Network connections by destination
3. Save dashboards with descriptive names.

### 11.3 Configure Alerting

1. Wazuh Manager → `/var/ossec/etc/ossec.conf` → Email alerts (if configured):
   ```xml
   <global>
     <email_notification>yes</email_notification>
     <smtp_server>smtp.gmail.com</smtp_server>
     <email_from>wazuh@hawkinsops.local</email_from>
     <email_to>raylee@example.com</email_to>
   </global>
   ```
2. Restart Wazuh Manager.

### 11.4 Test Detection Rules

1. **Test 1: Failed SSH Login**
   - Attempt failed SSH login to PRIMARY_OS.
   - Check Wazuh Dashboard for alert.

2. **Test 2: Privilege Escalation**
   - On Windows, run PowerShell as admin and execute suspicious command.
   - Check for alert.

3. **Test 3: File Integrity Monitoring**
   - Modify a monitored file (e.g., `/etc/passwd` on Linux).
   - Verify FIM alert in Wazuh.

**CHECKPOINT:** Detection rules firing alerts. Dashboards showing data.

---

## PHASE 12: Verification and Documentation

### 12.1 Health Check All Systems

Run through `30_services_matrix.md` and verify:
- All VMs pingable.
- All Wazuh agents "Active".
- DNS resolving `.hawkinsops.local` names.
- Domain-joined machines authenticate against AD.
- Web UIs accessible (pfSense, Wazuh, Proxmox).

### 12.2 Document Environment State

1. Update `assumptions.md` with any deviations.
2. Create backup of:
   - pfSense config XML.
   - Wazuh config files.
   - AD system state backup.
3. Export Proxmox VM configs:
   ```bash
   vzdump --mode snapshot --compress gzip --storage local --all
   ```

### 12.3 Create Restore Point

1. Take VM snapshots in Proxmox for all VMs.
2. Label snapshot: "Post-Rebuild-Clean-State-YYYY-MM-DD".
3. Copy `C:\HAWKINS_OPS\` to external backup.

### 12.4 Update Documentation

1. Record rebuild completion date in `00_index.md`.
2. Note any issues encountered and resolutions.
3. Update estimated rebuild time if significantly different.

**CHECKPOINT:** HawkinsOps fully operational. Rebuild complete.

---

## Post-Rebuild Next Steps

1. **Deploy additional endpoints** (Windows/Linux VMs for testing).
2. **Configure advanced detection rules** (MITRE ATT&CK mapping).
3. **Implement log retention policy** (archive old logs, manage disk space).
4. **Set up automated backups** (cron jobs, backup scripts).
5. **Conduct tabletop exercise** (simulate incident response).
6. **Document IR playbooks** (how to respond to specific alert types).

---

## Troubleshooting Common Issues

### Issue: Wazuh agents not connecting

**Symptoms:** Agents show "Never connected" or "Disconnected" in dashboard.

**Resolution:**
1. Verify network connectivity: `ping 192.168.50.10` from agent.
2. Check firewall rules on Wazuh Manager:
   ```bash
   sudo ufw status
   sudo ufw allow 1514/tcp
   sudo ufw allow 1515/tcp
   ```
3. Verify agent config: `cat /var/ossec/etc/ossec.conf | grep address` (Linux) or check `C:\Program Files (x86)\ossec-agent\ossec.conf` (Windows).
4. Restart agent:
   - Linux: `sudo systemctl restart wazuh-agent`
   - Windows: `NET STOP WazuhSvc && NET START WazuhSvc`

### Issue: DNS not resolving `.hawkinsops.local`

**Symptoms:** Cannot reach `wazuh.hawkinsops.local` or other internal hostnames.

**Resolution:**
1. Verify client DNS settings point to `192.168.50.20`.
2. Verify AD DNS service running: `nslookup hawkinsops.local 192.168.50.20`
3. Check DNS A records in DNS Manager on DC01.
4. Flush DNS cache on client:
   - Windows: `ipconfig /flushdns`
   - Linux: `sudo systemd-resolve --flush-caches`

### Issue: Cannot join domain

**Symptoms:** "Domain cannot be found" or "No logon servers available".

**Resolution:**
1. Verify client DNS is `192.168.50.20`.
2. Verify client can ping DC01: `ping dc01.hawkinsops.local`
3. Verify time sync (domain join requires time within 5 minutes):
   - Windows: `w32tm /resync`
   - Linux: `sudo ntpdate 192.168.50.20`
4. Check firewall on DC01 allows domain traffic (ports 88, 135, 139, 389, 445, 464, 636, 3268, 3269).

### Issue: pfSense not routing traffic

**Symptoms:** Clients have no internet access.

**Resolution:**
1. Verify WAN interface has IP and gateway: pfSense → Status → Interfaces.
2. Verify NAT outbound rule exists: Firewall → NAT → Outbound (should be "Automatic outbound NAT").
3. Test DNS from pfSense itself: Diagnostics → Ping → ping `8.8.8.8`.
4. Check LAN firewall rules allow outbound traffic.

---

## Emergency Rollback Procedures

### If Rebuild Fails Midway

1. **Stop immediately.** Do not proceed if critical errors occur.
2. **Document the failure:** What step failed? What was the error message?
3. **Restore from snapshot:** If you took VM snapshots at phase checkpoints, roll back to last known good state.
4. **Consult troubleshooting section** or external documentation.
5. **If unrecoverable:** Start over from Phase 1.

### If You Need to Abandon Rebuild

1. **Preserve current state:** Take snapshots of all VMs before destroying anything.
2. **Export configs:** pfSense XML, Wazuh config files, AD backup.
3. **Document what worked and what didn't** for next attempt.
4. **Consider partial rebuild:** Only rebuild failed components if others are functional.

---

## Rebuild Checklist

Use this checklist to track progress:

- [ ] Phase 1: Proxmox installed and updated
- [ ] Phase 2: pfSense deployed, network routing functional
- [ ] Phase 3: Windows Server AD DC deployed, DNS operational
- [ ] Phase 4: Wazuh Manager deployed, dashboard accessible
- [ ] Phase 5: Windows Powerhouse rebuilt and domain-joined
- [ ] Phase 6: PRIMARY_OS Linux rebuilt
- [ ] Phase 7: MINT-3 endpoint rebuilt
- [ ] Phase 8: Wazuh agents deployed to all hosts (all showing "Active")
- [ ] Phase 9: All Windows machines domain-joined
- [ ] Phase 10: Hardening applied to all systems
- [ ] Phase 11: Dashboards configured, detection rules tested
- [ ] Phase 12: Full environment verified, backups created

**Rebuild Status:** ☐ Not Started | ☐ In Progress | ☐ Complete

**Completion Date:** ___________

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
