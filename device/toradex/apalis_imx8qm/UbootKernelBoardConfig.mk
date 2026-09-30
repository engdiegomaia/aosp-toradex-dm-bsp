# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# U-Boot + kernel per-product config for Apalis iMX8 QuadMax on Ixora.
#
# common/build/Makefile line 16 includes this file by literal path from
# ${product_path}/. Its job is to declare TARGET_KERNEL_DEFCONFIG,
# TARGET_BOOTLOADER_CONFIG (list of U-Boot defconfigs to build), and
# related knobs. Missing this file is what caused kernel.mk to abort
# with "TARGET_KERNEL_DEFCONFIG not defined".
#
# Inherit NXP's i.MX8QM defaults, then select the Apalis kernel DTB and
# Toradex Apalis U-Boot defconfigs below. These settings require a clean
# build and fresh-board validation before the produced artifacts are
# considered bootable or suitable for deployment.
#
# References:
#   device/nxp/imx8q/mek_8q/UbootKernelBoardConfig.mk (upstream)
#   device/nxp/common/build/Makefile line 16          (include site)
#   device/nxp/common/build/kernel.mk line 38         (assertion site)

include $(dir $(lastword $(MAKEFILE_LIST)))/../mek_8q/UbootKernelBoardConfig.mk

# -------@block_p1_apalis_uboot-------
# P1.1: append the Apalis iMX8 U-Boot defconfig to the build list.
# apalis-imx8_defconfig lives at
#   vendor/nxp-opensource/uboot-imx/configs/apalis-imx8_defconfig
# and is upstream Toradex, merged into NXP's uboot-imx fork. It selects
# CONFIG_TARGET_APALIS_IMX8=y and the Toradex board files at
#   vendor/nxp-opensource/uboot-imx/board/toradex/apalis-imx8/
# which use the same SCU/SCFW ABI (firmware/imx/sci/sci.h) as MEK's
# board files — so the same SECO and SCFW binaries built during the
# MEK bootloader flow are reusable. AHAB is left unsigned for P1.1
# (developer-mode boot; assumes AHAB fuses are still open on this unit).
#
# LABEL FORMAT (load-bearing): the label before ':' is not free-form.
# device/nxp/common/build/uboot.mk line 148 passes it to build_imx_uboot
# as $2, and mek_8q/AndroidUboot.sh dispatches on `cut -d'-' -f1`:
#   "imx8qm*"  -> MKIMAGE_PLATFORM=iMX8QM, mx8qm-ahab-container.img
#   "imx8qxp*" -> MKIMAGE_PLATFORM=iMX8QX, mx8qx-ahab-container.img
#   "imx8dx*"  -> MKIMAGE_PLATFORM=iMX8QX, mx8qxc0-ahab-container.img
#   anything else -> no match, MKIMAGE_PLATFORM leaks from the previous
#     loop iteration. The initial P1.1 run used "apalis:" as the label,
#     which fell through to the trailing state of the last MEK 8QXP
#     entry, producing a wrong u-boot-apalis.imx signed against QXP-C0.
# So the label MUST start with imx8qm to select the 8QM branch, AND
# end in "-dual" so AndroidUboot.sh:194 dispatches the dual-bootloader
# publish path (see block_dual_suffix below for the full rationale).
# Use "imx8qm-apalis-dual" — the "-apalis-" infix distinguishes our
# artifacts from MEK's ("-md", "-hdmi", "-mek-uuu", "-xen*") and the
# trailing "-dual" triggers the SPL+bootloader split.
#
# Iterate on the imx8qm-apalis-dual output alone. Result artifacts:
#   out/target/product/apalis_imx8qm/spl-imx8qm-apalis-dual.bin
#   out/target/product/apalis_imx8qm/bootloader-imx8qm-apalis-dual.img
#
# The upstream Toradex env layout (CONFIG_ENV_OFFSET=0xFFFFDE00 at eMMC
# top) is preserved — that matches units pre-flashed with Toradex BSP
# and keeps env writes clear of AOSP dynamic partitions.
#
# References:
#   vendor/nxp-opensource/uboot-imx/configs/apalis-imx8_defconfig
#   vendor/nxp-opensource/uboot-imx/board/toradex/apalis-imx8/apalis-imx8.c
#   vendor/nxp-opensource/kernel_imx/arch/arm64/boot/dts/freescale/imx8qm-apalis-v1.1-ixora-v1.2.dts
#   device/nxp/imx8q/mek_8q/AndroidUboot.sh (SoC dispatch on cut -d'-')
#   device/nxp/common/build/uboot.mk line 138-154 (label loop)
#   docs/p1-bringup.md (this milestone's flash + boot procedure)

