# Migration Guide: V1 → V2

**Date:** 2026-02-08
**Purpose:** Map RH_MIGRATION_2026 (V1) to RH_MIGRATION_2026_V2
**Status:** V1 remains operational; V2 is new parallel system

---

## Executive Summary

**DO NOT delete or move V1.** V2 is a **new, parallel project** with improved architecture.

**V1 Location:** `C:\RH\OPS\SYSTEM\migrations\RH_MIGRATION_2026\`
**V2 Location:** `C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\`

**Key Difference:** V1 is phase-script based; V2 is config-driven with modular runner.

---

## Phase Mapping (V1 → V2)

| V1 Phase | V1 Name | V2 Phase | V2 Name | Notes |
|----------|---------|----------|---------|-------|
| 00 | Freeze the world | 00 | Baseline Snapshot | Same concept, standardized output |
| 01 | Lock canonical directory map | 01 | Contract Freeze | Expanded to include all contracts |
| 02 | Consolidate project structure | — | *(Merged into 01)* | Part of contract freeze |
| 03 | Full C:\RH inventory scan | 00 | Baseline Snapshot | Already done in Phase 00 |
| 04 | Quarantine Work-Unit Reconstruction | 04 | Classification v1 | Deterministic label-only |
| 05 | Duplicate elimination | *(Later)* | *(Not yet)* | Will be added as dedup module |
| 06 | Windows default routing | 05-06 | Routing Plan + Execute Moves | Split into plan + execute |
| 07 | Rename normalization | 07 | Rename Engine | Same concept, standardized |
| 08 | Root cleanup | — | *(Post-V2)* | Not part of initial V2 |
| 09 | Git packaging | — | *(Post-V2)* | PROOF_PACK handles this |
| 10 | Acceptance tests | — | *(Validation)* | Built into runner validation |
| 11 | Long-term guardrails | — | *(Runner gates)* | Built into runner |
| — | *(New)* | 02 | Inventory + Canonicalization | Script authority resolution |
| — | *(New)* | 03 | Runner + Config + Validation | Gatekeeper builder |
| — | *(New)* | 08 | Semantic Labeling (Tier 2.5) | AI-assisted classification |

---

## Architecture Comparison

### V1 Architecture (Current)

```
C:\RH\OPS\SYSTEM\migrations\RH_MIGRATION_2026\
├── phase_XX\
│   ├── scripts\          ← Phase-specific monolithic scripts
│   ├── docs\             ← Phase documentation
│   └── runs\             ← Run outputs mixed with docs
├── codex\                ← Prompts and templates
└── trash\                ← Quarantine area
```

**Characteristics:**
- Monolithic phase scripts
- Hardcoded paths in scripts
- Mixed outputs (runs + docs in same phase_XX folder)
- No unified runner
- 12 phases (00-11)

---

### V2 Architecture (New)

```
C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\
├── SRC\                  ← All runnable code
│   ├── run.ps1           ← Single gatekeeper entry point
│   ├── modules\          ← Modular components
│   ├── rules\            ← YAML rule files
│   └── templates\        ← Output templates
├── OUTPUTS\              ← All run artifacts (clean separation)
│   └── phase_XX\
│       └── run_MM-DD-YYYY_HHMMSS\
│           ├── plan.csv
│           ├── runlog.txt
│           ├── summary_MM-DD-YYYY.md
│           ├── metrics.json
│           ├── rollback.ps1
│           └── evidence\
├── PROOF_PACK\           ← Recruiter-ready curated evidence
└── agent_assets\         ← Prompts, policies, notes
```

**Characteristics:**
- Modular architecture (separate classifier, planner, mover)
- Config-driven (project_config.json)
- Clean SRC/OUTPUTS separation
- Single unified runner with validation
- Standardized audit spine (every run same format)
- 9 phases (00-08)

---

## Output Routing Differences

### V1 Output Locations

| Artifact Type | V1 Location |
|---------------|-------------|
| Phase scripts | `phase_XX\scripts\` |
| Phase docs | `phase_XX\docs\` |
| Run artifacts | `phase_XX\runs\<timestamp>\` |
| System runs | `C:\RH\OPS\SYSTEM\DATA\runs\phase_XX\` |
| Ledger docs | `codex\` |

**Problem:** Mixed outputs, duplicate run locations, no standardization.

---

### V2 Output Locations

| Artifact Type | V2 Location |
|---------------|-------------|
| Runnable code | `SRC\` (and ONLY SRC) |
| Run artifacts | `OUTPUTS\phase_XX\run_MM-DD-YYYY_HHMMSS\` |
| Evidence | `OUTPUTS\phase_XX\run_*\evidence\` |
| Proof pack | `PROOF_PACK\` |
| Agent assets | `agent_assets\` |

**Benefit:** Clean separation, no ambiguity, consistent audit spine.

---

## Key Improvements in V2

### 1. Config-Driven Design

**V1:** Hardcoded paths in each script
**V2:** All paths in `project_config.json`

**Why it matters:** No more "wrong script location" nightmare.

---

### 2. Modular Architecture

**V1:** Monolithic `Phase6-CanonicalInbox.ps1` (18,938 bytes)
**V2:** Separate modules (classifier, planner, mover, renamer)

**Why it matters:** Easier to maintain, test, and reuse.

---

### 3. Single Gatekeeper Runner

**V1:** Multiple phase scripts, each independently invoked
**V2:** One `run.ps1` with validation gates

**Why it matters:** Prevents execution from wrong location, checks config, detects duplicates.

---

### 4. Standardized Audit Spine

**V1:** Inconsistent artifacts across phases
**V2:** Every run produces same 5 files + evidence

**Why it matters:** Predictable outputs, easier to audit, proof-pack ready.

---

### 5. Tier 2.5 Semantic (Phase 08)

**V1:** No AI-assisted classification
**V2:** Phase 08 uses semantic labeling with deterministic override

**Why it matters:** Improves classification coverage without sacrificing control.

---

## What NOT to Move (Yet)

### Keep V1 Intact

**DO NOT:**
- Delete V1 phase directories
- Move V1 scripts to V2
- Modify V1 RUNBOOK_CANONICAL.md
- Touch V1 evidence in `phase_XX\runs\`

**WHY:** V1 is operational and contains historical evidence. V2 is a clean-slate rebuild.

---

### V1 Scripts to Reference (Not Copy)

When building V2 modules, **reference** (don't copy) V1 logic from:
- `phase_06\scripts\Phase6-CanonicalInbox.ps1` (for mover module)
- `phase_06\scripts\Fix-KnownFolders.ps1` (for Windows registry handling)
- `phase_06\scripts\Phase6_1-DownloadsSweep.ps1` (for inbox processing)

Extract **logic patterns**, not hardcoded paths.

---

### V1 Evidence to Import

Phase 00 can import baseline data from V1:
- Duplicate script reports (already generated)
- Known Folders registry snapshots
- Directory tree snapshots

**Location:** `C:\RH\OPS\SYSTEM\DATA\inventories\reality_snapshot_02-08-2026\`

---

## Migration Workflow

### Phase 00 (V2) — Complete ✅

**Status:** Baseline snapshot finished
**Evidence:** `OUTPUTS\phase_00\run_02-08-2026_140111\`
**Findings:** 9,883 files, 643 scripts, 88 configs, top 50 duplicates

---

### Phase 01 (V2) — Next Step

**Tasks:**
1. Create contract documents (directory, naming, no-delete, scope, execution)
2. Lock these contracts (never re-negotiate mid-run)
3. Generate OPS tree snapshot
4. Produce audit spine + evidence

**Reference V1:** Phase 01 docs for contract ideas

---

### Phase 02 (V2) — Script Authority

**Tasks:**
1. Identify all .ps1 scripts across C:\RH
2. Generate SHA256 hashes
3. Declare canonical script manifest (one authoritative copy per script name)
4. Quarantine duplicates for evidence-only

**Reference V1:** `reality_snapshot_02-08-2026\duplicate_scripts_detailed.txt`

---

### Phase 03 (V2) — Runner Build

**Tasks:**
1. Build `SRC\run.ps1` gatekeeper
2. Implement validation gates (location check, config check, duplicate check)
3. Test DryRun mode
4. Verify audit spine generation

**New in V2:** No V1 equivalent. This is the core improvement.

---

### Phase 04-08 (V2) — TBD

Follow phase model in `AGENTS_PROJECT.md`.

---

## Co-Existence Strategy

### V1 and V2 Run in Parallel

- **V1:** Operational for current Phase 06 work
- **V2:** New parallel system being built

**No conflict** because:
- Different root directories
- Different execution paths
- V2 won't touch V1 files

---

### When to Deprecate V1

**Criteria for V1 deprecation:**
1. V2 Phase 00-03 complete and validated
2. V2 Phase 04-06 tested in DryRun
3. V2 produces same/better results than V1
4. V2 runner proven stable

**Timeline:** Likely after V2 Phase 06 execution success.

---

## Naming Convention Alignment

### V1 Naming

- Phase folders: `phase_01`, `phase_02`, etc.
- Run folders: `2026-02-07__182747` (ISO date + time)
- Summary files: `summary_02-07-2026.md`

**Issue:** Mixed formats (ISO for runs, US for summaries).

---

### V2 Naming (Standardized)

- Phase folders: `phase_00`, `phase_01`, etc. (same as V1)
- Run folders: `run_02-08-2026_140111` (consistent MM-DD-YYYY)
- Summary files: `summary_02-08-2026.md` (consistent MM-DD-YYYY)

**Benefit:** No format confusion, consistent across all artifacts.

---

## Configuration Comparison

### V1 Configuration

**Location:** `C:\RH\OPS\SYSTEM\ai_context\codex\AGENTS.md`
**Format:** Markdown with embedded rules
**Problem:** Rules mixed with narrative, hard to parse programmatically

---

### V2 Configuration

**Location:** `C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\project_config.json`
**Format:** JSON (machine-readable)
**Benefit:** Parseable by scripts, no hardcoded paths

---

## Evidence Management

### V1 Evidence (Keep)

**Location:** `C:\RH\OPS\SYSTEM\migrations\RH_MIGRATION_2026\phase_XX\runs\`
**Status:** Historical record, do not modify

---

### V2 Evidence (New)

**Location:** `C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\OUTPUTS\phase_XX\run_*\evidence\`
**Status:** Clean slate with standardized audit spine

---

## Summary: Key Takeaways

1. **V1 and V2 coexist** — Don't touch V1
2. **V2 is cleaner** — Config-driven, modular, standardized
3. **Phase mapping** — V1 12 phases → V2 9 phases (streamlined)
4. **No hardcoded paths** — Everything in `project_config.json`
5. **Single runner** — `SRC\run.ps1` is gatekeeper
6. **Standardized outputs** — Every run has audit spine

---

## Next Actions

1. ✅ Phase 00 V2 complete (baseline snapshot)
2. ⏳ Build Phase 01 V2 contracts
3. ⏳ Build Phase 02 V2 canonical script manifest
4. ⏳ Build Phase 03 V2 runner with validation
5. ⏳ Test Phase 04-06 V2 in DryRun
6. ⏳ Execute Phase 06 V2 (parallel to V1 if needed)
7. ⏳ Evaluate V1 deprecation after V2 proven stable

---

**END OF MIGRATION GUIDE**
