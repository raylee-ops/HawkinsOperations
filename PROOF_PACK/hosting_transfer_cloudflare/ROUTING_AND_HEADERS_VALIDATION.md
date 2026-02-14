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
Validate parity against `site/_redirects`:
- `/security` -> `/security.html` (200)
- `/proof` -> `/proof.html` (200)
- `/resume` -> `/resume.html` (200)
- `/projects` -> `/projects.html` (200)
- `/lab` -> `/lab.html` (200)
- `/triage` -> `/triage.html` (200)
- `/Raylee_Hawkins_Resume.pdf` -> `/assets/Raylee_Hawkins_Resume.pdf` (301)

## Header checks
Validate parity against `site/_headers` for all HTML routes:
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `X-Frame-Options: DENY`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- `Content-Security-Policy` present

## Command log
Add command outputs from `curl -I` / equivalent checks into run evidence logs.
