# Build

## Status

The Apalis iMX8QM + Ixora proof of concept has produced and booted Android 16 from eMMC on a physical board. This repository does **not** yet reproduce that result from an empty checkout: its initial manifest is a pinned snapshot, but local overlay changes and proprietary NXP release material are not yet fully represented by this repository. Treat the commands below as the intended workflow, not a verified clean-build recipe.

## Host

Use a supported 64-bit Linux host with the requirements for the selected NXP Android release. Confirm exact distribution, package list, Java/Python versions, RAM, and disk requirements against the NXP `android-16.0.0_1.2.0` release documentation before setting up a clean host. Install Google's `repo` tool using the official Android instructions.

## Source checkout (pinned POC baseline)

```bash
mkdir toradex-android
cd toradex-android
repo init -u <manifest-repository-url> \
  -b android16-toradex \
  -m manifests/android16/nxp-imx8qm-poc-2026-09-15.xml
repo sync -j"$(nproc)"
```

The example manifest path assumes this repository is published as a Repo manifest repository. NXP proprietary packages and license-gated artifacts must be obtained separately under their applicable terms. A clean sync alone is not sufficient to recreate the POC today.

## Build (target workflow; product unresolved)

```bash
source build/envsetup.sh
lunch <verified-toradex-product>-userdebug
m -j"$(nproc)"
```

The POC used NXP's Android build integration and additional board-specific boot packaging. The exact clean-checkout commands, product name, proprietary package preparation, output image target, and required environment variables must be captured from the source checkout before this workflow can be marked verified. Do not infer a product name from the proposed convention.

## Deployment

The POC booted from existing Android eMMC partitions using a U-Boot/TFTP development workflow. It is not a factory provisioning recipe and does not establish an Easy Installer image or empty-eMMC install process. See the source POC's deployment notes before operating hardware; preserve board backups and confirm target partition layout before any write.
