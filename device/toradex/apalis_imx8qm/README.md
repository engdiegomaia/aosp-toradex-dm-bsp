# Apalis iMX8QM + Ixora Android integration

This Android 16 target adapts NXP's `imx8q/mek_8q` product for the Toradex Apalis iMX8QM on Ixora. The source files here are materialized into `device/nxp/imx8q/apalis_imx8qm/` because the NXP build scripts search that tree for product makefiles. This repository remains the source of truth; do not edit the generated destination.

The published Repo checkout places this repository at `vendor/toradex/aosp-toradex-dm-bsp/`. Run `scripts/prepare-apalis-overlay.sh "$PWD"` from the AOSP workspace before sourcing `build/envsetup.sh` and running `lunch`. The helper also applies the tracked kernel and U-Boot overlays and validates required external firmware hashes.

The lunch target remains `apalis_imx8qm-nxp_stable-userdebug` to match NXP's `TARGET_PRODUCT` assumptions in `imx-make.sh`. Renaming the Android product to a Toradex-specific lunch name is deferred until NXP's source lookup and image build are validated with such a name.

This target inherits NXP MEK platform configuration. Its partition table currently inherits the NXP MEK layout; that 28 GiB layout is not suitable for the 14.8 GiB eMMC observed on the reference Apalis. Do not use generated partition-table or flash artifacts to provision media. A board-sized, license-reviewed partition layout and clean installation flow remain release blockers.

The reference POC reports successful Android boot from a previously provisioned eMMC. This repository has not yet passed a clean checkout/build or a fresh image installation. See [`docs/vendor-baselines.md`](../../../docs/vendor-baselines.md), [`docs/build.md`](../../../docs/build.md), and [`docs/supported-hardware.md`](../../../docs/supported-hardware.md).