# P1.1 iteration-focus: replace the 21-entry MEK list with just our
# Apalis defconfig. Two reasons:
#   (a) uboot.mk:113-127 makes UBOOTENVSH a stale target — the file is
#       generated once at the start of build_uboot, then wiped by every
#       subsequent `make mrproper` in the loop. Loop iteration 15 or so
#       (imx8qm-trusty-rbidx-blob-dual) trips over the missing file
#       ("cannot open ubootenv.sh") and aborts BEFORE reaching our
#       entry. This is an upstream NXP bug, not something we should
#       patch in the vendor tree at P1.
#   (b) For P1 hardware bring-up we only need u-boot-imx8qm-apalis.imx
#       (flashed via uuu directly). The MEK bootloader-*.img matrix is
#       P0 parity artifacts we already validated once — no need to
#       regenerate them on every P1 iteration.
# When we return to broader releases (post-P3), swap back to `+=` and
# fix the ubootenv.sh regeneration properly.
#
# P1.2: swap apalis-imx8_defconfig (single-stage Yocto, 0 SPL symbols)
# for apalis-imx8_android_defconfig (dual-bootloader + Android/Fastboot
# + AVB/AB/Trusty). The Yocto defconfig produces only U-Boot proper —
# the NXP Android dual-bootloader flow needs SPL + u-boot.bin, and any
# stray MEK SPL binary in imx-mkimage/iMX8QM/ was silently reused and
# p1-2-board-port-map.md.
#
# The new defconfig lives in overlays/uboot/configs/ and is materialized
# into android_build/vendor/nxp-opensource/uboot-imx/configs/ by
# scripts/prepare-apalis-overlay.sh. Do NOT hand-copy it into the vendor
# tree; repo sync would clobber the copy.
# -------@block_dual_suffix-------
# Label MUST end in "-dual" so AndroidUboot.sh:194 takes the dual-
# bootloader publish path:
#   if [ ${PRODUCT_IMX_DUAL_BOOTLOADER} = true ] && [ last-token != uuu ]
#      || [ last-token = dual ]; then
#     cp boot-spl-container.img     -> spl-<label>.bin
#     cp u-boot-atf-container.img   -> bootloader-<label>.img
#   else
#     cp flash.bin                  -> u-boot-<label>.imx   # single-stage only
#   fi
#
# Our first P1.2 build used label "imx8qm-apalis". Last token = "apalis"
# ≠ "dual", so the shell fell through to the else branch and produced
# ONLY u-boot-imx8qm-apalis.imx. That's the single-stage flash.bin blob,
# not what fastboot_imx_flashall.sh (nor UG10156 §3.4 dual-bootloader
# flow) can consume.
#
# Switching to "imx8qm-apalis-dual":
#   - Last hyphen-separated token = "dual"       → dual path selected.
#   - Artifact names become spl-imx8qm-apalis-dual.bin and
#     bootloader-imx8qm-apalis-dual.img, matching UG10156 Table 20
#     naming convention.
#   - Aligns with the flash-script whitelist patch in
#     scripts/prepare-apalis-overlay.sh (imx8qm_uboot_feature already
#     includes "apalis-dual", so `-u apalis-dual` passes validation
#     and the script constructs bootloader-imx8qm-apalis-dual.img
#     via ${soc_name}-${uboot_feature}.img on line 275).
#
# The mkimage SoC dispatch in AndroidUboot.sh keys off "imx8qm*" prefix
# via `cut -d'-' -f1`, so the extra "-dual" suffix is invisible to that
# check — still selects MKIMAGE_PLATFORM=iMX8QM.
TARGET_BOOTLOADER_CONFIG := imx8qm-apalis-dual:apalis-imx8_android_defconfig

# -------@block_p1_apalis_uboot_uuu-------
# UUU transport bootloader. Same base as -dual with CONFIG_FASTBOOT_UUU_SUPPORT=y
# so `uuu` can drive SDPU/SDPV/FB stages during factory flash. Mirrors
# NXP's mek_8q pattern (imx8qm-mek-uuu). The output artifact
# u-boot-imx8qm-apalis-uuu.imx is consumed by uuu_imx_android_flash.sh
# via bootloader_used_by_uuu (line 843) after the apalis-dual override we
# add in that script. See overlays/uboot/configs/apalis-imx8_android_uuu_defconfig
# header for the full rationale.
TARGET_BOOTLOADER_CONFIG += imx8qm-apalis-uuu:apalis-imx8_android_uuu_defconfig

# -------@block_p1_3_kernel_gki_override-------
# Keep the pending builtin-console experiment for a controlled comparison.
# Earlycon itself is provided independently by CONFIG_SERIAL_IMX_EARLYCON;
# LPUART=m alone is not a diagnosis of silent boot in this NXP tree.
# prepare-apalis-overlay.sh materializes the Toradex-owned fragment.
# The fsl_lpuart.ko exclusions in BOTH BoardConfig.mk and SharedBoardConfig.mk
# must follow this experiment if it is later reverted.
# See docs/bringup/revisao-20260911.md.
ifeq ($(LOADABLE_KERNEL_MODULE),true)
  TARGET_KERNEL_GKI_DEFCONF := imx8q_gki_apalis_bringup.fragment
endif
