/* SPDX-License-Identifier: GPL-2.0+ */
/*
 * Copyright 2021 NXP
 * Copyright 2026 Toradex AG
 *
 * Apalis iMX8QM Android-specific board header. Mirrors
 * include/configs/imx8qm_mek_android.h but with Apalis env defaults
 * and no HDMI firmware load (deferred until UART serial boots).
 *
 * Included from apalis-imx8.h when CONFIG_ANDROID_SUPPORT is set.
 */

#ifndef __APALIS_IMX8_ANDROID_H
#define __APALIS_IMX8_ANDROID_H

#define CONFIG_USB_GADGET_VBUS_DRAW	2

#define FSL_FASTBOOT_FB_DEV "mmc"

/*
 * SPL page-table entry RAM base — MEK uses 0x801F8000, safely below
 * their DRAM_1 top (0x80000000 + 2 GB). Apalis DRAM_1 is also 2 GB
 * starting at 0x80000000; same PTE address is valid.
 */
#define CFG_SYS_SPL_PTE_RAM_BASE 0x801F8000

/*
 * Override the standard Apalis env — Android needs different splash
 * addresses, high memory limits, and Apalis-specific eMMC device
 * paths. Apalis eMMC is at bus@5b000000/5b010000.mmc (USDHC1). The
 * SD card slot on Ixora is at 5b020000.mmc (USDHC2), if present.
 */
#undef CFG_EXTRA_ENV_SETTINGS
#undef CONFIG_BOOTCOMMAND

#define CFG_EXTRA_ENV_SETTINGS		\
	"splashpos=m,m\0"			\
	"splashimage=0x9e000000\0"		\
	"fdt_high=0xffffffffffffffff\0"		\
	"initrd_high=0xffffffffffffffff\0"	\
	"emmc_dev=0\0"				\
	"sd_dev=1\0"				\
	"boot_devices_mmcblk0=bus@5b000000/5b010000.mmc\0" \
	"boot_devices_mmcblk1=bus@5b000000/5b020000.mmc\0"

#ifdef CONFIG_IMX_TRUSTY_OS
#define NS_ARCH_ARM64 1
#define KEYSLOT_HWPARTITION_ID   2
#define KEYSLOT_BLKS             0x3FFF
#define AVB_RPMB

#define BOOTLOADER_RBIDX_OFFSET  0x3FE000
#define BOOTLOADER_RBIDX_START   0x3FF000
#define BOOTLOADER_RBIDX_LEN     0x08
#define BOOTLOADER_RBIDX_INITVAL 0
#endif

#endif /* __APALIS_IMX8_ANDROID_H */
