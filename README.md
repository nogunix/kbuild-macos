# kbuild-macos

Linux kernel build environment for macOS (Apple Silicon).

Builds arm64 kernels natively and x86\_64 kernels via cross-compilation,
all inside a Podman/Docker container — no Linux VM setup required.

## Prerequisites

- macOS with Apple Silicon (M1/M2/M3/M4)
- [Podman](https://podman.io/) or [Docker](https://www.docker.com/)

```bash
brew install podman
podman machine init --cpus $(sysctl -n hw.ncpu) --memory 4096
podman machine start
```

### Kernel source on an external volume

Podman's VM only mounts `/Users` by default. If your kernel source lives on
an external volume (e.g. `/Volumes/KernelDev/linux`), add it when creating
the machine:

```bash
podman machine init \
    --volume /Volumes/KernelDev:/Volumes/KernelDev \
    --cpus $(sysctl -n hw.ncpu) --memory 4096
podman machine start
```

To add a volume to an existing machine, the machine must be recreated:

```bash
podman machine stop
podman machine rm
podman machine init \
    --volume /Volumes/KernelDev:/Volumes/KernelDev \
    --cpus $(sysctl -n hw.ncpu) --memory 4096
podman machine start
```

## Quick start

```bash
# Clone this repo
git clone https://github.com/nogunix/kbuild-macos.git

# Go to your kernel source tree
cd /path/to/linux

# Build the container image (one-time)
../kbuild-macos/scripts/kbuild-container build

# Build an arm64 kernel
../kbuild-macos/scripts/kbuild-container make defconfig
../kbuild-macos/scripts/kbuild-container make -j$(nproc) Image modules

# Cross-compile for x86_64
../kbuild-macos/scripts/kbuild-container x86 defconfig
../kbuild-macos/scripts/kbuild-container x86 -j$(nproc) bzImage modules

# Interactive shell
../kbuild-macos/scripts/kbuild-container shell
```

## Symlink setup (optional)

For convenience, symlink the script into your kernel tree:

```bash
cd /path/to/linux
ln -s /path/to/kbuild-macos/scripts/kbuild-container scripts/kbuild-container
```

Then use it as if it were part of the tree:

```bash
scripts/kbuild-container make defconfig
```

## Environment variables

| Variable | Default | Description |
|---|---|---|
| `KBUILD_IMAGE` | `kernel-build` | Container image name |
| `KBUILD_RUNTIME` | auto-detect | Force `podman` or `docker` |
| `KBUILD_CPUS` | nproc | Number of parallel jobs |
| `KBUILD_SRCDIR` | auto-detect | Kernel source directory to mount |

## What's in the container

Fedora 42 with:
- gcc, binutils, make, flex, bison, bc, perl, python3
- elfutils-libelf-devel, openssl-devel, ncurses-devel
- dtc, dwarves/pahole (BTF), kmod
- x86\_64 cross-compilation toolchain (`gcc-x86_64-linux-gnu`)
- Compression tools (xz, lz4, zstd, gzip, bzip2)

## License

Scripts are licensed under GPL-2.0, matching the Linux kernel.
