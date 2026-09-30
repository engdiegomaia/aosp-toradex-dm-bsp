# Supported hardware and validation

“Supported” requires a reproducible source sync/build and evidence on the stated module SKU and carrier revision. POC bench reports below describe the reference unit only; they are not release qualification.

| SoC | Module | Carrier | Android baseline | Clean build here | Status |
|---|---|---|---|---|---|
| NXP i.MX8QM | Apalis PN 0037, HW V1.1B, 88W8997 | Ixora V1.2 | NXP `android-16.0.0_1.2.0` | Not run | Reference POC; integration incomplete |

## Apalis + Ixora matrix

POC reports reflect the bench status through 2026-09-30. Full qualification requires fresh tests against an image built from this repository.

| Function | Status | Evidence and limits |
|---|---|---|
| Boot | Partially Supported | Existing, previously provisioned eMMC boots Android; clean checkout and fresh installation not validated. |
| eMMC | Partially Supported | Android runs from existing layout; generated NXP MEK partition tables are 13/28 GiB and must not be flashed to this 14.8 GiB unit. |
| SD | Not Tested | |
| USB host | Partially Supported | USB SiS touch device `0457:0819` enumerated and worked after reconnect. |
| USB device / ADB | Not Tested | |
| Ethernet | Supported | DHCP, Internet, and DNS reported validated after reboot on the reference unit. |
| Wi-Fi | Supported | 88W8997 enumerated on PCIe B; saved network reconnection, regulatory country `BR`, DHCP, Internet, and DNS reported validated. SKU-specific. |
| Bluetooth | Not Tested | POC reports pending; 88W8997 transport requires USB/HSIC handling. |
| HDMI display | Partially Supported | Existing Android image reaches GUI; a newly built kernel/DTB caused HDMI disappearance and was reverted. Fix awaits board validation. |
| LVDS display | Partially Supported | LVDS bring-up documented; no full qualification. |
| Touch | Partially Supported | HDMI monitor USB touch tested; LVDS touch not fully qualified. |
| Audio | Not Tested | |
| UART | Partially Supported | 115200 8N1 serial console and ttyLP1 documented; Android serial function not qualified. |
| I2C / SPI / GPIO | Not Tested | |
| CAN | Not Tested | |
| PCIe | Partially Supported | Wi-Fi card observed on PCIe B; general PCIe not qualified. |
| Camera | Not Tested | |
| GPU | Not Tested | |
| Video encode/decode | Not Tested | |
| Miracast / Wi-Fi Display | Partially Supported | Cast settings enabled P2P discovery; no sink was available, so discovery success or streaming is unconfirmed. |
| Suspend/resume | Not Tested | |
| Reboot | Partially Supported | Wi-Fi reconnection after reboot reported; full cycle matrix pending. |
| Power-off | Not Tested | |
| Fastboot | Not Tested | |

For every new result, record date, module PN/revision, carrier revision, source/image hashes, test steps, logs, and outcome. Do not promote an item to `Supported` without testing a cleanly built image on the identified combination.
