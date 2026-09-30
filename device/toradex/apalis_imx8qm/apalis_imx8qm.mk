# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# Product config for Toradex Apalis iMX8 QuadMax on Ixora carrier.
#
# P0 strategy: inherit the full NXP MEK product target, then override
# only the identity fields. All HALs, packages, permissions, overlays,
# powerhint JSONs, and product.prop continue to come from MEK's dir
# because mek_8q.mk computes IMX_DEVICE_PATH from $(MAKEFILE_LIST) — it
# resolves to device/nxp/imx8q/mek_8q/ even when included from here.
# This is load-bearing: do NOT copy mek_8q.mk into this dir, that would
# rebind IMX_DEVICE_PATH and silently break every relative PRODUCT_COPY.
#
# The identity :=  overrides below run AFTER the inherit-product call,
# so they win over MEK's own PRODUCT_NAME/DEVICE/MODEL assignments.
#
# References:
#   device/nxp/imx8q/mek_8q/mek_8q.mk           (source of inheritance)
#   device/nxp/imx8q/ProductConfigCommon.mk     (common product config)
#   device/nxp/imx8q/AndroidProducts.mk         (MEK equivalent)

$(call inherit-product, device/nxp/imx8q/mek_8q/mek_8q.mk)

# -------@block_identity-------
# Overrides that identify this target as Apalis/Ixora, not MEK.
# Anything else divergent MUST come in a later, single-subsystem commit
# citing either the MEK config it changes or the Toradex Linux BSP file

PRODUCT_NAME := apalis_imx8qm
PRODUCT_DEVICE := apalis_imx8qm
PRODUCT_MODEL := Apalis-iMX8QM-Ixora
PRODUCT_MANUFACTURER := Toradex

TARGET_BOOTLOADER_BOARD_NAME := apalis_imx8qm

# Enable Android's Wi-Fi Display (Miracast source) adapter for this product.
# Product overlays take precedence over the inherited MEK device overlay.
# This exposes the framework feature; a working Wi-Fi Direct/RTSP session
# still depends on the 88W8997 firmware, driver, and a compatible sink.
PRODUCT_PACKAGE_OVERLAYS += device/nxp/imx8q/apalis_imx8qm/overlay
# Keep this framework resource static even when the product enforces RROs;
# config_enableWifiDisplay is consumed while system_server starts.
PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += \
    device/nxp/imx8q/apalis_imx8qm/overlay/frameworks/base/core/res/res \
    device/nxp/imx8q/apalis_imx8qm/overlay/frameworks/base/packages/SettingsProvider/res

# -------@block_dynamic_partitions_reinject-------
# MEK's mek_8q.mk sets PRODUCT_USE_DYNAMIC_PARTITIONS := true inside a
# TARGET_USE_DYNAMIC_PARTITIONS==true guard (line 155-164), but that
# guard evaluates at the moment inherit-product reads MEK's file —
# BEFORE our BoardConfig.mk (where we set TARGET_USE_DYNAMIC_PARTITIONS)
# is loaded. Result: MEK's ifeq is always false during our inherit, so
# PRODUCT_USE_DYNAMIC_PARTITIONS never gets set, product_config.mk:505
# leaves PRODUCT_USE_DYNAMIC_PARTITION_SIZE empty, image_info.txt files
# omit use_dynamic_partition_size=true, and build_image.py dies with
# KeyError: 'partition_size' when packaging vendor_dlkm/system_dlkm.
#
# Set both directly at the leaf. PRODUCT_USE_DYNAMIC_PARTITION_SIZE is
# what product_config.mk would derive from PRODUCT_USE_DYNAMIC_PARTITIONS
# anyway (line 504-505), setting it explicitly avoids depending on that
# derivation.
#
# Reference: device/nxp/imx8q/mek_8q/mek_8q.mk line 155-164
#            build/make/core/product_config.mk line 504-505
#            build/make/core/Makefile line 2364
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_USE_DYNAMIC_PARTITION_SIZE := true

