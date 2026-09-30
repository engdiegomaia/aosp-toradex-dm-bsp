# Build the Apalis iMX8QM + Ixora target

## Current status

The reference POC reports Android booting from an already provisioned Apalis eMMC. This repository now contains the NXP Android 16 manifest export, the Apalis product layer, and source overlays, but **a clean Repo sync and build have not been run from this repository**. The host currently has about 5.5 GB free; NXP Android requires hundreds of GB for a clean source/build tree. The workspace also lacks the authorized Apalis SCFW/SECO inputs and NXP restricted codec package.

Do not use the inherited NXP 13/28 GiB partition-table artifacts on the reference Apalis. The observed PN 0037 eMMC user area is 14.8 GiB. A board-sized, license-reviewed partition table and clean install flow remain unfinished.

## Host requirements

Use a Linux host supported by NXP's Android `16.0.0_1.2.0` User's Guide. Its documented Docker build environment is Ubuntu 20.04. Install the NXP-required packages and Java/Python versions from that release guide. The NXP kernel-prebuilt setup downloads roughly 5–10 GB. Install the Arm GNU 12.3.Rel1 AArch32 and AArch64 toolchains and Google's `repo` tool. Allow at least 500 GB free disk as a practical clean-checkout/build budget; more may be needed for retained output and parallel builds. Use 64 GB RAM where available; reduce build parallelism on smaller hosts.

The POC uses these environment variables (override paths in the shell or host-local configuration):

```bash
KERNEL_PREBUILTS_PATH=/opt/android-kernel-prebuilts-6.12
AARCH32_GCC_CROSS_COMPILE=/opt/arm-gnu-toolchain-12.3.rel1-x86_64-arm-none-eabi/bin/arm-none-eabi-
AARCH64_GCC_CROSS_COMPILE=/opt/arm-gnu-toolchain-12.3.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
TORADEX_APALIS_FIRMWARE_DIR=/path/to/authorized/apalis-firmware
```

The kernel prebuilts are prepared by NXP's `device/nxp/common/tools/setup_android_kernel_prebuilts.sh`. Do not store local credentials or proprietary inputs in this repository.

## Repo checkout and build

```bash
mkdir toradex-android && cd toradex-android
repo init -u git@github.com:engdiegomaia/aosp-toradex-dm-bsp.git \
  -b android16-toradex -m manifests/android16/apalis-imx8qm-ixora.xml
repo sync -j4

export TORADEX_APALIS_FIRMWARE_DIR=/path/to/authorized/apalis-firmware
vendor/toradex/aosp-toradex-dm-bsp/scripts/prepare-apalis-overlay.sh "$PWD"
source build/envsetup.sh
lunch apalis_imx8qm-nxp_stable-userdebug
./imx-make.sh -j4
```

This lunch name is retained because NXP's `imx-make.sh` locates the product by `TARGET_PRODUCT=apalis_imx8qm`. The user-facing `toradex_apalis_imx8qm_ixora` name is not wired up. `repo sync` also includes NXP repositories that may require account access or separately licensed inputs. Obtain the two firmware files through an authorized Toradex BSP build and verify them against `firmware/apalis/SHA256SUMS`.

The commands are the intended flow and have not yet been validated end to end. NXP's MEK product references a separately licensed signed VPU codec artifact; do not substitute an unsigned stub. Resolve its authorized acquisition or remove the dependency through a reviewed product adaptation before claiming a clean build.

## Output, flashing, and validation

NXP image and bootloader outputs are under `out/target/product/apalis_imx8qm/`. Do not flash the generated partition tables or use them to provision blank media. The current inherited MEK layout exceeds the reference eMMC capacity, and no Easy Installer package or blank-media installation procedure is supported here. The POC's existing eMMC/TFTP installer is not included in this repository. Record the exact generated image hashes and bench results in [`supported-hardware.md`](supported-hardware.md) after a clean build and separately reviewed installation procedure.
