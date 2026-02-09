# HawkinsOps Services Matrix

## Purpose

This matrix provides a comprehensive inventory of all hosts, services, and health check procedures for the HawkinsOps environment. Use this document to verify system health during rebuild, troubleshooting, or routine maintenance.

---

## Host Inventory

| Host ID | Hostname | FQDN | IP Address | OS | Role | Physical/Virtual |
|---------|----------|------|------------|----|----- |------------------|
| H01 | WIN-POWERHOUSE | win-powerhouse.hawkinsops.local | 192.168.50.101 | Windows 11 Pro | Security Analyst Workstation | Bare Metal |
| H02 | PRIMARY-OS | primary-os.hawkinsops.local | 192.168.50.100 | Linux Mint 21.x | Operations Server, File Server | Bare Metal |
| H03 | MINT-3 | mint-3.hawkinsops.local | 192.168.50.102 | Linux Mint 21.x | Monitored Endpoint | Bare Metal or VM |
| H04 | DC01 | dc01.hawkinsops.local | 192.168.50.20 | Windows Server 2022 | Active Directory Domain Controller, DNS | VM (Proxmox) |
| H05 | Wazuh-Manager | wazuh.hawkinsops.local | 192.168.50.10 | Ubuntu 22.04 LTS | SIEM, Log Aggregation, Alerting | VM (Proxmox) |
| H06 | pfSense | pfsense.hawkinsops.local | 192.168.50.1 (LAN) | pfSense 2.7.x | Firewall, Router, Gateway | VM (Proxmox) |
| H07 | Proxmox | proxmox.hawkinsops.local | 192.168.10.10 (MGMT) | Proxmox VE 8.x | Hypervisor, VM Host | Bare Metal |
| H08 | Win-Endpoint-01 | win-endpoint-01.hawkinsops.local | 192.168.50.110 | Windows 10/11 Pro | Test Endpoint | VM (Proxmox) |
| H09 | Win-Endpoint-02 | win-endpoint-02.hawkinsops.local | 192.168.50.111 | Windows 10/11 Pro | Test Endpoint | VM (Proxmox) |
| H10 | Linux-Endpoint-01 | linux-endpoint-01.hawkinsops.local | 192.168.50.120 | Ubuntu 22.04 | Test Endpoint | VM (Proxmox) |

---

## Critical Services by Host

### H01: WIN-POWERHOUSE (Windows 11 Analyst Workstation)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Wazuh Agent | Security monitoring agent | 1514/1515 outbound | TCP | `Get-Service WazuhSvc` (PowerShell) |
| Windows Defender | Antivirus/antimalware | N/A | N/A | `Get-MpComputerStatus` (PowerShell) |
| Windows Firewall | Host-based firewall | N/A | N/A | `Get-NetFirewallProfile \| Select Name, Enabled` |
| RDP (optional) | Remote desktop access | 3389 | TCP | `Test-NetConnection -ComputerName localhost -Port 3389` |
| SSH Client | SSH to Linux hosts | N/A | N/A | `ssh -V` |
| SMB Client | Access file shares | 445 outbound | TCP | `Test-Path \\192.168.50.100\HAWKINS_OPS` |

