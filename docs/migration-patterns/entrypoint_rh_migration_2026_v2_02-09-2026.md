# ENTRYPOINT — RH_MIGRATION_2026_V2

Read and obey, in this order:
1) AGENTS_PROJECT.md (hard rules, scope, safety)
2) PROJECT_SUMMARY.md (phases + deliverables)
3) OUTPUTS\phase_00\run_02-08-2026_140111\summary_02-08-2026.md (baseline reality)

Hard rules (non-negotiable):
- No deletes, no overwrites
- DryRun default
- Scan roots (see project_config.json allowlist_roots): C:\RH\INBOX, C:\RH\OPS
- Quarantine destination (never scanned): C:\RH\TEMPORARY
- Excluded roots: C:\RH\VAULT, C:\RH\LIFE, C:\LEGACY, C:\Windows, C:\Program Files, C:\Users
- Outputs only to: OUTPUTS\phase_0X\run_MM-DD-YYYY_HHMMSS\
- No moves/renames without a reviewed plan.csv
