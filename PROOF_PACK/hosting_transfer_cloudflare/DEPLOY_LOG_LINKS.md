# Deploy Log Links

Record every validation deploy and commit mapping.

| Timestamp (UTC) | Commit SHA | Branch | Host | Deploy URL | Status | Notes |
|---|---|---|---|---|---|---|
| `2026-02-14T03:15:25Z` | `9ebeca3ce3ec10a23d53b7be7638942867828513` | `main` | Cloudflare Pages (production) | `https://dash.cloudflare.com/?to=/7f3a740ef623f9737001cad31a9c0d2f/pages/view/hawkinsoperations/06dbacf2-7ca4-44bb-90db-e6cc9aff0b57` | `success` | Deterministic deploy run 1/3. |
| `2026-02-14T03:15:48Z` | `169794db79ae93f3d940b83f902d511e151652de` | `main` | Cloudflare Pages (production) | `https://dash.cloudflare.com/?to=/7f3a740ef623f9737001cad31a9c0d2f/pages/view/hawkinsoperations/bfe83eb1-1ece-46af-a411-1888415194b5` | `success` | Deterministic deploy run 2/3. |
| `2026-02-14T03:16:12Z` | `2980335c9d0d66cd838d4f279078db808ddcaeec` | `main` | Cloudflare Pages (production) | `https://dash.cloudflare.com/?to=/7f3a740ef623f9737001cad31a9c0d2f/pages/view/hawkinsoperations/0b84c568-7d1a-4d80-84eb-399337fcdefc` | `success` | Deterministic deploy run 3/3. |
| `2026-02-14T03:02:09Z` | `df99a71d68460b404fcca5ff94583797cb028467` | `ops/hosting-cutover-run-results` | Cloudflare Pages (preview/check) | `https://dash.cloudflare.com/?to=/7f3a740ef623f9737001cad31a9c0d2f/pages/view/hawkinsoperations/6d6d8cfc-0698-4f2f-b698-81d8a8141465` | `success` | Preview/check deploy used for validation lane. |

Evidence log:
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/deploy_mapping_capture_02-14-2026.txt`
- `PROOF_PACK/hosting_transfer_cloudflare/run_02-14-2026_031137/evidence/logs/deterministic_deploy_capture_02-14-2026.txt`