**Health Check Script (PowerShell):**
```powershell
# Run from PowerShell 7 as Administrator
Write-Host "=== WIN-POWERHOUSE Health Check ===" -ForegroundColor Cyan

# Wazuh Agent
$wazuh = Get-Service -Name WazuhSvc -ErrorAction SilentlyContinue
if ($wazuh.Status -eq 'Running') { Write-Host "[OK] Wazuh Agent: Running" -ForegroundColor Green }
else { Write-Host "[FAIL] Wazuh Agent: Not Running" -ForegroundColor Red }

# Windows Defender
$defender = Get-MpComputerStatus
if ($defender.RealTimeProtectionEnabled) { Write-Host "[OK] Windows Defender: Enabled" -ForegroundColor Green }
else { Write-Host "[FAIL] Windows Defender: Disabled" -ForegroundColor Red }

# Domain Membership
$domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain
if ($domain -eq 'hawkinsops.local') { Write-Host "[OK] Domain: $domain" -ForegroundColor Green }
else { Write-Host "[FAIL] Domain: $domain (expected hawkinsops.local)" -ForegroundColor Red }

# Network Connectivity
$tests = @{
    'pfSense' = '192.168.50.1'
    'AD DC' = '192.168.50.20'
    'Wazuh' = '192.168.50.10'
    'PRIMARY_OS' = '192.168.50.100'
}
foreach ($name in $tests.Keys) {
    if (Test-Connection $tests[$name] -Count 2 -Quiet) {
        Write-Host "[OK] Connectivity to $name ($($tests[$name]))" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] Cannot reach $name ($($tests[$name]))" -ForegroundColor Red
    }
}

Write-Host "=== Health Check Complete ===" -ForegroundColor Cyan
```

---

### H02: PRIMARY-OS (Linux Mint Operations Server)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| SSH | Remote administration | 22 | TCP | `systemctl is-active ssh` |
| Samba (SMB) | File sharing to Windows | 445 | TCP | `systemctl is-active smbd` |
| Wazuh Agent | Security monitoring agent | 1514/1515 outbound | TCP | `systemctl is-active wazuh-agent` |
| UFW Firewall | Host-based firewall | N/A | N/A | `sudo ufw status` |
| Auditd | System audit daemon | N/A | N/A | `systemctl is-active auditd` |
| Fail2ban | Intrusion prevention | N/A | N/A | `systemctl is-active fail2ban` |

**Health Check Script (Bash):**
```bash
#!/bin/bash
# /home/raylee/HAWKINS_OPS/scripts/health_check_primary_os.sh

echo "=== PRIMARY-OS Health Check ==="

services=("ssh" "smbd" "wazuh-agent" "ufw" "auditd" "fail2ban")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo -e "\e[32m[OK]\e[0m $service is running"
    else
        echo -e "\e[31m[FAIL]\e[0m $service is NOT running"
    fi
done

# Network connectivity
echo ""
echo "Testing network connectivity..."
hosts=("192.168.50.1:pfSense" "192.168.50.20:DC01" "192.168.50.10:Wazuh")
for host in "${hosts[@]}"; do
    ip="${host%%:*}"
    name="${host##*:}"
    if ping -c 2 -W 2 "$ip" > /dev/null 2>&1; then
        echo -e "\e[32m[OK]\e[0m Can reach $name ($ip)"
    else
        echo -e "\e[31m[FAIL]\e[0m Cannot reach $name ($ip)"
    fi
done

# Disk space
echo ""
echo "Disk space:"
df -h / | tail -1

echo "=== Health Check Complete ==="
```

**Run from Windows PowerShell:**
```powershell
ssh raylee@primary-os.hawkinsops.local "bash ~/HAWKINS_OPS/scripts/health_check_primary_os.sh"
```

---

### H03: MINT-3 (Linux Mint Endpoint)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Wazuh Agent | Security monitoring agent | 1514/1515 outbound | TCP | `systemctl is-active wazuh-agent` |
| SSH (optional) | Remote administration | 22 | TCP | `systemctl is-active ssh` |
| UFW Firewall | Host-based firewall | N/A | N/A | `sudo ufw status` |

**Health Check (Bash):**
```bash
systemctl is-active wazuh-agent && echo "[OK] Wazuh Agent" || echo "[FAIL] Wazuh Agent"
ping -c 2 192.168.50.10 && echo "[OK] Connectivity to Wazuh" || echo "[FAIL] Cannot reach Wazuh"
```

---

