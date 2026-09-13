# Containerfile — Linux kernel build environment for arm64 (+ x86_64 cross)
#
# Usage:
#   podman build -t kernel-build .
#   ./scripts/kbuild-container shell          # interactive
#   ./scripts/kbuild-container make defconfig  # one-shot build command

FROM fedora:42

RUN dnf -y update && dnf -y install \
    # Core build tools
    make gcc binutils flex bison \
    bc perl python3 \
    # Headers & libs
    elfutils-libelf-devel openssl-devel \
    # Kconfig UI (menuconfig / nconfig)
    ncurses-devel \
    # Device-tree compiler
    dtc \
    # Module signing, BTF, debug
    elfutils dwarves \
    # Compressed kernel images
    xz lz4 zstd gzip bzip2 \
    # Docs & misc
    diffutils findutils hostname tar cpio kmod rsync \
    # x86_64 cross-compilation toolchain
    gcc-x86_64-linux-gnu binutils-x86_64-linux-gnu \
    # pahole for BTF generation
    pahole \
    # git for in-tree scripts
    git \
    && dnf clean all

ENV CROSS_COMPILE_X86=x86_64-linux-gnu-

VOLUME /src
WORKDIR /src
