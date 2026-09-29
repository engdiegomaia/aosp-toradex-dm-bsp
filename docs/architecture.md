# Architecture

## Integration model

```text
AOSP release + SoC-vendor Android BSP + Toradex hardware references
                              ↓
                 Toradex community adaptation
                              ↓
                  module + carrier Android product
```

Reuse the SoC vendor's Android platform, kernel, bootloader, HALs, graphics, multimedia, firmware, and services whenever suitable. Adapt only the differences needed for Toradex modules and carrier boards. Keep each adaptation traceable to its source and reason.

## Hardware layers

- **SoC:** vendor Android baseline and SoC-wide support.
- **Module:** Toradex module configuration, memory, storage, module peripherals, and module-specific device tree.
- **Carrier:** connector routing and carrier peripherals, isolated under `boards/<carrier>/` when practical.

The first combination is NXP i.MX8QM → Apalis iMX8QM → Ixora. Do not assume an Apalis + Ixora setting applies to another carrier or module SKU.

## Source layout

This repository is an integration layer. Repo manifests describe upstream/vendor source repositories; `device/toradex/` holds Toradex product definitions and small, reviewable adaptations. Do not vendor complete source trees without a documented licensing or technical reason. Keep SoC vendor, module, carrier, and temporary workaround changes distinct.

## Initial product naming

The POC currently uses vendor product configuration under `device/toradex/apalis_imx8qm`. The target convention is `toradex_apalis_imx8qm_ixora-userdebug`; exact lunch name remains to be verified from the integrated tree before it is advertised as buildable.
