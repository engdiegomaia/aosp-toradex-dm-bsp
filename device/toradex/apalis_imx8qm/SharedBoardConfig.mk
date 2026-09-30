# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# Shared board config for the Toradex Apalis iMX8 QuadMax on Ixora.
#
# common/build/Makefile expects this file at ${product_path}/ and
# includes it by literal path — the AOSP inherit-product graph does
# NOT cover the NXP kernel/U-Boot build helpers, so we must materialize
# it here.
#
# Inherit NXP's common i.MX8QM settings, then override Apalis bootloader
# and kernel options below. Keep carrier-specific settings out of the
# common product where possible. The partition layout remains an NXP MEK
# fallback and is not safe to flash to the reference Apalis eMMC.
#
# References:
#   device/nxp/imx8q/mek_8q/SharedBoardConfig.mk (upstream)
#   device/nxp/common/build/Makefile line 14   (include site)

include $(dir $(lastword $(MAKEFILE_LIST)))/../mek_8q/SharedBoardConfig.mk

# -------@block_apalis_overrides-------
#
# Note: TARGET_USE_DYNAMIC_PARTITIONS is set in BoardConfig.mk, not
# here. This file is included by device/nxp/common/build/Makefile
# (the NXP kernel/U-Boot build helpers), which runs in a separate
# process from AOSP's Soong config. Flags that need to influence
# AOSP's product/board resolution must go in BoardConfig.mk.

# -------@block_p1_bootloader_ota-------
# MEK's SharedBoardConfig.mk line 274 sets
#   BOARD_OTA_BOOTLOADERIMAGE := bootloader-imx8qm-trusty-dual.img
# which is one of the 21 MEK defconfigs we dropped in P1.1
# (UbootKernelBoardConfig.mk). uboot.mk:159's `bootloader` target
# copies BOARD_OTA_BOOTLOADERIMAGE from UBOOT_COLLECTION into
# bootloader.img — the file MUST exist in UBOOT_COLLECTION or the
# copy fails with "cannot stat ...".
#
# P1.2 now builds via label "imx8qm-apalis-dual" (dual-bootloader
# path in AndroidUboot.sh:194), which produces both
#   spl-imx8qm-apalis-dual.bin       (from boot-spl-container.img)
#   bootloader-imx8qm-apalis-dual.img (from u-boot-atf-container.img)
# in UBOOT_COLLECTION. Point BOARD_OTA_BOOTLOADERIMAGE at the U-Boot
# proper container — that's what OTA delivers and what the flash
# script expects on line 275 for `-u apalis-dual`.
#
# Historical note: earlier P1.1 revisions of this file pointed at
# u-boot-imx8qm-apalis.imx (the single-stage flash.bin dump), which
# was correct while the label lacked the -dual suffix. See git
# history on this file for the transition.
#
# Reference: device/nxp/imx8q/mek_8q/SharedBoardConfig.mk line 274
#            device/nxp/common/build/uboot.mk line 158-161
#            device/nxp/imx8q/mek_8q/AndroidUboot.sh line 194-199
BOARD_OTA_BOOTLOADERIMAGE := bootloader-imx8qm-apalis-dual.img

