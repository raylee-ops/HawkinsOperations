# GPU Passthrough Evidence Summary

Generated: 2026-02-11
Pack path: `/home/raylee/proofpack_gpu_passthrough_20260203T093234Z`

## What This Proof Pack Demonstrates
This bundle demonstrates NVIDIA GPU passthrough inside a Linux VM with driver-level visibility, virtualization mode reported as pass-through, and a sustained compute stress run with high utilization.

## Inventory (files and size)
- `baseline.txt`, `nvidia-smi.txt`, `nvidia-smi-L.txt`, `nvidia-smi-q.txt`
- `burn_result.txt`, `gpu-burn_600s.txt`, `telemetry.csv`, `health_summary.txt`
- `dmesg_post.txt`, `lspci-nnk.txt`, `journalctl-k-current-boot.txt`, `journalctl-k-current-filtered.txt`
- `journalctl-k-burn-window-2026-02-11.txt`, `journalctl-k-burn-window-filtered-2026-02-11.txt`
- Total size: ~460K

## Key Evidence Files
- `nvidia-smi-q.txt`: GPU model, driver/CUDA versions, virtualization mode (`Pass-Through`), ECC/health fields.
- `baseline.txt`: one-shot `nvidia-smi` table showing device visibility in the guest.
- `gpu-burn_600s.txt`: raw stdout from a fresh 600-second `gpu_burn` run, ending with `GPU 0: OK`.
- `burn_result.txt`: concise parsed run result summary (exit code, max temp/utilization, final progress line).
- `telemetry.csv`: per-second utilization/power/temp during run.
- `lspci-nnk.txt`: guest PCI topology showing NVIDIA GPU bound to `nvidia` kernel driver.
- `journalctl-k-current-filtered.txt`: current-boot VFIO/IOMMU/NVIDIA kernel log excerpt.
- `journalctl-k-burn-window-2026-02-11.txt`: exact kernel log window aligned with the fresh 600-second burn run.
- `journalctl-k-burn-window-filtered-2026-02-11.txt`: filtered error-signature scan for that same run window (empty = no matched red flags).
- `dmesg_post.txt`: preserved original boot excerpt from the original run.

## Quick Status (PASS/FAIL)
| Check | Status | Evidence |
|---|---|---|
| GPU visible inside VM | PASS | `baseline.txt`, `nvidia-smi.txt`, `nvidia-smi-q.txt` |
| Driver + CUDA stack coherent | PASS | Driver `535.288.01`, CUDA `12.2` |
| Passthrough mode indicated | PASS | `nvidia-smi-q.txt` -> `Virtualization Mode: Pass-Through` |
| Stress/load test completed | PASS | Raw `gpu_burn` output captured in `gpu-burn_600s.txt` and telemetry confirms sustained load |
| No VFIO/IOMMU red flags | PASS | Boot-level VFIO/IOMMU/NVIDIA init is clean and burn-window kernel scan has no matched fault signatures |
| Evidence completeness for recruiting | PASS | Required evidence files and raw burn evidence are present |

## Key Metrics
- GPU model: Tesla V100-SXM2-32GB
- Driver version: 535.288.01
- CUDA version: 12.2
- Stress duration target: 600 seconds
- Telemetry window: `2026/02/11 11:33:43.159` to `2026/02/11 11:44:17.746`
- Max GPU utilization observed: 100%
- Max GPU temperature observed: 83 C
- Samples >=90% utilization: 609 / 628

## Commands Used
```bash
cd /home/raylee/proofpack_gpu_passthrough_20260203T093234Z
find . -maxdepth 3 -type f -printf '%P\t%s bytes\n' | sort
du -h --max-depth=2 | sort -h
cat nvidia-smi-L.txt
cat nvidia-smi.txt
cat lspci-nnk.txt
cat journalctl-k-current-filtered.txt
rg -n -i 'vfio|iommu|xid|nvrm|error|failed|fault|timeout' dmesg_post.txt baseline.txt nvidia-smi-q.txt
awk -F',' 'NR==2{start=$1} NR>1{gsub(/^ +| +$/,"",$2); t=$2+0; if(t>maxT) maxT=t; gsub(/ %/,"",$3); gsub(/^ +| +$/,"",$3); u=$3+0; if(u>maxU) maxU=u; end=$1} END{print start,end,maxT,maxU}' telemetry.csv
```

## Redaction Note
Sensitive identifiers were detected in raw artifacts (guest hostname, GPU serial number, GPU UUID). Recruiter-facing outputs in this folder avoid exposing them. A sanitized tarball was also produced.

## Recommended Improvements
- Optional: retain both 2026-02-03 and 2026-02-11 windowed runs if you want side-by-side historical comparison.
