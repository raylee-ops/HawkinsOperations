# Rollback Plan and Trigger

## Trigger conditions
Rollback to Netlify if one or more occurs:
- Production cutover causes route failures on required endpoints.
- Required security headers are missing after Cloudflare deployment.
- Cloudflare production deployment for `main` fails and cannot be corrected within 15 minutes.

## Rollback procedure
1. Select last known good commit SHA.
2. Trigger Netlify deploy for that commit (rollback-only host).
3. Validate routes and headers on Netlify target.
4. Repoint DNS records to Netlify target.
5. Confirm resolver propagation on two resolvers.
6. Record timeline, owner, and outcome in this file and `DEPLOY_LOG_LINKS.md`.

## Exit criteria for rollback state
- Netlify serves all required routes correctly.
- Resume PDF path works.
- Required headers and redirects are confirmed.

## Roll-forward criteria
- Cloudflare Pages deploy is green for a fixed commit.
- Full stress test passes.
- DNS points back to Cloudflare with propagation confirmed.