# -------@block_p1_dual_partition_table-------
# Force the dual-bootloader partition table generation path.
#
# partition_table.mk:3 branches on PRODUCT_IMX_DUAL_BOOTLOADER. MEK
# only sets it := true inside `ifeq ($(TARGET_PRODUCT),mek_8q_car)`
# (SharedBoardConfig.mk:10), so for non-CAR the variable is empty and
# partition_table.mk drops to line 22-42 territory. Two things then
# go wrong for us:
#   1. Line 15 of common/build/Makefile includes SharedBoardConfig.mk
#      BEFORE partition_table.mk. When NXP's `make` is invoked directly
#      by imx-make.sh (not via AOSP Soong), TARGET_USE_DYNAMIC_PARTITIONS
#      is not defined in that make context — even though our
#      BoardConfig.mk sets it to `true` for Soong. So partition_table.mk
#      falls to lines 34-42, which produces a NON-dual primary table
#      and no `-dual` addition variants at all.
#   2. fastboot_imx_flashall.sh:502 needs partition-table-dual.img
#      when -u <feature> ends in "-dual" (support_dual_bootloader=1).
#      Without it: "partition-table-dual.img does not exist, the -c
#      option is not correctly used".
#
# Setting PRODUCT_IMX_DUAL_BOOTLOADER := true here has three effects:
#   (a) partition_table.mk:3-15 branch runs → the PRIMARY partition-
#       table.img is generated from device-partitions-*-ab-dual-
#       bootloader*.bpt (see partition_table.mk lines 4-14 for
#       exactly which .bpt gets picked based on dynamic-partitions
#       + no-product flags). Result: partition-table.img IS the dual
#       variant, no separate -dual file needed. Flash script's
#       ${card_size}=0 code path then finds it correctly.
#   (b) AndroidUboot.sh:194 first clause of the OR becomes true (was
#       already reaching the second clause via our label's "-dual"
#       suffix, so no functional change to the U-Boot publish path).
#   (c) mek_8q/UbootKernelBoardConfig.mk:90-92 only `export`s the
#       variable when TARGET_PRODUCT=mek_8q_car. Non-CAR: not exported
#       into the shell env, but STILL visible to sub-make since it's
#       a make variable. AndroidUboot.sh is dot-sourced from a make
#       recipe (uboot.mk:147), so it inherits the recipe shell's env.
#       Recipe substitutes ${PRODUCT_IMX_DUAL_BOOTLOADER} at expansion
#       time — value present. Safe.
#
# NOTE: fastboot_imx_flashall.sh:502 asks for a file named
# partition-table-dual.img specifically. In the DUAL_BOOTLOADER=true
# branch (lines 3-15 of partition_table.mk), NXP names the primary
# partition-table.img (dual internally) but does NOT emit a symlink
# or copy named partition-table-dual.img. The flash script needs the
# `-dual` suffix regardless. Adding an ADDITION_BPT_PARTITION alias
# below to satisfy that check.
#
# Reference: device/nxp/imx8q/mek_8q/partition_table.mk (branches)
#            device/nxp/common/build/gpt.mk line 33-40 (ADDITION_BPT loop)
#            device/nxp/common/tools/fastboot_imx_flashall.sh line 497-509
PRODUCT_IMX_DUAL_BOOTLOADER := true

# -------@block_p1_3_bringup_module_prune-------
# Companion to the TARGET_KERNEL_GKI_DEFCONF override in
# UbootKernelBoardConfig.mk. When our bring-up fragment forces
# CONFIG_SERIAL_FSL_LPUART=y, drivers/tty/serial/fsl_lpuart.ko is
# no longer emitted. MEK's SharedBoardConfig.mk line 82 lists
#   $(KERNEL_OUT)/drivers/tty/serial/fsl_lpuart.ko
# in BOARD_VENDOR_RAMDISK_KERNEL_MODULES; the ramdisk copy step
# in kernel.mk would then abort with "cannot stat …/fsl_lpuart.ko".
#
# Strip the entry from the inherited list. Any other .ko entries
# untouched. When the GKI override above is reverted (fragment
# goes back to =m, .ko re-emitted), remove this filter-out too so
# the module gets picked up again for the ramdisk.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(filter-out $(KERNEL_OUT)/drivers/tty/serial/fsl_lpuart.ko,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES))

# Generic panel-lvds compatible used by the Toradex 10.1-inch LVDS kit.
# Include in both Soong and NXP module packaging graphs (as for LPUART above).
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-lvds.ko

# Capacitive touch controller on the Toradex LVDS kit.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(KERNEL_OUT)/drivers/input/touchscreen/atmel_mxt_ts.ko
