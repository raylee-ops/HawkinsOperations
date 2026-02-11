# GPU Passthrough Validation Report (VM 102)
Date: 2026-02-11
Scope: Validate `/home/raylee/proofpack_gpu_passthrough_20260203T093234Z` for authenticity, coherence, and recruiter readiness.

## Verdict
Overall: PASS.

## PASS/FAIL Checks
| Check | Result | Notes |
|---|---|---|
| GPU visible in guest | PASS | NVIDIA device present and queryable in guest artifacts. |
| Driver stack coherent | PASS | Driver 535.288.01 and CUDA 12.2 are consistent across files. |
| Passthrough mode confirmed | PASS | NVIDIA query artifact reports virtualization mode as pass-through. |
| Sustained stress execution | PASS | Raw 600-second `gpu_burn` stdout captured; run ends `GPU 0: OK`, with zero reported errors. |
| VFIO/IOMMU health | PASS | VFIO/IOMMU/NVIDIA lines present in boot evidence; burn-window kernel scan contains no matched Xid/fault signatures. |
| Evidence completeness | PASS | `lspci-nnk.txt`, journal excerpts, raw burn log, and rebuilt health summary are present. |

## Key Metrics
- GPU: Tesla V100-SXM2-32GB
- Driver: 535.288.01
- CUDA: 12.2
- Stress duration target: 600 sec
- Max temperature observed: 83 C
- Max utilization observed: 100%
- Samples with >=90% utilization: 609 / 628

## Authenticity / Coherence Notes
- Fresh burn, telemetry, and result timestamps align to the same run window on 2026-02-11.
- Thermal and power behavior are plausible for a V100 under compute stress (near power cap during high utilization).
- No obvious contradictions between summary artifacts and detailed NVIDIA query output.
- Kernel log capture was also collected for the same burn window; no red-flag signatures were matched.

## Redactions Applied
Sensitive identifiers were detected in raw files and redacted/withheld from recruiter-facing outputs:
- Guest hostname
- GPU serial number
- GPU UUID
No public IP or MAC exposure was included in generated summary outputs.

## Remaining Caveat
1. None for the refreshed 2026-02-11 run set.
