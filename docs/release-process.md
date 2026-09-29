# Release process

Do not create a release tag until the manifest and all required adaptation repositories are pinned and a clean checkout/build has been verified. Keep development branches named for the Android baseline, for example `android16-toradex`; put exact SoC-vendor revisions in manifests and release notes.

Each release should include:

- Android version and security patch level;
- SoC-vendor BSP release and manifest revision;
- kernel and bootloader versions;
- supported module SKUs and carrier revisions;
- required proprietary packages and acquisition/license notes;
- build host and exact build commands;
- image outputs and deployment procedure;
- validation matrix and known limitations.

Tag examples: `android16-toradex-1.0`. Release manifests must pin every repository to a commit or immutable tag; do not use floating branches. Preserve upstream notices and licenses. Do not include restricted vendor blobs unless redistribution is explicitly permitted.
