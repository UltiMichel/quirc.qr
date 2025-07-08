#!/bin/bash
set -e

# Quirc build script
# This script builds the Debian package for the specified architecture

echo "Starting build..."

# Get architecture from command line argument or environment variable
ARCH=${1:-${ARCH:-arm64}}

echo "Building quirc for architecture: ${ARCH}"

# Validate architecture
if [[ ! "${ARCH}" =~ ^(arm64|armhf)$ ]]; then
    echo "Unsupported architecture: ${ARCH}"
    echo "Supported architectures: arm64, armhf"
    exit 1
fi

echo "Building for supported architecture: ${ARCH}"

# Create a writable workspace in /tmp
BUILD_DIR="/tmp/quirc-build"
echo "Creating writable build directory: ${BUILD_DIR}"
rm -rf ${BUILD_DIR}
cp -r /src ${BUILD_DIR}
cd ${BUILD_DIR}

# Set cross-compilation environment variables
case ${ARCH} in
    arm64)
        CROSS_TRIPLE="aarch64-linux-gnu"
        ;;
    armhf)
        CROSS_TRIPLE="arm-linux-gnueabihf"
        ;;
esac

export CC=${CROSS_TRIPLE}-gcc
export CXX=${CROSS_TRIPLE}-g++
export AR=${CROSS_TRIPLE}-ar
export STRIP=${CROSS_TRIPLE}-strip
export PKG_CONFIG_PATH=/usr/lib/${CROSS_TRIPLE}/pkgconfig

echo "Using cross-compiler: ${CC}"

# Build the package
echo "Building Debian package for ${ARCH}..."
dpkg-buildpackage -a${ARCH} -Pcross -uc -us -b

# Copy built packages to output directory
echo "Copying build artifacts to /output..."
mkdir -p /output
cp ../*.deb /output/ 2>/dev/null || true

echo "Build completed successfully!"
echo "Available packages in /output/:"
ls -la /output/