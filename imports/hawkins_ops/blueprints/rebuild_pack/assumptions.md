# HawkinsOps Rebuild Pack - Assumptions

## Purpose

This document lists all assumptions made during the design of the HawkinsOps rebuild pack. If any assumption does not match your actual environment, adjustments must be made to the rebuild procedures.

**CRITICAL: Read this file FIRST before starting any rebuild operations.**

---

## Network Assumptions

### ASSUMPTION #1: IP Address Ranges

**Assumption:**
- Lab network uses subnet `192.168.50.0/24`
- Management network uses subnet `192.168.10.0/24`
- DMZ network uses subnet `192.168.60.0/24` (future use)
- Isolated test network uses subnet `192.168.70.0/24` (future use)

**Impact if wrong:**
- All IP addresses in documentation will be incorrect
- Network connectivity will fail
- DNS records will point to wrong IPs
- Firewall rules will not match traffic

**How to adjust:**
1. Decide on your actual subnet ranges
2. Use find-replace in all documentation files:
   - Replace `192.168.50.` with your lab subnet prefix
   - Replace `192.168.10.` with your management subnet prefix
3. Update static IP assignments in `01_hawkinsops_high_level_architecture.md`
4. Update firewall rules and DHCP scopes in pfSense configuration
5. Update DNS A records in Active Directory

---

### ASSUMPTION #2: Static IP Assignments

**Assumption:**
The following static IPs are assigned:

| Host | IP Address |
|------|------------|
| pfSense (LAN) | 192.168.50.1 |
| Wazuh Manager | 192.168.50.10 |
| AD DC (DC01) | 192.168.50.20 |
| PRIMARY_OS Linux | 192.168.50.100 |
| Windows Powerhouse | 192.168.50.101 |
| MINT-3 Endpoint | 192.168.50.102 |
| Windows Endpoint 01 | 192.168.50.110 |
| Windows Endpoint 02 | 192.168.50.111 |
| Linux Endpoint 01 | 192.168.50.120 |
| Proxmox (Management) | 192.168.10.10 |

**Impact if wrong:**
- Hosts will not be reachable at documented IPs
- DNS records will be incorrect
- Firewall rules may not apply correctly
- Wazuh agents will fail to connect to manager

**How to adjust:**
1. Choose your preferred IP addressing scheme
2. Update all references in documentation files
3. Update DNS A records after AD DC installation
4. Update DHCP reservations (if using DHCP instead of static)
5. Update Wazuh agent configurations with correct manager IP

---

### ASSUMPTION #3: DNS Domain Name

**Assumption:**
- Active Directory domain name: `hawkinsops.local`
- All hosts use `.hawkinsops.local` FQDN suffix

**Impact if wrong:**
- Domain join operations will fail
- DNS resolution will not work as documented
- Kerberos authentication will fail
- SSL certificates (if issued internally) will have wrong CN

**How to adjust:**
1. Choose your actual domain name (e.g., `mylab.local`, `homelab.internal`)
2. Use find-replace across all documentation: `hawkinsops.local` → `yourdomain.local`
3. Update domain join commands in all runbooks
4. Update DNS zone creation in AD DC setup
5. Update pfSense DNS settings

---

### ASSUMPTION #4: Default Gateway

**Assumption:**
- Default gateway for all lab hosts: `192.168.50.1` (pfSense LAN interface)
- Proxmox uses management gateway: `192.168.10.1` (pfSense management interface or separate physical router)

**Impact if wrong:**
- Hosts will not have internet connectivity
- Inter-VLAN routing will fail
- Outbound traffic will not be NAT'd properly

**How to adjust:**
1. Identify your actual gateway IP(s)
2. Update network configuration commands in all runbooks
3. Update pfSense WAN interface configuration
4. Ensure NAT rules are configured correctly on gateway

---

### ASSUMPTION #5: Primary DNS Server

