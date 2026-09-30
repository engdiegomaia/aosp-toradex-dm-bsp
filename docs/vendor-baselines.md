# Vendor baselines, adaptation inventory, and licensing

## Pinned Android baseline

The initial source is NXP `android-16.0.0_1.2.0`, based on AOSP `android-16.0.0_r1`. `manifests/android16/nxp-imx-android-16.0.0_1.2.0-pinned.xml` is exported with `repo manifest -r` from the POC's synchronized source tree on 2026-09-30. It contains 1,018 projects pinned to resolved revisions; SHA-256: `0acfb7893fe89247b2ab8c706f99bfdf2496143fa69b768bc254027b8a6d5074`.

Key projects:

| Component | Project | Pinned revision |
|---|---|---|
| NXP device | `android-imx_device_fsl` | `53ec745a82a4eaaaa30f5dc64cd0dc2f95859443` |
| Android kernel | `linux-imx` / `vendor/nxp-opensource/kernel_imx` | `35bbdb55359ca55922de0df807a606a7a968a5d3` |
| U-Boot | `uboot-imx` | `f97912fcabb0a0931e848ae597d652096e9cc44e` |
| ATF | `imx-atf` | `a266ff458c2526a6474036a5c6648be6fdc54fe3` |
| imx-mkimage | `imx-mkimage` | `be80fadd5e7988214149a2bc48daac1b0950d4c2` |

The manifest includes NXP project remotes with separate account and license requirements. A successful public Repo sync has not been demonstrated; obtain access to restricted projects through NXP's authorized channels.

## Apalis + Ixora changes

| Area | Adaptation | Source/reference | Status |
|---|---|---|---|
| Product | Thin `apalis_imx8qm` identity/configuration inheriting NXP `mek_8q` | NXP device project above | Imported; clean build pending |
| Device tree | Apalis module and Ixora v1.1/v1.2 DTSI plus v1.2 top-level DTS | Toradex `linux-toradex` 6.6.138, SRCREV `f8f08c0cd5c2aae681887579e7502200178cf66c` | Ported to NXP kernel 6.12; hardware/source compatibility needs further validation |
| Kernel config | Apalis GKI fragment | NXP kernel baseline `35bbdb5` | Included; clean kernel build pending |
| HDMI firmware load | Small patch to NXP `cdns-mhdp-imx8qm.c` | NXP kernel project above | Patch included; application/build not validated here |
| U-Boot | Apalis board, SPL, Android defconfigs and container configuration | Toradex U-Boot 2024.04 reference SRCREV `1f3c8b6671de3afad7f3dfa4c8ac1631f0a7a987`; NXP Android U-Boot above | Included; clean build pending |
| Build integration | Materialize product into NXP `device/nxp/imx8q/`; enable Apalis DTB and add Apalis U-Boot feature names | NXP `imx-make.sh` source behavior | Helper included; NXP checkout not modified in this workspace |
| SCFW/SECO | Apalis firmware pair required for bootloader image generation | Toradex BSP outputs | Not redistributed; required SHA-256 values are in `firmware/apalis/SHA256SUMS` |
| Partitioning | Current source inherits NXP MEK 13/28 GiB layout | NXP partition files | Unsafe for reference unit's 14.8 GiB eMMC; no Apalis layout included |

The POC's September 15 patch bundle is a historical snapshot, not an extra patch queue. Its current overlay setup already represents some patch content. Historical UUU/`FLASH_TARGET` edits that the POC no longer reapplies are excluded. Do not apply the old snapshot patches over the overlay setup without reviewing each hunk.

## Licensing and excluded inputs

- Product makefiles and kernel config use SPDX `Apache-2.0`.
- Ported Toradex kernel device-tree files retain their `GPL-2.0-or-later OR MIT` notices.
- U-Boot adaptations retain GPL notices; the HDMI kernel patch is marked `GPL-2.0-only`.
- SCFW and SECO binaries are not stored here; builders must obtain authorized copies and match the listed hashes.
- The POC boot animation and custom partition-table data are excluded because their redistribution license was not established. The code currently falls back to the NXP MEK table, which must not be flashed to Apalis.
- NXP's MEK product references a signed VPU codec artifact from a separately licensed package. Do not replace it with an unsigned stub; clean build remains blocked until this dependency is lawfully resolved or removed by a reviewed adaptation.

Retain upstream copyright notices and follow the terms of every manifest project. No release or redistribution claim is made for external vendor firmware.
