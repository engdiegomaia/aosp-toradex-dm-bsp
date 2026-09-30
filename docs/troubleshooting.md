# Troubleshooting

## `repo sync` cannot fetch a project

The pinned NXP manifest contains account-controlled or separately licensed projects. Confirm that your NXP account has access and that the release terms permit your use. Do not remove a manifest project silently or replace it with a floating branch.

## The Apalis product is missing from `lunch`

Run `scripts/prepare-apalis-overlay.sh "$PWD"` from the Android workspace before `source build/envsetup.sh`. It copies the product into the `device/nxp/imx8q/` location required by NXP's Soong discovery and build scripts. Confirm `device/nxp/imx8q/apalis_imx8qm/AndroidProducts.mk` exists afterward.

## Overlay preparation fails on firmware hashes

Obtain the Apalis SCFW and matching SECO container through an authorized Toradex BSP build, place only those inputs in a local directory, set `TORADEX_APALIS_FIRMWARE_DIR`, and check the listed SHA-256 values. Do not download arbitrary versions or commit the binaries.

## Kernel patch or overlay does not apply

Confirm the manifest uses the documented NXP Android 16 baseline. The helper refuses unexpected DTS Makefile and U-Boot whitelist layouts; inspect the upstream diff before updating the matching logic. Do not hand-edit generated vendor files because `repo sync` replaces them.

## Build or flash fails

The NXP MEK product depends on a restricted signed codec artifact. Obtain the licensed package; never create an unsigned replacement. The current partition table inherits a 28 GiB MEK layout and is unsafe for the reference 14.8 GiB eMMC. Do not flash generated partition or installer images. Capture UART logs and use the POC's tested recovery chain until a reviewed Apalis installation procedure is available.