**Assumption:**
- Primary DNS server: `192.168.50.20` (AD DC)
- Secondary DNS: `192.168.50.1` (pfSense)
- pfSense forwards to `8.8.8.8` and `8.8.4.4` (Google DNS)

**Impact if wrong:**
- `.hawkinsops.local` names will not resolve
- Internet domain resolution may fail
- Domain join operations will fail

**How to adjust:**
1. Choose your DNS architecture (AD-integrated, separate DNS server, etc.)
2. Update DNS server settings in all network configurations
3. Update pfSense DNS forwarder/resolver settings
4. Update DHCP-distributed DNS server addresses

---

## Hardware Assumptions

### ASSUMPTION #6: Proxmox Host Resources

**Assumption:**
- Proxmox host has minimum 32GB RAM
- Proxmox host has minimum 500GB storage (1TB preferred)
- Proxmox host has CPU with virtualization extensions enabled (Intel VT-x / AMD-V)
- Proxmox host has dual NICs (optional but recommended)

**Impact if wrong:**
- Insufficient resources to run all planned VMs simultaneously
- Performance degradation
- Storage exhaustion

**How to adjust:**
1. Assess actual hardware specs
2. If RAM < 32GB:
   - Reduce VM RAM allocations
   - Prioritize critical VMs (pfSense, Wazuh, DC01)
   - Use memory ballooning/overcommitment (with performance impact)
3. If storage < 500GB:
   - Reduce VM disk sizes
   - Use thin provisioning
   - Plan external NAS/storage
4. If single NIC:
   - Use software VLAN tagging (all traffic on one physical interface)
   - Accept potential performance bottleneck

---

### ASSUMPTION #7: Windows Powerhouse is Bare Metal

**Assumption:**
- Windows 11 Powerhouse is installed on physical hardware (not a VM)
- Has sufficient resources for daily analyst work
- Minimum: 16GB RAM, 500GB SSD, 6+ core CPU

**Impact if wrong:**
- If it's a VM, some instructions (e.g., BIOS settings) are not applicable
- Performance may vary

**How to adjust:**
1. If Windows Powerhouse is a VM:
   - Skip BIOS-related steps
   - Ensure VM has adequate resources allocated
   - Follow VM-specific installation steps (mount ISO in hypervisor)
2. If lower specs:
   - Expect slower performance
   - Close unnecessary applications
   - Consider upgrading hardware

---

### ASSUMPTION #8: PRIMARY_OS is Bare Metal or Dedicated VM

**Assumption:**
- PRIMARY_OS runs on physical hardware or dedicated VM (not within Proxmox cluster)
- Has persistent storage
- Minimum: 8GB RAM, 250GB SSD

**Impact if wrong:**
- If within Proxmox cluster, depends on Proxmox being operational
- Creates circular dependency for backups

**How to adjust:**
1. If PRIMARY_OS is Proxmox VM:
   - Accept dependency on Proxmox
   - Ensure PRIMARY_OS VM starts early in boot order
   - Use external backup location (not dependent on Proxmox)
2. If bare metal:
   - PRIMARY_OS can serve as backup host for Proxmox configs

---

## Software Assumptions

### ASSUMPTION #9: Software Versions

**Assumption:**
The rebuild pack assumes these software versions (or newer):

| Software | Version |
|----------|---------|
| Proxmox VE | 8.x |
| pfSense | 2.7.x |
| Windows Server | 2022 |
| Windows 11 | 23H2 or later |
| Linux Mint | 21.x |
| Ubuntu Server | 22.04 LTS |
| Wazuh | 4.x (latest stable) |

**Impact if wrong:**
- Older versions may have different installation steps
- Newer versions may have breaking changes
- Configuration file formats may differ
- CLI commands may have changed

**How to adjust:**
1. Check official documentation for your specific version
2. Note differences in installation procedures
3. Test configuration compatibility
4. Update documentation with version-specific steps

---

### ASSUMPTION #10: Wazuh All-in-One Installation

