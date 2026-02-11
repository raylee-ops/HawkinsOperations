# OpenClaw Docker Rebuild Proof (Sanitized)

## Scope
Evidence for the February 11, 2026 VM rebuild activities:
- Host OpenClaw user service disabled
- Dockerized Moltbot/OpenClaw gateway as primary endpoint
- NVIDIA CDI regeneration to fix stale GPU mount path
- Pairing/health validation against Docker gateway

## Outcome Summary
- Host `openclaw-gateway.service` is disabled/inactive.
- Docker gateway is running and serving UI on `[LOOPBACK]:28789`.
- NVIDIA CDI path references current `libnvidia-egl-wayland.so.1.1.21`.
- Container can see GPU device(s).
- OpenClaw health call returns `ok: true` after pairing approval.

## Key Artifacts
- `summary.txt`
- `docker-compose.yml`
- `docker-ps.txt`
- `docker-info.txt`
- `docker-service-status.txt`
- `nvidia-cdi-lib-paths.txt`
- `container-nvidia-smi-L.txt`
- `openclaw-user-service-status.txt`
- `gateway-ui-http.txt`
- `gateway-probe.json`
- `openclaw-health.json`
- `devices-pending.json`
- `devices-paired.json`
- `openclaw-config-sanitized.json`
- `moltbot-gateway-tail.log`
- `nvidia-smi-host.txt`
- `lspci-nnk.txt`

## Notes
- This folder intentionally focuses on setup/operational proof and excludes sensitive data.
- Token-like values and IPs are redacted for safe publication.
