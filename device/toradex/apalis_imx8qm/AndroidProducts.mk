# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
#
# This file exposes the apalis_imx8qm product target to the AOSP build
# system. Structure mirrors device/nxp/imx8q/AndroidProducts.mk.

PRODUCT_MAKEFILES := \
  $(LOCAL_DIR)/apalis_imx8qm.mk

COMMON_LUNCH_CHOICES := \
  apalis_imx8qm-nxp_stable-userdebug
