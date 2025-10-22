# Linux Kernel Module Building - Quick Reference

## Essential Build Commands

### In-Tree Modules

```bash
# Build all modules
make modules -j$(nproc)

# Build specific module
make drivers/net/ethernet/intel/e1000/e1000.ko
make M=drivers/usb/storage

# Install modules
sudo make modules_install
sudo make INSTALL_MOD_PATH=/mnt modules_install
```

### Out-of-Tree Modules

```bash
# Build against running kernel
make -C /lib/modules/$(uname -r)/build M=$PWD

# Build with separate output directory
make -C /lib/modules/$(uname -r)/build M=$PWD MO=/tmp/build

# Install external module
sudo make -C /lib/modules/$(uname -r)/build M=$PWD modules_install

# Clean
make -C /lib/modules/$(uname -r)/build M=$PWD clean
```

### New Syntax (Linux 6.13+)

```bash
# Avoid directory changes with -f
make -f /lib/modules/$(uname -r)/build/Makefile M=$PWD
```

## Makefile Templates

### Simple Module

```makefile
obj-m := mymodule.o

KDIR := /lib/modules/$(shell uname -r)/build

all:
	$(MAKE) -C $(KDIR) M=$$PWD

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

.PHONY: all clean
```

### Multi-File Module

```makefile
obj-m := driver.o
driver-y := main.o hardware.o protocol.o
ccflags-y := -I$(src)/include -Wall
```

### Multiple Modules

```makefile
obj-m := module1.o module2.o
module1-y := mod1_main.o mod1_util.o
module2-y := mod2_core.o
```

## Key Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `M=` | Module directory | `M=$PWD` |
| `MO=` | Output directory | `MO=/tmp/build` |
| `INSTALL_MOD_PATH` | Install prefix | `INSTALL_MOD_PATH=/mnt` |
| `INSTALL_MOD_DIR` | Subdir name | `INSTALL_MOD_DIR=extra` |
| `INSTALL_MOD_STRIP` | Strip symbols | `INSTALL_MOD_STRIP=1` |
| `KBUILD_EXTRA_SYMBOLS` | External symbols | Path to Module.symvers |
| `KCFLAGS` | Extra compiler flags | `KCFLAGS=-O3` |
| `V=1` | Verbose output | `V=1` or `V=2` |

## Compilation Flags

```makefile
# Modern (recommended)
ccflags-y := -DDEBUG -I$(src)/include
asflags-y := -Wa,-gdwarf-2
ldflags-y := -T$(src)/script.lds

# Deprecated (DO NOT USE)
EXTRA_CFLAGS := -DDEBUG  # Use ccflags-y instead

# Subdirectory flags
subdir-ccflags-y := -I$(src)/common

# Per-file flags
CFLAGS_main.o := -DVERSION=1
```

## Module Signing

```bash
# Check config
grep CONFIG_MODULE_SIG /boot/config-$(uname -r)

# Sign module manually
scripts/sign-file sha256 \
    certs/signing_key.pem \
    certs/signing_key.x509 \
    mymodule.ko

# Check signature
modinfo mymodule.ko | grep sig

# Generate signing key
openssl req -new -x509 -newkey rsa:2048 \
    -keyout key.pem -outform DER -out key.x509 \
    -nodes -days 36500 -subj "/CN=Module Signing Key/"
```

## Module Compression

### Config Options

```
CONFIG_MODULE_COMPRESS=y
CONFIG_MODULE_COMPRESS_GZIP=y    # .ko.gz
CONFIG_MODULE_COMPRESS_XZ=y      # .ko.xz
CONFIG_MODULE_COMPRESS_ZSTD=y    # .ko.zst (5.13+)
```

### Manual Compression

```bash
gzip -9 mymodule.ko      # Gzip
xz -9 mymodule.ko        # XZ (best ratio)
zstd -19 mymodule.ko     # Zstandard (fast + good ratio)
```

## Module Management

```bash
# Load module
sudo modprobe mymodule
sudo insmod mymodule.ko

# Load with parameters
sudo modprobe mymodule debug=1 device="eth0"

# Unload module
sudo modprobe -r mymodule
sudo rmmod mymodule

# Module info
modinfo mymodule
lsmod | grep mymodule

# Dependencies
modprobe --show-depends mymodule

# Dry run
modprobe -n mymodule

# Update dependencies
sudo depmod -a
```

## Module Configuration

### /etc/modprobe.d/mymodule.conf

```bash
# Set default parameters
options mymodule debug=1

# Blacklist module
blacklist mymodule

# Load order dependencies
softdep mymodule pre: dep1 post: dep2

# Custom install command
install mymodule /sbin/modprobe --ignore-install mymodule && /usr/local/bin/setup.sh
```

### Auto-load at Boot

