# docs/ - Reference Documentation

This directory contains reference documentation, architectural guides, runbooks, and procedural documentation.

## Directory Structure

```
docs/
├── blueprints/            # System architecture and rebuild documentation
├── migration-patterns/    # Filesystem migration project patterns
├── wazuh/                 # Wazuh deployment guides (existing)
└── VERIFY_COMMANDS_POWERSHELL.md (existing)
```

---

## blueprints/

**Source:** hawkins_ops/blueprints/rebuild_pack
**Purpose:** System architecture and rebuild procedures

### rebuild_pack/

Complete documentation for system rebuild and infrastructure setup.

| Document | Purpose |
|----------|---------|
| `00_index.md` | Master index of all blueprint documents |
| `01_hawkinsops_high_level_architecture.md` | System architecture overview |
| `02_rebuild_master_runbook.md` | Step-by-step rebuild procedures |
| `10_windows_powerhouse_rebuild.md` | Windows workstation setup guide |
| `20_primary_os_rebuild_overview.md` | Primary OS installation overview |
| `30_services_matrix.md` | Services and dependencies matrix |
| `40_sample_scripts_and_snippets.md` | Reusable PowerShell/Bash snippets |
| `assumptions.md` | Project assumptions and constraints |

**Use Case:** System rebuilds, disaster recovery, new workstation setup

---

## migration-patterns/

**Source:** RH_MIGRATION_2026_V2 (private repo)
**Purpose:** Filesystem migration project documentation and configuration patterns

### Documentation

| Document | Purpose |
|----------|---------|
| `AGENTS_PROJECT.md` | Complete migration project specification |
| `PROJECT_SUMMARY.md` | Phase definitions and milestones |
| `MIGRATION_GUIDE_V1_TO_V2_02-08-2026.md` | V1 to V2 upgrade procedures |
| `ENTRYPOINT.md` | Project startup guide |
| `CLAUDE.md` | Claude Code instructions for migration |
| `CODEX.md` | Reference pointer to codex documentation |

### Configuration

| File | Purpose |
|------|---------|
| `project_config.json` | Migration configuration schema and rules |
| `migration.gitignore` | Recommended .gitignore patterns for migration projects |
| `FILES_CREATED_02-08-2026.md` | Generated file inventory (dated artifact) |

**Related Tools:** See `tools/migration-tools/validate_config.ps1`

**Key Patterns:**
- Phase-based execution model (11 phases)
- Safety-first with dry-run/execute modes
- Timestamped output routing
- Filename convention: `name_MM-DD-YYYY.ext`
- Quarantine before delete workflow

---

## Existing Documentation

### wazuh/
Wazuh SIEM deployment guides and rule management documentation

### VERIFY_COMMANDS_POWERSHELL.md
PowerShell commands for verifying detection rule counts

---

## Documentation Standards

When adding new documentation:
1. Use Markdown format (.md)
2. Include a clear purpose/summary at the top
3. Provide executable examples where applicable
4. Cross-reference related tools and docs
5. Update this README with new entries
6. Follow the repository's filename convention
