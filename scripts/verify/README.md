# Verification Scripts

- `verify-counts.ps1` prints current detection/playbook counts.
- `generate-verified-counts.ps1` updates `PROOF_PACK/VERIFIED_COUNTS.md` from live repository counts.

Run from repository root:

```powershell
pwsh -NoProfile -File ".\scripts\verify\verify-counts.ps1"
pwsh -NoProfile -File ".\scripts\verify\generate-verified-counts.ps1" -OutFile ".\PROOF_PACK\VERIFIED_COUNTS.md"
```
