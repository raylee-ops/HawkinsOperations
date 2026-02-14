# Hosting Transfer Stress Test Checklist

## Commit storm plan (3+ consecutive commits)
- Commit A: doc-only change on `main`
- Commit B: doc-only change on `main`
- Commit C: doc-only change on `main`
- For each commit, confirm Cloudflare Pages preview and production deploy outcomes are deterministic.

## Pass/fail matrix

| Check | Pass criteria | Fail criteria | Evidence file |
|---|---|---|---|
| Deploy determinism | 3 consecutive commits deploy successfully with expected files | Any commit produces missing files, stale assets, or failed deployment | `DEPLOY_LOG_LINKS.md` |
| Route coverage | `/`, `/security`, `/projects`, `/resume`, `/proof`, `/lab`, `/triage`, and custom `404` all return expected page | Any route returns wrong page, wrong status, or broken content | `ROUTING_AND_HEADERS_VALIDATION.md` |
| Redirect behavior | Pretty URLs resolve via `_redirects` exactly as in `site/_redirects` | Any mismatch or loop | `ROUTING_AND_HEADERS_VALIDATION.md` |
| Header behavior | Security headers match `site/_headers` | Missing or altered required headers | `ROUTING_AND_HEADERS_VALIDATION.md` |
| Resume download | `/assets/Raylee_Hawkins_Resume.pdf` downloads successfully | 404, wrong file, or blocked download | `ROUTING_AND_HEADERS_VALIDATION.md` |
| Desktop/mobile cache parity | Hard refresh on desktop and mobile shows latest assets | Stale JS/CSS/HTML after hard refresh | `RESULTS.md` |

## Required route list
- `/`
- `/security`
- `/projects`
- `/resume`
- `/proof`
- `/lab`
- `/triage`
- `/404` (and unknown path -> custom `404.html`)

## Execution notes
- Use one browser on desktop and one mobile device (or emulator).
- Capture timestamps for each validation run.
- Save raw command outputs under `run_MM-DD-YYYY_HHMMSS/evidence/logs/`.
