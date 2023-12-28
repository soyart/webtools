Dec 20, [2020](/blog/2020/)

# Building Zen2-optimized kernel on Arch Linux

The Linux kernel includes multiple options and modules for AMD Zen2 x86 architecture. The vanilla kernel (`linux`) shipped by Arch does not include such configuration, so to get the most out of Zen2 CPUs on Arch, I will have to custom build my kernel.

## Using AUR - `linux-znver2`

The Arch User Repositories include kernel package `linux-amd-znver2` which is similar to the versatile vanilla Arch Linux kernel (`linux`), but with AMD Zen2 optimizations and other AMD-platform options. This is good enough for me, because it includes all the modules (both essential and bloated), thus ensuring that my system will work correctly should it need to load some extra modules.

## Customizing `linux-znver2`

But because unused modules _will_ be compiled, its presence alone wastes build time. I don't want to build USB support for my PlayStation2 controller on my AMD laptop. This is when I began to find a way to customing the kernel build option (`config`) further, and led me to write this article as a note to myself.

#### Caveats

Be sure that the module dependencies for those modules in `HOOKS` section of `mkinitcpio.conf` are available. The same is true for other `-dkms` modules.

### `make` options I used

It's best to read the kernel `README` before attempting to build the kernel. The official descriptions `make XXconfig` lists below can be found on the [README file](https://github.com/torvalds/linux/blob/master/Documentation/admin-guide/README.rst).

- `make localmodconfig` - Will use `lsmod` (or `$LSMOD` shell variable to the file containing target machine's `lsmod` output) to determine which modules will be built. The result will be a very streamlined kernel.
- `make nconfig` - `ncurses` menu for customizing `config` (`Kconfig`). Dubbed new `menuconfig`. Good for manually removing/adding modules without corrupting the `config` file.
- `make menuconfig` - deprecated, use `nconfig` instead.
- `make olddefconfig` - Uses old `config`, defaults for new options. This is default for our `linux-amd-znver2` package.
  So, to customize `config` after using our `lsmod` as a template, add these lines to `prepare()` section of `PKGBUILD`:
  make localmodconfig
  make nconfig
  Optionally, use `LSMOD=/path/to/file`:
  make LSMOD=/tmp/lsmod localmodconfig
  make nconfig

### The idea

The process is simple, but a bit time consuming. First you need to build a vanilla `linux-znver2`, and then after verifying that it works with your system, tries to minimize the extra modules and decides which ones should be built in or made as LKM. The main criteria to me when deciding whether to build it into the kernel, or as loadable kernel modules in `/usr/lib`, is the resulting `initramfs` size.
