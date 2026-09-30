#!/bin/bash
# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# Per-product U-Boot build helper for Apalis iMX8QM on Ixora.
#
# uboot.mk sources this script twice per label iteration:
#   line 136 (before the label loop):  . AndroidUboot.sh; build_pre_image
#   line 147 (inside the label loop):  . AndroidUboot.sh; build_imx_uboot ...
# Each source rebuilds the shell function table, so our overrides win
# for every iteration. The recipe runs under whatever /bin/sh is on the
# host (dash on Ubuntu), so this script must be POSIX-compatible — no
# `[[`, no `declare -f`, no `local`.
#
# P0 strategy was a thin dot-source of MEK's AndroidUboot.sh. P1.2
# forced us to redefine build_imx_uboot() to add a post-mkimage stub
# for uboot.mk:153, which insists on copying u-boot-<label>.imx even
# when the dual-bootloader branch (AndroidUboot.sh:194-196) writes only
# spl-*.bin + bootloader-*.img. The redefinition is a verbatim copy of
# MEK's function body plus a trailing block_p1_dual_imx_stub section.
#
# When NXP updates AndroidUboot.sh in a future release, diff MEK's
# build_imx_uboot() against our copy below and forward-port any changes,
# keeping the stub block at the tail.
#
# References:
#   device/nxp/imx8q/mek_8q/AndroidUboot.sh (upstream, our source of truth)
#   device/nxp/common/build/uboot.mk line 136, 147, 153
#   docs/p1-bringup.md (P1.2 label rename + dual-bootloader publish path)

# shellcheck disable=SC1091
# Source MEK's AndroidUboot.sh first — it defines build_pre_image() and
# sets up ATF_CROSS_COMPILE, plus loads ImxPathConfig.mk paths. Its
# build_imx_uboot() will be overridden immediately below.
. device/nxp/imx8q/mek_8q/AndroidUboot.sh

