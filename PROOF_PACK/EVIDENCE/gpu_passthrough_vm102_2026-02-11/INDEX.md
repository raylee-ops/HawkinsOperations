# VM102 GPU Passthrough Proof Pack (Sanitized)

## Summary
- VM guest sees NVIDIA Tesla V100-SXM2-32GB via passthrough.
- Driver/CUDA stack is coherent (`535.288.01` / `12.2`).
- 600s `gpu_burn` stress test completed with raw stdout captured and `GPU 0: OK`.
- Telemetry shows sustained load (max util 100%, high-util samples 609/628).
- No kernel red-flag signatures in the burn-window scan.

## Key Files
- `README.md`
- `gpu_passthrough_report_02-11-2026.md`
- `gpu-burn_600s.txt`
- `burn_result.txt`
- `telemetry.csv`
- `nvidia-smi-q.txt`
- `lspci-nnk.txt`
- `journalctl-k-burn-window-2026-02-11.txt`
- `journalctl-k-burn-window-filtered-2026-02-11.txt`
- `proofpack_gpu_passthrough_SANITIZED_02-11-2026.tar.gz`

## Redaction
- Host identifiers, GPU serial, and GPU UUID are redacted.
