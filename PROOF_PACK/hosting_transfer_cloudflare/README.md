# Cloudflare Hosting Transfer Proof Pack

This folder stores execution evidence for Cloudflare Pages production hosting.

## Required artifacts
- `CF_PAGES_PROJECT_SETTINGS.md`
- `DNS_CUTOVER_RECORDS.md`
- `ROUTING_AND_HEADERS_VALIDATION.md`
- `ROLLBACK_PLAN_AND_TRIGGER.md`
- `DEPLOY_LOG_LINKS.md`
- `PHASE_CHECKLIST.md` (status tracker for AGENTS phase-order gates)

## Run outputs
Each execution run must create a timestamped folder:
- `run_MM-DD-YYYY_HHMMSS/RESULTS.md`
- `run_MM-DD-YYYY_HHMMSS/evidence/screenshots/`
- `run_MM-DD-YYYY_HHMMSS/evidence/logs/`

## Notes
- Do not commit secrets.
- Do not commit internal/private IPs or hostnames.
- Use sanitized screenshots/log output only.
