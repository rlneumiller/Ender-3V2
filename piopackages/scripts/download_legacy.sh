#!/bin/bash
# Download historical PlatformIO artifacts for end-3v2 bit-perfect reproduction

PKG_DIR="./piopackages/archives"
mkdir -p "$PKG_DIR"

# 1. Platform ststm32 v12.1.1
if [ ! -f "$PKG_DIR/ststm32-12.1.1.tar.gz" ]; then
    echo "Downloading ststm32 v12.1.1..."
    curl -L "https://github.com/platformio/platform-ststm32/archive/refs/tags/v12.1.1.tar.gz" -o "$PKG_DIR/ststm32-12.1.1.tar.gz"
fi

# 2. Framework Arduino_Core_STM32 v2.2.0
if [ ! -f "$PKG_DIR/Arduino_Core_STM32-2.2.0.tar.gz" ]; then
    echo "Downloading Arduino_Core_STM32 v2.2.0..."
    curl -L "https://github.com/stm32duino/Arduino_Core_STM32/archive/refs/tags/2.2.0.tar.gz" -o "$PKG_DIR/Arduino_Core_STM32-2.2.0.tar.gz"
fi

# 3. GCC Toolchain - Version 1.70201.200117 (corresponds to ~1.70201.0 in PIO)
if [ ! -f "$PKG_DIR/toolchain-gccarmnoneeabi-1.70201.200117.tar.gz" ]; then
    echo "Downloading Historical GCC Toolchain (x86_64)..."
    curl -L "https://dl.bintray.com/platformio/dl-packages/toolchain-gccarmnoneeabi-linux_x86_64-1.70201.200117.tar.gz" -o "$PKG_DIR/toolchain-gccarmnoneeabi-1.70201.200117.tar.gz" || \
    echo "Note: Bintray link may have moved. Use modern DL: https://dl.platformio.org/packages/toolchain-gccarmnoneeabi-linux_x86_64-1.70201.200117.tar.gz"
    curl -L "https://dl.platformio.org/packages/toolchain-gccarmnoneeabi-linux_x86_64-1.70201.200117.tar.gz" -o "$PKG_DIR/toolchain-gccarmnoneeabi-1.70201.200117.tar.gz"
fi

echo "Done. Packages stored in $PKG_DIR"