**Assumption:**
- Wazuh is installed using the all-in-one installation script
- Single-node deployment (Wazuh Manager, Indexer, Dashboard on one VM)
- No cluster/high-availability setup

**Impact if wrong:**
- Multi-node Wazuh clusters have different installation procedures
- Configuration files are distributed across nodes
- Backup procedures differ

**How to adjust:**
1. If deploying Wazuh cluster:
   - Follow official Wazuh cluster documentation
   - Update backup procedures to cover all nodes
   - Update health check scripts for cluster status
2. If using separate Indexer/Dashboard nodes:
   - Document each node's IP and role
   - Update connectivity checks

---

### ASSUMPTION #11: Windows Uses Local Admin Then Domain Join

**Assumption:**
- Windows machines are installed with local admin account first
- Domain join occurs post-installation
- Local admin account remains active after domain join (for recovery)

**Impact if wrong:**
- Some organizations disable local admin after domain join
- Cloud-joined or Azure AD-joined machines have different procedures

**How to adjust:**
1. If local admin must be disabled:
   - Ensure domain admin access is always available
   - Document domain admin credentials securely
   - Have offline recovery media (password reset disk)
2. If Azure AD / cloud-joined:
   - Different authentication flow
   - May not integrate with on-prem AD DC

---

## Service Assumptions

### ASSUMPTION #12: Wazuh Manager Port

**Assumption:**
- Wazuh agents connect to manager on ports 1514 (agent communication) and 1515 (enrollment)
- Default Wazuh installation uses these ports

**Impact if wrong:**
- Agents will fail to connect
- Firewall rules will not allow traffic

**How to adjust:**
1. Check Wazuh Manager configuration: `/var/ossec/etc/ossec.conf`
2. Identify actual ports used
3. Update firewall rules on all hosts
4. Update agent installation commands with correct ports

---

### ASSUMPTION #13: Active Directory Functional Level

**Assumption:**
- AD forest/domain functional level: Windows Server 2016 or higher
- No legacy domain controllers (pre-2016)

**Impact if wrong:**
- Some security features may not be available
- Group Policy functionality may differ

**How to adjust:**
1. If lower functional level required (legacy compatibility):
   - Check which features are unavailable at your level
   - Adjust Group Policy and security configurations accordingly
2. Document functional level in environment documentation

---

### ASSUMPTION #14: No External Certificate Authority

**Assumption:**
- All SSL/TLS certificates are self-signed
- No internal PKI/CA infrastructure
- Browser warnings are expected and accepted

**Impact if wrong:**
- If internal CA exists, certificates should be properly signed
- Proper cert validation reduces MITM risk

**How to adjust:**
1. If internal CA is available:
   - Issue certificates from CA for all web UIs (Wazuh, pfSense, Proxmox)
   - Distribute CA root cert to all endpoints
   - Update installation procedures to import/trust CA
2. If using Let's Encrypt or external CA:
   - Ensure external DNS records exist
   - Configure ACME client for cert renewal

---

## Backup and Recovery Assumptions

### ASSUMPTION #15: No Automated Backup Solution (Initially)

**Assumption:**
- Backups are manual or semi-automated via scripts
- No enterprise backup software (Veeam, Commvault, etc.)
- Backups stored on external USB drive or NAS

**Impact if wrong:**
- If enterprise backup exists, integrate with it
- Automated backups reduce risk of data loss

**How to adjust:**
1. If backup solution available:
   - Configure backup jobs for critical VMs
   - Document backup/restore procedures
   - Test restore regularly
2. If no backup solution:
   - Implement manual backup schedule
   - Document backup locations
   - Practice restore procedures

---

### ASSUMPTION #16: Single Proxmox Node (No Cluster)

**Assumption:**
- Proxmox runs on single physical host
- No high-availability cluster
- No shared storage (Ceph, NFS, etc.)

**Impact if wrong:**
- Clustered Proxmox has different configuration
- Shared storage changes VM backup/migration procedures

**How to adjust:**
1. If Proxmox cluster:
   - Document all cluster nodes
   - Update health check scripts for cluster status
   - Use cluster-aware backup strategies (HA, live migration)
