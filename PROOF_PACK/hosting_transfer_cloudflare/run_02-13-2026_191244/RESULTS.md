# Hosting Transfer Run Results (Netlify -> Cloudflare Pages)
AS_OF: 2026-02-13T19:12:44 (America/Chicago)

## 0) Scope
- Primary host: Cloudflare Pages
- Rollback host: Netlify (rollback-only; previews disabled)
- Repo: HawkinsOperations
- Publish directory: site/
- Build: none

## 1) Cloudflare Pages Deployment
- Project name: hawkinsoperations
- pages.dev URL: https://hawkinsoperations.pages.dev
- Production branch: main
- Deploy status: PASS
- Deployment log URL: https://dash.cloudflare.com/ (Workers & Pages -> hawkinsoperations -> Deployments -> View details)

Notes:
- Production deployment visible in UI with green status.
- Deployed commit shown in UI: `43b1c1e`.

## 2) Custom Domain Setup
- Domain added in Pages:
  - hawkinsops.com: IN PROGRESS (Verifying/Initializing shown in Cloudflare UI)
  - www.hawkinsops.com: PENDING ADD/VERIFY
- Cloudflare provided DNS targets used (no guesses): IN PROGRESS

DNS records applied (from Cloudflare UI):
- @ : CNAME hawkinsops.com -> hawkinsoperations.pages.dev (target shown by Pages custom domain wizard)
- www: CNAME www -> hawkinsoperations.pages.dev (required; verify in DNS records)

Timestamp:
- DNS change initiated: <FILL ISO>
- DNS propagation observed: <FILL ISO>

## 3) Pre-cutover Baseline (BEFORE DNS change)
Base URL tested: https://hawkinsops.com

### 3.1 Route header checks (curl -I)
Paste output blocks below:

See log file:
- `evidence/logs/before_dns_headers_02-13-2026.txt`

## 4) Post-cutover Validation (AFTER DNS change)
Base URL tested: https://hawkinsops.com

### 4.1 Route header checks (curl -I)
See log files:
- `evidence/logs/after_dns_headers_02-13-2026.txt`
- `evidence/logs/pages_dev_headers_02-13-2026.txt`

Note:
- This terminal environment cannot complete outbound HTTPS checks to public hosts (`curl: (7) Failed to connect ... port 443`), so browser-captured evidence is authoritative for live validation.

### 4.2 Browser smoke checks (manual)
- / loads: IN PROGRESS
- /projects loads: FAIL (`ERR_TOO_MANY_REDIRECTS`) (evidence: `raw_unredacted_do_not_commit/Screenshot 2026-02-13 201133.png`)
- /security loads: IN PROGRESS
- /resume loads: IN PROGRESS
- Theme toggle + persistence (refresh + hard refresh): PENDING
- Resume print preview (Ctrl+P): PENDING
- Direct PDF download works: IN PROGRESS

## 5) Redirects + Headers Parity
Files referenced:
- site/_redirects: present YES/NO
- site/_headers: present YES/NO

Validation method:
- Compared expected redirects/headers to observed response headers via curl -I.

Results:
- Redirect parity: FAIL (current loop observed in browser on `/projects`)
- Header parity: INCONCLUSIVE (terminal cannot reach public hosts from this environment)

Notes:
- Likely root cause is mixed/partial host cutover (one host still pointing to prior target) or conflicting redirect rules at edge.
- Resolution checklist:
- Ensure both `hawkinsops.com` and `www.hawkinsops.com` in Pages Custom Domains.
- Ensure both DNS CNAME records point to `hawkinsoperations.pages.dev`.
- Remove conflicting Cloudflare Redirect/Page Rules if both apex->www and www->apex are active simultaneously.
- Re-run browser smoke test after DNS verification is Active.

## 6) Deterministic Deploy "Commit Storm" (3 commits)
Goal: prove repeated deploys succeed and site serves updated content without weird caching.

Test branch used: <FILL>
Commit SHAs:
- 1: <FILL>
- 2: <FILL>
- 3: <FILL>

Cloudflare deployments (URLs):
- 1: <FILL>
- 2: <FILL>
- 3: <FILL>

Outcome:
- All deploys succeeded: PASS (current production deployment green)
- Content updated each time: IN PROGRESS
- No redirect loops: FAIL (active loop observed)
- No stale-cache artifacts after hard refresh: IN PROGRESS

Evidence files saved under:
- evidence/screenshots/: `README_REDACTION.md`, `EVIDENCE_INDEX.md`, `raw_unredacted_do_not_commit/`
- evidence/logs/: `before_dns_headers_02-13-2026.txt`, `after_dns_headers_02-13-2026.txt`, `pages_dev_headers_02-13-2026.txt`

## 7) Netlify Rollback-Only Hardening
Actions taken in Netlify UI:
- Deploy previews disabled: PASS/FAIL
- Build hooks disabled/reviewed: PASS/FAIL
- Auto-publish behavior confirmed not burning credits: PASS/FAIL

Notes:
- <FILL>

## 8) Final Verdict
- Cutover completed: IN PROGRESS
- Production stable: FAIL (redirect loop active)
- Rollback path documented: PASS

Next actions:
- Add/verify `www.hawkinsops.com` in Pages Custom Domains.
- Confirm both apex and `www` CNAME records point to `hawkinsoperations.pages.dev`.
- Check Cloudflare Rules for conflicting redirects and disable duplicates.
- Re-run route smoke checks and print preview evidence capture.

## Command Blocks (PowerShell)
Run once BEFORE DNS change and once AFTER DNS change.

```powershell
$base = "https://hawkinsops.com"
$paths = @("/","/projects","/security","/resume","/assets/Raylee_Hawkins_Resume.pdf")

foreach ($p in $paths) {
  "`n=== $p ==="
  curl.exe -sI "$base$p" | findstr /i "HTTP/ location: cache-control: content-type: cf-cache-status: age: server:"
}
```

Optional pages.dev validation:

```powershell
$base = "https://<your-project>.pages.dev"
$paths = @("/","/projects","/security","/resume","/assets/Raylee_Hawkins_Resume.pdf")

foreach ($p in $paths) {
  "`n=== $p ==="
  curl.exe -sI "$base$p" | findstr /i "HTTP/ location: cache-control: content-type: cf-cache-status: age: server:"
}
```

Suggested evidence filenames:
- cf_pages_deploy_success_02-13-2026.png
- cf_domain_ssl_active_02-13-2026.png
- routes_projects_pass_02-13-2026.png
- resume_print_preview_pass_02-13-2026.png
- deployments_list_commit_storm_02-13-2026.png
