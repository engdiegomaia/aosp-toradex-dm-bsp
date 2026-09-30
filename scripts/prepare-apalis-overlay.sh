#!/usr/bin/env bash
# Copyright (C) 2026 Toradex AG
# SPDX-License-Identifier: Apache-2.0
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
    echo "Usage: $0 AOSP_ROOT" >&2
    echo "Set TORADEX_APALIS_FIRMWARE_DIR to an authorized directory containing the two hashed Apalis firmware files." >&2
}

if [[ $# -ne 1 ]]; then
    usage
    exit 2
fi

DRY_RUN="${TORADEX_OVERLAY_DRY_RUN:-0}"
AOSP_ROOT="$(cd "$1" && pwd)"
FIRMWARE_DIR="${TORADEX_APALIS_FIRMWARE_DIR:-}"
DEVICE_SRC="${REPO_ROOT}/device/toradex/apalis_imx8qm"
DEVICE_DST="${AOSP_ROOT}/device/nxp/imx8q/apalis_imx8qm"
KERNEL_ROOT="${AOSP_ROOT}/vendor/nxp-opensource/kernel_imx"
UBOOT_ROOT="${AOSP_ROOT}/vendor/nxp-opensource/uboot-imx"

for required in \
    "${AOSP_ROOT}/build/envsetup.sh" \
    "${AOSP_ROOT}/device/nxp/imx8q/AndroidProducts.mk" \
    "${KERNEL_ROOT}/arch/arm64/boot/dts/freescale/Makefile" \
    "${UBOOT_ROOT}/board/toradex/apalis-imx8/Makefile" \
    "${AOSP_ROOT}/device/nxp/common/tools/fastboot_imx_flashall.sh"; do
    if [[ ! -f "${required}" ]]; then
        echo "ERROR: incomplete or unsupported NXP checkout; missing ${required}" >&2
        exit 1
    fi
done

if [[ -z "${FIRMWARE_DIR}" || ! -d "${FIRMWARE_DIR}" ]]; then
    echo "ERROR: set TORADEX_APALIS_FIRMWARE_DIR to authorized Apalis firmware inputs." >&2
    usage
    exit 1
fi

for name in mx8qm-scfw-tcm.bin mx8qmb0-ahab-container.img; do
    if [[ ! -f "${FIRMWARE_DIR}/${name}" ]]; then
        echo "ERROR: missing ${FIRMWARE_DIR}/${name}" >&2
        exit 1
    fi
done

(cd "${FIRMWARE_DIR}" && sha256sum --check "${REPO_ROOT}/firmware/apalis/SHA256SUMS")

python3 - "${KERNEL_ROOT}/arch/arm64/boot/dts/freescale/Makefile" \
    "${AOSP_ROOT}/device/nxp/common/tools/fastboot_imx_flashall.sh" <<'PY'
from pathlib import Path
import sys

kernel_makefile = Path(sys.argv[1]).read_text()
flash_script = Path(sys.argv[2]).read_text()
dtb = "imx8qm-apalis-v1.1-ixora-v1.2.dtb"
if f"dtb-$(CONFIG_ARCH_MXC) += {dtb}" not in kernel_makefile:
    disabled = f"#dtb-$(CONFIG_ARCH_MXC) += {dtb}"
    if kernel_makefile.count(disabled) != 1:
        raise SystemExit(f"Expected exactly one disabled {dtb} entry")
prefix = "imx8qm_uboot_feature=("
if sum(line.startswith(prefix) for line in flash_script.splitlines()) != 1:
    raise SystemExit(f"Expected one {prefix} entry")
PY

if git -C "${KERNEL_ROOT}" apply --reverse --check \
    "${REPO_ROOT}/overlays/kernel/patches/0001-hdmi-load-firmware-before-start.patch" 2>/dev/null; then
    PATCH_STATE="already applied"
else
    git -C "${KERNEL_ROOT}" apply --check \
        "${REPO_ROOT}/overlays/kernel/patches/0001-hdmi-load-firmware-before-start.patch"
    PATCH_STATE="will apply"
fi

if [[ "${DRY_RUN}" == "1" ]]; then
    echo "DRY RUN: would materialize Apalis product and kernel/U-Boot overlays; HDMI patch ${PATCH_STATE}; copy verified external firmware."
    exit 0
fi

mkdir -p "${DEVICE_DST}"
rsync -a --delete "${DEVICE_SRC}/" "${DEVICE_DST}/"
rsync -a "${REPO_ROOT}/overlays/uboot/" "${UBOOT_ROOT}/"
rsync -a "${REPO_ROOT}/overlays/kernel/arch/arm64/boot/dts/freescale/" \
    "${KERNEL_ROOT}/arch/arm64/boot/dts/freescale/"
rsync -a "${REPO_ROOT}/overlays/kernel/arch/arm64/configs/" \
    "${KERNEL_ROOT}/arch/arm64/configs/"

python3 - "${KERNEL_ROOT}/arch/arm64/boot/dts/freescale/Makefile" \
    "${AOSP_ROOT}/device/nxp/common/tools/fastboot_imx_flashall.sh" <<'PY'
from pathlib import Path
import sys

kernel_makefile = Path(sys.argv[1])
flash_script = Path(sys.argv[2])
dtb = "imx8qm-apalis-v1.1-ixora-v1.2.dtb"
disabled = f"#dtb-$(CONFIG_ARCH_MXC) += {dtb}"
enabled = f"dtb-$(CONFIG_ARCH_MXC) += {dtb}"

text = kernel_makefile.read_text()
if enabled not in text:
    if text.count(disabled) != 1:
        raise SystemExit(f"Expected exactly one disabled {dtb} entry in {kernel_makefile}")
    kernel_makefile.write_text(text.replace(disabled, enabled, 1))

text = flash_script.read_text()
lines = text.splitlines(keepends=True)
prefix = "imx8qm_uboot_feature=("
matches = [i for i, line in enumerate(lines) if line.startswith(prefix)]
if len(matches) != 1:
    raise SystemExit(f"Expected one {prefix} entry in {flash_script}")
line = lines[matches[0]]
for feature in ("apalis-dual", "trusty-apalis-dual"):
    if feature not in line:
        line = line.replace(prefix, prefix + feature + " ", 1)
lines[matches[0]] = line
flash_script.write_text("".join(lines))
PY

if [[ "${PATCH_STATE}" == "already applied" ]]; then
    echo "HDMI kernel patch already applied"
else
    git -C "${KERNEL_ROOT}" apply \
        "${REPO_ROOT}/overlays/kernel/patches/0001-hdmi-load-firmware-before-start.patch"
fi

mkdir -p "${AOSP_ROOT}/vendor/nxp/fsl-proprietary/uboot-firmware/imx8q" \
    "${AOSP_ROOT}/vendor/nxp/imx-seco/firmware/seco"
install -m 0644 "${FIRMWARE_DIR}/mx8qm-scfw-tcm.bin" \
    "${AOSP_ROOT}/vendor/nxp/fsl-proprietary/uboot-firmware/imx8q/mx8qm-scfw-tcm.bin"
install -m 0644 "${FIRMWARE_DIR}/mx8qmb0-ahab-container.img" \
    "${AOSP_ROOT}/vendor/nxp/imx-seco/firmware/seco/mx8qmb0-ahab-container.img"

echo "Apalis product and open-source overlays prepared. This does not validate generated partition tables or authorize flashing."
