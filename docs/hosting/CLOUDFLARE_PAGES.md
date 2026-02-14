# Cloudflare Pages Production Settings

This repository is a static site deployment from `site/`.

## Site type detection
- Type: static site
- Why: `netlify.toml` uses `publish = "site"` with an empty build command, and all pages are prebuilt HTML in `site/`.

## Exact Cloudflare Pages UI settings
- Project name: `<your-pages-project-name>`
- Production branch: `main`
- Framework preset: `None`
- Build command: `(none)`
- Build output directory: `site`
- Root directory: `/`
- Node.js version: `(default)`
- Environment variables: none required

## Git branch mapping
- `main` -> Production
- Non-`main` branches -> Preview

## DNS record plan format (Cloudflare DNS)
Use CNAME flattening at apex, proxied through Cloudflare.

| Name | Type | Content | Proxy | TTL | Purpose |
|---|---|---|---|---|---|
| `@` | `CNAME` | `<your-pages-project-name>.pages.dev` | Proxied | Auto | Apex production hostname |
| `www` | `CNAME` | `<your-pages-project-name>.pages.dev` | Proxied | Auto | `www` production hostname |

## TLS and edge settings
- SSL/TLS mode: `Full (strict)`
- Always Use HTTPS: `On`
- Automatic HTTPS Rewrites: `On`
- Minimum TLS version: `1.2`

## Post-cutover validation
- Validate routes: `/`, `/security`, `/projects`, `/resume`, `/proof`, `/lab`, `/triage`, `404`
- Validate resume path: `/assets/Raylee_Hawkins_Resume.pdf`
- Validate `_redirects` and `_headers` behavior after cutover
