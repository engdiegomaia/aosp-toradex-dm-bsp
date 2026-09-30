# Architecture

## Integration model

```text
AOSP + SoC-vendor Android BSP + Toradex module/carrier hardware support
                              ↓
                   Toradex Android layer
                              ↓
                   module/carrier product
```

Prefer vendor Android implementations for platform, kernel, bootloader, HALs, graphics, multimedia, firmware, and services. Use the corresponding Toradex BSP as a hardware reference. Port only required differences and record provenance, hardware dependency, and upstream revision.

## Branches and platforms

Branches identify Android baseline and platform where a dedicated platform branch is needed: the Apalis reference branch is `android16-toradex-apalis-imx8`. Prefer adding compatible platforms as `device/toradex/<module>/` folders and manifests on the same baseline branch; split branches when vendor baselines or maintenance needs differ. Keep carrier-specific configuration under `boards/<carrier>/` where the NXP build permits it. Give each buildable combination its own Repo manifest, for example `manifests/android16/apalis-imx8qm-ixora.xml`.

The initial target uses NXP's required product identifier `apalis_imx8qm` and lunch choice `apalis_imx8qm-nxp_stable-userdebug`. NXP `imx-make.sh` searches `device/nxp` for this product name, so the integration repository is checked out at `vendor/toradex/aosp-toradex-dm-bsp`; the helper copies the product into `device/nxp/imx8q/apalis_imx8qm`. A symlink or product only under `device/toradex` is not discovered by the current NXP tooling.

## Source layout and licensing

- `manifests/android16/` pins the vendor/AOSP source tree; platform manifests add this integration project.
- `device/toradex/` contains Toradex Android product definitions.
- `overlays/kernel/` and `overlays/uboot/` contain small, license-identified adaptations.
- `scripts/` materializes overlays after `repo sync`; do not edit generated files in the Android checkout.
- `firmware/` contains hashes and instructions only. Restricted binary firmware stays outside Git.
- `docs/` records baselines, build procedures, validation, and limitations.

The self-project entry in a development manifest follows the baseline branch. Release manifests must pin this project to the integration commit and every other project to immutable revisions.
