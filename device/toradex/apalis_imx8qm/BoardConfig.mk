# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# BoardConfig for Toradex Apalis iMX8 QuadMax on Ixora carrier.
#
# Inherit NXP's SoC-common board configuration, then override the Apalis
# kernel DTB and boot settings below. The MEK prebuilt-DTBO path is not
# valid for this product; the Apalis DTB is selected through the NXP
# vendor_boot build path. The partition layout remains a MEK fallback and
# is not safe to flash to the reference eMMC.
#
# References:
#   device/nxp/imx8q/mek_8q/BoardConfig.mk
#   device/nxp/imx8q/BoardConfigCommon.mk

# -------@block_pre_include_flags-------
# MEK's mek_8q/SharedBoardConfig.mk line 286 guards
# TARGET_USE_DYNAMIC_PARTITIONS on ifeq($(TARGET_PRODUCT),mek_8q) — our
# target doesn't match, so without an early override the whole dynamic-
# partition cascade collapses, causing build_image.py to fail with
# KeyError: 'partition_size' when packaging vendor_dlkm/system_dlkm.
#
# Set the flag here (BoardConfig.mk is included before AOSP's product
# resolution runs) so that BoardConfigCommon.mk's dynamic-partition
# block at line 195 evaluates true, MEK's mek_8q.mk line 155 conditional
# runs, PRODUCT_USE_DYNAMIC_PARTITIONS gets set, and
# product_config.mk:505 derives PRODUCT_USE_DYNAMIC_PARTITION_SIZE
# from it, so build/make/core/Makefile emits use_dynamic_partition_size=true
# into image_info.txt files.
#
# Reference: device/nxp/imx8q/mek_8q/SharedBoardConfig.mk line 286-294
#            device/nxp/imx8q/BoardConfigCommon.mk line 195
#            device/nxp/imx8q/mek_8q/mek_8q.mk line 155
TARGET_USE_DYNAMIC_PARTITIONS ?= true
# Force DTB into vendor_boot.img unconditionally. MEK's SharedBoardConfig
# gates this on SUPPORT_GBL (see mek_8q/SharedBoardConfig.mk:291), but we
# always want the Apalis dtb embedded regardless of GBL selection so
# vendor_boot.img is bootable on plain U-Boot handoff (Torizon U-Boot).
TARGET_INCLUDE_DTB_TO_VENDOR_BOOT := true

# BOARD_* vars from MEK's mek_8q.mk guarded block (line 162-163) that
# don't propagate through inherit-product. Needed so super.img actually
# gets built and gets included in the OTA update package.
BOARD_BUILD_SUPER_IMAGE_BY_DEFAULT := true
BOARD_SUPER_IMAGE_IN_UPDATE_PACKAGE := true

include device/nxp/imx8q/mek_8q/BoardConfig.mk

# Regulatory country validated on the Brazil bench; override the MEK default.
BOARD_BOOTCONFIG := $(filter-out androidboot.wificountrycode=%,$(BOARD_BOOTCONFIG))
BOARD_BOOTCONFIG += androidboot.wificountrycode=BR

# -------@block_apalis_overrides-------
# MEK's BoardConfig sets:
#   BOARD_PREBUILT_DTBOIMAGE := $(OUT_DIR)/target/product/$(PRODUCT_DEVICE)/dtbo-imx8qm-revd.img
# With PRODUCT_DEVICE=apalis_imx8qm that MEK artifact path is not produced.
# The Apalis DTB is built into vendor_boot via TARGET_BOARD_DTS_CONFIG
# below, so no separate DTBO artifact is configured.
BOARD_PREBUILT_DTBOIMAGE :=

