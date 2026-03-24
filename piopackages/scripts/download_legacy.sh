#!/bin/bash
# Download historical PlatformIO package archives for the Ender-3 V2
# bit-perfect 2022 firmware reproduction.
#
# PRIMARY SOURCE: GitHub Release assets on this fork
#   https://github.com/rlneumiller/Ender-3V2/releases/tag/pio5-toolchain-archives-2022
#
# Why a GitHub Release?
#   The package archives are too large to store in the git tree (~151 MB total)
#   and the original PlatformIO CDN now blocks all PIO 5.x clients. Hosting them
#   as Release assets on this fork provides a durable, version-pinned mirror that
#   is independent of the PlatformIO registry and does not bloat the git history.
#   GitHub Release assets are preserved even during ownership transfers and are
#   included in GitHub's own archival programme (Software Heritage / Arctic Vault).
#
# FALLBACK SOURCES are attempted if the release asset download fails.
#
# Usage: run from the repository root
#   bash piopackages/scripts/download_legacy.sh

set -euo pipefail

PKG_DIR="./piopackages/archives"
GH_RELEASE_BASE="https://github.com/rlneumiller/Ender-3V2/releases/download/pio5-toolchain-archives-2022"

mkdir -p "$PKG_DIR"

download_with_fallback() {
    local dest="$1"
    local primary="$2"
    shift 2
    local fallbacks=("$@")

    if [ -f "$dest" ]; then
        echo "Already present: $(basename "$dest")"
        return 0
    fi

    echo "Downloading $(basename "$dest")..."
    if curl -fL "$primary" -o "$dest" 2>/dev/null; then
        echo "  -> from primary: $primary"
        return 0
    fi

    for url in "${fallbacks[@]}"; do
        echo "  primary failed, trying fallback: $url"
        if curl -fL "$url" -o "$dest" 2>/dev/null; then
            echo "  -> from fallback: $url"
            return 0
        fi
    done

    echo "ERROR: all sources failed for $(basename "$dest")" >&2
    return 1
}

# 1. Platform ststm32 v12.1.1
#    This archive contains engines.platformio="^5" — the live registry version
#    was changed to require PIO 6, making the local archive the only usable copy.
download_with_fallback \
    "$PKG_DIR/ststm32-12.1.1.tar.gz" \
    "$GH_RELEASE_BASE/ststm32-12.1.1.tar.gz" \
    "https://github.com/platformio/platform-ststm32/archive/refs/tags/v12.1.1.tar.gz"

# 2. Framework: Arduino_STM32 maple core (2020-11-29 snapshot)
#    PlatformIO package name: framework-arduinoststm32-maple 3.10000.201129
download_with_fallback \
    "$PKG_DIR/framework-arduinoststm32-maple-3.10000.201129.tar.gz" \
    "$GH_RELEASE_BASE/framework-arduinoststm32-maple-3.10000.201129.tar.gz"

# 3. GCC ARM Toolchain v1.70201.0 (GCC 7.2.1, linux_x86_64)
#    This is ARM's official "GNU Arm Embedded Toolchain 7-2017-q4-major",
#    repackaged by PlatformIO. The original from ARM is:
#      https://developer.arm.com/downloads/-/gnu-rm  (look for 7-2017-q4-major)
#    The PIO-repackaged tarball has a flat directory layout expected by the
#    Dockerfile; rebuilding from the ARM source requires re-creating that layout.
download_with_fallback \
    "$PKG_DIR/toolchain-gccarmnoneeabi-1.70201.0.tar.gz" \
    "$GH_RELEASE_BASE/toolchain-gccarmnoneeabi-1.70201.0.tar.gz"

# 4. Upload tool: tool-stm32duino v1.0.1 (linux_x86_64)
download_with_fallback \
    "$PKG_DIR/tool-stm32duino-1.0.1.tar.gz" \
    "$GH_RELEASE_BASE/tool-stm32duino-1.0.1.tar.gz"

echo ""
echo "All archives present in $PKG_DIR"
ls -lh "$PKG_DIR"/*.tar.gz
