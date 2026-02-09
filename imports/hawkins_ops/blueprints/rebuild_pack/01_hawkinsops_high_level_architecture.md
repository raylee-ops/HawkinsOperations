# HawkinsOps High-Level Architecture

## Overview

HawkinsOps is a multi-tier security operations environment designed to mirror enterprise infrastructure. The architecture consists of physical hardware, virtualized infrastructure, network segmentation, security monitoring, and centralized logging.

---

## Component Hierarchy

```
PHYSICAL LAYER
├── Windows 11 Powerhouse (Bare Metal)
│   ├── Role: Security analyst workstation + administrative console
│   ├── OS: Windows 11 Pro
│   └── Primary Use: SIEM dashboard access, admin tools, documentation
│
├── Linux PRIMARY_OS (Bare Metal or Primary VM Host)
│   ├── Role: Source-of-truth server, daily driver, operations hub
│   ├── OS: Linux Mint 21.x
│   └── Primary Use: File storage, automation scripts, development
│
└── Linux MINT-3 (Bare Metal or VM)
    ├── Role: Monitored endpoint for detection testing
    ├── OS: Linux Mint 21.x
    └── Primary Use: Generate realistic user activity, agent testing

VIRTUALIZATION LAYER (Proxmox Cluster)
├── Proxmox Host(s)
│   ├── Role: Hypervisor for infrastructure VMs
│   ├── OS: Proxmox VE 8.x
│   └── Management: Web UI at https://proxmox.hawkinsops.local:8006
│
├── VM: pfSense Firewall
│   ├── Role: Network gateway, firewall, routing, VLANs
│   ├── OS: pfSense 2.7.x
│   ├── Interfaces: WAN, LAN, DMZ, LAB
│   └── Management: Web UI at https://pfsense.hawkinsops.local
│
├── VM: Wazuh Manager
│   ├── Role: SIEM, log aggregation, alerting, detection rules
│   ├── OS: Ubuntu 22.04 LTS or Rocky Linux 9
│   ├── Components: Wazuh Manager, Elasticsearch, Kibana/OpenSearch
│   └── Management: Web UI at https://wazuh.hawkinsops.local
│
├── VM: Windows Server (AD Domain Controller)
│   ├── Role: Active Directory, DNS, domain services
│   ├── OS: Windows Server 2022
│   ├── Domain: hawkinsops.local
│   └── Services: AD DS, DNS, DHCP (optional)
│
├── VM: Windows 10/11 Endpoints (Multiple)
│   ├── Role: Domain-joined workstations for testing
│   ├── OS: Windows 10/11 Pro
│   └── Purpose: Simulate enterprise user endpoints
│
└── VM: Linux Endpoints (Multiple)
    ├── Role: Domain-joined or standalone Linux clients
    ├── OS: Ubuntu, CentOS, Debian
    └── Purpose: Simulate mixed-OS enterprise environment
```

---

## Network Architecture

### Network Segments

| VLAN/Subnet | Name | Purpose | IP Range |
|-------------|------|---------|----------|
| VLAN 10 | WAN/INTERNET | External connectivity | DHCP from ISP |
| VLAN 20 | MANAGEMENT | Admin access to infra | 192.168.10.0/24 |
| VLAN 50 | LAB_NETWORK | Main lab environment | 192.168.50.0/24 |
| VLAN 60 | DMZ | Exposed services (future) | 192.168.60.0/24 |
| VLAN 70 | ISOLATED_TEST | Air-gapped testing | 192.168.70.0/24 |

### Static IP Assignments (LAB_NETWORK - 192.168.50.0/24)

| Host | IP Address | Hostname | Role |
|------|------------|----------|------|
| pfSense LAN Interface | 192.168.50.1 | pfsense.hawkinsops.local | Gateway |
| Wazuh Manager | 192.168.50.10 | wazuh.hawkinsops.local | SIEM |
| Windows Server (AD DC) | 192.168.50.20 | dc01.hawkinsops.local | Domain Controller |
| PRIMARY_OS Linux | 192.168.50.100 | primary-os.hawkinsops.local | Operations Server |
| Windows Powerhouse | 192.168.50.101 | win-powerhouse.hawkinsops.local | Analyst Workstation |
| MINT-3 Linux | 192.168.50.102 | mint-3.hawkinsops.local | Monitored Endpoint |
| Windows Endpoint 1 | 192.168.50.110 | win-endpoint-01.hawkinsops.local | Test Endpoint |
| Windows Endpoint 2 | 192.168.50.111 | win-endpoint-02.hawkinsops.local | Test Endpoint |
| Linux Endpoint 1 | 192.168.50.120 | linux-endpoint-01.hawkinsops.local | Test Endpoint |