# -------@block_p1_build_imx_uboot_override-------
# Overrides MEK's build_imx_uboot() (dot-sourced above) to add a
# post-mkimage stub that satisfies uboot.mk:153. See file header.
build_imx_uboot()
{
	if [ `echo $2 | cut -d '-' -f1` = "imx8qm" ] && [ `echo $2 | cut -d '-' -f2` != "xen" ]; then
		MKIMAGE_PLATFORM=iMX8QM
		SCFW_PLATFORM=8qm
		ATF_PLATFORM=imx8qm
		REV=B0
		# Apalis P1.2 override: use flash_spl instead of MEK's flash_linux_m4.
		# flash_spl (imx-mkimage/iMX8QM/soc.mak:123) produces a SCFW+SPL
		# container with no M4 firmware — matches Toradex's imx-boot-recoverytezi
		# layout verified 2026-07-23. flash_linux_m4 (soc.mak:141) bakes MEK's
		# imx8qm_m4_{0,1}_default.bin into the container at 0x34FE0000 and
		# 0x38FE0000; on Apalis those regions are behind XRDC partitions the
		# Apalis SCFW hasn't granted the A35 access to, halting SPL before
		# its first UART print. See memory apalis-flash-target-patch.md.
		FLASH_TARGET=flash_spl

		cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qm*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
		# M4 firmware copies removed — flash_spl doesn't reference them and
		# the source binaries (imx8qm_m4_{0,1}_default.bin) are MEK-only.
		cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmitxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmitxfw.bin
		cp ${FSL_PROPRIETARY_PATH}/linux-firmware-imx/firmware/hdmi/cadence/hdmirxfw.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmirxfw.bin

		if [ "${PRODUCT_IMX_CAR}" = "true" ] && [ `echo $2 | rev | cut -d '-' -f1` != "uuu" ]; then
			if [ "${PRODUCT_IMX_CAR_M4}" = "true" ] ; then
				if [ "${IMX8QM_A72_BOOT}" = "true" ] ; then
					FLASH_TARGET=flash_b0_spl_container_m4_1_trusty_a72
				else
					FLASH_TARGET=flash_b0_spl_container_m4_1_trusty
				fi
				if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_1_image.bin ]; then
					rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_1_image.bin
				fi
				cp  ${UBOOT_M4_OUT}/MIMX8QM/${UBOOT_M4_BUILD_TYPE}/m4_image.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_1_image.bin
			elif [ "${IMX8QM_A72_BOOT}" = "true" ] ; then
				FLASH_TARGET=flash_b0_spl_container_m4_0_1_trusty_a72
			fi
			if [ `echo $2 | cut -d '-' -f2` != "md" ]; then
				rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmitxfw.bin
				rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/hdmirxfw.bin
			fi
		fi
	elif [ "$2" = "imx8qm-xen-dom0" ]; then
		MKIMAGE_PLATFORM=iMX8QM
		SCFW_PLATFORM=8qm
		ATF_PLATFORM=imx8qm
		REV=B0
		cp  ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qm*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
		FLASH_TARGET=flash_spl
	elif [ "$2" = "imx8qm-xen" ]; then
		MKIMAGE_PLATFORM=iMX8QM
		FLASH_TARGET=flash_b0_xen_uboot
		REV=B0
	elif [ `echo $2 | cut -d '-' -f1` = "imx8qxp" ]; then
		MKIMAGE_PLATFORM=iMX8QX
		SCFW_PLATFORM=8qx
		ATF_PLATFORM=imx8qx
		FLASH_TARGET=flash_linux_m4
		if [ `echo $2 | cut -d '-' -f2` = "c0" ] || [ "`echo $2 | cut -d '-' -f3`" = "c0" ]; then
			REV=C0
		else
			REV=B0
		fi
		cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qx*ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
		cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/mcu-sdk/imx8q/imx8qx_m4_default.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
		if [ "${PRODUCT_IMX_CAR}" = "true" ] && [ `echo $2 | rev | cut -d '-' -f1` != "uuu" ]; then
			if [ "${PRODUCT_IMX_CAR_M4}" = "true" ] ; then
				FLASH_TARGET=`echo flash_all_spl_container_ddr_car`
				if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin ]; then
					rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
				fi
				cp  ${UBOOT_M4_OUT}/MIMX8QX/${UBOOT_M4_BUILD_TYPE}/rear_view_camera.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/m4_image.bin
			fi
		fi

	elif [ `echo $2 | cut -d '-' -f1` = "imx8dx" ]; then
		MKIMAGE_PLATFORM=iMX8QX
		SCFW_PLATFORM=8dx
		ATF_PLATFORM=imx8qx
		REV=C0
		if [ `echo $2 | rev | cut -d '-' -f1` = "uuu" ]; then
			FLASH_TARGET=flash
		else
			FLASH_TARGET=flash_spl
		fi
		cp ${FSL_PROPRIETARY_PATH}/imx-seco/firmware/seco/mx8qxc0-ahab-container.img ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/
	fi
	if [ "${PRODUCT_IMX_CAR_M4}" = "true" ]; then
		cp  ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8q_car/mx$SCFW_PLATFORM-scfw-tcm.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/scfw_tcm.bin
	else
		cp  ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8q/mx$SCFW_PLATFORM-scfw-tcm.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/scfw_tcm.bin
	fi
	if [ "${PRODUCT_IMX_CAR}" = "true" -a  `echo $2 | rev | cut -d '-' -f1` != "uuu" -o `echo $2 | cut -d '-' -f2` = "trusty" ]; then
		if [ `echo $2 | cut -d '-' -f1` = "imx8qm" ] && [ "$2" != "imx8qm-xen-dom0" ] && [ "${IMX8QM_A72_BOOT}" = "true" ]; then
			cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8q_car/tee-imx$SCFW_PLATFORM-a72.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin
		else
			cp ${FSL_PROPRIETARY_PATH}/fsl-proprietary/uboot-firmware/imx8q_car/tee-imx$SCFW_PLATFORM.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin
		fi
	else
		if [ -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin ]; then
			rm -f ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/tee.bin
		fi
	fi
	if [ "$2" != "imx8qm-xen" ]; then
		make -C ${IMX_PATH}/arm-trusted-firmware/ PLAT=$ATF_PLATFORM clean
		if [ "${PRODUCT_IMX_CAR}" = "true" -a `echo $2 | rev | cut -d '-' -f1` != "uuu" -o `echo $2 | cut -d '-' -f2` = "trusty" ]; then
			make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 SPD=trusty -B IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
		else
			make -C ${IMX_PATH}/arm-trusted-firmware/ CROSS_COMPILE="${ATF_CROSS_COMPILE}" PLAT=$ATF_PLATFORM bl31 -B IMX_ANDROID_BUILD=true 1>/dev/null || exit 1
		fi
		cp ${IMX_PATH}/arm-trusted-firmware/build/$ATF_PLATFORM/release/bl31.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/bl31.bin
		cp  ${UBOOT_OUT}/u-boot.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot.bin
		cp  ${UBOOT_OUT}/spl/u-boot-spl.bin ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-spl.bin
		cp  ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/mkimage_uboot

		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
		pwd_backup=${PWD}
		PWD=${PWD}/${IMX_MKIMAGE_PATH}/imx-mkimage/
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=$MKIMAGE_PLATFORM REV=$REV $FLASH_TARGET || exit 1
		PWD=${pwd_backup}
		if [ "${PRODUCT_IMX_DUAL_BOOTLOADER}" = "true" ] && [ `echo $2 | rev | cut -d '-' -f1` != "uuu" ] || [ `echo $2 | rev | cut -d '-' -f1 | rev` = "dual" ]; then
			cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/boot-spl-container.img ${UBOOT_COLLECTION}/spl-$2.bin
			cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-atf-container.img ${UBOOT_COLLECTION}/bootloader-$2.img
		else
			cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/flash.bin ${UBOOT_COLLECTION}/u-boot-$2.imx
		fi
	else
		cp ${UBOOT_OUT}/u-boot.$1 ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot.bin
		cp ${UBOOT_OUT}/spl/u-boot-spl.bin ${UBOOT_COLLECTION}/spl-$2.bin
		cp ${UBOOT_OUT}/tools/mkimage  ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/mkimage_uboot

		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ clean
		pwd_backup=${PWD}
		PWD=${PWD}/${IMX_MKIMAGE_PATH}/imx-mkimage/
		make -C ${IMX_MKIMAGE_PATH}/imx-mkimage/ SOC=$MKIMAGE_PLATFORM REV=$REV $FLASH_TARGET || exit 1
		PWD=${pwd_backup}
		cp ${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/u-boot-xen-container.img ${UBOOT_COLLECTION}/bootloader-$2.img
	fi

	# -------@block_p1_dual_imx_stub-------
	# uboot.mk:153 unconditionally copies UBOOT_COLLECTION/u-boot-$2.imx
	# into UBOOT_BIN, even when we took the dual-bootloader publish path
	# above (which only produces spl-$2.bin + bootloader-$2.img).
	#
	# For any label that ended in the dual branch (last-token = "dual"),
	# stage a u-boot-$2.imx from flash.bin (the raw byte-concatenation
	# mkimage already produced on line 192 of the copy above). This is
	# not the bootable artifact for our target — uuu flashes spl-*.bin
	# and bootloader-*.img directly per UG10156 §3.4 — but it satisfies
	# the make recipe's copy step so the `bootloader` target exits
	# cleanly.
	#
	# BOARD_OTA_BOOTLOADERIMAGE already points at bootloader-*.img (see
	# SharedBoardConfig.mk block_p1_bootloader_ota) so uboot.mk:160's
	# OTA copy uses the real artifact, not this stub.
	if [ "`echo $2 | rev | cut -d '-' -f1 | rev`" = "dual" ]; then
		imx_stub="${UBOOT_COLLECTION}/u-boot-$2.imx"
		flash_bin="${IMX_MKIMAGE_PATH}/imx-mkimage/$MKIMAGE_PLATFORM/flash.bin"
		if [ ! -f "$imx_stub" ] && [ -f "$flash_bin" ]; then
			cp "$flash_bin" "$imx_stub"
			echo "toradex: staged u-boot-$2.imx from flash.bin (uboot.mk:153 stub)"
		fi
	fi
}

# -------@block_p0_overrides-------
# (empty for P0 — Apalis-specific build_pre_image goes here in P1)
