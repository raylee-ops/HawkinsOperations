# HawkinsOps Rebuild Pack - Index

## Purpose

This rebuild pack contains complete documentation for reconstructing the HawkinsOps Security Operations Center from bare metal. HawkinsOps is not a toy lab—it is a production-grade personal SOC environment designed to demonstrate enterprise-level security operations capabilities for SOC analyst positions.

**Owner:** Raylee
**Target Career:** Tier 1 SOC Analyst → Cloud/IAM/OT Security
**Hire-Ready Target:** May 1, 2026
**Use Case:** Job interview proof-of-capability + ongoing security operations training

---

## What is HawkinsOps?

HawkinsOps is a multi-node security operations center consisting of:
- Windows 11 powerhouse workstation (analyst desktop + monitoring)
- Linux Mint PRIMARY_OS (source-of-truth server node)
- Linux Mint MINT-3 (monitored endpoint)
- Proxmox virtualization cluster
- pfSense firewall/router
- Wazuh SIEM (manager + agents across all nodes)
- Active Directory domain services
- Multiple Windows/Linux endpoints for detection testing

The environment mirrors real enterprise infrastructure with logging, monitoring, alerting, and security hardening applied throughout.

---

## Rebuild Pack Files

| File Name | Purpose | Priority | Dependencies |
|-----------|---------|----------|--------------|
| `00_index.md` | This file - table of contents | [CRITICAL] | None |
| `assumptions.md` | All assumptions made during rebuild design | [CRITICAL] | Read FIRST |
| `01_hawkinsops_high_level_architecture.md` | Architecture overview, components, data flows | [CRITICAL] | None |
| `02_rebuild_master_runbook.md` | Complete bare-metal rebuild procedure | [CRITICAL] | All other files |
| `30_services_matrix.md` | Host/service inventory with health checks | [CRITICAL] | Architecture doc |
| `10_windows_powerhouse_rebuild.md` | Windows 11 workstation rebuild steps | [IMPORTANT] | Master runbook |
| `20_primary_os_rebuild_overview.md` | PRIMARY_OS Linux server rebuild overview | [IMPORTANT] | Master runbook |
| `40_sample_scripts_and_snippets.md` | Script examples for common tasks | [IMPORTANT] | Component runbooks |

---

## How to Use This Pack

### Scenario 1: Complete Disaster Recovery
1. Read `assumptions.md` first - verify all assumptions match your environment.
2. Read `01_hawkinsops_high_level_architecture.md` to understand the target state.
3. Follow `02_rebuild_master_runbook.md` from start to finish.
4. Reference component-specific runbooks (10, 20, etc.) as needed.
5. Use `30_services_matrix.md` to verify each component is healthy.

### Scenario 2: Single Component Rebuild
1. Check `30_services_matrix.md` to identify dependencies.
2. Go directly to the component-specific runbook (e.g., `10_windows_powerhouse_rebuild.md`).
3. Verify assumptions in `assumptions.md` are still valid.
4. Execute rebuild steps for that component only.
5. Verify integration with other components using health checks.

### Scenario 3: New Lab Build (No Existing Infrastructure)
1. Read `assumptions.md` and adjust IP ranges/hostnames for your environment.
2. Study `01_hawkinsops_high_level_architecture.md` to understand component relationships.
3. Follow `02_rebuild_master_runbook.md` in exact order.
4. Document any deviations in a separate `local_customizations.md` file.

---

## Maintenance Notes

**Last Updated:** 2025-11-18
**Version:** 1.0
**Created By:** Claude Code (HawkinsOps Rebuild Architect)

### Update Triggers
Update this pack when:
- Major architecture changes occur (new VMs, new services)
- Network topology changes (new VLANs, IP ranges)
- Critical software versions change (Wazuh major version, Proxmox upgrade)
- New security controls are added that affect multiple hosts

### Where This Pack Lives
- **Primary:** `C:\HAWKINS_OPS\blueprints\rebuild_pack\` (Windows powerhouse)
- **Mirror:** `/home/raylee/HAWKINS_OPS/blueprints/rebuild_pack/` (PRIMARY_OS Linux)
- **Sync Method:** Manual file copy or sync tool (TBD in environment setup)

---

## Quick Reference

**Emergency Contact:** N/A (personal lab)
**Primary Documentation Location:** This directory
**Backup Location:** PRIMARY_OS Linux mirror
**Estimated Full Rebuild Time:** 8-12 hours (depends on ISO download speeds and familiarity)

---

## File Reading Order for First-Time Users

1. `assumptions.md` ← Start here
2. `01_hawkinsops_high_level_architecture.md`
3. `30_services_matrix.md`
4. `02_rebuild_master_runbook.md`
5. Component-specific runbooks as needed

---

**Note:** This is a living document. As HawkinsOps evolves, update this index to reflect new components, changed priorities, or revised procedures.
