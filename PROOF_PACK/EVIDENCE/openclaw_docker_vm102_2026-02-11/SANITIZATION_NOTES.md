# Sanitization Notes

Applied redaction transforms:
- 64-hex values -> `[REDACTED_HEX64]`
- 32-hex values -> `[REDACTED_HEX32]`
- IPv4 addresses -> `[REDACTED_IP]`
- `/home/raylee` -> `/home/[REDACTED_USER]`
- `/srv/moltbot` -> `/srv/[REDACTED_SERVICE]`

Preserved fields:
- Service states
- Driver/runtime versions
- Port mappings
- Evidence sequencing/timestamps

Purpose:
- Keep technical reproducibility while removing sensitive identifying data.