### H04: DC01 (Windows Server 2022 - Active Directory)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Active Directory Domain Services | AD DS | 88, 389, 636, 3268, 3269 | TCP | `Get-Service NTDS` |
| DNS Server | Domain DNS | 53 | TCP/UDP | `Get-Service DNS` |
| Kerberos | Authentication | 88 | TCP/UDP | N/A (part of AD DS) |
| LDAP | Directory queries | 389, 636 | TCP | `Test-NetConnection -ComputerName localhost -Port 389` |
| Netlogon | Domain authentication | 445 | TCP | `Get-Service Netlogon` |
| Wazuh Agent | Security monitoring agent | 1514/1515 outbound | TCP | `Get-Service WazuhSvc` |

**Health Check Script (PowerShell):**
```powershell
# Run on DC01 or remotely via PowerShell Remoting
Write-Host "=== DC01 Health Check ===" -ForegroundColor Cyan

$services = @('NTDS', 'DNS', 'Netlogon', 'WazuhSvc')
foreach ($svc in $services) {
    $status = (Get-Service -Name $svc -ErrorAction SilentlyContinue).Status
    if ($status -eq 'Running') {
        Write-Host "[OK] $svc : Running" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $svc : $status" -ForegroundColor Red
    }
}

# Test DNS resolution
$dnsTest = Resolve-DnsName -Name hawkinsops.local -ErrorAction SilentlyContinue
if ($dnsTest) {
    Write-Host "[OK] DNS: hawkinsops.local resolves" -ForegroundColor Green
} else {
    Write-Host "[FAIL] DNS: Cannot resolve hawkinsops.local" -ForegroundColor Red
}

# AD Replication health (if multi-DC environment)
# repadmin /showrepl

Write-Host "=== Health Check Complete ===" -ForegroundColor Cyan
```

**DNS Health Check from Any Host:**
```powershell
# Windows
nslookup hawkinsops.local 192.168.50.20
nslookup dc01.hawkinsops.local 192.168.50.20

# Linux
nslookup hawkinsops.local 192.168.50.20
dig @192.168.50.20 hawkinsops.local
```

---

### H05: Wazuh-Manager (Ubuntu 22.04 - SIEM)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Wazuh Manager | Core SIEM engine | 1514, 1515 | TCP | `systemctl is-active wazuh-manager` |
| Wazuh API | API for dashboard | 55000 | TCP | `curl -k https://localhost:55000/` |
| Elasticsearch / OpenSearch | Log indexing | 9200 | TCP | `curl -X GET "https://localhost:9200/" -u admin:admin -k` |
| Kibana / OpenSearch Dashboards | Web UI | 443 | TCP | `systemctl is-active wazuh-dashboard` |
| Filebeat | Log shipper | N/A | N/A | `systemctl is-active filebeat` |

**Health Check Script (Bash):**
```bash
#!/bin/bash
# /var/ossec/bin/health_check_wazuh.sh

echo "=== Wazuh Manager Health Check ==="

services=("wazuh-manager" "wazuh-dashboard" "filebeat")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo -e "\e[32m[OK]\e[0m $service is running"
    else
        echo -e "\e[31m[FAIL]\e[0m $service is NOT running"
    fi
done

# Check Wazuh API
echo ""
echo "Testing Wazuh API..."
curl -s -k -u admin:admin https://localhost:55000/ | grep -q "title" && \
    echo -e "\e[32m[OK]\e[0m Wazuh API responding" || \
    echo -e "\e[31m[FAIL]\e[0m Wazuh API not responding"

# Check Elasticsearch/OpenSearch
echo ""
echo "Testing Elasticsearch/OpenSearch..."
curl -s -k -u admin:admin https://localhost:9200/ | grep -q "cluster_name" && \
    echo -e "\e[32m[OK]\e[0m Elasticsearch responding" || \
    echo -e "\e[31m[FAIL]\e[0m Elasticsearch not responding"

# Agent count
echo ""
echo "Active Wazuh agents:"
/var/ossec/bin/agent_control -l | grep -c "is available" || echo "0"

echo "=== Health Check Complete ==="
```

