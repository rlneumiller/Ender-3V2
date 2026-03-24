# Ender3V2 stm32 based 4.2.2 mainboard 2022 Firmware Reproduction

This section documents how to reproduce a byte-for-byte identical firmware binary from the January 2022 state of this repository using a hermetic, fully offline container build. No live PlatformIO registry access is required.

## Background

The PlatformIO registry (`registry.platformio.org`) now blocks all PIO 5.x clients with an HTTP error requiring an upgrade to PIO 6. The ststm32 platform package on the live registry was also updated to require PIO 6. To reproduce the exact 2022 toolchain:

- **PlatformIO Core**: 5.2.4 (latest release before Jan 18, 2022)
- **Platform**: `ststm32` 12.1.1 (local archive, `engines.platformio: "^5"`)
- **Toolchain**: `toolchain-gccarmnoneeabi` 1.70201.0 → GCC ARM 7.2.1
- **Framework**: `framework-arduinoststm32-maple` 3.10000.201129
- **Upload tool**: `tool-stm32duino` 1.0.1
- **Build system**: `tool-scons` 4.3.0 (via `pip`, synthetic shim package)

The required package archives are stored in `piopackages/archives/`. The container image bakes all packages in at build time so no network access is needed at run time.

## Prerequisites

- [Podman](https://podman.io/) (or Docker — substitute `docker` for `podman`)
- The package archives under `piopackages/archives/` (see below)

## Package Archives

The toolchain archives are too large to store in the git tree (~151 MB total) and the original PlatformIO CDN now blocks all PIO 5.x clients. To solve both problems, the archives are hosted as assets on a dedicated GitHub Release on this fork:

**https://github.com/rlneumiller/Ender-3V2/releases/tag/pio5-toolchain-archives-2022**

| Asset | Size | Description |
|---|---|---|
| `ststm32-12.1.1.tar.gz` | 5.6 MB | ststm32 platform (engines: PIO ^5) |
| `framework-arduinoststm32-maple-3.10000.201129.tar.gz` | 35 MB | Arduino_STM32 maple core |
| `toolchain-gccarmnoneeabi-1.70201.0.tar.gz` | 109 MB | GCC ARM 7.2.1 |
| `tool-stm32duino-1.0.1.tar.gz` | 929 KB | STM32duino upload tool |

To download all archives to the correct location, run from the repository root:

```bash
bash piopackages/scripts/download_legacy.sh
```

The script tries the GitHub Release URL first, then falls back to the original upstream sources where they exist. It is safe to run repeatedly — already-present files are skipped.

**Why a GitHub Release and not git-lfs or the git tree?**  
GitHub Release assets are stored outside the git object graph. They survive repository ownership transfers and are included in GitHub's archival partnerships (Software Heritage / Arctic Vault). They also have no per-file size limit (up to 2 GB) and do not consume LFS bandwidth quota. The download script documents the original source of each archive so the files can be reconstructed from upstream if the release is ever lost.

## Build the Container Image

```bash
podman build -f docker/Dockerfile.pio5 -t localhost/pio5-bitperfect .
```

This produces a tagged image `localhost/pio5-bitperfect` with PIO 5.2.4 and all toolchain packages pre-seeded. The image is fully self-contained and requires no internet access at run time.

## Compile the Firmware

```bash
podman run --rm -v "$PWD":/workspace:Z localhost/pio5-bitperfect
```

The `:Z` suffix on the volume mount is required on SELinux-enabled systems (Fedora, RHEL, etc.). On non-SELinux systems use `-v "$PWD":/workspace` without `:Z`.

On success you will see:

```
PLATFORM: ST STM32 (12.1.1) > STM32F103RE (64k RAM. 512k Flash)
PACKAGES:
 - framework-arduinoststm32-maple 3.10000.201129 (1.0.0)
 - tool-stm32duino 1.0.1
 - toolchain-gccarmnoneeabi 1.70201.0 (7.2.1)
...
========================= [SUCCESS] ...
```

The firmware binary is written to:

```
.pio/build/STM32F103RET6_creality/firmware.bin
```

## Notes and Known Pitfalls

**Stale `.piopm` files from older PIO 5.x builds**  
If `.pio/libdeps/` contains `.piopm` files written by an older PIO 5.x release (before the `uri` → `url` field rename), the build will fail with:
```
TypeError: PackageSpec.__init__() got an unexpected keyword argument 'uri'
```
Fix: replace `"uri"` with `"url"` in any affected `.piopm` file under `.pio/libdeps/`, or delete the file. PIO will regenerate it from the library's own manifest.

**Platform `.piopm` owner field**  
PIO 5.2.4's `test_pkg_spec()` rejects pre-seeded packages whose `.piopm` has `owner: null` when the requesting spec includes `owner: "platformio"`. The Dockerfile writes explicit `.piopm` files with `"owner":"platformio"` for all four pre-seeded packages to work around this.

**Registry is fully bypassed**  
The environment variables `PLATFORMIO_SETTING_ENABLE_TELEMETRY=false`, `PLATFORMIO_SETTING_CHECK_PLATFORMIO_INTERVAL=0`, and `PLATFORMIO_SETTING_CHECK_PLATFORMS_INTERVAL=0` disable all outbound registry calls during the build. The "Failed to check for PlatformIO upgrades" warning at the end is expected and harmless.

---

# Ender-3 V2 Firmware

Creality attaches great importance to users. As 3D printing industry evangelist, Creality, dedicating to bringing benefits to human beings via technology innovations, has received support from both users and 3D printing enthusiasts. With gratefulness, Creality wants to continue the pace of making the world a better place with you all. This time, Creality will open the source code and we believe GitHub is the way to go. 

This is the repository that contains the source code and the development versions of the firmware running on the Creality [Ender-3 V2](https://www.creality.com/goods-detail/ender-3-v2-3d-printer), [Ender-3 S1](https://www.creality.com/goods-detail/creality-ender-3-s1-3d-printer), [CR-30/3DPrintMill](https://www.creality.com/goods-detail/creality-3dprintmill-3d-printer), [Ender-2 Pro](https://www.creality.com/goods-detail/creality-ender-2-pro-3d-printer), [Sermoon D1](https://www.creality.com/goods-detail/creality-sermoon-d1-3d-printer) and more products in the future. It's based on the well-known Marlin but with modifications.

The firmware for the Creality Ender-3 V2is proudly based on Marlin2.0 byScott Lahteine (@thinkyhead), Roxanne Neufeld (@Roxy-3D), Chris Pepper (@p3p), Bob Kuhn (@Bob-the-Kuhn), João Brazio (@jbrazio), Erik van der Zalm (@ErikZalm) and is distributed under the terms of the GNU GPL 3 license.

If you want to download the latest firmware version, go to Releases page and download the needed files. In the releases page you will find the source code and the SD Files needed for the LCD Display. After that, normally you need to update the SD files of the display and gradually complete the updates of menus, graphics and functionalities. 

Please refer to: [YouTube](https://www.youtube.com/watch?v=Jswzrh2_ekk)
In order to get instructions on how to upgrade the firmware and load new LCD SD files to the display.

# Table of contents
Windows build 
Documentation
Please refer to: [Marlin Page](https://marlinfw.org/docs/basics/introduction.html)

# New Features
1. Fix the problem of losing long file names in resume printing.
2. Fix the problem of time reset with automatic return to zero.
3. Fix some UI display defects.
4. Add auto zero return function and UI display after power up.
5. Add auto screen resting function.
6. Add card pulling detection function.

# Issues and Suggestions
Your feedback is very important to us, as it helps us improve even faster. Feel free to feedback us if there is an issue.
In order to get responses in an efficient way, we recommend you to follow some guidelines:
1. First of all, search for related issues.
2. Detail the firmware version you're running.
3. Explain to us the error or bug, so that we can test it properly.
4. In the title, indicate the label of the issue. (For example: #issue)

# Development Process
The code is currently in development, trying to improve functionalities.
Since it’s possible for the advanced users to contribute in firmware development, we suppose you know the points even if they have not been clearly illustrated by Creality.

The master branch is stable and it's currently of the version 2.0.x. The master branch stores code created by Creality. Once a release is done, the users, get to upgrade the version and give feedback to us. We get to know the bugs as well as optimization based on the feedback from you and Creality will make a decision on what to be included into the master branch. 

By integrating suggested improvements, we will make a branch from the version.

This is a classic code development process and we want more, so we really want you to participate from the very beginning.
