# Troubleshooting

## `repo sync` succeeds but the product is missing

The POC snapshot manifest does not by itself import the local Toradex wrapper/product files. Confirm that the selected integration revision includes the device definitions and any vendor-prescribed setup steps.

## Build requires unavailable files

NXP Android releases may require proprietary packages or release archives not present in public Git repositories. Obtain them from the vendor under the applicable terms and follow the matching release documentation. Do not substitute files from another BSP version without checking compatibility.

## Board does not boot

The POC development flow depended on a specific Apalis SKU, Ixora revision, existing Android eMMC partition layout, U-Boot configuration, and matching kernel/DT/ramdisk payloads. Capture the serial log and verify image provenance and hashes. Do not treat historical TFTP scripts as a blank-eMMC provisioning procedure.

## Peripheral behavior differs

Check exact module SKU and carrier revision first. Compare the Android kernel/device tree with the matching Toradex BSP, then record the test and evidence in the hardware matrix. Do not copy a Linux BSP change into Android without validating it against the Android vendor baseline.
