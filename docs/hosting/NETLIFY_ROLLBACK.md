# Netlify Rollback-Only Procedure

Netlify remains available only as rollback hosting while Cloudflare Pages is primary.

## Netlify UI settings to disable
- Project settings -> Build & deploy -> Continuous Deployment ->
  - Production branch: keep `main` configured (for fallback deploys only)
  - Deploy previews: disable
  - Branch deploys: disable
- Site settings -> Access control: keep defaults (no public preview requirement)
- Build command: empty
- Publish directory: `site`

## Rollback trigger conditions
Trigger rollback to Netlify if any condition is true:
- Cloudflare production deployment fails for the latest `main` commit and cannot be restored within 15 minutes.
- DNS cutover causes persistent 5xx or route failures on required paths.
- Security headers or redirects regress in production and hotfix cannot be deployed quickly.

## Rollback steps
1. Confirm last known good commit SHA from `main`.
2. In Netlify, open the site -> Deploys -> Trigger deploy from that commit (or latest green).
3. Verify Netlify deploy success and smoke-test required routes.
4. Update DNS records to point traffic back to Netlify target.
5. Re-run routing/header validation checks.
6. Record incident details in `PROOF_PACK/hosting_transfer_cloudflare/ROLLBACK_PLAN_AND_TRIGGER.md` and `DEPLOY_LOG_LINKS.md`.

## Roll-forward after rollback
1. Fix Cloudflare Pages deploy issue on a new commit.
2. Deploy to Cloudflare preview then production.
3. Re-point DNS to Cloudflare Pages.
4. Confirm parity checks pass.
5. Document timestamps and final state in Proof Pack artifacts.
