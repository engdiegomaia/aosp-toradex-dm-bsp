# Vendor baselines and POC change inventory

## Known baseline

The POC README and its snapshot identify NXP Android `android-16.0.0_1.2.0`, with AOSP Android tag `android-16.0.0_r1` in the Repo manifest. Snapshot date: 2026-09-15. The POC reports no GMS. The manifest pins many NXP forks and Android projects to commit IDs.

The pinned snapshot is at [`../manifests/android16/nxp-imx8qm-poc-2026-09-15.xml`](../manifests/android16/nxp-imx8qm-poc-2026-09-15.xml). Its source README says it does not include local modifications or NXP proprietary release blobs. It is therefore evidence of the source baseline, not by itself a complete reproducible release manifest.

## Change inventory (initial)

| Area | Evidence in POC | Classification | Integration status |
|---|---|---|---|
| Android device/product | `device/toradex/apalis_imx8qm/` wrapper and product files | Toradex module / Android / build system | Not copied; audit needed |
| Vendor NXP device tree/config | `device_nxp.patch` snapshot | SoC vendor + module/device-tree; individual hunks need review | Not copied; audit needed |
| Kernel | `vendor_nxp-opensource_kernel_imx.patch` snapshot and kernel probe/build notes | Kernel / device-tree | Not copied; classify each hunk |
| U-Boot | `vendor_nxp-opensource_uboot-imx.patch` snapshot | Bootloader | Not copied; classify each hunk |
| Local overlays and scripts | POC `overlays/`, `scripts/`, and wrapper files | Android/product/build/deployment | Not copied; license and necessity review required |
| Ixora-specific behavior | HDMI/LVDS, touch, networking and boot evidence | Carrier-board | Must isolate and map to exact files |
| Historical UUU / `FLASH_TARGET` | Snapshot note says these changes are not reapplied by current setup; one is redundant and one belongs to an old attempt | Temporary/historical | Exclude from active integration unless re-justified |

This is not a complete patch-by-patch classification. Before importing any POC code, inspect every patch, new/untracked file, license, and source origin. The POC notes warn that applying all snapshot patches on top of its overlay setup duplicates changes and can conflict.

## Missing reproducibility inputs

- NXP proprietary release packages/blobs and their access/license conditions.
- Exact export of the currently validated workspace state; the cited manifest snapshot is from 2026-09-15 while later work is documented through 2026-09-29.
- Audited, non-overlapping Toradex adaptation set with source commits and patch purpose.
- Clean-checkout setup/build commands and verified lunch product/output target.
