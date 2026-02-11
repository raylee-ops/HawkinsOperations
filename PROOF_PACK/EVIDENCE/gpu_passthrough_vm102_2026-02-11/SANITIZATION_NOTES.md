# Sanitization Notes
- Redacted guest hostname tokens from host-prefixed log lines.
- Redacted GPU serial number fields.
- Redacted GPU UUID fields.
- Retained technical evidence required for validation (driver/CUDA, utilization, temps, PCI binding, VFIO/IOMMU signals).
