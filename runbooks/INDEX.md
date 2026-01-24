# Runbooks Index

## Overview

Operational procedures for daily SOC operations, maintenance, and administration.

---

## Runbook Categories

| Category | Count | Purpose |
|----------|-------|---------|
| Daily Operations | 3 | Shift handoff, monitoring, triage |
| Maintenance | 2 | Updates, backups, health checks |
| Administration | 2 | User management, configuration |

---

## Daily Operations

### RB-001: Shift Handoff Procedure
- Review open incidents
- Check alert queue status
- Document ongoing investigations
- Transfer ownership of active cases

### RB-002: Alert Triage Workflow
- Initial alert assessment
- Severity classification
- Escalation criteria
- Documentation requirements

### RB-003: Daily Health Check
- SIEM connectivity verification
- Agent status review
- Log ingestion validation
- Queue depth monitoring

---

## Maintenance

### RB-004: Weekly Maintenance
- Rule updates and tuning
- False positive review
- Performance optimization
- Backup verification

### RB-005: Monthly Review
- Detection coverage assessment
- MITRE ATT&CK gap analysis
- Playbook updates
- Metrics reporting

---

## Administration

### RB-006: Wazuh Agent Deployment
- Agent installation steps
- Registration process
- Group assignment
- Verification checklist

### RB-007: Rule Deployment Process
- Development workflow
- Testing requirements
- Deployment steps
- Rollback procedure

---

## Quick Reference

| Task | Runbook | Time |
|------|---------|------|
| Start of shift | RB-001 | 15 min |
| New alert | RB-002 | 5 min |
| Morning check | RB-003 | 10 min |
| Weekly maint | RB-004 | 1 hour |
| New endpoint | RB-006 | 30 min |
| New rule | RB-007 | 1 hour |

---

[← Back to Main README](../README.md)
