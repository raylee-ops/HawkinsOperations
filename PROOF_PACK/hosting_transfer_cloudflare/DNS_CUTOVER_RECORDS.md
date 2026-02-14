# DNS Cutover Records

## Current resolver state (observed)
Captured at: `2026-02-14` (UTC equivalent based on local run time)

| Timestamp (UTC) | Name | Type | Before | After | Proxy | TTL | Operator |
|---|---|---|---|---|---|---|---|
| `2026-02-14T00:00:00Z` | `@` | `A/AAAA` | `pending backfill` | `104.21.52.41`, `172.67.195.16`, `2606:4700:3035::6815:3429`, `2606:4700:3033::ac43:c310` | Cloudflare edge | n/a | `ops` |

## Resolver checks
Captured output from two resolvers:
- Resolver A: `1.1.1.1`
- Resolver B: `8.8.8.8`

Command used:
- `nslookup hawkinsops.com 1.1.1.1`
- `nslookup hawkinsops.com 8.8.8.8`

Evidence log:
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-13-2026_191244/evidence/logs/dns_resolver_capture_02-14-2026.txt`

## Remaining required evidence
- Exact "before" provider values and timestamped cutover change window are still pending backfill from provider history/screenshots.
