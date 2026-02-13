CONTEXT_FILE: C:\RH\OPS\BUILD\agents\codex\codex_context_latest.txt

# AGENTS.md — HawkinsOperations (Codex instructions)

## Project identity
- Purpose: evidence-first SOC portfolio for job hunting
- Target roles: Primary SOC Analyst (T1/T2); Secondary junior detection + automation
- Clearance line (use verbatim everywhere): “Eligible to obtain clearance; willing to pursue sponsorship.”

## Environment constraints
- Windows 11 + Linux Mint dual-boot
- When giving commands:
  - Prefer PowerShell (`pwsh`) for verification scripts and Windows workflows
  - Use fish-compatible syntax on Linux (avoid bashisms)
- Deployment: Netlify auto-deploys from `main`
- Site publish directory is `site/` (static HTML/CSS/JS, no framework)

## Source of truth (numbers)
- All public numbers MUST match `PROOF_PACK/VERIFIED_COUNTS.md`
- Never use “200+ detections” or any inflated claims
- Never change counts unless verification passes and the source-of-truth file is updated

## Files you must not break
- `PROOF_PACK/VERIFIED_COUNTS.md`
- `START_HERE.md`
- `README.md`
- `site/index.html`
- `scripts/verify/verify-counts.ps1`
- `netlify.toml`

## Netlify guardrails
- `netlify.toml` must keep `publish = "site"`
- `site/_redirects` supports pretty URLs (`/security -> /security.html`, etc.)
- `site/_headers` exists (security headers)
- `site/404.html` exists (custom 404)
- Resume PDF must exist at: `site/assets/Raylee_Hawkins_Resume.pdf`
- Resume link must be: `/assets/Raylee_Hawkins_Resume.pdf` (absolute path)

## Standard workflow (no vibes)
1) Check repo state first (`git status`, recent commits/PR context if relevant)
2) Make smallest change that satisfies the requested phase
3) Run verification + local test before calling it “done”
4) Keep diffs small; do not add dependencies unless explicitly requested
5) Never print or commit secrets/tokens

## Verification / local test
- Verify counts:
  - `pwsh -File scripts/verify/verify-counts.ps1`
- Serve site locally:
  - `python -m http.server --directory site 8000`
- Minimum click-test paths:
  - `/`, `/security`, `/projects`, `/resume` (PDF download), `/proof`, `/lab`, `/triage`
