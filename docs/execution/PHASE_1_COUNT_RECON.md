# Phase 1 Count Reconciliation

## Date
- AS_OF 2026-02-13

## Authoritative Numeric Source
- `PROOF_PACK/VERIFIED_COUNTS.md`

## Verification Commands Run
- `pwsh -NoProfile -File .\scripts\verify\verify-counts.ps1`
- `pwsh -NoProfile -File .\scripts\verify\generate-verified-counts.ps1 -OutFile .\PROOF_PACK\VERIFIED_COUNTS.md`

## Drift Scan Commands Run
- `rg -n -i "200\+|over\s+200|30\s+IR|30\s+playbooks|dozens\s+of\s+playbooks|50\s+threat|50\s+hunt|dozens\s+of\s+hunts|Huntsville\s+May\s+2026" -S --glob "!.git/**" --glob "!node_modules/**" --glob "!dist/**" --glob "!build/**" --glob "!.terraform/**" .`
- `rg -n -i "200\+|over\s+200|30\s+IR|30\s+playbooks|dozens\s+of\s+playbooks|50\s+threat|50\s+hunt|dozens\s+of\s+hunts|Huntsville\s+May\s+2026" -S site README.md START_HERE.md PROOF_PACK`

## Results
- Live/public paths scan result (`site/`, `README.md`, `START_HERE.md`, `PROOF_PACK/`): no matches.
- Remaining matches are in `projects/legacy-archive/_archive/imports/soc-content/**` and are treated as archive-only historical imports.
- `AGENTS.md` includes a policy sentence containing `200+` as a prohibition, not a claim.

## Reconciliation Actions
- No live-site or proof-lane copy edits required in this run.
- Verified counts regenerated to keep `PROOF_PACK/VERIFIED_COUNTS.md` current.

## Status
- Phase 1 DoD condition met for active/public content.
- Archive-only legacy strings are explicitly documented and non-authoritative.
