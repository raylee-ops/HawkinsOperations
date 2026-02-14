# DNS Cutover Records

## Record template (before -> after)

| Timestamp (UTC) | Name | Type | Before | After | Proxy | TTL | Operator |
|---|---|---|---|---|---|---|---|
| `<YYYY-MM-DDTHH:MM:SSZ>` | `@` | `CNAME` | `<prior-host-target>` | `<your-pages-project-name>.pages.dev` | Proxied | Auto | `<initials>` |
| `<YYYY-MM-DDTHH:MM:SSZ>` | `www` | `CNAME` | `<prior-host-target>` | `<your-pages-project-name>.pages.dev` | Proxied | Auto | `<initials>` |

## Resolver checks
Capture output from at least two resolvers after cutover:
- Resolver A: `1.1.1.1`
- Resolver B: `8.8.8.8`

Example command format:
- `nslookup yourdomain.tld 1.1.1.1`
- `nslookup yourdomain.tld 8.8.8.8`

Store command output in run evidence logs and summarize convergence time.
