// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * Copyright 2018, 2021 NXP
 * Copyright 2026 Toradex AG
 *
 * SPL boilerplate for i.MX 8QuadMax dual-bootloader boot flow.
 * Verbatim copy of board/freescale/imx8qm_mek/spl.c — the sequence
 * is entirely SCU/misc-driver + preloader console, no MEK-specific
 * hardware assumptions documented in the Apalis iMX8QM bring-up notes.
 */

#include <dm.h>
#include <image.h>
#include <init.h>
#include <log.h>
#include <spl.h>
#include <asm/global_data.h>
#include <dm/uclass.h>
#include <dm/device.h>
#include <dm/uclass-internal.h>
#include <dm/device-internal.h>
#include <dm/lists.h>
#include <asm/arch/sys_proto.h>
#include <asm/sections.h>
#include <bootm.h>

DECLARE_GLOBAL_DATA_PTR;

void spl_board_init(void)
{
	struct udevice *dev;

	uclass_get_device_by_driver(UCLASS_MISC, DM_DRIVER_GET(imx8_scu), &dev);

	uclass_find_first_device(UCLASS_MISC, &dev);

	for (; dev; uclass_find_next_device(&dev)) {
		if (device_probe(dev))
			continue;
	}

	board_early_init_f();

	timer_init();

#ifdef CONFIG_SPL_SERIAL
	preloader_console_init();

	puts("Normal Boot\n");
#endif
}

/*
 * board_quiesce_devices lives on MEK in board/freescale/imx8qm_mek/
 * imx8qm_mek.c and powers off the debug UART's DMA power domain before
 * SPL hands off to U-Boot proper. Apalis debug UART is LPUART1 (see
 * apalis-imx8.c:86 SC_R_UART_1). Empty stub for now — the SCU keeps the
 * power domain active by default; not powering it off just leaves a
 * few mW on the table, which is fine for bring-up. Wire in
 * imx8_power_off_pd_devices("dma_lpuart1") once boot is stable.
 */
void __weak board_quiesce_devices(void)
{
}

void spl_board_prepare_for_boot(void)
{
	board_quiesce_devices();
}

#ifdef CONFIG_SPL_LOAD_FIT
int board_fit_config_name_match(const char *name)
{
	debug("%s: %s\n", __func__, name);

	return 0;
}
#endif

void board_init_f(ulong dummy)
{
	memset(__bss_start, 0, __bss_end - __bss_start);

	arch_cpu_init();

	board_init_r(NULL, 0);
}
