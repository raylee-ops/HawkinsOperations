# HawkinsOps SOC Content Library

Recruiter-friendly SOC artifacts with **verifiable** counts and a **real deployment path** (Wazuh).

## Quick Links
- Start Here: `START_HERE.md`
- Proof Pack: `PROOF_PACK/PROOF_INDEX.md`
- Detection Rules Index: `detection-rules/INDEX.md`
- Verification (PowerShell): `docs/VERIFY_COMMANDS_POWERSHELL.md`
- Wazuh Deployment Reality: `docs/wazuh/DEPLOYMENT_REALITY.md`
- v1.0.1 Checklist: `RELEASE_v1.0.1_CHECKLIST.md`

## What’s in this repo (truthful)
This release is **Wazuh-first**.

- **Wazuh rules:** stored as XML modules in `detection-rules/wazuh/_incoming/WAZUH_RULES_PRIMARY/`
- **IR playbooks:** Markdown playbooks in `incident-response/playbooks/`
- **Threat hunting + runbooks:** scaffolded indices (content in progress)
- **Sigma + Splunk:** scaffolded folders (planned)

> Counts are intentionally not hard-coded here. Use the verification commands and quote the output.

## Verify counts (Windows)
Run from repo root:
- `docs/VERIFY_COMMANDS_POWERSHELL.md`

## Wazuh deployment (fast path)
Build a deployable bundle from the repo’s Wazuh XML modules:

```bash
bash ./scripts/build-wazuh-bundle.sh
```

Then follow:
- `docs/wazuh/DEPLOYMENT_REALITY.md`

## Portfolio safety
- No secrets, tokens, internal IPs, or private hostnames are included.
- See `SECURITY.md` for reporting concerns responsibly.
