# Porting guide

For each new module/carrier combination:

1. Record SoC, exact module SKU, carrier revision, and the official SoC-vendor Android release.
2. Pin the corresponding Toradex BSP branch and identify the kernel, device-tree, U-Boot, firmware, and license baselines.
3. Compare the Android and Toradex hardware implementations. Treat Toradex Linux files as hardware references; check kernel binding/version differences before porting.
4. Inventory and classify every change as SoC, module, carrier, Android, kernel, bootloader, device-tree, or build-system work. Preserve upstream notices and do not redistribute restricted inputs.
5. Add a module product under `device/toradex/<module>/`. Isolate carrier-specific resources under `boards/<carrier>/` when supported by vendor product discovery.
6. Add a platform manifest under `manifests/<android-major>/` that includes the pinned vendor baseline and the integration project. Keep development branch revisions out of release manifests.
7. Run clean sync and build; document exact commands and licensed input retrieval. Validate deployment on the exact hardware before claiming boot or peripheral support.
8. Record evidence and limitations in the hardware matrix. Leave untested functions marked `Not Tested`.

## Apalis iMX8QM + Ixora reference

The first target inherits NXP's i.MX8QM MEK product. NXP build scripts require product files under `device/nxp/imx8q/<product>/`; `scripts/prepare-apalis-overlay.sh` copies the Toradex source there and applies the kernel/U-Boot overlays. Its lunch name remains `apalis_imx8qm-nxp_stable-userdebug` until the NXP `TARGET_PRODUCT` lookup is validated with a Toradex-prefixed product name.

The Android kernel is NXP `kernel_imx` at 35bbdb5 (6.12 line); the Toradex reference kernel is 6.6.138. The device-tree port therefore requires explicit compatibility review, not a blind copy. Do not use the inherited 13/28 GiB MEK partition table on the 14.8 GiB Apalis eMMC. Blank-media provisioning remains unsupported until a board-sized layout and safe installation flow are reviewed.
