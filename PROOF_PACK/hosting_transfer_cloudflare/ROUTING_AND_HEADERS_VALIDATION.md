# Routing and Headers Validation

## Routes to validate
- `/`
- `/security`
- `/projects`
- `/resume`
- `/proof`
- `/lab`
- `/triage`
- unknown route -> custom `404.html`

## Redirect checks
Current parity target from `site/_redirects`:
- `/Raylee_Hawkins_Resume.pdf` -> `/assets/Raylee_Hawkins_Resume.pdf` (301)
- `/assets/raylee_hawkins_resume.pdf` -> `/assets/Raylee_Hawkins_Resume.pdf` (301)

Cloudflare route behavior expectation:
- Extensionless routes (`/projects`, `/security`, `/resume`) return `200` directly.
- No extensionless-to-`.html` rewrite rules are present to avoid redirect loops.

## Header checks
Validate parity against `site/_headers` for all HTML routes:
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- `Content-Security-Policy` present

## Command log
Captured command outputs:
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/route_header_validation_02-14-2026.txt`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/route_body_behavior_404_02-14-2026.txt`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/redirect_parity_02-14-2026.txt`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/route_clicktest_status_02-14-2026.txt`

Observed result snapshot:
- `/` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/projects` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/security` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/resume` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/proof` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/lab` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/triage` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/assets/Raylee_Hawkins_Resume.pdf` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/__not_a_real_route__phase3` -> `HTTP/1.1 404 Not Found` with custom page title `HawkinsOps | Page not found`

Redirect parity snapshot:
- `/Raylee_Hawkins_Resume.pdf` returns `301` to `/assets/Raylee_Hawkins_Resume.pdf`
- `/assets/raylee_hawkins_resume.pdf` returns `301` to `/assets/Raylee_Hawkins_Resume.pdf`

Screenshot evidence:
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/home_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/projects_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/security_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/resume_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/proof_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/lab_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/triage_02-14-2026.png`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/screenshots/404_02-14-2026.png`