2. If shared storage:
   - Document storage configuration
   - Update backup procedures to include storage layer

---

## Access and Authentication Assumptions

### ASSUMPTION #17: Password-Based Authentication (Initially)

**Assumption:**
- SSH uses password authentication initially
- SSH keys are optional and set up post-deployment
- Local accounts exist on all machines for recovery

**Impact if wrong:**
- Key-based auth is more secure but requires key distribution
- Password-only is less secure for long-term use

**How to adjust:**
1. If SSH keys are mandatory:
   - Generate SSH keys before deployment
   - Distribute public keys during installation
   - Disable password auth after keys are verified
2. If multi-factor auth is required:
   - Plan MFA implementation (Google Authenticator, FIDO2, etc.)
   - Document MFA setup procedures

---

### ASSUMPTION #18: All Admin Passwords Stored in KeePassXC

**Assumption:**
- Single KeePassXC database stores all credentials
- Database located at `C:\HAWKINS_OPS\secure\hawkinsops.kdbx` (Windows) and mirrored to PRIMARY_OS
- Master password is memorized (not written down)

**Impact if wrong:**
- If no password manager, risk of weak/reused passwords
- If different password manager, file locations differ

**How to adjust:**
1. If using different password manager (1Password, Bitwarden, LastPass):
   - Adjust file paths in documentation
   - Ensure password manager is accessible from both Windows and Linux
2. If no password manager:
   - **Strongly recommended to implement one**
   - Document all passwords securely (encrypted file, physical safe)

---

## Monitoring and Alerting Assumptions

### ASSUMPTION #19: Wazuh is Primary SIEM

**Assumption:**
- Wazuh is the sole SIEM/logging platform
- No Splunk, ELK, or other SIEM solutions
- All security monitoring flows through Wazuh

**Impact if wrong:**
- If multiple SIEMs, logs may need to be duplicated
- Alert correlation may occur across platforms

**How to adjust:**
1. If secondary SIEM exists:
   - Configure log forwarding (syslog, filebeat, etc.)
   - Document which logs go where
   - Ensure no critical logs are missed
2. If replacing Wazuh:
   - Adapt agent deployment procedures
   - Update all references to Wazuh-specific features

---

### ASSUMPTION #20: No Email Alerting Configured (Initially)

**Assumption:**
- Wazuh alerts are viewed in dashboard only
- No email/SMS/Slack notifications configured initially
- Alerting is added post-deployment

**Impact if wrong:**
- If email alerting is critical, configure during initial setup

**How to adjust:**
1. If email alerting required:
   - Obtain SMTP server details (Gmail, Office 365, internal mail server)
   - Configure Wazuh email integration during Phase 4 (Wazuh deployment)
   - Test alert delivery
2. If other notification channels needed (Slack, PagerDuty):
   - Plan integration points
   - Document configuration steps

---

## Scalability and Future Growth Assumptions

### ASSUMPTION #21: Initial Deployment is ~10 Hosts

**Assumption:**
- Initial environment has approximately 10 managed hosts:
  - Proxmox (1)
  - pfSense (1)
  - Wazuh Manager (1)
  - AD DC (1)
  - Windows Powerhouse (1)
  - PRIMARY_OS (1)
  - MINT-3 (1)
  - Test endpoints (3)
- Environment will grow but start small

**Impact if wrong:**
- If many more hosts planned, scale infrastructure accordingly
- Wazuh may need multi-node deployment for >50 agents

**How to adjust:**
1. If >20 hosts planned:
   - Consider Wazuh cluster (manager, worker nodes)
   - Scale Proxmox resources (more RAM, CPU)
   - Plan IP address ranges to accommodate growth
2. If >100 hosts:
   - Enterprise-grade infrastructure required
   - Consider commercial SIEM alternatives
   - Implement configuration management (Ansible, Puppet)

---

### ASSUMPTION #22: No Production Workloads

