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
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-13-2026_191244/evidence/logs/prod_headers_capture_02-13-2026.txt`

Observed result snapshot from captured log:
- `/` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/projects` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/security` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/resume` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)
- `/assets/Raylee_Hawkins_Resume.pdf` -> `HTTP/1.1 200 OK` (`Server: cloudflare`)

## Remaining required evidence
- `/proof`, `/lab`, `/triage`, and custom `404` header captures still pending in current run log.
