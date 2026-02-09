# imports/ - Raw Repository Staging Area

This directory contains the **raw, unprocessed imports** from consolidated GitHub repositories. Content here serves as an archive and staging area before curation into final locations.

## Purpose

- **Archive:** Preserves original directory structure from source repos
- **Staging:** Raw content before processing/organization
- **Reference:** Source material for understanding original context

## Do NOT Modify

Content in `imports/` should remain **read-only**. Curated versions exist in final locations (see Consolidated Content Map below).

---

## Source Repositories

### hawkinsops-framework/
**Source:** raylee-ops/hawkinsops-framework
**Imported:** 2026-02-09
**Content:**
- System/Scripts/ - Bash automation utilities
- System/Config/ - CLI aliases and configuration
- README.md

**Status:** ✅ Curated to `tools/framework-scripts/`

---

### hawkins_ops/
**Source:** raylee-ops/hawkins_ops
**Imported:** 2026-02-09
**Content:**
- blueprints/rebuild_pack/ - System architecture documentation
- scripts/autosync.ps1 - Windows sync automation
- README.md

**Status:** ✅ Curated to `tools/windows-automation/` and `docs/blueprints/`

---

### hawkinsops-site/
**Source:** raylee-ops/hawkinsops-site
**Imported:** 2026-02-09
**Content:**
- hawkinsops-v2/ - Public website HTML and branding assets

**Status:** ✅ Curated to `content/website/`

---

### RH_MIGRATION_2026_V2/
**Source:** raylee-ops/RH_MIGRATION_2026_V2 (private)
**Imported:** 2026-02-09
**Content:**
- *.md - Migration project documentation
- project_config.json - Migration configuration patterns
- tools/validate_config.ps1 - PowerShell validation utility
- migration.gitignore - Recommended exclusion patterns

**Status:** ✅ Curated to `docs/migration-patterns/` and `tools/migration-tools/`

---

## Consolidated Content Map

| Original Location | Final Location | Type |
|-------------------|----------------|------|
| hawkinsops-framework/System/Scripts/ | tools/framework-scripts/ | Bash scripts |
| hawkinsops-framework/System/Config/ | tools/framework-scripts/ | Config files |
| hawkins_ops/blueprints/rebuild_pack/ | docs/blueprints/rebuild_pack/ | Documentation |
| hawkins_ops/scripts/autosync.ps1 | tools/windows-automation/ | PowerShell |
| hawkinsops-site/hawkinsops-v2/ | content/website/hawkinsops-v2/ | Website |
| RH_MIGRATION_2026_V2/*.md | docs/migration-patterns/ | Documentation |
| RH_MIGRATION_2026_V2/project_config.json | docs/migration-patterns/ | Config |
| RH_MIGRATION_2026_V2/tools/ | tools/migration-tools/ | Scripts |

---

## What Was Excluded

**Not imported (outputs/artifacts/secrets):**
- Data/, logs/, workspace/ directories (run artifacts)
- vault/ directories (sensitive data)
- .env, *.token, *.key files (secrets)
- node_modules/, venv/ (dependencies)

**Sanitization applied:**
- No git history merged (copy-import only)
- No credentials or sensitive data
- No build artifacts or generated outputs
