# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# Keep NXP's Android image-generation rules. The inherited NXP MEK tables
# are 13/28 GiB and are NOT safe to flash to the reference Apalis eMMC.
# A board-sized, license-reviewed layout is required before deployment.
include device/nxp/imx8q/mek_8q/partition_table.mk