# MEK's same guarded block also inherits Virtual A/B OTA product config.
# TARGET_USE_VENDOR_BOOT defaults to true in mek_8q.mk line 110, and
# BoardConfigCommon.mk doesn't override it, so we take the compression
# variant. Enables snapshotted A/B OTA with xor compression — required
# for the super partition update flow to work.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression_with_xor.mk)

# Do NOT add ro.soc.manufacturer or ro.soc.model here. MEK's mek_8q.mk
# already sets both via PRODUCT_VENDOR_PROPERTIES += ; adding our own
# accumulates duplicates, and Android 16's post_process_props aborts
# the build with "found duplicate sysprop assignments" at packaging
# time (~4 hours in). MEK's value ro.soc.model=IMX8Q is the family
# name (covers 8QuadMax + 8QuadXPlus) — acceptable for P0 parity.
# For a shipping product wanting the specific SKU string IMX8QM,
# override via PRODUCT_PROPERTY_OVERRIDES (last-writer-wins) or
# provide a device product.prop that shadows MEK's.
#
# Reference: device/nxp/imx8q/mek_8q/mek_8q.mk
#            (declares ro.soc.manufacturer=nxp and ro.soc.model=IMX8Q)

# -------@block_board_vars_reinject-------
# AOSP's inherit-product only propagates PRODUCT_* variables through
# the product graph — BOARD_* assignments inside the inherited .mk are
# NOT carried across. mek_8q.mk sets four AVB/GBL rollback-index
# BOARD_* variables which gbl.mk / avbtool / image assembly rules
# reference directly. Without them, gbl_signtool.py is invoked with
# --rollback_index <empty> and image assembly fails.
#
# Re-declare here with the same conditional-with-fallback guards as
# MEK. Not-guarded on PRODUCT_IMX_CAR since our target doesn't build
# the car variant, but the AVB_BOOT / AVB_INIT_BOOT guards in MEK are
# themselves inside "ifneq ($(PRODUCT_IMX_CAR),true)" — so with
# PRODUCT_IMX_CAR undefined (our case) they should run, which is what
# we replicate here.
#
# If additional BOARD_* variables surface as missing later, add them
# to this block with the same MEK-cited pattern — do NOT copy mek_8q.mk
# into this dir (see IMX_DEVICE_PATH note above).
#
# Reference: device/nxp/imx8q/mek_8q/mek_8q.mk lines 319-346

ifneq ($(AVB_RBINDEX),)
BOARD_AVB_ROLLBACK_INDEX := $(AVB_RBINDEX)
else
BOARD_AVB_ROLLBACK_INDEX := 0
endif

ifneq ($(AVB_BOOT_RBINDEX),)
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(AVB_BOOT_RBINDEX)
else
BOARD_AVB_BOOT_ROLLBACK_INDEX := 0
endif

ifneq ($(AVB_INIT_BOOT_RBINDEX),)
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := $(AVB_INIT_BOOT_RBINDEX)
else
BOARD_AVB_INIT_BOOT_ROLLBACK_INDEX := 0
endif

ifneq ($(GBL_RBINDEX),)
BOARD_GBL_ROLLBACK_INDEX := $(GBL_RBINDEX)
else
BOARD_GBL_ROLLBACK_INDEX := 0
endif

# -------@block_restricted_codec_note-------
# MEK's mek_8q.mk line 562 declares a PRODUCT_COPY_FILES entry that
# copies vpu_fw_imx8_dec.bin.signed into the vendor image. The .signed
# file is produced by device/nxp/common/build/encrypt_and_sign_firmware.mk
# from an NXP-restricted RealVideo codec blob under
# vendor/nxp-private/fsl-restricted-codec/ (licensed separately, not
# in the standard imx-manifest). Additionally, imx-make.sh line 320
# only invokes that .mk when TARGET_PRODUCT = "mek_8q" — so for our
# target the .signed file is never generated even if the source blob
# existed.
#
# The integration does not manufacture an unsigned substitute. Obtain
# this input through an authorized NXP package or remove the dependency
# through a separately reviewed product adaptation before building.
#
# Reference: device/nxp/imx8q/mek_8q/mek_8q.mk line 562
#            device/nxp/common/build/encrypt_and_sign_firmware.mk line 14
#            android_build/imx-make.sh line 320
