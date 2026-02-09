# tools/ - Automation & Utility Scripts

This directory contains automation scripts, utilities, and helper tools consolidated from multiple repositories.

## Directory Structure

```
tools/
├── framework-scripts/     # Cross-platform bash automation
├── windows-automation/    # Windows-specific PowerShell tools
├── migration-tools/       # Filesystem migration utilities
├── import/                # Content import scripts (existing)
└── security-automation/   # Security automation configs (existing)
```

---

## framework-scripts/

**Source:** hawkinsops-framework
**Platform:** Linux/macOS (Bash)
**Purpose:** Cross-platform automation and productivity utilities

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `auto_report` | Automated reporting utility | `./auto_report` |
| `loglab` | Logging framework for operations | `./loglab [args]` |
| `opsnote` | Quick note-taking tool | `./opsnote "message"` |
| `setup_scriptpack_2_0.sh` | Cross-platform setup installer | `bash setup_scriptpack_2_0.sh` |
| `hawkins_aliases.sh` | CLI aliases and shortcuts | `source hawkins_aliases.sh` |

**Installation:**
```bash
# Make scripts executable
chmod +x tools/framework-scripts/*

# Source aliases in your shell profile
echo "source $(pwd)/tools/framework-scripts/hawkins_aliases.sh" >> ~/.bashrc
```

---

## windows-automation/

**Source:** hawkins_ops
**Platform:** Windows (PowerShell)
**Purpose:** Windows-specific automation and sync utilities

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `autosync.ps1` | Windows directory sync automation | `pwsh autosync.ps1 -Mode Execute` |

**Usage:**
```powershell
# Run sync automation
pwsh -NoProfile -ExecutionPolicy Bypass -File tools/windows-automation/autosync.ps1
```

---

## migration-tools/

**Source:** RH_MIGRATION_2026_V2
**Platform:** Windows (PowerShell)
**Purpose:** Filesystem migration configuration validation

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `validate_config.ps1` | Validates migration config JSON | `pwsh validate_config.ps1 -ConfigPath <path>` |

**Related Documentation:** See `docs/migration-patterns/` for full migration project docs

---

## Existing Directories

### import/
Legacy content import script (marked WIP/unreliable)

### security-automation/
Security automation configurations (scaffolded)

---

## Script Safety Guidelines

1. **Always test scripts in dry-run mode first** (if supported)
2. **Review scripts before execution** - Understand what they do
3. **Use absolute paths** when possible
4. **Check execution policy** for PowerShell scripts
5. **Verify permissions** for Bash scripts (chmod +x)

## Adding New Tools

When adding new automation scripts:
1. Choose the appropriate subdirectory by platform/purpose
2. Include inline documentation (comments)
3. Update this README
4. Test thoroughly before committing
5. Exclude any generated outputs via .gitignore