```bash
# Method 1: /etc/modules
echo "mymodule" | sudo tee -a /etc/modules

# Method 2: modules-load.d
echo "mymodule" | sudo tee /etc/modules-load.d/mymodule.conf
```

## Debugging

```bash
# Verbose build
make V=1
make V=2  # Show rebuild reasons

# Generate intermediate files
make drivers/mydriver/main.i   # Preprocessed
make drivers/mydriver/main.s   # Assembly
make drivers/mydriver/main.lst # Mixed listing

# Static analysis
make C=2 M=$PWD       # Sparse
make W=1 M=$PWD       # Extra warnings
scripts/checkpatch.pl --file mymodule.c

# Runtime debugging
dmesg | tail
journalctl -k -f
echo 'module mymodule +p' | sudo tee /sys/kernel/debug/dynamic_debug/control
```

## Common Build Flags

```bash
# Cross-compilation
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- M=$PWD

# LLVM toolchain
make LLVM=1 M=$PWD

# Additional compiler flags
make KCFLAGS="-O3 -march=native" M=$PWD

# Module-specific flags
make CFLAGS_MODULE="-DDEBUG" M=$PWD

# Disable version warnings
make KBUILD_MODPOST_WARN=1 M=$PWD

# Skip final link (fast test)
make KBUILD_MODPOST_NOFINAL=1 M=$PWD
```

## Module Dependencies

```bash
# Build module A (exports symbols)
cd module_a
make -C /lib/modules/$(uname -r)/build M=$PWD
# Creates Module.symvers

# Build module B (uses module A symbols)
cd module_b
make -C /lib/modules/$(uname -r)/build M=$PWD \
    KBUILD_EXTRA_SYMBOLS=/path/to/module_a/Module.symvers
```

## Troubleshooting

| Error | Solution |
|-------|----------|
| "No rule to make target" | `make modules_prepare` |
| "Module version mismatch" | Rebuild with correct Module.symvers |
| "Invalid module format" | Kernel version mismatch, rebuild |
| "Required key not available" | Sign module or disable Secure Boot |
| "Unknown symbol" | Load dependencies first |
| "SUBDIRS ignored" | Use M= instead (kernel 5.4+) |

## File Structure

```
/lib/modules/$(uname -r)/
├── build -> /usr/src/linux-headers-*    # Kernel headers
├── kernel/                               # In-tree modules
├── updates/                              # External modules
├── extra/                                # Alternative location
├── modules.dep                           # Dependencies
├── modules.alias                         # Aliases
└── Module.symvers                        # Symbol versions
```

## Important Notes

- **SUBDIRS deprecated**: Use `M=` instead (removed in kernel 5.4)
- **ccflags-y vs EXTRA_CFLAGS**: Use ccflags-y (EXTRA_CFLAGS deprecated)
- **Module signing**: Required for Secure Boot systems
- **Module compression**: Transparent to users, saves disk space
- **depmod**: Run after module installation to update dependencies
- **KERNELRELEASE check**: Separates kbuild from normal make in Makefile

## Quick Workflow

```bash
# 1. Create module source
cat > hello.c << 'EOF'
#include <linux/module.h>
#include <linux/kernel.h>
static int __init hello_init(void) {
    printk(KERN_INFO "Hello!\n");
    return 0;
}
static void __exit hello_exit(void) {
    printk(KERN_INFO "Goodbye!\n");
}
module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");
EOF

# 2. Create Makefile
cat > Makefile << 'EOF'
obj-m := hello.o
KDIR := /lib/modules/$(shell uname -r)/build
all:
	$(MAKE) -C $(KDIR) M=$$PWD
clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean
EOF

# 3. Build
make

# 4. Test
sudo insmod hello.ko
dmesg | tail -1
sudo rmmod hello
dmesg | tail -1

# 5. Install (optional)
sudo make -C /lib/modules/$(uname -r)/build M=$PWD modules_install
sudo depmod -a
```

## Configuration Queries

```bash
# Check if modules enabled
grep CONFIG_MODULES= /boot/config-$(uname -r)

# Check module signing
grep CONFIG_MODULE_SIG /boot/config-$(uname -r)

# Check compression
grep CONFIG_MODULE_COMPRESS /boot/config-$(uname -r)

# Check versioning
grep CONFIG_MODVERSIONS /boot/config-$(uname -r)

# Get kernel version
uname -r
make kernelrelease
```

## Resources

- Official docs: `Documentation/kbuild/modules.rst`
- Module signing: `Documentation/admin-guide/module-signing.rst`
- Kbuild: `Documentation/kbuild/kbuild.rst`
- Makefiles: `Documentation/kbuild/makefiles.rst`
- Man pages: `man modprobe`, `man modinfo`, `man depmod`
