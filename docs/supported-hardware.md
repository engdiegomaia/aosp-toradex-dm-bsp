# Supported hardware

“Supported” requires a reproducible build and recorded validation on the stated module SKU and carrier revision. POC evidence is not automatically a release claim.

| SoC | Toradex module | Carrier | Android baseline | Build reproducible here | Status |
|---|---|---|---|---|---|
| NXP i.MX8QM | Apalis iMX8QM PN 0037, HW V1.1B | Ixora V1.2 | NXP `android-16.0.0_1.2.0` | No | Reference POC; integration in progress |

## Apalis + Ixora validation matrix

Initial entries reflect POC notes available on 2026-09-29. They are bench observations, not a formal release qualification. Status vocabulary: Supported, Partially Supported, Not Tested, Not Supported.

| Area | Status | Evidence/qualification |
|---|---|---|
| Boot | Partially Supported | Android starts from existing eMMC layout via development U-Boot/TFTP flow; clean provisioning is not validated. |
| eMMC | Partially Supported | Existing Android layout used; blank-media provisioning not established. |
| SD | Not Tested | |
| USB host | Partially Supported | USB touch device enumerated and worked after reconnect. |
| USB device / ADB | Not Tested | |
| Ethernet | Supported | DHCP, Internet, and DNS reported validated after reboot on the test unit. |
| Wi-Fi | Supported | 88W8997 PCIe B, wlan0 reconnect, regulatory country persistence, network validation reported. SKU-specific. |
| Bluetooth | Not Tested | POC reports pending; actual transport differs from inherited MEK assumption. |
| Display | Partially Supported | HDMI and LVDS bring-up documented; not a full qualification. |
| Touch | Partially Supported | USB SiS `0457:0819` touch validated with HDMI monitor. |
| Audio | Not Tested | |
| UART | Partially Supported | Console procedure and ttyLP1 documented; Android UART function not qualified. |
| I2C | Not Tested | |
| SPI | Not Tested | |
| GPIO | Not Tested | |
| CAN | Not Tested | |
| PCIe | Partially Supported | Wi-Fi card enumerated on PCIe B; general PCIe not qualified. |
| Camera | Not Tested | |
| GPU | Not Tested | |
| Video encode/decode | Not Tested | |
| Suspend/resume | Not Tested | |
| Reboot | Partially Supported | Wi-Fi/network behavior after reboot documented; full matrix not qualified. |
| Power-off | Not Tested | |
| Fastboot | Not Tested | |

Update entries with dated test records and exact hardware SKU before making broader claims.
