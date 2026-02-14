# Hosting Transfer Proof Pack (Cloudflare Only)

## Scope
Docs-only execution checklist for Cloudflare Pages hosting validation.

## Target state
- Cloudflare Pages = production primary
- No secondary host

## Required artifact directory
- `PROOF_PACK/hosting_transfer_cloudflare/`

## Required artifacts
1. `CF_PAGES_PROJECT_SETTINGS.md`
   - build command, publish directory (`site/`), branch mapping, environment notes
2. `DNS_CUTOVER_RECORDS.md`
   - before/after DNS records, change timestamps, resolver outputs
3. `ROUTING_AND_HEADERS_VALIDATION.md`
   - redirect/header parity checks against expected behavior
4. `ROLLBACK_PLAN_AND_TRIGGER.md`
   - trigger criteria, command steps, owner, and verification sequence
5. `DEPLOY_LOG_LINKS.md`
   - Cloudflare deploy URLs and commit SHAs for each validation run

## Stress test checklist
- [ ] Run deploys for at least 3 consecutive commits and verify deterministic output.
- [ ] Validate routes: `/`, `/security`, `/projects`, `/resume`, `/proof`, `/lab`, `/triage`, and `404`.
- [ ] Validate PDF download path: `/assets/Raylee_Hawkins_Resume.pdf`.
- [ ] Validate `_headers` and `_redirects` parity after cutover.
- [ ] Hard refresh desktop + mobile and confirm no stale asset behavior.

## Evidence capture checklist
- [ ] Cloudflare Pages production deploy screenshot/log link.
- [ ] Cloudflare Pages preview deploy screenshot/log link.
- [ ] DNS propagation checks from two resolvers with timestamps.
- [ ] Header/redirect validation command outputs.
- [ ] Rollback drill evidence using DNS-record rollback to the previous provider/targets.
