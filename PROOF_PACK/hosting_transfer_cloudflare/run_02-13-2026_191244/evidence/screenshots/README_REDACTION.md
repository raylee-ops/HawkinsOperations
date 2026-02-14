# Screenshot Redaction Rules

- Crop out account email addresses, team/member names, and profile avatars before saving.
- Remove or mask API tokens, auth headers, cookies, and any bearer/session values.
- Hide billing identifiers: account IDs, invoice numbers, payment method details, and subscription IDs.
- Redact domain registrar account panels and nameserver account metadata not needed for proof.
- Do not include internal hostnames, private IPs, or infrastructure labels in screenshots.
- Exclude browser tabs/bookmarks that reveal unrelated project names or sensitive URLs.
- Keep only proof-relevant UI elements (deploy status, domain status, route checks, timestamps).
- If redaction is uncertain, crop more aggressively and add context in `RESULTS.md` notes.
- Use consistent filename format: `<artifact>_<status>_MM-DD-YYYY.png`.
- Recommended examples: `cf_pages_deploy_success_02-13-2026.png`, `resume_print_preview_pass_02-13-2026.png`.
