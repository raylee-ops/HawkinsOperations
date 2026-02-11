# HawkinsOperations

[![Verification](https://img.shields.io/github/actions/workflow/status/raylee-ops/HawkinsOperations/verify.yml?branch=main&label=verify)](https://github.com/raylee-ops/HawkinsOperations/actions/workflows/verify.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Security operations portfolio repository focused on verifiable detection engineering, incident response playbooks, and reproducible proof artifacts.

## Start Here

- 5-minute reviewer path: [START_HERE.md](START_HERE.md)
- Proof index: [PROOF_PACK/PROOF_INDEX.md](PROOF_PACK/PROOF_INDEX.md)
- Detection catalog: [detection-rules/INDEX.md](detection-rules/INDEX.md)
- Incident response index: [incident-response/00-Playbook-Index.md](incident-response/00-Playbook-Index.md)
- Migration project entrypoint: [projects/migration-rh/README.md](projects/migration-rh/README.md)

## Repository Map

- `PROOF_PACK/` curated artifacts for validation and interviews
- `detection-rules/` Sigma, Splunk, Wazuh, and mapping content
- `incident-response/` playbooks, templates, and checklists
- `threat-hunting/` hunt matrices and hypothesis-driven query notes
- `scripts/` bundle builders and verification scripts
- `tools/migration-tools/` shared migration utilities only
- `projects/` portfolio project subtrees and entrypoints

## Quick Verification

Run from repo root:

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
pwsh -NoProfile -File ".\scripts\build-wazuh-bundle.ps1"
```

Expected artifacts:

- `PROOF_PACK/VERIFIED_COUNTS.md`
- `dist/wazuh/local_rules.xml`

## Security

- Policy: [SECURITY.md](SECURITY.md)
- Sanitization checklist: [PROOF_PACK/EVIDENCE_CHECKLIST.md](PROOF_PACK/EVIDENCE_CHECKLIST.md)

## License

MIT. See [LICENSE](LICENSE).