**Web UI Access Check:**
```powershell
# From Windows Powerhouse
Start-Process https://wazuh.hawkinsops.local
# Should load Wazuh dashboard login page
```

**Agent List Check:**
```bash
# On Wazuh Manager
sudo /var/ossec/bin/agent_control -l
```

---

### H06: pfSense (Firewall/Router)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| pfSense WebUI | Web management interface | 443 | TCP | Browse to https://192.168.50.1 |
| Firewall | Packet filtering | N/A | N/A | Check Status → System Logs → Firewall |
| DHCP Server | IP address assignment | 67 | UDP | Status → DHCP Leases |
| DNS Forwarder/Resolver | DNS resolution | 53 | TCP/UDP | Diagnostics → Ping (test DNS resolution) |
| NAT | Network address translation | N/A | N/A | Firewall → NAT → Outbound (check rules) |

**Health Check (Web UI):**
1. Browse to `https://pfsense.hawkinsops.local` or `https://192.168.50.1`.
2. Login as `admin`.
3. Dashboard → Widgets:
   - **Interfaces:** WAN up, LAN up.
   - **Gateways:** Default gateway online, 0% packet loss.
   - **System Information:** CPU < 50%, Memory < 80%, Uptime > 0.
4. Status → System Logs → Firewall: Check for blocked traffic (normal), no errors.

**Health Check (Command Line via SSH):**
```bash
# SSH to pfSense (enable SSH in System → Advanced → Admin Access)
ssh admin@192.168.50.1

# Check interfaces
ifconfig | grep -E "vtnet|UP"

# Check firewall states
pfctl -s states | wc -l

# Check gateway status
route -n get default

# Exit SSH
exit
```

**Connectivity Test from Client:**
```powershell
# Windows
Test-NetConnection -ComputerName 192.168.50.1 -Port 443
ping 192.168.50.1

# Test internet via pfSense
ping 8.8.8.8
nslookup google.com
```

---

### H07: Proxmox (Hypervisor)

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Proxmox Web UI | VM management | 8006 | TCP | Browse to https://192.168.10.10:8006 |
| pve-cluster | Cluster management | N/A | N/A | `systemctl is-active pve-cluster` |
| pvedaemon | API daemon | 8006 | TCP | `systemctl is-active pvedaemon` |
| pveproxy | Web proxy | 8006 | TCP | `systemctl is-active pveproxy` |

**Health Check (Web UI):**
1. Browse to `https://proxmox.hawkinsops.local:8006`.
2. Login as `root`.
3. Check:
   - **Node status:** Online, CPU/Memory usage reasonable.
   - **VM status:** All critical VMs running (pfSense, Wazuh, DC01).
   - **Storage:** Local and shared storage online, > 20% free space.

**Health Check (SSH):**
```bash
ssh root@192.168.10.10

# Check all VMs status
qm list

# Check running VMs
qm list | grep running

# Check storage
pvesm status

# Check cluster status (if clustered)
pvecm status

exit
```

**VM Status from Windows:**
```powershell
# Via API (requires API token setup)
# Or SSH
ssh root@proxmox.hawkinsops.local "qm list"
```

---

### H08-H10: Windows/Linux Endpoints

| Service Name | Description | Port(s) | Protocol | Health Check Command |
|--------------|-------------|---------|----------|----------------------|
| Wazuh Agent | Security monitoring agent | 1514/1515 outbound | TCP | Windows: `Get-Service WazuhSvc` / Linux: `systemctl is-active wazuh-agent` |
| Domain Membership (Windows) | Domain authentication | N/A | N/A | `(Get-WmiObject Win32_ComputerSystem).Domain` |
| SSH (Linux) | Remote administration | 22 | TCP | `systemctl is-active ssh` |