**DNS Server:** 192.168.50.20 (AD DC) with forwarder to 192.168.50.1 (pfSense) → external DNS

---

## Data Flow Architecture

### Log Collection Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        LOG SOURCES                              │
├─────────────────────────────────────────────────────────────────┤
│ • Windows Powerhouse (Wazuh Agent)                             │
│ • PRIMARY_OS Linux (Wazuh Agent)                               │
│ • MINT-3 Linux (Wazuh Agent)                                   │
│ • Windows Endpoints (Wazuh Agents)                             │
│ • Linux Endpoints (Wazuh Agents)                               │
│ • pfSense (Syslog → Wazuh)                                     │
│ • Windows Server AD DC (Wazuh Agent + Event Forwarding)        │
│ • Proxmox (Syslog → Wazuh)                                     │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                    Port 1514/1515 (Agent)
                    Port 514 (Syslog)
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│               WAZUH MANAGER (192.168.50.10)                     │
├─────────────────────────────────────────────────────────────────┤
│ • Agent log ingestion                                           │
│ • Syslog ingestion                                              │
│ • Log parsing and normalization                                 │
│ • Detection rule evaluation                                     │
│ • Alert generation                                              │
│ • Log archival                                                  │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                    Internal API
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│            ELASTICSEARCH / OPENSEARCH CLUSTER                   │
├─────────────────────────────────────────────────────────────────┤
│ • Indexed log storage                                           │
│ • Search queries                                                │
│ • Alert data                                                    │
│ • Agent status                                                  │
└─────────────────────────────────────────────────────────────────┘
                           ↓
                    API / Visualization
                           ↓
┌─────────────────────────────────────────────────────────────────┐
│              KIBANA / OPENSEARCH DASHBOARDS                     │
├─────────────────────────────────────────────────────────────────┤
│ • Web UI: https://wazuh.hawkinsops.local                       │
│ • Security dashboards                                           │
│ • Alert management                                              │
│ • Agent management                                              │
│ • Custom queries and visualizations                             │
└─────────────────────────────────────────────────────────────────┘
                           ↑
                  HTTPS Access from:
                           ↑
┌─────────────────────────────────────────────────────────────────┐
│         ANALYST WORKSTATIONS                                    │
├─────────────────────────────────────────────────────────────────┤
│ • Windows Powerhouse (192.168.50.101)                          │
│ • PRIMARY_OS Linux (192.168.50.100)                            │
└─────────────────────────────────────────────────────────────────┘
```

### Network Traffic Flow

```
INTERNET
   ↓
[ISP Router/Modem]
   ↓
pfSense WAN (DHCP or Static)
   ↓
pfSense Firewall Rules + NAT
   ↓
├─→ VLAN 20 (Management) → Proxmox Web UI, pfSense Web UI
├─→ VLAN 50 (Lab Network) → All VMs and endpoints
├─→ VLAN 60 (DMZ) → Future external-facing services
└─→ VLAN 70 (Isolated) → Malware analysis (no internet)
```

### Authentication Flow

```
User Login Attempt
   ↓
┌─────────────────────────────────────────────────┐
│ Is this a domain-joined machine?               │
└─────────────────────────────────────────────────┘
   ↓ YES                                  ↓ NO
   ↓                                      ↓
Windows Server AD DC          Local authentication
(192.168.50.20)              (standalone machines)
   ↓
Kerberos authentication
   ↓
Group Policy applied
   ↓
Wazuh agent logs authentication event
   ↓
