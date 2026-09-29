# Apalis iMX8QM device integration

This directory is the intended home for the Toradex Android product integration for Apalis iMX8QM. No POC implementation files have been imported yet: the source patch set, licenses, exact active workspace state, and overlap between patches and setup overlays must be audited first.

The reference hardware observed by the POC is Apalis iMX8QM PN 0037, HW V1.1B, with an 88W8997 wireless SKU, on Ixora V1.2. Those facts describe one test unit; do not generalize them to all Apalis iMX8QM SKUs.

Planned organization:

- module-wide product and configuration at this level;
- Ixora-specific configuration and evidence under `boards/ixora/`;
- SoC-vendor source remains in its upstream Repo projects;
- only small Toradex adaptations belong here, with provenance and licensing recorded.

The target lunch product is expected to make both module and carrier clear, but its exact name is not verified. See [vendor baseline inventory](../../../docs/vendor-baselines.md) and [hardware status](../../../docs/supported-hardware.md).
