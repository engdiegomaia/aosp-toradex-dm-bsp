# Porting guide

For each new module/carrier combination:

1. Identify the SoC and official SoC-vendor Android BSP release.
2. Identify the corresponding Toradex Linux BSP branch and module/carrier documentation.
3. Record both source revisions, licenses, kernel versions, bootloader versions, and device-tree baselines.
4. Compare kernel configuration, device trees, pinmux, regulators, storage, network, display, audio, buses, and power management. Check applicability against the Android vendor kernel before carrying over Linux BSP changes.
5. Classify each required adaptation as SoC, module, carrier, Android, kernel, bootloader, device-tree, or build-system work.
6. Add a Toradex Android device definition and product. Keep carrier-specific configuration separable where feasible.
7. Integrate only required kernel/device-tree and bootloader changes; record upstream source, reason, hardware dependency, and upstreaming potential.
8. Add Repo manifest entries pinned to tested revisions. Document proprietary artifacts and acquisition terms without redistributing restricted material.
9. Validate a clean checkout and build, then validate flashing and the hardware matrix.
10. Record known limitations and evidence. Do not mark untested peripherals supported.

The Apalis iMX8QM + Ixora POC is the first comparison case. Its source snapshot notes separate local patch files for `device/nxp`, the kernel, and U-Boot; wrapper/product files and overlays also contain local work. Audit and classify these before importing implementation files into this repository.
