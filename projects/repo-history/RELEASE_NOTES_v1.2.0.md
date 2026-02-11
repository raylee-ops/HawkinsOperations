# Release v1.2.0 - Structure and Verification Stability

**Status:** Draft  
**Target Date:** February 11, 2026  
**Tag:** v1.2.0

---

## Overview

This release stabilizes repository structure, verification output, and CI behavior so published claims remain consistent and low-noise.

## Key Changes

### Verification and CI
- Fixed `scripts/verify/generate-verified-counts.ps1` output formatting.
- Standardized count logic to include both `.yml` and `.yaml` Sigma files.
- Standardized IR playbook counting to `IR-*.md` only.
- Removed automatic commit/push behavior from `.github/workflows/verify.yml`.
- Reduced workflow permissions from `contents: write` to `contents: read`.

### Documentation Consistency
- Updated front-door links to use `incident-response/INDEX.md` as the canonical IR index.
- Converted `incident-response/00-Playbook-Index.md` into a compatibility redirect with current file references.
- Added historical-context banner to `RELEASE_NOTES_v1.1.0.md` to avoid confusion with current counts.

### Noise Reduction
- Stopped bot-driven count-update commits on `main`.
- Removed stale claims from legacy IR index entrypoint.

---

## Verified Content Counts

Counts are generated from live repository content:

- Sigma (YAML): **105**
- Splunk (SPL): **8**
- Wazuh XML files: **25**
- Wazuh `<rule id=>` blocks: **29**
- IR playbooks (`IR-*.md`): **10**

Reference: `PROOF_PACK/VERIFIED_COUNTS.md`

---

## Validation Commands

Run from repository root:

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
pwsh -NoProfile -File ".\scripts\build-wazuh-bundle.ps1"
```

---

## Release Checklist

1. Merge `refactor/portfolio-structure-v2` into `main`.
2. Run validation commands locally and confirm expected outputs.
3. Confirm GitHub Actions `verify` workflow passes on the merge commit.
4. Create and push tag `v1.2.0`.
5. Publish GitHub Release using this file as release notes.
