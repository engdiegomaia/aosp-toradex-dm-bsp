# Toradex Community AOSP BSP

A community-maintained integration of SoC-vendor Android BSPs with Toradex module and carrier support. This is not an official Toradex Android BSP and is not maintained or officially supported by Toradex.

The first reference target is **Apalis iMX8QM + Ixora**, using NXP Android `android-16.0.0_1.2.0`. This branch is `android16-toradex-apalis-imx8`. Additional platforms should use separate `device/toradex/<module>/` folders and platform manifests; create platform-specific branches only when their source baselines require independent maintenance.

## Status

The Apalis product definition and pinned vendor manifest are present. The POC has booted Android from previously provisioned eMMC, but this repository has not yet passed a clean Repo sync, full build, or fresh image installation. The partition table, restricted codec input, authorized firmware acquisition, and deployment flow remain unresolved.

## Documentation

- [Architecture and Repo checkout layout](docs/architecture.md)
- [Build and current blockers](docs/build.md)
- [Porting guide](docs/porting-guide.md)
- [Supported hardware and validation matrix](docs/supported-hardware.md)
- [Vendor baselines, changes, and licensing](docs/vendor-baselines.md)
- [Release process](docs/release-process.md)
- [Troubleshooting](docs/troubleshooting.md)

The manifest references upstream AOSP/NXP repositories and does not redistribute their source or restricted firmware. Retain and follow the licenses and trademarks of each upstream project.