# -------@block_p1_dtb-------
# Wire built kernel dtbs into vendor_boot.img via TARGET_BOARD_DTS_CONFIG.
#
# History: originally we set BOARD_PREBUILT_DTBIMAGE_DIR to the raw kernel
# KERNEL_OBJ/.../freescale/ directory. AOSP's build/make/core/Makefile:1020
# globs *.dtb from that dir at parse time — which pulled in ALL ~620 dtbs
# the NXP kernel Makefile compiles by default (MEK, Phantom-MEK, DXL,
# validation boards, etc.). Result: dtb.img=50 MB, vendor_boot.img=73 MB,
# over the 64 MiB BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE, mkbootimg failed.
#
# Fix: switch to the NXP dtbo.mk pipeline via TARGET_BOARD_DTS_CONFIG
# (device/nxp/common/build/dtbo.mk:34). That path only concatenates the
# dtbs explicitly listed here — the Apalis-Ixora-v1.2 dtb, ~60 KiB — and
# ALSO declares KERNEL_BIN as a prerequisite (dtbo.mk:43), which forces a
# real kernel rebuild after any DTS overlay change (ninja can't see into
# the make-driven KERNEL_OBJ subprocess).
#
# CRITICAL: MEK's BoardConfig.mk sets TARGET_BOARD_DTS_CONFIG with `:=`
# (assignment, not `+=`) inside its non-CAR branch (line 172: sets it to
# imx8qm-mek-ov5640-dual-rpmsg.dtb and 15 more). The `include ...mek_8q/
# BoardConfig.mk` above blows away anything we set beforehand. So the
# override MUST come AFTER the include, and it MUST use `:=` (not `+=`)
# to reset the list to Apalis-only.
#
# BOARD_PREBUILT_DTBIMAGE_DIR is intentionally unset — leaving it
# undefined disables the AOSP glob rule (build/make/core/Makefile:1019
# guard) and lets dtbo.mk's rule at INSTALLED_DTBIMAGE_TARGET
# (line 42-52) own the target.
TARGET_BOARD_DTS_CONFIG := imx8qm-apalis-v1.1-ixora-v1.2:imx8qm-apalis-v1.1-ixora-v1.2.dtb

# -------@block_p1_3_bringup_module_prune_soong-------
# Soong/ninja mirror of the same filter-out in
# device/toradex/apalis_imx8qm/SharedBoardConfig.mk. Two separate build
# graphs consume BOARD_VENDOR_RAMDISK_KERNEL_MODULES:
#
#   1. NXP make (invoked by imx-make.sh) reads SharedBoardConfig.mk via
#      device/nxp/common/build/Makefile:14. Our SharedBoardConfig.mk
#      wraps MEK's and applies the filter-out there. This graph builds
#      the kernel + copies .ko files into vendor_ramdisk/lib/modules/.
#
#   2. Soong reads BoardConfig.mk (this file). apalis_imx8qm.mk
#      inherits mek_8q.mk, which `include`s MEK's SharedBoardConfig.mk
#      directly (mek_8q.mk:12) — bypassing our wrapper. Soong generates
#      a ninja rule to copy every entry of the ORIGINAL list into
#      depmod_vendor_ramdisk_stripped_intermediates/. When we flipped
#      LPUART builtin the .ko stopped being emitted, and that ninja
#      rule then failed with:
#         FAILED: ninja: 'obj/KERNEL_OBJ/drivers/tty/serial/fsl_lpuart.ko'
#         needed by 'depmod_vendor_ramdisk_stripped_intermediates/fsl_lpuart.ko'
#         missing and no known rule to make it
#
# Same filter-out here, applied post-include, closes the Soong side of
# the graph. Revert both this block and the SharedBoardConfig.mk
# companion when the GKI override in UbootKernelBoardConfig.mk is
# removed (fragment back to =m, .ko re-emitted).
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(filter-out $(KERNEL_OUT)/drivers/tty/serial/fsl_lpuart.ko,$(BOARD_VENDOR_RAMDISK_KERNEL_MODULES))

# -------@block_p1_3_console_cmdline-------
# Select the i.MX earlycon handler through DT stdout-path/compatible.
# imx_earlycon.c applies the i.MX register offset and little-endian access;
# the named lpuart32 handler in fsl_lpuart.c does not do that.
# This affects Android image assembly; raw booti tests require bootargs.
# See docs/bringup/revisao-20260911.md for source evidence and limitations.
BOARD_KERNEL_CMDLINE += console=ttyLP1,115200 earlycon

# Generic panel-lvds compatible used by the Toradex 10.1-inch LVDS kit.
# Include in both Soong and NXP module packaging graphs (as for LPUART above).
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(KERNEL_OUT)/drivers/gpu/drm/panel/panel-lvds.ko

# Capacitive touch controller on the Toradex LVDS kit.
BOARD_VENDOR_RAMDISK_KERNEL_MODULES += $(KERNEL_OUT)/drivers/input/touchscreen/atmel_mxt_ts.ko