**Assumption:**
- HawkinsOps is a lab/training environment
- No production business applications
- Downtime is acceptable for maintenance/learning
- Security is important but not life-critical

**Impact if wrong:**
- If production workloads exist, change management is critical
- High-availability and redundancy become mandatory

**How to adjust:**
1. If production workloads:
   - Implement HA for critical services (clustered AD, pfSense failover)
   - Schedule maintenance windows
   - Implement change control procedures
   - Test all changes in dev environment first
2. If mission-critical:
   - Consider professional support contracts
   - Implement 24/7 monitoring
   - Plan disaster recovery with RTO/RPO targets

---

## Miscellaneous Assumptions

### ASSUMPTION #23: Internet Connectivity Available

**Assumption:**
- Reliable internet connection available during rebuild
- Sufficient bandwidth for ISO downloads (10+ GB total)
- No restrictive firewalls blocking package repositories

**Impact if wrong:**
- Cannot download ISOs, packages, updates
- Offline installation media required

**How to adjust:**
1. If limited/no internet:
   - Pre-download all ISOs and store on USB drive
   - Setup local package mirrors (apt-mirror, local yum repo)
   - Use offline installation methods
2. If restrictive firewall:
   - Document required outbound URLs/IPs
   - Whitelist package repositories, Microsoft/Google services

---

### ASSUMPTION #24: English (US) Locale and Keyboard

**Assumption:**
- All systems use English (US) language
- US keyboard layout
- US timezone (adjust per user's location)

**Impact if wrong:**
- Different keyboard layouts may affect special characters
- Different locales may affect date/time formats in logs

**How to adjust:**
1. If different locale:
   - Select appropriate language during OS installation
   - Update keyboard layout settings
   - Adjust timezone in all systems
2. If multilingual environment:
   - Document language settings per host
   - Ensure logging/alerting handles character encoding

---

### ASSUMPTION #25: No Compliance Requirements (Initially)

**Assumption:**
- No PCI-DSS, HIPAA, NIST 800-53, or other compliance frameworks required
- Security is based on best practices, not regulatory mandates
- Audit logging is for learning, not compliance

**Impact if wrong:**
- Compliance frameworks add specific controls
- Audit requirements are more stringent
- Documentation must be compliance-ready

**How to adjust:**
1. If compliance required:
   - Identify applicable framework(s)
   - Map HawkinsOps controls to framework requirements
   - Implement missing controls (encryption at rest, access logging, etc.)
   - Engage compliance auditor for validation
2. Document compliance status in separate file

---

## Summary of Critical Assumptions

**Top 5 assumptions most likely to require adjustment:**

1. **Network IP ranges** (192.168.50.x, etc.) - Adjust if your network uses different subnets
2. **Domain name** (hawkinsops.local) - Adjust if you prefer different domain
3. **Proxmox resources** (32GB RAM, 500GB storage) - Scale based on actual hardware
4. **Software versions** (Wazuh 4.x, pfSense 2.7.x, etc.) - Update procedures if using different versions
5. **Authentication method** (passwords → SSH keys) - Enhance security post-deployment

---

## How to Update This File

As you customize HawkinsOps for your environment:

1. **Document deviations:** When you change an assumption, note it here.
2. **Update impact:** Describe how the change affects other components.
3. **Update procedures:** Adjust runbooks to reflect your actual configuration.
4. **Version control:** Commit changes to Git (if using version control).

**Example deviation entry:**

```
DEVIATION #1: Changed lab network subnet
- Original assumption: 192.168.50.0/24
- Actual configuration: 10.0.100.0/24
- Date changed: 2025-11-20
- Files updated: All runbooks, architecture doc, services matrix
- Reason: Avoid conflict with existing home network
```

---

**Document Version:** 1.0
**Last Updated:** 2025-11-18
**Maintained By:** Raylee

**READ THIS FILE BEFORE EVERY REBUILD TO ENSURE ASSUMPTIONS ARE STILL VALID.**
