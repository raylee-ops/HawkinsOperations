# AGENTS_PROJECT.md — RH_MIGRATION_2026_V2

**Location:** `C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\AGENTS_PROJECT.md`
**Purpose:** Single source of truth for all AI agents working on this project
**Last Updated:** 2026-02-08

---

## Identity & Context

You are assisting **Raylee Hawkins** with **RH_MIGRATION_2026_V2** — a systematic, phased filesystem reorganization using deterministic classification + Tier 2.5 semantic enhancement.

**Operator Profile:**
- 23yo factory supervisor → cybersecurity career transition (SOC analyst target)
- Learning style: "controlled chaos" — rapid iteration, pattern recognition
- September 2026 employment deadline (Huntsville AL preferred)

**Project Status:** Phase 00 (Baseline) completed. Phases 01-08 pending.

---

## Project Structure (MEMORIZE THIS)

```
C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\
├── SRC\                    ← Runnable scripts/modules ONLY
│   ├── run.ps1             ← Single gatekeeper entry point
│   ├── modules\            ← Modular components (classifier, planner, mover, etc.)
│   ├── rules\              ← Classification/rename/dedup rules (YAML)
│   └── templates\          ← Output templates
├── OUTPUTS\                ← All run artifacts (NEVER mix with SRC)
│   └── phase_XX\
│       └── run_MM-DD-YYYY_HHMMSS\
│           ├── plan.csv
│           ├── runlog.txt
│           ├── summary_MM-DD-YYYY.md
│           ├── metrics.json
│           ├── rollback.ps1
│           └── evidence\
├── PROOF_PACK\             ← Curated recruiter-ready output
│   ├── evidence\
│   ├── results\
│   └── code_excerpt\
└── agent_assets\           ← Prompts, policies, notes for agents
    ├── prompts\
    ├── policies\
    └── notes\
```

---

## NON-NEGOTIABLE RULES (Enforce Strictly)

### 1. NO DELETES. NO OVERWRITES.
- **NEVER** delete files permanently
- **NEVER** overwrite existing files without backup
- Collision policy: suffix `_01`, `_02`, etc.
- Quarantine uncertain files to `C:\RH\TEMPORARY`

### 2. DryRun First (Always)
- **Every** move/rename/dedup operation must run in DryRun mode first
- Generate plan files showing what will happen
- Require explicit approval before execution

### 3. Scan Roots vs Quarantine (No Full C:\ Scans)
**Scan these only (defined in project_config.json allowlist_roots):**
- `C:\RH\INBOX` (Downloads, Desktop sweeps, incoming files)
- `C:\RH\OPS` (Operations, projects, proof packs, research)

**Quarantine destination only (NEVER scanned):**
- `C:\RH\TEMPORARY` (low-confidence files, trash, unsorted)

**FORBIDDEN (Never Touch):**
- `C:\RH\VAULT` (sensitive credentials)
- `C:\RH\LIFE` (personal files)
- `C:\LEGACY` (legacy system backups)
- `C:\Windows` (system files)
- `C:\Program Files` (installed applications)
- `C:\Users\Raylee\AppData` (user profile data)