**Quick Health Check:**
- Verify in Wazuh Dashboard: All endpoints show "Active" status.
- Ping test from Windows Powerhouse: `Test-Connection win-endpoint-01, win-endpoint-02, linux-endpoint-01`

---

## Centralized Health Check Dashboard

### Option 1: Wazuh Dashboard

1. Login to Wazuh: `https://wazuh.hawkinsops.local`.
2. Navigate to **Agents**.
3. Verify all agents show status "Active":
   - win-powerhouse
   - primary-os
   - mint-3
   - dc01
   - win-endpoint-01
   - win-endpoint-02
   - linux-endpoint-01

**Healthy Environment:**
- All agents: Active
- Last keep alive: < 60 seconds
- No critical alerts (some info/warning alerts are normal)

### Option 2: Custom Health Check Script (Master)

**Create on Windows Powerhouse: `C:\HAWKINS_OPS\scripts\health_check_all.ps1`**

```powershell
# HawkinsOps Master Health Check Script
# Run from Windows Powerhouse

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  HawkinsOps Environment Health Check  " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Define all hosts
$hosts = @{
    'pfSense' = '192.168.50.1'
    'Wazuh' = '192.168.50.10'
    'DC01' = '192.168.50.20'
    'PRIMARY_OS' = '192.168.50.100'
    'WIN-POWERHOUSE' = '192.168.50.101'
    'MINT-3' = '192.168.50.102'
    'Win-Endpoint-01' = '192.168.50.110'
    'Win-Endpoint-02' = '192.168.50.111'
    'Linux-Endpoint-01' = '192.168.50.120'
}

Write-Host "[STEP 1] Network Connectivity Check" -ForegroundColor Yellow
foreach ($name in $hosts.Keys) {
    if (Test-Connection $hosts[$name] -Count 2 -Quiet) {
        Write-Host "  [OK] $name ($($hosts[$name]))" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] $name ($($hosts[$name])) - UNREACHABLE" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[STEP 2] DNS Resolution Check" -ForegroundColor Yellow
$dnsNames = @('hawkinsops.local', 'dc01.hawkinsops.local', 'wazuh.hawkinsops.local', 'pfsense.hawkinsops.local')
foreach ($dnsName in $dnsNames) {
    try {
        $result = Resolve-DnsName $dnsName -ErrorAction Stop
        Write-Host "  [OK] $dnsName resolves to $($result.IPAddress)" -ForegroundColor Green
    } catch {
        Write-Host "  [FAIL] $dnsName - Cannot resolve" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "[STEP 3] Critical Services Check" -ForegroundColor Yellow

# Wazuh Agent on Windows Powerhouse
$wazuh = Get-Service -Name WazuhSvc -ErrorAction SilentlyContinue
if ($wazuh.Status -eq 'Running') {
    Write-Host "  [OK] Wazuh Agent (local): Running" -ForegroundColor Green
} else {
    Write-Host "  [FAIL] Wazuh Agent (local): Not Running" -ForegroundColor Red
}

# Wazuh Dashboard (web check)
try {
    $response = Invoke-WebRequest -Uri https://wazuh.hawkinsops.local -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] Wazuh Dashboard: Accessible (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Wazuh Dashboard: Not accessible" -ForegroundColor Red
}

# pfSense WebUI
try {
    $response = Invoke-WebRequest -Uri https://pfsense.hawkinsops.local -SkipCertificateCheck -TimeoutSec 5 -ErrorAction Stop
    Write-Host "  [OK] pfSense WebUI: Accessible (HTTP $($response.StatusCode))" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] pfSense WebUI: Not accessible" -ForegroundColor Red
}

Write-Host ""
Write-Host "[STEP 4] Wazuh Agents Status" -ForegroundColor Yellow
Write-Host "  (Manual check required: Open Wazuh Dashboard → Agents)" -ForegroundColor Gray
Write-Host "  Expected agents: win-powerhouse, primary-os, mint-3, dc01, endpoints" -ForegroundColor Gray

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Health Check Complete                 " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
```

