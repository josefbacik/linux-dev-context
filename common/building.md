# Kernel Building

## Overview

The Linux kernel build system (kbuild) is a sophisticated make-based system that handles compilation of the kernel, modules, documentation, and various utilities. It supports building for multiple architectures, both native and cross-compilation, and provides numerous customization options.

The kernel version 6.x uses a recursive build process that starts from the top-level Makefile and descends into subsystem directories. Configuration is handled through Kconfig, and the actual build output can be separated from source via the `O=` option.

## Key Concepts

### Build System Architecture

The kernel build system consists of several layers:

1. **Top-level Makefile** - Coordinates the entire build process
2. **Architecture Makefiles** - `arch/$(SRCARCH)/Makefile` provides architecture-specific settings
3. **Kbuild Makefiles** - Present in every subdirectory, define what to build
4. **Configuration** - `.config` file generated from Kconfig hierarchy
5. **Scripts** - `scripts/` contains build infrastructure and helper tools

### Output Separation

By default, all object files and generated files are placed alongside source files. You can separate output using:
- `make O=/path/to/output` - Redirect all output to specified directory
- `export KBUILD_OUTPUT=/path/to/output` - Environment variable alternative
- The `O=` option must be used consistently across all make invocations

### Build Targets

The primary build products are:

- **vmlinux** - The bare kernel (ELF image)
- **modules** - Loadable kernel modules (.ko files)
- **Architecture-specific images** - Compressed and bootable images (arch/*/boot/)
  - `arch/x86/boot/bzImage` - Compressed x86 kernel
  - `arch/arm64/boot/Image` - ARM64 kernel
  - `arch/arm/boot/zImage` - ARM kernel

## Common Make Targets

### Build Targets

```
make [all]              Build kernel and modules (default targets marked with [*])
make vmlinux            Build bare kernel only
make modules            Build all modules
make modules_install    Install modules to /lib/modules/$(KERNELRELEASE)/ by default
make modules_prepare    Set up kernel for external module building
make bzImage            Build compressed kernel image (x86)
make Image              Build kernel image (arm64, etc)
make dtbs               Build device tree blobs (ARM platforms)
make headers            Build ready-to-install UAPI headers
make headers_install    Install sanitized headers to INSTALL_HDR_PATH
```

### Specialized Targets

```
make dir/                   Build all files in directory and subdirectories
make dir/file.o             Build specific object file
make dir/file.i             Generate preprocessed C file
make dir/file.s             Generate assembly file
make dir/file.ll            Build LLVM assembly (requires compiler support)
make dir/file.lst           Build mixed source/assembly listing
make dir/file.ko            Build module with final link
make kselftest              Build and run kernel self-tests
make kselftest-all          Build self-tests
make kselftest-install      Build and install self-tests
make kselftest-clean        Clean self-test artifacts
```

### Configuration Targets

```
make config             Plain text configuration interface
make menuconfig          Text-based menu interface (ncurses)
make nconfig            Enhanced text-based menus
make xconfig            Qt-based graphical interface
make gconfig            GTK-based graphical interface
make defconfig          Use default architecture config
make tinyconfig         Minimal kernel configuration
make allyesconfig       Set all options to 'y' (build-in)
make allmodconfig       Set all options to 'm' (modules)
make allnoconfig        Set all options to 'n' (disabled)
make oldconfig          Prompt for new options, use existing for known ones
make olddefconfig       Use defaults for new options (no prompting)
make localmodconfig     Build config for currently loaded modules
make localyesconfig     Like localmodconfig but built-in instead of modules
make randconfig         Random configuration
make ${PLATFORM}_defconfig  Platform-specific defaults (use "make help")
```

Configuration files are machine-generated and stored in:
- `.config` - User configuration file (in build directory)
- `include/config/auto.conf` - Internal representation
- `include/generated/autoconf.h` - C header for kernel code

### Cleaning Targets

```
make clean              Remove generated files except .config and external module support
make mrproper           Remove all generated files, configuration, and backups
make distclean          mrproper + editor backups, patch files, and version control leftovers
make [arch]clean        Architecture-specific cleaning
```

The three-level cleaning approach:
- **clean** - Safest for development; preserves .config for rebuilds
- **mrproper** - Complete clean including .config (forces reconfiguration)
- **distclean** - Removes all temporary files including editor backups

### Documentation and Analysis

```
make help               List all available targets and options
make kernelversion      Output VERSION.PATCHLEVEL.SUBLEVEL
make kernelrelease      Output complete kernel version with any EXTRAVERSION
make image_name         Output the kernel image filename
make tags               Generate tags file for editors (ctags)
make TAGS               Generate TAGS file for editors (etags)
make cscope             Generate cscope index
make gtags              Generate GNU GLOBAL index
make checkstack         Find functions with large stack usage
make versioncheck       Sanity check on version.h usage
make includecheck       Check for duplicate includes
make headerdep          Detect header inclusion cycles
make coccicheck         Check with Coccinelle static checker
make clang-analyzer     Run clang static analyzer
make clang-tidy         Run clang-tidy checker
make nsdeps             Generate missing symbol namespace dependencies
```

### Installation Targets

```
make install            Install kernel image (requires installkernel script)
make modules_install    Install modules to INSTALL_MOD_PATH
make headers_install    Install sanitized headers to INSTALL_HDR_PATH
make dtbs_install       Install device tree blobs
make vdso_install       Install vDSO files (virtual dynamic shared objects)
```

## Build Flags and Environment Variables

### Architecture and Cross-Compilation

```
ARCH=<arch>                 Target architecture (arm, arm64, x86, etc)
SRCARCH=<arch>              Architecture source directory mapping
SUBARCH=<arch>              Subarchitecture for some architectures
CROSS_COMPILE=<prefix>      Compiler prefix (e.g., aarch64-linux-gnu-)
LLVM=1                      Use LLVM/Clang toolchain instead of GCC
LLVM=<path>                 Path to LLVM toolchain directory (with trailing /)
LLVM=-<version>             LLVM version suffix (e.g., -14 for clang-14)
LLVM_IAS=0                  Use non-integrated assembler with Clang
```

### Output Directory Control

```
O=<dir>                     Specify output directory for build artifacts
KBUILD_OUTPUT=<dir>         Environment variable for output directory
MO=<dir>                    Output directory for external modules
```

### Compilation Verbosity and Warnings

```
V=0                         Quiet mode (default)
V=1                         Show full compilation commands
V=2                         Show commands and reason for rebuilds
V=12                        Combine V=1 and V=2 output
W=1                         Show warnings (may be relevant, infrequent)
W=2                         Show more warnings (occur often, still relevant)
W=3                         Show obscure warnings (usually ignorable)
W=c                         Extra Kconfig checks
W=e                         Treat warnings as errors
W=123                       Combine multiple warning levels
C=1                         Check only recompiled source with sparse
C=2                         Check all source files with sparse (sparse checker)
CF=<flags>                  Additional flags for sparse checker
```

### Compiler Selection

```
CC=<compiler>               C compiler (default: gcc)
CXX=<compiler>              C++ compiler
HOSTCC=<compiler>           Host C compiler for build tools
HOSTCXX=<compiler>          Host C++ compiler
RUSTC=<compiler>            Rust compiler
CLIPPY=1                    Enable Clippy linter for Rust code
```

### Module Building and Installation

```
M=<dir>                     Build external module in specified directory
KBUILD_EXTMOD=<dir>         Environment variable for external module directory
INSTALL_MOD_PATH=<path>     Prefix for module installation (default: /)
INSTALL_MOD_STRIP=1         Strip modules after installation (1=default, or custom flags)
MODLIB=<path>               Full path for module installation
KBUILD_MODPOST_WARN=1       Emit warnings instead of errors for undefined symbols
KBUILD_MODPOST_NOFINAL=1    Skip final link stage (test builds only)
KBUILD_EXTRA_SYMBOLS=<file> Module symbols from other modules
```

### Installation Paths

```
INSTALL_PATH=<path>         Where to install kernel image (default: /boot)
INSTALL_HDR_PATH=<path>     Where to install headers (default: $(objtree)/usr)
INSTALL_DTBS_PATH=<path>    Where to install device tree blobs
INSTALL_MOD_PATH=<path>     Prefix for module paths
INSTALLKERNEL=<script>      Custom kernel installation script
```

### Build Configuration

```
KCFLAGS=<flags>             Additional C compiler flags (all targets)
KAFLAGS=<flags>             Additional assembler flags (all targets)
KRUSTFLAGS=<flags>          Additional Rust compiler flags (all targets)
CFLAGS_KERNEL=<flags>       Flags only for built-in code
CFLAGS_MODULE=<flags>       Flags only for modules
RUSTFLAGS_KERNEL=<flags>    Rust flags only for built-in code
RUSTFLAGS_MODULE=<flags>    Rust flags only for modules
LDFLAGS_MODULE=<flags>      Linker flags for modules
USERCFLAGS=<flags>          Flags for userspace programs
USERLDFLAGS=<flags>         Linker flags for userspace programs
HOSTCFLAGS=<flags>          Flags for build host programs
HOSTCXXFLAGS=<flags>        Flags for build host C++ programs
HOSTRUSTFLAGS=<flags>       Flags for build host Rust programs
LDFLAGS_vmlinux=<flags>     Linker flags for kernel image
```

### Build Behavior

```
LOCALVERSION=<string>       Append to kernel version (shown in uname -v)
KBUILD_BUILD_TIMESTAMP=<ts> Override build timestamp (empty for reproducible builds)
KBUILD_BUILD_USER=<user>    Override user in version string
KBUILD_BUILD_HOST=<host>    Override hostname in version string
KBUILD_VERBOSE=<level>      Same as V= flag
KBUILD_EXTRA_WARN=<level>   Same as W= flag
KBUILD_CHECKSRC=<level>     Same as C= flag
KBUILD_CLIPPY=<level>       Same as CLIPPY= flag
KBUILD_ABS_SRCTREE=1        Use absolute paths instead of relative
KBUILD_SIGN_PIN=<pin>       PIN/passphrase for module signing
KBUILD_KCONFIG=<file>       Top-level Kconfig file (default: Kconfig)
ALLSOURCE_ARCHS=<archs>     Architectures for tags targets (e.g., "x86 arm")
IGNORE_DIRS=<dirs>          Directories to exclude from tags (space-separated)
```

### Debugging and Checking

```
RECORDMCOUNT_WARN=1         Warn about ignored mcount sections
CHECK_DTBS=1                Validate device tree files
KBUILD_DEBARCH=<arch>       Override Debian architecture detection
KDOCFLAGS=<flags>           Extra flags for kernel-doc checks
```

## Build Process Flow

### Configuration Phase

1. Run a configuration target (menuconfig, defconfig, etc.)
2. Kconfig system generates `.config` file
3. Build system creates `include/config/auto.conf` and `include/generated/autoconf.h`
4. Configuration is validated and syncconfig updates generated headers

### Preparation Phase

1. `prepare` target creates necessary generated files:
   - Version headers (include/generated/version.h, utsrelease.h)
   - Compilation information (include/generated/compile.h)
   - Rust configuration (include/generated/rustc_cfg)
   - Architecture-specific preparation

2. Architecture-specific setup:
   - Symbol exports and version info
   - Assembly generic headers
   - Architecture Makefiles included

### Build Phase

1. **Descend** into all configured subdirectories
2. **Compile** source files using configuration options
3. **Link** objects into built-in.a archives per directory
4. **Final link** combines all objects and libraries into vmlinux
5. **Module build** (if CONFIG_MODULES=y):
   - Compile module source files
   - Link modules with module-specific sections
   - Generate Module.symvers and modules.builtin files

### Installation Phase

1. Install kernel image to /boot or custom INSTALL_PATH
2. Install modules to INSTALL_MOD_PATH/lib/modules/$(KERNELRELEASE)
3. Optional: Sign modules if CONFIG_MODULE_SIG=y
4. Optional: Strip modules if INSTALL_MOD_STRIP is set

## Common Build Scenarios

### Basic Kernel Build

```bash
# Configure kernel
make menuconfig

# Build kernel and modules
make -j$(nproc)

# Install
sudo make modules_install install
```

### Out-of-Tree Build (Recommended)

```bash
# Create build directory
mkdir -p build/kernel

# Configure in output directory
make O=build/kernel menuconfig

# Build in output directory
make O=build/kernel -j$(nproc)

# Install from output directory
sudo make O=build/kernel modules_install install
```

### Cross-Compilation Example (ARM64)

```bash
# Set architecture and cross-compiler
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig

# Build for ARM64
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)

# Install to staging directory
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- \
     INSTALL_MOD_PATH=/tmp/arm64-install \
     modules_install install
```

### Using LLVM/Clang Toolchain

```bash
# Use LLVM=1 for full LLVM toolchain
make LLVM=1 menuconfig
make LLVM=1 -j$(nproc)

# Or with version suffix
make LLVM=-14 menuconfig
make LLVM=-14 -j$(nproc)

# Or with LLVM path
make LLVM=/path/to/llvm/ menuconfig
make LLVM=/path/to/llvm/ -j$(nproc)
```

### Verbose Build Output

```bash
# Show all commands
make V=1 -j$(nproc)

# Show commands and rebuild reasons
make V=2 -j$(nproc)

# Combined verbose output
make V=12 -j$(nproc)
```

### Static Analysis

```bash
# Check with sparse (C static checker)
make C=2 -j$(nproc)

# Enable extra warnings
make W=1 -j$(nproc)

# Treat warnings as errors
make W=e -j$(nproc)

# Run Coccinelle static checker
make coccicheck

# Run clang analyzer
make clang-analyzer

# Run clang-tidy
make clang-tidy
```

### Minimal Kernel Configuration

```bash
# Create tiny kernel
make tinyconfig

# Review and adjust
make menuconfig

# Build
make -j$(nproc)
```

### Configuration-Based Module Building

```bash
# Build config based on currently loaded modules
make localmodconfig

# Review and build
make menuconfig
make modules -j$(nproc)
```

### External Module Development

```bash
# Prepare kernel for external modules
make modules_prepare

# Build external module
make -C /path/to/kernel M=$PWD

# Or using -f option (Linux 6.13+)
make -f /path/to/kernel/Makefile M=$PWD

# Install external module
make -C /path/to/kernel M=$PWD modules_install
```

### Build Single Component

```bash
# Build specific driver
make drivers/usb/ -j$(nproc)

# Build specific object file
make drivers/usb/core/usb.o

# Generate preprocessed file
make drivers/usb/core/usb.i

# Generate assembly listing
make drivers/usb/core/usb.s

# Build with mixed source/assembly
make drivers/usb/core/usb.lst
```

### Debug Builds

```bash
# Enable debug symbols
make menuconfig  # Enable CONFIG_DEBUG_INFO

# Enable kernel debugging (with reduced optimization)
make menuconfig  # Look under Kernel hacking -> Debug options

# Preserve symbols in modules
make INSTALL_MOD_STRIP=0 modules_install
```

## Configuration System (Kconfig)

### Understanding .config

The `.config` file is the central configuration file containing all kernel build options. Format:
```
CONFIG_OPTION=y         # Option enabled (built-in)
CONFIG_OPTION=m         # Option as module
CONFIG_OPTION=<value>   # String/number value
# CONFIG_OPTION is not set  # Option disabled
```

### Kconfig Structure

Configuration options are defined in Kconfig files throughout the source tree. Key sections:
- `arch/<arch>/Kconfig` - Architecture options
- `drivers/Kconfig` - Driver configuration
- `fs/Kconfig` - Filesystem configuration
- `net/Kconfig` - Networking configuration

### Configuration Tips

```bash
# Get help on a config option
make menuconfig  # Navigate to option and press '?'

# Search for config options
make menuconfig  # Press '/' to search

# Load configuration from another system
make oldconfig  # Based on .config, asks about new options

# Auto-answer new options with defaults
make olddefconfig

# Merge configs from multiple machines
scripts/kconfig/merge_config.sh -m .config config1 config2

# Show loaded modules config (create config for running kernel)
make LSMOD=/proc/modules localmodconfig
```

## File Structure

### Important Generated Files

```
.config                          # Kernel configuration
include/config/                  # Config header files
include/config/auto.conf         # Configuration in makefile format
include/generated/
  ├── autoconf.h                 # Configuration as C header
  ├── version.h                  # Kernel version constants
  ├── utsrelease.h               # Kernel release version
  ├── compile.h                  # Build timestamp/compiler info
  └── rustc_cfg                  # Rust compiler configuration
arch/<arch>/boot/                # Architecture-specific boot files
System.map                        # Kernel symbol map
vmlinux                          # Uncompressed kernel ELF
vmlinux.o                        # Linked kernel objects (before final link)
Module.symvers                   # Module version symbols
modules.builtin                  # List of built-in modules
modules.builtin.modinfo          # Metadata of built-in modules
```

## Debugging Build Issues

### Common Problems and Solutions

**Issue: "Kernel configuration is invalid"**
```bash
# Solution: Reconfigure kernel
make oldconfig && make prepare
```

**Issue: "Module version mismatch"**
```bash
# Solution: Rebuild modules and Module.symvers
make clean
make -j$(nproc)
make modules_install
```

**Issue: Stale build artifacts**
```bash
# Solution: Full clean and rebuild
make mrproper
make menuconfig
make -j$(nproc)
```

**Issue: Compiler mismatch on rebuild**
```bash
# Solution: Rebuild with consistent compiler
make clean
make CC=gcc-11 -j$(nproc)
```

### Build Debugging Flags

```bash
# Verbose output showing all commands
make V=1

# Show why files are being rebuilt
make V=2

# Keep intermediate files for inspection
make KEEP_STATE=1

# Useful with out-of-tree builds
make O=build V=2 -j4
```

## Performance Optimization

Building the Linux kernel can be time-consuming, especially for full builds. This section covers comprehensive techniques to optimize build performance through parallel compilation, caching, configuration optimization, and hardware considerations.

### Parallel Builds

The kernel build system scales well with parallel compilation. Optimal job count depends on your CPU architecture and available resources.

#### Optimal Job Numbers

```bash
# Basic: Use all CPU cores/threads
make -j$(nproc)

# Conservative: Number of cores + 1 (good for CPU-bound workloads)
make -j$(($(nproc) + 1))

# Aggressive: 1.5x to 2x number of cores (better for I/O-bound systems)
make -j$((2 * $(nproc)))

# Intel with Hyper-Threading: cores × 1.5 often optimal
# Example: 6-core with HT: -j9 can be 11% faster than -j6
make -j$(($(nproc) * 3 / 2))

# Very high core count systems (>50 cores): test 50-60 jobs
# Performance often flattens after -j56 and may degrade after -j75
make -j56
```

#### Load-Based Parallelism

```bash
# Limit system load to prevent overload (useful for shared systems)
make -l$(nproc) -j$(nproc)

# More conservative load limit
make -l$(($(nproc) / 2)) -j$(nproc)
```

#### Performance Considerations

- **CPU-bound processes**: Use `n+1` jobs where n = core count
- **I/O-bound processes**: Use `2n` to `3n` jobs if storage is fast (SSD/NVMe)
- **Memory pressure**: Monitor RAM usage; too many jobs can cause swapping
- **System responsiveness**: For desktop systems, consider `n` or `n+1` to maintain usability
- **Benchmarking**: Test different values on your hardware; optimal varies by system

**Recent kernel improvements (Linux 5.6+)**: Parallel builds scale significantly better on high-core-count systems like AMD Threadripper and Intel Xeon processors.

### Incremental Builds

Incremental compilation only rebuilds changed files and their dependencies, dramatically reducing build time for iterative development.

#### When to Use Incremental Builds

```bash
# Regular development: Just run make
make -j$(nproc)

# Typical time savings: 1-2 minutes vs 10-20 minutes for full rebuild
# Example: Clean build: 19min 8s, Incremental: 1min 4s (18x faster)

# Apply minor patches (e.g., 3.18.11 → 3.18.12)
make oldconfig
make -j$(nproc)  # Only changed files rebuild
```

#### Clean vs mrproper

Understanding when to clean is critical for build performance:

```bash
# make clean: Remove build artifacts, keep .config
# - Deletes: *.o, *.ko, vmlinux, etc.
# - Keeps: .config, external module support
# - Use when: Rebuilding same config, forcing full rebuild
make clean
make -j$(nproc)

# make mrproper: Remove everything including .config
# - Deletes: All generated files + config + backups
# - Use when: Switching kernel versions, starting fresh
# - Note: More thorough than clean (includes clean's deletions)
make mrproper
make defconfig
make -j$(nproc)

# make distclean: mrproper + editor backups, patches
# - Use when: Preparing pristine source tree
make distclean
```

**Best Practice**: For active development on a stable kernel version with minor changes:
- **Avoid** `make clean` unless necessary
- Let incremental builds handle dependencies
- Use `make clean` when dependency tracking seems broken
- Use `make mrproper` only when changing configurations or versions

#### Incremental Build Safety

While incremental builds are generally reliable, some scenarios benefit from clean rebuilds:

```bash
# Safe incremental scenarios:
# - Modifying a few source files
# - Working on isolated drivers/subsystems
# - Same kernel version with local patches

# Consider 'make clean' when:
# - Configuration changes (especially major ones)
# - Compiler version changes
# - Suspicious build errors
# - Applying large patch sets

# Always clean when:
# - Switching kernel versions
# - Cross-compilation target changes
# - Build system reports dependency issues
```

### ccache Integration

ccache (compiler cache) dramatically speeds up recompilation by caching previous compilation results. Can provide **5-10x speedup** for subsequent builds.

#### Performance Gains

```
First build (cold cache): 735s (13.6% slower than no cache)
Subsequent build (hot cache): 98.9s (6.54x faster)
```

#### Installation and Setup

```bash
# Install ccache
# Fedora/RHEL
sudo dnf install ccache

# Debian/Ubuntu
sudo apt install ccache

# Arch Linux
sudo pacman -S ccache

# Configure cache size (2-10GB recommended)
ccache -M 5G

# Check cache statistics
ccache -s

# Monitor cache in real-time
watch -n1 -d ccache -s
```

#### Using ccache with Kernel Builds

```bash
# Method 1: Direct CC specification
make CC="ccache gcc" -j$(nproc)

# Method 2: Using LLVM with ccache
KBUILD_BUILD_TIMESTAMP='' make LLVM=1 CC="ccache clang" -j$(nproc)

# Method 3: Masquerade mode (add ccache to PATH)
export PATH="/usr/lib/ccache:$PATH"
make -j$(nproc)

# Method 4: Environment variable
export CC="ccache gcc"
make -j$(nproc)
```

#### Critical: Reproducible Builds with ccache

**IMPORTANT**: Must set `KBUILD_BUILD_TIMESTAMP` to avoid 100% cache misses:

```bash
# Without this, ccache will miss every time due to changing timestamps
KBUILD_BUILD_TIMESTAMP='' make CC="ccache gcc" -j$(nproc)

# Or set to deterministic value
KBUILD_BUILD_TIMESTAMP='2024-01-01 00:00:00' make CC="ccache gcc" -j$(nproc)
```

#### Configuration Considerations

```bash
# Disable CONFIG_LOCALVERSION_AUTO to improve cache hits
# This option appends git version to kernel version string,
# changing compile.h frequently and forcing unnecessary rebuilds
make menuconfig
# Navigate to: General setup -> Local version - append to kernel release
# Disable: Automatically append version information to the version string

# Set cache directory (optional)
export CCACHE_DIR=/path/to/cache

# Configure in .bashrc for persistence
echo 'export CCACHE_DIR=$HOME/.ccache' >> ~/.bashrc
echo 'export CC="ccache gcc"' >> ~/.bashrc
```

#### ccache Best Practices

- **First build is slower**: Accept one-time 10-15% overhead to populate cache
- **Best for**: Repeated builds of same kernel version with minor changes
- **Less effective for**: Always working with latest mainline kernel
- **Module-focused work**: Excellent cache hit rates for isolated module development
- **Combine with incremental builds**: Maximum performance for development workflow

### Build Configuration Optimization

Configuration choices significantly impact build time. A minimal config can reduce build time from hours to minutes.

#### localmodconfig: Minimal Configuration

Creates a configuration based only on currently loaded modules, dramatically reducing build scope.

```bash
# Load all modules you'll need first
# Plug in all hardware, load all drivers you use
sudo modprobe <any_additional_modules>

# Create minimal config
make localmodconfig

# Review and adjust
make menuconfig

# Build with minimal config
make -j$(nproc)

# Performance improvement: 64min (2772 modules) → 16min (244 modules)
# That's 4x faster build time!
```

#### Using modprobed-db for Comprehensive Module Tracking

For even better `localmodconfig` results, track modules over time:

```bash
# Install modprobed-db (AUR for Arch, or from GitHub)
# https://github.com/graysky2/modprobed-db

# Run modprobed-db periodically to record loaded modules
sudo modprobed-db store

# After using system for a while with various hardware/tasks
sudo modprobed-db recall  # Loads all previously recorded modules

# Now create config
make localmodconfig

# Result: Config includes all modules you've ever needed
```

#### localyesconfig: Built-in Instead of Modules

Similar to localmodconfig but compiles everything as built-in (y) instead of modules (m):

```bash
# No modules, no initrd needed
make localyesconfig

# Smaller kernel build, faster boot
make -j$(nproc)
```

#### Important Considerations for localmodconfig

**Warnings**:
- Only includes **currently loaded** or **previously recorded** modules
- Missing modules for hardware not currently attached
- Missing modules for tasks not yet performed
- Missing filesystem drivers for unmounted filesystems

**Best Practice**:
1. Boot distribution kernel first
2. Use system normally for several days
3. Attach all hardware you own
4. Mount all filesystem types you use
5. Perform all tasks you do (VPN, virtualization, containers, etc.)
6. Run `modprobed-db store` periodically
7. Then run `make localmodconfig`

#### Manual Configuration Optimization

```bash
# Start with defconfig, then minimize
make defconfig
make menuconfig

# Disable unnecessary subsystems:
# - Unused network protocols (IPv6 if not needed, exotic protocols)
# - Unused filesystems (XFS, BTRFS if you only use ext4)
# - Debugging options (huge impact on build time and size)
# - Unused device drivers (staging drivers, exotic hardware)

# Kernel size reduction example:
# - Default config: ~5GB build artifacts, 2772 modules
# - Optimized config: <1GB build artifacts, 244 modules
# - Boot time: 1/5 of original time
```

#### Configuration File Management

```bash
# Save optimized config
cp .config ~/kernel-config-fast

# Use KCONFIG_ALLCONFIG for preset values
echo "CONFIG_LOCALVERSION=\"-custom\"" > my.config
KCONFIG_ALLCONFIG=my.config make alldefconfig

# Merge multiple configs
scripts/kconfig/merge_config.sh -m .config config1 config2

# Generate minimal config file (only non-default values)
make savedefconfig
# Creates defconfig file with minimal options
```

### Compiler and Linker Optimization

#### Compiler Optimization Levels

The kernel defaults to `-O2`, which is the recommended optimization level:

```bash
# Default: -O2 (recommended, safe, well-tested)
make -j$(nproc)

# Performance optimization: -O3 (experimental, risky)
make KCFLAGS="-O3" -j$(nproc)

# Size optimization: -Os
# Enabled via: make menuconfig → General setup → Optimize for size
make -j$(nproc)
```

**-O3 Considerations**:
- **Marginal gains**: Average 1-3% performance improvement, some workloads up to 270%
- **Code size**: Significantly larger binaries (30-50% increase)
- **Reliability concerns**: Linus Torvalds has expressed concern about GCC -O3 correctness
- **Compilation time**: Longer compile times
- **Memory usage**: Larger code may hurt cache performance
- **Recommendation**: Stick with -O2 unless you have specific benchmarked reasons for -O3

#### Alternative Linkers

Faster linkers can significantly reduce link time, especially for large kernel images:

```bash
# Default: GNU ld (slowest)
make -j$(nproc)

# GNU gold linker (3-4x faster than ld, deprecated as of binutils 2.44)
make LDFLAGS="-fuse-ld=gold" -j$(nproc)
# Enable multithreading for gold
make LDFLAGS="-fuse-ld=gold -Wl,--threads -Wl,--thread-count=$(nproc)" -j$(nproc)

# LLVM lld linker (fastest, 2x faster than gold, actively maintained)
make LLVM=1 -j$(nproc)
# Or explicitly
make LD=ld.lld -j$(nproc)

# mold linker (newest, fastest - up to 26x faster than gold)
# Note: May require patches/newer kernel for full support
make LD=mold -j$(nproc)
```

**Linker Performance (Chromium 1.57 GiB debug build example)**:
- GNU ld: Couldn't complete (N/A)
- GNU gold: 40.86s
- LLVM lld: 12.69s (3.2x faster than gold)
- mold: 2.2s (18.6x faster than gold)

**Kernel-Specific Considerations**:
- **lld**: Best supported for kernel builds, use with LLVM=1
- **gold**: Deprecated, Linux kernels may not boot when linked with gold
- **mold**: Very new, may need kernel >= 6.x for compatibility

```bash
# Recommended for fastest builds with LLVM
make LLVM=1 -j$(nproc)
# Uses lld automatically, clang compiler, and LLVM tools
```

### Out-of-Tree Builds

Separating build artifacts from source tree improves build performance and organization:

```bash
# Benefits:
# - Clean source tree
# - Multiple configurations from same source
# - Better for version control
# - Easier to clean (rm -rf build dir)
# - Can build on faster storage while source is on slower storage

# Method 1: O= parameter
mkdir -p /fast/storage/kernel-build
make O=/fast/storage/kernel-build defconfig
make O=/fast/storage/kernel-build -j$(nproc)

# Method 2: KBUILD_OUTPUT environment variable
export KBUILD_OUTPUT=/fast/storage/kernel-build
make defconfig
make -j$(nproc)

# Build on tmpfs (RAM) for ultimate speed
mkdir -p /tmp/kernel-build
make O=/tmp/kernel-build defconfig
make O=/tmp/kernel-build -j$(nproc)
```

**Important**: Use `O=` consistently across all make invocations (defconfig, build, install).

### Hardware Considerations

Hardware choices have dramatic impact on kernel build performance:

#### RAM Requirements

```bash
# Minimum: 4GB (single-threaded builds, small configs)
# Recommended: 16GB (parallel builds, standard configs)
# Optimal: 32GB+ (high parallelism, debug builds, ccache)

# Typical RAM usage during parallel builds:
# - 4-8GB: Basic parallel build (-j4 to -j8)
# - 8-16GB: Full parallel build (-j$(nproc) on 8-core)
# - 16GB+: Aggressive parallelism, ccache, multiple builds
# - 20GB+: Full debug build (with CONFIG_DEBUG_INFO)

# Monitor RAM during build
watch -n1 free -h

# If RAM is insufficient, reduce parallel jobs
make -j4  # Instead of -j$(nproc)

# Warning: Too many jobs with insufficient RAM causes swapping,
# dramatically slowing builds (can be 10x slower)
```

**Performance Impact**:
- **Sufficient RAM**: CPU-bound compilation, RAM acts as filesystem cache
- **With enough RAM**: All source files cached in memory, I/O eliminated
- **Insufficient RAM**: I/O-bound, excessive swapping, system hangs

#### Storage Performance

```bash
# HDD: 30-60 minutes for full kernel build
# SATA SSD: 10-20 minutes for full kernel build
# NVMe SSD: 5-10 minutes for full kernel build
# tmpfs (RAM): 3-5 minutes for full kernel build

# Typical impact:
# - SSD vs HDD: 2-3x faster builds
# - NVMe vs SATA SSD: 1.5-2x faster builds
# - tmpfs vs NVMe: 1.5-2x faster builds (if enough RAM)

# Build on tmpfs (ramdisk) for maximum I/O performance
sudo mkdir -p /mnt/ramdisk
sudo mount -t tmpfs -o rw,size=32G,noatime,nodev,nosuid tmpfs /mnt/ramdisk
cd /mnt/ramdisk
tar xf /path/to/linux-source.tar.xz
cd linux-6.x
make defconfig
make -j$(nproc)

# Or just build output on tmpfs
make O=/mnt/ramdisk/build -j$(nproc)
```

**tmpfs Performance Considerations**:
- **RAM requirement**: Need 8-20GB depending on config
- **Performance gain**: 50-100% faster than SSD, 2-7x faster than HDD
- **Best for**: Repeated builds, development workflow
- **Watch out**: Ensure sufficient RAM+swap to back tmpfs
- **Lost on reboot**: Copy final vmlinuz/modules before reboot

**Mount options for best performance**:
```bash
# noatime: Don't update access times (reduces writes)
# nodev, nosuid: Security options
sudo mount -t tmpfs -o rw,size=20G,noatime,nodev,nosuid tmpfs /mnt/ramdisk
```

#### CPU Architecture

```bash
# Modern CPUs (2020+) with 8+ cores: 5-15 minutes
# Older CPUs (2015-) with 4 cores: 20-40 minutes
# Very high core count (Threadripper, Xeon): 2-5 minutes

# Example build times:
# - i5 Jasper Lake (16GB RAM, SSD): 5 minutes
# - AMD Threadripper 3990X (64C/128T): Sub-2 minutes
# - AMD EPYC 7742 2P: 15-16 seconds (defconfig)
# - i7-3770 (4C/8T, 24GB RAM): Best at -j8 to -j12

# Hyperthreading (HT) considerations:
# - Intel HT: Use cores × 1.5 for optimal performance
# - Disabling HT: Can reduce compile time by 20%+ (better cache)
# - Test both: Benchmark with and without HT on your workload
```

**CPU Performance Factors**:
- Core count (more is better)
- Clock speed (higher is better)
- Cache size (larger L3 cache helps significantly)
- Memory bandwidth (important for parallel builds)
- Thermal performance (throttling slows builds)

#### Distributed Compilation

For multiple machines, distributed compilation can dramatically reduce build times:

```bash
# distcc: Simple distributed compilation
# Install distcc on all machines
sudo apt install distcc

# On build machine
export DISTCC_HOSTS="localhost/4 buildserver1/8 buildserver2/8"
make CC="distcc gcc" -j20

# icecream: More sophisticated, dynamic scheduling
# Install icecc
sudo apt install icecc

# Start scheduler (on one machine)
iceccd -s buildserver1

# Configure icecream environment
icecc-create-env --gcc /usr/bin/gcc /usr/bin/g++
export ICECC_VERSION=/path/to/environment.tar.gz

# Build with icecream
make CC="icecc gcc" -j40

# Icecream advantages over distcc:
# - Dynamic load balancing
# - Central scheduler
# - Easier ccache integration
# - Better cross-compilation support
# - Automatic compiler distribution

# Performance: Can utilize 20-40+ cores across multiple machines
# Example: Raspberry Pi kernel compile drops from 2 hours to 20-30 minutes
```

**Build Farm Considerations**:
- All machines must have identical compilers (build compiler yourself)
- Fast network required (Gigabit minimum)
- Kernel builds parallelize well (many equal-sized compilation units)
- Setup complexity vs. performance gain tradeoff

### Build Timing and Statistics

Measure and analyze build performance:

```bash
# Basic timing
time make -j$(nproc)

# Detailed timing with GNU time
/usr/bin/time -v make -j$(nproc)

# Shows: Real time, user time, system time, memory usage, I/O stats

# Phoronix Test Suite benchmark
phoronix-test-suite benchmark build-linux-kernel

# kcbench: Kernel compile benchmark
# https://gitlab.com/knurd42/kcbench
kcbench -j $(nproc)

# Output includes:
# - Elapsed time
# - CPU usage
# - Context switches
# - Average compilation units per second

# Log build for analysis
make V=1 -j$(nproc) 2>&1 | tee build.log

# Analyze bottlenecks
# - High system time: I/O bound, need faster storage
# - High user time: CPU bound, optimize parallelism
# - High real time vs user time: Insufficient parallelism
# - Page faults: RAM pressure, reduce jobs or add RAM
```

#### Performance Baselines

Typical build times for reference (Linux 6.x defconfig):

```
Configuration: x86_64 defconfig
CPU: Modern 8-core (16-thread) @ 3.5GHz
RAM: 16GB DDR4
Storage: NVMe SSD
Build: make -j16

Clean build: 8-12 minutes
Incremental: 1-3 minutes
With ccache (hot): 1-2 minutes

Configuration: localmodconfig (~250 modules)
Same hardware:

Clean build: 3-5 minutes
Incremental: 30-60 seconds
With ccache (hot): 20-40 seconds
```

### Combined Optimization Strategy

For maximum build performance, combine multiple techniques:

```bash
#!/bin/bash
# Optimal kernel build script

# Configuration
KERNEL_SRC=/path/to/linux
BUILD_DIR=/mnt/ramdisk/kernel-build  # tmpfs mounted ramdisk
JOBS=$(($(nproc) * 3 / 2))           # 1.5x cores

# Setup ccache
export CCACHE_DIR=$HOME/.ccache
ccache -M 10G

# Create minimal config (first time only)
cd $KERNEL_SRC
# Boot distro kernel, use system normally for a week, then:
# sudo modprobed-db store  # periodically
# sudo modprobed-db recall
make localmodconfig

# Disable CONFIG_LOCALVERSION_AUTO for better ccache
scripts/config --disable LOCALVERSION_AUTO

# Build with all optimizations
KBUILD_BUILD_TIMESTAMP='' make O=$BUILD_DIR \
    CC="ccache gcc" \
    LLVM=1 \
    -j$JOBS

# Result:
# - Minimal config: 4x fewer modules
# - ccache: 6x faster rebuilds
# - tmpfs: 2x faster I/O
# - Optimal -j: 1.5x better CPU utilization
# - lld linker: 3x faster linking
# Combined: 10-20x faster than naive "make" for iterative development!

# Install
sudo make O=$BUILD_DIR modules_install install

# Backup before reboot (tmpfs is volatile!)
cp $BUILD_DIR/arch/x86/boot/bzImage /boot/vmlinuz-custom
```

### Troubleshooting Performance Issues

```bash
# Build is slow:
# 1. Check I/O wait
iostat -x 1

# High iowait? → Use SSD or tmpfs

# 2. Check memory pressure
free -h
vmstat 1

# Swapping? → Reduce jobs or add RAM

# 3. Check CPU utilization
htop

# Low CPU usage? → Increase jobs
# 100% on few cores? → Dependency serialization (normal for link phase)

# 4. Check build was incremental
make V=2 -j$(nproc) 2>&1 | grep "is up to date"

# Many rebuilds? → Configuration changed, use make clean carefully

# 5. Verify ccache is working
ccache -s

# Low hit rate? → Check KBUILD_BUILD_TIMESTAMP is set

# ccache not being used? → Verify CC="ccache gcc"
make V=1 -j1 | grep ccache

# 6. Profile build bottlenecks
make -j1 2>&1 | ts -i '%.s' | tee build-profile.log

# Find slowest compilation units
```

### Performance Optimization Checklist

**Essential (always use)**:
- [ ] Parallel builds: `make -j$(nproc)`
- [ ] Incremental builds: Avoid unnecessary `make clean`
- [ ] Reasonable configuration: Don't enable everything

**High impact (recommended)**:
- [ ] ccache: 6x faster rebuilds
- [ ] localmodconfig: 4x fewer modules
- [ ] SSD storage: 2-3x faster I/O
- [ ] Sufficient RAM: 16GB+ for smooth builds

**Medium impact (if applicable)**:
- [ ] Out-of-tree builds: Better organization
- [ ] LLVM/lld: Faster linking
- [ ] tmpfs builds: 2x faster I/O (needs RAM)
- [ ] Disable CONFIG_LOCALVERSION_AUTO: Better ccache

**Advanced (diminishing returns)**:
- [ ] -O3 optimization: Marginal gains, stability risk
- [ ] Distributed compilation: Complex setup
- [ ] mold linker: Experimental, setup complexity
- [ ] Hyper-threading tuning: System-specific

**Monitoring**:
- [ ] Measure baseline: `time make -j$(nproc)`
- [ ] Track improvements after each optimization
- [ ] Monitor RAM/CPU/I/O during builds
- [ ] Verify ccache hit rates

## Debug and Sanitizer Builds

Building the kernel with debug options and sanitizers helps find bugs during development. These options add runtime checks but impact performance.

### KASAN (Kernel Address Sanitizer)

KASAN detects out-of-bounds and use-after-free bugs at runtime.

#### Configuration

```bash
# Enable in menuconfig
make menuconfig
# Navigate: Kernel hacking → Memory Debugging → KASAN: runtime memory debugger

# Or via config options
echo "CONFIG_KASAN=y" >> .config
echo "CONFIG_KASAN_GENERIC=y" >> .config  # For debugging (slower but more thorough)
echo "CONFIG_KASAN_INLINE=y" >> .config   # Faster than outline mode
echo "CONFIG_STACKTRACE=y" >> .config     # Better error reports
make olddefconfig
```

#### KASAN Modes

**Generic KASAN** (debugging):
- Architecture: x86_64, arm, arm64, powerpc, riscv, s390, xtensa
- Memory overhead: ~1/8 of RAM
- Performance: ~3x slowdown
- Best for: Development and testing

**SW-Tags KASAN** (lighter weight):
- Architecture: arm64 only
- Memory overhead: ~1/16 of RAM
- Performance: ~20% overhead
- Best for: Continuous testing

**HW-Tags KASAN** (production-safe):
- Architecture: arm64 with MTE (Memory Tagging Extension)
- Memory overhead: ~1/32 of RAM
- Performance: Low overhead
- Best for: Production monitoring

#### Build with KASAN

```bash
# Full debug build with KASAN
make menuconfig
# Enable: CONFIG_KASAN, CONFIG_KASAN_GENERIC, CONFIG_KASAN_INLINE
# Enable: CONFIG_DEBUG_INFO, CONFIG_FRAME_POINTER

# Build
make -j$(nproc)

# Boot parameters for KASAN
# panic_on_warn=1  # Panic on KASAN detection
# kasan_multi_shot=1  # Report all errors, not just first
```

### KFENCE (Kernel Electric Fence)

Low-overhead sampling-based memory error detector suitable for production.

```bash
# Enable KFENCE (production-safe)
echo "CONFIG_KFENCE=y" >> .config
echo "CONFIG_KFENCE_SAMPLE_INTERVAL=100" >> .config  # milliseconds
echo "CONFIG_KFENCE_NUM_OBJECTS=255" >> .config
make olddefconfig
make -j$(nproc)

# Runtime control
# Boot: kfence.sample_interval=100
# Disable: echo 0 > /sys/module/kfence/parameters/sample_interval
```

### UBSAN (Undefined Behavior Sanitizer)

Detects undefined behavior like integer overflow and array bounds violations.

```bash
# Enable UBSAN
echo "CONFIG_UBSAN=y" >> .config
echo "CONFIG_UBSAN_BOUNDS=y" >> .config
echo "CONFIG_UBSAN_SHIFT=y" >> .config
echo "CONFIG_UBSAN_BOOL=y" >> .config
echo "CONFIG_UBSAN_ENUM=y" >> .config
make olddefconfig
make -j$(nproc)
```

### KCOV (Code Coverage)

Enable code coverage for fuzzing tools like syzkaller.

```bash
# Enable KCOV for fuzzing
echo "CONFIG_KCOV=y" >> .config
echo "CONFIG_KCOV_INSTRUMENT_ALL=y" >> .config
echo "CONFIG_KCOV_ENABLE_COMPARISONS=y" >> .config
make olddefconfig
make -j$(nproc)
```

### Lockdep (Lock Dependency Validator)

Detects potential deadlocks and locking issues.

```bash
# Enable comprehensive lock debugging
echo "CONFIG_LOCKDEP=y" >> .config
echo "CONFIG_PROVE_LOCKING=y" >> .config
echo "CONFIG_DEBUG_LOCK_ALLOC=y" >> .config
echo "CONFIG_DEBUG_LOCKDEP=y" >> .config
make olddefconfig
make -j$(nproc)

# Warning: Significant performance impact (20-30% overhead)
```

### Complete Debug Kernel Configuration

```bash
#!/bin/bash
# Comprehensive debug kernel build

# Start with defconfig
make defconfig

# Core debugging
scripts/config --enable CONFIG_DEBUG_KERNEL
scripts/config --enable CONFIG_DEBUG_INFO
scripts/config --enable CONFIG_DEBUG_INFO_DWARF4
scripts/config --enable CONFIG_FRAME_POINTER

# Memory debugging
scripts/config --enable CONFIG_KASAN
scripts/config --enable CONFIG_KASAN_GENERIC
scripts/config --enable CONFIG_KASAN_INLINE
scripts/config --enable CONFIG_KFENCE
scripts/config --enable CONFIG_DEBUG_KMEMLEAK

# Undefined behavior
scripts/config --enable CONFIG_UBSAN
scripts/config --enable CONFIG_UBSAN_BOUNDS

# Lock debugging
scripts/config --enable CONFIG_LOCKDEP
scripts/config --enable CONFIG_PROVE_LOCKING

# Tracing and debugging tools
scripts/config --enable CONFIG_FTRACE
scripts/config --enable CONFIG_FUNCTION_TRACER
scripts/config --enable CONFIG_KGDB
scripts/config --enable CONFIG_KGDB_SERIAL_CONSOLE

# Coverage for fuzzing
scripts/config --enable CONFIG_KCOV
scripts/config --enable CONFIG_KCOV_INSTRUMENT_ALL

# Apply configuration
make olddefconfig

# Build
make -j$(nproc)
```

### Performance Impact Summary

| Sanitizer | Memory Overhead | Performance Impact | Production Safe |
|-----------|----------------|-------------------|-----------------|
| KASAN Generic | ~12.5% RAM | ~3x slower | No |
| KASAN SW-Tags | ~6% RAM | ~20% slower | Limited |
| KASAN HW-Tags | ~3% RAM | Low | Yes (ARM64) |
| KFENCE | Minimal | <1% | Yes |
| UBSAN | ~5% size | Low-moderate | Depends |
| KCOV | Low | Low | Limited |
| Lockdep | Moderate | 20-30% slower | No |

## Advanced Cross-Compilation

Cross-compilation allows building kernels for different target architectures from your development machine.

### Toolchain Installation

#### Ubuntu/Debian Packages

```bash
# ARM 64-bit (aarch64)
sudo apt-get install gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu

# ARM 32-bit (armhf)
sudo apt-get install gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf

# RISC-V 64-bit
sudo apt-get install gcc-riscv64-linux-gnu binutils-riscv64-linux-gnu

# PowerPC 64-bit
sudo apt-get install gcc-powerpc64le-linux-gnu binutils-powerpc64le-linux-gnu

# MIPS
sudo apt-get install gcc-mips-linux-gnu binutils-mips-linux-gnu
```

#### Building Custom Toolchains

For RISC-V or other architectures without packages:

```bash
# Clone RISC-V GNU toolchain
git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain

# Install prerequisites
sudo apt-get install autoconf automake autotools-dev curl python3 \
    python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential \
    bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

# Build for Linux targets
./configure --prefix=/opt/riscv --with-arch=rv64gc --with-abi=lp64d
make linux -j$(nproc)

# Add to PATH
export PATH=/opt/riscv/bin:$PATH
```

### Architecture-Specific Builds

#### ARM64 (aarch64) Build

```bash
# Set environment
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-

# Configure
make defconfig  # Generic ARM64 config
# Or use board-specific config
make bcm2711_defconfig  # Raspberry Pi 4

# Build kernel, modules, and device trees
make -j$(nproc) Image modules dtbs

# Install to staging directory
make INSTALL_MOD_PATH=/tmp/arm64-root modules_install
make INSTALL_DTBS_PATH=/tmp/arm64-root/boot/dtbs dtbs_install

# Copy kernel image
cp arch/arm64/boot/Image /tmp/arm64-root/boot/
```

#### ARM 32-bit Build

```bash
export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

# Choose appropriate config for your board
make multi_v7_defconfig  # Generic ARMv7
make omap2plus_defconfig  # BeagleBone Black
make bcm2835_defconfig   # Raspberry Pi 1/Zero

# Build zImage and device trees
make -j$(nproc) zImage modules dtbs

# Create uImage for U-Boot (if needed)
mkimage -A arm -O linux -T kernel -C none -a 0x80008000 -e 0x80008000 \
    -n "Linux Kernel" -d arch/arm/boot/zImage arch/arm/boot/uImage
```

#### RISC-V Build

```bash
export ARCH=riscv
export CROSS_COMPILE=riscv64-linux-gnu-

# Configure
make defconfig

# Build
make -j$(nproc) Image modules dtbs

# Test with QEMU
qemu-system-riscv64 -M virt -smp 4 -m 2G \
    -kernel arch/riscv/boot/Image \
    -append "console=ttyS0" \
    -nographic
```

### Using LLVM for Cross-Compilation

LLVM/Clang simplifies cross-compilation as it includes all backends in a single binary:

```bash
# No CROSS_COMPILE needed with LLVM
make ARCH=arm64 LLVM=1 defconfig
make ARCH=arm64 LLVM=1 -j$(nproc)

# Or with specific LLVM version
make ARCH=arm64 LLVM=-14 defconfig
make ARCH=arm64 LLVM=-14 -j$(nproc)

# Supported architectures with LLVM:
# arm, arm64, hexagon, loongarch, mips, powerpc, riscv, s390, sparc64, um, x86
```

### Cross-Compilation Helper Script

Create a reusable script for cross-compilation:

```bash
#!/bin/bash
# xbuild.sh - Cross-compilation helper

ARCH=${1:-arm64}
BOARD=${2:-defconfig}
OUTPUT=${3:-build-$ARCH}

case $ARCH in
    arm)
        export CROSS_COMPILE=arm-linux-gnueabihf-
        IMAGE=zImage
        ;;
    arm64)
        export CROSS_COMPILE=aarch64-linux-gnu-
        IMAGE=Image
        ;;
    riscv)
        export CROSS_COMPILE=riscv64-linux-gnu-
        IMAGE=Image
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

export ARCH=$ARCH

# Configure
make O=$OUTPUT $BOARD

# Build
make O=$OUTPUT -j$(nproc) $IMAGE modules dtbs

# Install
make O=$OUTPUT INSTALL_MOD_PATH=$OUTPUT/modules modules_install
make O=$OUTPUT INSTALL_DTBS_PATH=$OUTPUT/dtbs dtbs_install

echo "Build complete in $OUTPUT/"
```

## Module Building

Kernel modules can be built as part of the main kernel (in-tree) or separately (out-of-tree). Module building is covered comprehensively in separate documentation:

- **[module-building.md](module-building.md)** - Complete guide covering all aspects of module development including:
  - In-tree and out-of-tree module building
  - Multi-file modules and complex Makefiles
  - Module signing and secure boot
  - Dependencies and symbol management
  - Compression and optimization
  - Troubleshooting and best practices

- **[module-building-quick-ref.md](module-building-quick-ref.md)** - Quick reference cheat sheet with:
  - Essential commands and syntax
  - Makefile templates
  - Common patterns and examples

### Quick Examples

```bash
# Build all modules
make modules -j$(nproc)

# Build specific in-tree module
make M=drivers/net/ethernet/intel/e1000e -j$(nproc)
make drivers/net/ethernet/intel/e1000e/e1000e.ko

# Build external (out-of-tree) module
make -C /lib/modules/$(uname -r)/build M=$PWD

# Install modules
sudo make modules_install
make INSTALL_MOD_PATH=/custom/path modules_install

# Module operations
sudo modprobe module_name    # Load with dependencies
sudo rmmod module_name        # Unload module
modinfo module_name.ko        # Show module information
```

For detailed information including multi-file modules, signing, dependencies, compression, and troubleshooting, refer to the dedicated module documentation linked above.

## Kernel Configuration Methods

The kernel provides multiple configuration interfaces to suit different workflows.

### Interactive Configuration

#### menuconfig (Most Popular)

```bash
# Text-based menu interface
make menuconfig

# Navigation:
# - Arrow keys: Move through menus
# - Enter: Select submenu
# - Space: Toggle option
# - ?: Get help on option
# - /: Search for options
# - ESC ESC: Go back

# Search example:
# Press / then type "KASAN" to find memory sanitizer options
# Press number shown to jump directly to that option
```

#### xconfig and gconfig (GUI)

```bash
# Qt-based GUI (requires qt5-dev)
make xconfig

# GTK-based GUI (requires gtk3-dev)
make gconfig

# Better for browsing large configuration trees
# Good search and dependency visualization
```

### Automated Configuration

#### Using scripts/config

Programmatically modify kernel configuration:

```bash
# Enable/disable options
scripts/config --enable CONFIG_KASAN
scripts/config --disable CONFIG_DEBUG_INFO
scripts/config --module CONFIG_E1000E

# Set values
scripts/config --set-str CONFIG_LOCALVERSION "-custom"
scripts/config --set-val CONFIG_LOG_BUF_SHIFT 18

# Query configuration
scripts/config --state CONFIG_KASAN
# Output: y, m, n, or value

# Apply changes (important!)
make olddefconfig
```

#### Configuration Fragments

Manage features as separate config fragments:

```bash
# Create debug fragment
cat > debug.config << EOF
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_KERNEL=y
CONFIG_KASAN=y
CONFIG_UBSAN=y
EOF

# Create network fragment
cat > network.config << EOF
CONFIG_NETFILTER=y
CONFIG_NF_CONNTRACK=y
CONFIG_BRIDGE=y
EOF

# Merge fragments with base config
scripts/kconfig/merge_config.sh .config debug.config network.config

# Or during build
make defconfig debug.config network.config
```

#### localmodconfig Workflow

Build minimal kernel for specific hardware:

```bash
# 1. Boot with distribution kernel
# 2. Connect all your hardware
# 3. Load all features you need

# Record loaded modules over time (optional)
sudo modprobe usb-storage  # Example: USB drive support
sudo modprobe kvm-intel    # Virtualization

# Create config from loaded modules
make localmodconfig

# Review what will be removed
make localmodconfig 2>&1 | grep "depends on"

# Keep specific subsystems even if not loaded
make LMC_KEEP="drivers/usb:net/netfilter" localmodconfig

# Build minimal kernel
make -j$(nproc)
```

## Reproducible Builds

```bash
# Control build timestamp for reproducibility
KBUILD_BUILD_TIMESTAMP='2024-01-01 00:00:00' make -j$(nproc)

# Empty timestamp for relative time-based reproducibility
KBUILD_BUILD_TIMESTAMP='' make -j$(nproc)

# Fixes user/host strings in version info
KBUILD_BUILD_USER=kernel make -j$(nproc)
KBUILD_BUILD_HOST=build make -j$(nproc)
```

## References

### Official Kernel Documentation
- `Documentation/kbuild/kbuild.rst` - Kbuild variables and behavior
- `Documentation/kbuild/makefiles.rst` - Makefile syntax and structure
- `Documentation/kbuild/modules.rst` - Building external modules
- `Documentation/kbuild/kconfig.rst` - Configuration system details
- `Documentation/kbuild/llvm.rst` - LLVM/Clang building
- `Documentation/admin-guide/README.rst` - Installation and setup
- `Documentation/kbuild/reproducible-builds.rst` - Reproducible build practices

### Key Files in Kernel Source
- `Makefile` - Top-level build orchestration
- `arch/$(ARCH)/Makefile` - Architecture-specific settings
- `scripts/Kbuild.include` - Common build definitions
- `scripts/Makefile.build` - Object file compilation rules
- `scripts/Makefile.lib` - Library of makefile functions
- `scripts/link-vmlinux.sh` - Kernel linking script