### 4. All Outputs Go to OUTPUTS Only
- **NEVER** write artifacts to `SRC\`
- **NEVER** write artifacts to project root
- **ALWAYS** write to: `OUTPUTS\phase_XX\run_MM-DD-YYYY_HHMMSS\`

### 5. Runnability Rule
- Scripts are run **ONLY** from `SRC\` directory
- Runner validates it's being invoked from correct location
- Runner checks for duplicate canonical scripts (refuse if duplicates exist)

### 6. Low Confidence Goes to Review Queue
- Auto-move threshold: confidence >= 0.85
- Review queue: confidence 0.60 - 0.84
- Quarantine: confidence < 0.60
- **NEVER** auto-move low-confidence classifications

### 7. Rollback Required for Every Mutating Phase
- Phases 06-07 (moves/renames) **MUST** generate `rollback.ps1`
- Rollback script must be tested in DryRun before execution
- Log every action to enable reversal

---

## Phase Model (00-08)

### Universal Audit Spine (Every Run Must Have)

Every `run_MM-DD-YYYY_HHMMSS` folder contains exactly:
1. `plan.csv` - What will happen (or happened)
2. `runlog.txt` - Execution log with timestamps
3. `summary_MM-DD-YYYY.md` - Human-readable summary
4. `metrics.json` - Machine-readable metrics
5. `rollback.ps1` - Undo script (or no-op if read-only)
6. `evidence\` - Phase-specific proof artifacts

---

### Phase 00 — Baseline Snapshot (Read-Only)

**Purpose:** "Before" anchor. No changes, no moves.

**Evidence:**
- `rh_tree_folders_only.txt` - Directory structure
- `rh_inventory.csv` - Full file inventory with metadata
- `script_files_list.csv` - All .ps1, .py, .sh, .bat, .cmd files
- `rules_and_config_list.csv` - All config/rules files
- `duplicate_filenames_top.csv` - Top duplicate filename groups

**Success Definition:** Can prove what existed and where, without memory.

---

### Phase 01 — Contract Freeze (Foundation Rules)

**Purpose:** Lock down directory structure, naming conventions, and safety contracts.

**Evidence:**
- `directory_contract.md` - Canonical directory structure rules
- `naming_contract.md` - `name_MM-DD-YYYY` format enforcement
- `no_delete_contract.md` - No-delete policy
- `scope_allowlist.md` - Allowed/forbidden roots
- `execution_doorway_rules.md` - Runner validation rules
- `ops_tree_after.txt` - OPS directory structure snapshot

**Success Definition:** Contract written once, never re-negotiated mid-run.

---

### Phase 02 — Inventory + Canonicalization

**Purpose:** Identify canonical scripts and eliminate "which file is real" ambiguity.

**Evidence:**
- `state_tree_before.txt` - Pre-canonicalization state
- `script_inventory.csv` - All scripts with hashes
- `script_hashes.csv` - SHA256 hashes for integrity
- `duplicate_scripts_report.csv` - Script duplicates analysis
- `canonical_script_manifest.csv` - Authoritative script registry
- `rules_inventory.csv` - All rules/config files

**Success Definition:** "Which file is real" is no longer a question.

---

### Phase 03 — Runner + Config + Dry-Run Validation

**Purpose:** Build gatekeeper runner with config-driven design.

**Evidence:**
- `project_config.json` - Runtime configuration (no hardcoded paths)
- `run.ps1` - Gatekeeper runner script
- `run_interface.md` - How to run (usage documentation)
- `dryrun_validation_checklist.md` - DryRun test results
- `canonical_paths_proof.txt` - Runner prints/logs canonical paths

**Success Definition:** DryRun produces all spine outputs and writes only to OUTPUTS.

---

### Phase 04 — Classification v1 (Deterministic Label-Only)

**Purpose:** Label files with destination buckets (no moves yet).

**Evidence:**
- `classification_rules_v1.yaml` - Deterministic classification rules
- `rules_version.json` - Rule version for reproducibility
- `classification_results.csv` - All files with labels + confidence
- `misclass_queue.csv` - Low-confidence items for review
- `bucket_taxonomy.md` - Bucket definitions and criteria

**Success Definition:** Outputs include "reason + confidence" and low-confidence queued.

---

### Phase 05 — Routing Plan (Still No Moves)

**Purpose:** Generate move plan with collision detection.

**Evidence:**
- `move_plan.csv` - Source, destination, action for every file
- `collisions.csv` - Files that would collide (require suffix)
- `exclusions_applied.txt` - Files excluded from moves (and why)
- `planned_changes_summary.md` - Human-readable plan overview

**Success Definition:** Can review plan and predict outcomes before execution.

---

### Phase 06 — Execute Moves (Rollback Required)

**Purpose:** Perform file moves based on Phase 05 plan.

**Evidence:**
- `moves_executed.csv` - Every file moved (source → destination)
- `errors.csv` - Any failures or warnings
- `state_tree_after_moves.txt` - Post-move directory structure

**Success Definition:** Can undo it and can prove what moved.

---

### Phase 07 — Rename Engine (MM-DD-YYYY Enforcement)

**Purpose:** Enforce `name_MM-DD-YYYY` naming convention.

**Evidence:**
- `rename_rules_v1.yaml` - Rename pattern rules
- `rename_plan.csv` - Old name, new name, reason
- `rename_executed.csv` - Actual renames performed
- `rename_collisions.csv` - Conflicts requiring suffix
- `rename_examples.md` - Before/after examples

**Success Definition:** Naming convention enforced deterministically without overwrites.

---

### Phase 08 — Tier 2.5 Semantic Labeling (Label-Only Enhancement)

**Purpose:** Use semantic/AI-assisted classification to improve confidence/coverage.

**Evidence:**
- `training_examples_manifest.csv` - Examples used for semantic model
- `semantic_labels.csv` - AI-generated labels with confidence
- `merge_logic.md` - How deterministic + semantic rules merge
- `semantic_misclass_queue.csv` - Low-confidence semantic labels
- `classification_rules_v2.yaml` - (Optional) Promoted semantic rules
- `evaluation_notes.md` - Wins/failures analysis

**Success Definition:** Semantic improves confidence/coverage but never moves files directly.

---

## Runner Behavior (SRC\run.ps1)

### Gatekeeper Validation (Runner Must Check)

**Before executing, runner MUST:**
1. Verify invoked from correct directory (`SRC\` or project root)
2. Check `project_config.json` exists and is valid
3. Verify allowlist roots are defined
4. Check for duplicate canonical scripts (refuse if found)
5. Validate output root is correct (`OUTPUTS\`)
6. Create timestamped run directory: `run_MM-DD-YYYY_HHMMSS`
7. Generate audit spine files before any work

**Runner refuses to run if:**
- Launched from wrong directory
- Allowlist missing or invalid
- Config missing or malformed
- Duplicate canonical scripts detected
- Output root invalid or missing

---

## Filename Conventions

### Run Directories
Format: `run_MM-DD-YYYY_HHMMSS`

Example: `run_02-08-2026_140111`

### Summary Files
Format: `name_MM-DD-YYYY.md`

Example: `summary_02-08-2026.md`

### General Files
Format: `descriptive-name_MM-DD-YYYY.ext`

Examples:
- `classification_results_02-08-2026.csv`
- `move_plan_02-08-2026.csv`
- `rollback_02-08-2026.ps1`

**NEVER use:**
- ISO dates (2026-02-08) — WRONG
- Year-first dates (2026_02_08) — WRONG
- No dates on versioned files — WRONG

---

## project_config.json Structure

**IMPORTANT:** All scan/quarantine configuration defers to `project_config.json`.
- `allowlist_roots`: Only these directories are scanned (exactly `["C:\\RH\\INBOX", "C:\\RH\\OPS"]`)
- `quarantine_root`: Destination for low-confidence files (`"C:\\RH\\TEMPORARY"`)
- C:\RH\TEMPORARY must NEVER appear in allowlist_roots (never scanned, only written to)

```json
{
  "project_root": "C:\\RH\\OPS\\PROJECTS\\RH_MIGRATION_2026_V2",
  "outputs_root": "C:\\RH\\OPS\\PROJECTS\\RH_MIGRATION_2026_V2\\OUTPUTS",
  "inbox_root": "C:\\RH\\INBOX",
  "quarantine_root": "C:\\RH\\TEMPORARY",
  "allowlist_roots": [
    "C:\\RH\\INBOX",
    "C:\\RH\\OPS"
  ],
  "exclude_roots": [
    "C:\\RH\\VAULT",
    "C:\\RH\\LIFE",
    "C:\\LEGACY",
    "C:\\Windows",
    "C:\\Program Files",
    "C:\\Program Files (x86)",
    "C:\\Users\\Raylee\\AppData"
  ],
  "confidence_thresholds": {
    "auto_move": 0.85,
    "review_queue": 0.60,
    "quarantine": 0.60
  },
  "naming_format": "name_MM-DD-YYYY",
  "collision_policy": {
    "suffix_pattern": "_{:02d}",
    "max_attempts": 99
  },
  "log_level": "info"
}
```

---

## Communication Style

- **Direct** - Skip preamble, provide executable commands
- **Safety-focused** - Always mention DryRun, verification, rollback
- **Evidence-driven** - Show proof, not assertions
- **Absolute paths** - Never use relative paths in commands

---

## End of AGENTS_PROJECT.md

**This is the canonical truth. All other agent instructions defer to this file.**
