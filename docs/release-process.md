# Release process

There is no release yet. Do not tag the current tree as a supported BSP: it has not passed a clean Repo sync/build, does not contain a verified Apalis-sized partition layout or installation path, and requires authorized vendor inputs.

Branches identify Android baselines (`android16-toradex`). Add hardware through device folders and platform manifests on the matching baseline branch. Development manifests may follow the baseline branch; release manifests must pin the integration project and every vendor/AOSP project to immutable commits or tags.

Before the first release:

1. Complete the POC patch, license, and proprietary-input audit.
2. Resolve the restricted VPU codec dependency and obtain authorized firmware access; never use an unsigned stand-in.
3. Generate and review an Apalis-sized partition layout; validate it against the exact eMMC before offering any install workflow.
4. Build twice from clean checkouts and record host, toolchain, security patch level, manifest hash, source revisions, output hashes, and build logs.
5. Install through a reviewed deployment method and validate boot plus the hardware matrix on Apalis PN 0037 + Ixora V1.2.
6. Publish source/license notices, known limitations, and rollback/recovery instructions.

Use tags such as `android16-toradex-1.0`. Release notes must list the Android version/security patch level, NXP BSP, kernel and bootloader revisions, supported module SKUs/carriers, licensed external inputs, build procedure, deployment method, validation results, and known issues. Do not call the project an official Toradex Android BSP.
