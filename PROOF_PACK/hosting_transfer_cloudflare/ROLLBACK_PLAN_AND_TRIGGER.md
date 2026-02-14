# Rollback Plan and Trigger

## Trigger conditions
Rollback to previous DNS provider/records if one or more occurs:
- Production cutover causes route failures on required endpoints.
- Required security headers are missing after Cloudflare deployment.
- Cloudflare production deployment for `main` fails and cannot be corrected within 15 minutes.

## Rollback procedure
1. Select last known good commit SHA.
2. Restore previous known-good DNS records/provider targets.
3. Validate routes and headers on restored DNS target.
4. Confirm resolver propagation on two resolvers.
5. Record timeline, owner, and outcome in this file and `DEPLOY_LOG_LINKS.md`.

## Exit criteria for rollback state
- Restored DNS target serves all required routes correctly.
- Resume PDF path works.
- Required headers and redirects are confirmed.

## Roll-forward criteria
- Cloudflare Pages deploy is green for a fixed commit.
- Full stress test passes.
- DNS points back to Cloudflare with propagation confirmed.