**Run:**
```powershell
C:\HAWKINS_OPS\scripts\health_check_all.ps1
```

---

## Service Dependency Map

```
Internet
  ↓
pfSense (MUST be up for internet access)
  ↓
├─→ AD DC (MUST be up for domain auth and DNS)
│    ↓
│    └─→ Domain-joined hosts (depend on AD DC for auth)
│
├─→ Wazuh Manager (MUST be up for agent reporting)
│    ↓
│    └─→ All Wazuh agents (depend on manager for log shipping)
│
└─→ Proxmox (MUST be up for VMs to run)
     ↓
     └─→ All VMs (pfSense, Wazuh, DC01, endpoints)
```

**Critical Path:**
1. Proxmox must be operational.
2. pfSense must boot and provide routing.
3. AD DC must boot and provide DNS.
4. Wazuh Manager must boot and accept agents.
5. Endpoints can then boot and integrate.

---

## Expected Baseline Metrics

| Metric | Healthy Range | Warning Threshold | Critical Threshold |
|--------|---------------|-------------------|-------------------|
| Wazuh Agent "Active" Count | 7+ (all enrolled agents) | < 7 | < 5 |
| pfSense CPU Usage | < 30% | 50-70% | > 80% |
| Wazuh Manager CPU Usage | < 50% | 60-80% | > 90% |
| Wazuh Manager Disk Free | > 30% | 20-30% | < 20% |
| AD DC Event Log Errors | < 10/hour | 10-50/hour | > 50/hour |
| Firewall Blocked Connections | Variable (expected) | N/A | Sudden spike (10x normal) |
| Failed Login Attempts (domain) | < 5/hour | 5-20/hour | > 20/hour (possible attack) |

---

## Maintenance Windows and Downtime Planning

### Planned Maintenance Order (Minimize Downtime)

**Scenario: Update all systems**

1. **Endpoints first:** Windows/Linux test endpoints (minimal impact).
2. **Workstations:** WIN-POWERHOUSE, PRIMARY_OS (can work offline temporarily).
3. **Wazuh Manager:** Update during low-activity period (agents will queue logs).
4. **AD DC:** Schedule after-hours, ensure all domain-joined machines are idle.
5. **pfSense:** Very brief reboot, expect 1-2 minutes of network downtime.
6. **Proxmox:** Only if absolutely necessary (all VMs will be down).

**Emergency Shutdown Order (Disaster Scenario):**

1. Gracefully shut down endpoints.
2. Shut down Wazuh Manager (after agents stop sending).
3. Shut down AD DC.
4. Shut down pfSense.
5. Shut down Proxmox (powers off all VMs).

**Startup Order (After Outage):**

1. Power on Proxmox.
2. Start pfSense VM first (wait for full boot, ~2 minutes).
3. Start AD DC (wait for DNS to be ready, ~3 minutes).
4. Start Wazuh Manager (wait for dashboard to load, ~5 minutes).
5. Start all other VMs and endpoints.
6. Verify all Wazuh agents report "Active" within 5 minutes.

---

## Disaster Recovery Health Verification

After a full rebuild or disaster recovery:

- [ ] All hosts pingable
- [ ] All DNS names resolving correctly
- [ ] All Wazuh agents showing "Active" in dashboard
- [ ] pfSense passing traffic on all VLANs
- [ ] AD DC allowing domain authentication
- [ ] Wazuh dashboard accessible and displaying events
- [ ] No critical alerts in Wazuh (expected: some info/warning)
- [ ] All VM consoles accessible via Proxmox
- [ ] Firewall logs showing normal traffic patterns
- [ ] Endpoint can browse internet through pfSense
- [ ] Windows Powerhouse can access PRIMARY_OS file share
- [ ] All scheduled tasks/cron jobs operational

**Sign-off:** Environment is healthy and ready for operations.

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
