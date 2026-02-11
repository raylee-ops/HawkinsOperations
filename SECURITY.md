# Security Policy

This repository contains security detections, incident response content, and proof artifacts.

## Report a Security Concern

If you find exposed secrets, unsanitized evidence, or unsafe instructions:

- Do not post sensitive details in a public issue.
- Open a private report through the repository security advisory flow.
- Include file path, branch/commit, and a short impact summary.

## Sanitization Standard

Before publishing screenshots, logs, or sample artifacts, use:

- `PROOF_PACK/EVIDENCE_CHECKLIST.md`

Minimum requirements:

- No credentials, tokens, secrets, or internal-only identifiers.
- No sensitive hostnames, usernames, or email addresses.
- Use sanitized examples and redact where needed.

## Scope

This repository does not ship a managed service. Content is provided as reference material and must be reviewed and tested before production use.
