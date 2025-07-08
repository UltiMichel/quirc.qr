FROM debian:bookworm

# Build argument for target architecture
ARG TARGET_ARCH=arm64

# Set cross-compilation variables based on architecture
RUN case "${TARGET_ARCH}" in \
        arm64) \
            echo "CROSS_TRIPLE=aarch64-linux-gnu" > /etc/cross-compile-env; \
            ;; \
        armhf) \
            echo "CROSS_TRIPLE=arm-linux-gnueabihf" > /etc/cross-compile-env; \
            ;; \
        *) \
            echo "Unsupported architecture: ${TARGET_ARCH}" >&2; exit 1; \
            ;; \
    esac

# Add target architecture
RUN dpkg --add-architecture ${TARGET_ARCH}

# Install base development tools and cross-compilation dependencies
RUN . /etc/cross-compile-env && \
    apt-get update && apt-get install -y \
    build-essential \
    debhelper \
    devscripts \
    fakeroot \
    pkg-config \
    libjpeg-dev \
    libpng-dev \
    gcc-${CROSS_TRIPLE} \
    g++-${CROSS_TRIPLE} \
    crossbuild-essential-${TARGET_ARCH} \
    libjpeg-dev:${TARGET_ARCH} \
    libpng-dev:${TARGET_ARCH} \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src

# Copy the source code
COPY . /src/

# Make build script executable
RUN chmod +x /src/build.sh

# Default command
CMD ["./build.sh", "arm64"]
