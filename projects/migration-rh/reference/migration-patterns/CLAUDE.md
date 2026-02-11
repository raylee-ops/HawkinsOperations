# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ⚠️ STOP — Read This First

**DO NOT proceed without reading:**

```
C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\AGENTS_PROJECT.md
```

`AGENTS_PROJECT.md` is the **single source of truth** for this project.

All rules, constraints, phase definitions, and operational procedures are defined there.

**This file exists only to ensure you don't miss the instructions.**

---

## Quick Reference

- **Project Root:** `C:\RH\OPS\PROJECTS\RH_MIGRATION_2026_V2\`
- **Runnable Scripts:** `SRC\` only
- **Outputs:** `OUTPUTS\phase_XX\run_MM-DD-YYYY_HHMMSS\`
- **Entry Point:** `SRC\run.ps1`
- **Config:** `project_config.json` (defines scan roots and quarantine destination)
- **Scan Roots:** `C:\RH\INBOX` and `C:\RH\OPS` only
- **Quarantine:** `C:\RH\TEMPORARY` (never scanned)

---

**Read `AGENTS_PROJECT.md` now.**
