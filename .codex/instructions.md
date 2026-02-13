# Codex Instructions (Phase 0 Baseline)

## Authoritative Context
- Authoritative pointer: `C:\RH\OPS\BUILD\agents\codex\codex_context_latest.txt`
- Dated snapshots are archive-only.
- Time-bound claims must use `AS_OF YYYY-MM-DD` or `VERIFY_CURRENT`.

## Hard Gate (Must Pass Before Any Phase Work)
Stop execution if either file is missing:
- `.codex/instructions.md`
- `PROOF_PACK/EXECUTION_LOG.md`

If missing, create both files first, then continue.

## Guardrails
- Use `PROOF_PACK/VERIFIED_COUNTS.md` as the sole public numeric source.
- Never commit secrets, tokens, credentials, or internal identifiers.
- Before merge/push: run verify scripts, drift scan, and secrets scan.