Wazuh SIEM (alert on suspicious auth patterns)
```

---

## Security Monitoring Coverage

### What is Monitored

1. **Endpoint Activity**
   - Process execution (suspicious processes, privilege escalation)
   - File integrity monitoring (critical system files, config files)
   - Registry changes (Windows persistence mechanisms)
   - User authentication (failed logins, privilege changes)
   - Network connections (outbound C2 patterns, lateral movement)

2. **Network Activity**
   - pfSense firewall logs (blocked connections, port scans)
   - DNS queries (suspicious domains, DGA detection)
   - Traffic volume anomalies
   - Intrusion detection (Suricata on pfSense - planned)

3. **Infrastructure Activity**
   - Proxmox host logs (VM lifecycle, resource alerts)
   - Active Directory logs (account creation, group changes, GPO modifications)
   - Service availability (Wazuh agent status, service restarts)

4. **Application Activity**
   - Web server logs (if web services are deployed)
   - Database logs (if databases are deployed)
   - SSH/RDP access logs

### Detection Rules

**Current Rule Categories:**
- MITRE ATT&CK framework alignment
- Credential access attempts
- Lateral movement indicators
- Persistence mechanisms (startup items, scheduled tasks, services)
- Command and control patterns
- Data exfiltration indicators
- Privilege escalation attempts

**Custom Rules:**
- Lab-specific rules for testing scenarios
- Baseline deviation alerts (unusual processes, new network connections)

---

## Component Dependencies

### Critical Path

```
1. pfSense MUST be operational before other VMs can communicate
   ↓
2. DNS (AD DC) MUST be operational before domain joins
   ↓
3. Wazuh Manager MUST be operational before agent enrollment
   ↓
4. Agents can be enrolled and begin sending logs
```

### Service Dependencies

| Service | Depends On | Reason |
|---------|------------|--------|
| Wazuh Agents | pfSense, Wazuh Manager | Network connectivity, manager enrollment |
| Domain Joins | pfSense, AD DC, DNS | Network + directory services |
| Wazuh Dashboards | Wazuh Manager, Elasticsearch | Data source |
| Endpoint Internet Access | pfSense | Gateway/routing |
| All Web UIs | pfSense, DNS | Network routing, name resolution |

---

## Backup and Disaster Recovery

### What Must Be Backed Up

1. **Wazuh Configuration**
   - `/var/ossec/etc/ossec.conf`
   - Custom detection rules in `/var/ossec/etc/rules/`
   - Custom decoders in `/var/ossec/etc/decoders/`
   - API credentials

2. **pfSense Configuration**
   - Full config XML export from web UI (Diagnostics → Backup & Restore)

3. **Active Directory**
   - System State backup using Windows Server Backup
   - AD database backup

4. **Proxmox Configuration**
   - `/etc/pve/` directory (cluster config, VM configs)
   - VM backup images (optional, large storage requirement)

5. **Scripts and Automation**
   - `C:\HAWKINS_OPS\` (Windows Powerhouse)
   - `/home/raylee/HAWKINS_OPS/` (PRIMARY_OS)

### Backup Locations

- **Primary:** External USB HDD connected to PRIMARY_OS
- **Secondary:** Cloud backup (encrypted) - TBD
- **Offline:** Quarterly full backup to offline drive (stored separately)

---

## Scalability and Future Expansion

### Planned Additions

1. **Security Tools**
   - Velociraptor for endpoint forensics
   - TheHive for case management
   - MISP for threat intelligence
   - Security Onion for NSM (network security monitoring)

2. **Infrastructure**
   - Second Proxmox node (HA cluster)
   - NAS for centralized storage (TrueNAS or similar)
   - Separate monitoring stack (Prometheus + Grafana for infrastructure metrics)

3. **Endpoints**
   - macOS endpoint (if hardware available)
   - Additional Windows Server roles (SQL, Exchange, web server)
   - IoT/OT simulation devices (Raspberry Pi, Arduino)

4. **Network Segmentation**
   - Guest network VLAN
   - OT/ICS isolated network
   - Honeypot network

---

## Access Points and Management URLs

| Service | URL | Authentication |
|---------|-----|----------------|
| Proxmox | https://proxmox.hawkinsops.local:8006 | root + local password |
| pfSense | https://pfsense.hawkinsops.local | admin + local password |
| Wazuh Dashboard | https://wazuh.hawkinsops.local | admin + wazuh password |
| Windows Server RDP | RDP to 192.168.50.20 | Domain admin account |

**Note:** All credentials must be stored in a password manager (KeePassXC recommended, database stored in `C:\HAWKINS_OPS\secure\`).

---

## Health Check Summary

A healthy HawkinsOps environment has:
- All Wazuh agents reporting status "Active" in the dashboard
- pfSense firewall passing traffic on all VLANs
- DNS resolution working for all `.hawkinsops.local` hostnames
- No critical alerts in Wazuh dashboard (expected: some info/warning alerts)
- All VMs pingable from Windows Powerhouse
- Domain-joined machines able to authenticate against AD DC
- Wazuh dashboard accessible from Windows Powerhouse and PRIMARY_OS

See `30_services_matrix.md` for detailed health check commands.

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee
