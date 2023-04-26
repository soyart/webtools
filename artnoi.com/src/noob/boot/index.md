# Low-level booting

The moment you turn you machine on, the CPU doesn't just jump right into the operating system code. The processing of starting the operating system after powered on is called _bootstraping_ the computer, or just _booting_.

## Legacy systems

Legacy systems rely on the [MBR (Master Boot Record)](https://en.wikipedia.org/wiki/Master_boot_record) partition scheme to boot the operating system. The MBR is usually 512 (or more) bytes in the drive's first sector. The information in the MBR includes the bootstrap code (boot loader), and the partition table.

Because the MBR also stores partition information and thus it limits the maximum number of partitions a medium can hold (limited to 4 _primary_ partitions), as well as the maximum amount of data adressable (2TB).

> The boot code is, in simplest terms, a special small program that helps transferring control of the machine from the BIOS to the OS.

Because the boot code is already stored _raw_ on the disk's first sector, legacy systems don't actually require a boot partition or filesystem to store the boot code file, although it is still recommended to do so.

## (U)EFI systems

UEFI systems relies on EFI interface, which is a standardized communication standards between the firmware and the operating systems. To boot in this mode, you will need EFI support in both hardware and software (the EFI bootloader).

### EFI boot entries

The EFI boot entries can be manipulated on Linux with `efibootmgr`. For example, show the entries with:

```shell
efibootmgr -v;
```

To make next boot `0001`, do:

```shell
efibootmgr -n 0001;
```

To set new boot order, in this case '`0002,0003,0001,0000`', do:

```shell
efibootmgr -o 0002,0003,0001,0000;
```

Removing an entry (`-B`), in this case entry number 0001 (`-b 001`):

```shell
efibootmgr -b 001 -B;
```

Adding custom entry (`-c` create, `-d` disk, `-l` location, `-L` label) for `/boot/loader/EFI/systemd/systemd-bootx64.efi`:

```shell
efibootmgr -c -d /dev/sdX -p Y -l "EFI\systemd\systemd-bootx64.efi" -L "CUSTOMNAME";
```

## UEFI vs legacy

Booting using EFI has some technical advantages over legacy boots, for example, the EFI boot disks can be formatted with a GPT partition table, which is much more modern and suitable for today's large drives.

# Starting the kernel

Once the computer finished initializing its components, it then accesses the disk, looking for a higher-level bootloader to continue booting to the operating systems. Different boot modes (legacy vs UEFI) will require different type of bootloaders.

## Linux bootloaders

The kernel cannot load itself, even after the hardware has finished initial boot processes. Instead, a special program (bootloader) helps boot the kernel by executing the kernels with the correct parameters for target system.

There are biliions of bootloaders for the Linux kernel, but in this article I'm only going to focus on EFI-only `systemd-boot` (Arch's default) and the more popular swiss army knife `grub`.

### `systemd-boot`

`systemd-boot` is a great utility, but it's EFI-only, which is fine on modern machines. Arch Linux ships with `systemd-boot`, so it's convenient to install it to the `/boot` partition on Arch with:

```shell
bootctl --path=/boot install;
```

This should install the EFI bootloader program to `/boot`, or the EFI system partition.

To configure `systemd-boot`, edit `/boot/loader/loader.conf`.

### `grub`

Installing `grub` legacy boot code on an MBR disk:

```shell
grub-install --target=i386-pc /dev/sdX;
```

Installing `grub` on an EFI system partition (ESP, in this example mounted on `/boot`):

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB;
```

Configuring `grub` is done mostly on the `/etc/default/grub` template file, which will later be used to produce `grub.cfg` in our `/boot`. After editing `grub` config in `/etc/default`, update the `grub` config in `/boot` with:

```shell
grub-mkconfig -o /boot/grub/grub.cfg;
```

## Initramfs and initrd

> To boot the operating system, the computer first boots into BIOS, and executes a bootloader program (an EFI program for EFI systems, or platform-specific bootloader for legacy systems). Then, that bootloader starts initial kernel, by literally copying _initramfs_ into RAM (and thus the name initial _ramdisk_, or initrd).

The initramfs is a compressed `cpio(1)` image of a small filesystem containing the kernel and other essential utilities essential to boot into the actual root filesystem.

Because each root filesystem is configured differently, so it is crucial that the initramfs is properly configured and contain all the utilities to _prepare to mount_ the actual root filesystem.

## `mkinitcpio(8)`

On Arch Linux, `mkinitcpio(8)` is a shell (more like bash) utility used to create initramfs. If your root filesystem is not on special block device, the default settings in `/etc/mkinitcpio.conf` will work most of the times.

There might be some exception: you may need to embed `/usr/bin/btrfs` binaries to the image if Btrfs is used as root filesystem (because `fsck(8)` doesn't work on Btrfs), even though that Btrfs root is sitting on raw partition (not [`dm` device](/cheat/device-mapper/)), or embedding the modules `amdgpu` and `radeon` when using AMD GPU.

## `mkinitcpio(8)` for non-standard root filesystem

If your root filesystem is on a special block device, you will need to edit the `mkinitcpio(8)` settings so that the resulting image is able to mount the actual root filesystem.

Hooks in `mkinicpio(8)` are `bash(1)` scripts which are sourced in the order specified in `mkinitcpio.conf`'s `HOOKS` variable.

Below are some of my staple, frequently used `mkinitcpio(8) HOOKS` for encrypted root filesystems.

LUKS-on-LVM, and LVM-on-LUKS

```shell
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems resume fsck);
```

Encrypted ZFS

```shell
    HOOKS=(base udev autodetect modconf block keyboard zfs filesystems);
```

You should recheck with the Arch Wiki if your machine fails to boot.

## Linux Kernel parameters (boot parameters)

The kernel is like any other programs - it can have parameters (arguments). The boot parameter is passed to the kernel by the higher-level bootloader, usually dictating the kernel behaviors and limitations.

Sysadmins edit the boot parameters to match their kernel/booting needs. Kernel boot parameters are usually configured with bootloaders, e.g. `systemd-boot` and `grub`.

### `systemd-boot`

> The guide below is an example for [booting into encrypted root filesystem](/cheat/device-mapper/)

Edit `options` field in `/boot/loader/entries/*.conf` for your desired parameters. Examples include

```
options	loglevel=3
options	rd.luks.options=discard
options	rd.luks.name=UUID0=cryptlvm
options	root=/dev/mapper/my-root
options	resume=/dev/mapper/my-swap"
```

### `grub`

`grub` is usually used as the bootloader, and so sysadmins usually edit `grub` config file `/etc/default/grub` to change kernel parameters. An example below would set the same kernel parameter as the example for `systemd-boot`:

```
GRUB_CMDLINE_LINUX_DEFAULT="\
    loglevel=3\
    rd.luks.options=discard\
    rd.luks.name=UUID0=cryptlvm\
    root=/dev/mapper/my-root\
    resume=/dev/mapper/my-swap\
"
```

## Linux boot and initramfs

> Both UEFI and legacy systems will use initramfs after the initial boot processes.

The initramfs is a `cpio` image (usually compressed) in `/boot` partition of the Linux system. The booting kernel will mount this initial root image as RAM disk, and will use this root filesystem during initialization processes, e.g. when probing for the real root.

This is why if your real root is customized, i.e. installed on an encrypted volume, you will usually need to modify the initramfs to accommodate unlocking and mounting the real root.

### Why use initramfs?

The initramfs can be used to customize boot processes, i.e. by editting config files in `/etc` of the initramfs image, or by embedding custom application in the initramfs.

## Kernel file size

The Linux kernel source code is so large that having all of the parts built-in to one running kernel would be a huge waste of RAM space.

The developers then came up with the ideas of loadable kernel modules - for dummies, it is a system that allows loading needed modules (from `/usr/lib/modules`) to memory **as you need them**, leaving only the essential modules in the actual kernel.

Lately, I have seen people trying to optimize boot time by not using loadable kernel modules. If you build the modules right into the kernel (not as loadable), then the built-in modules will be embedded in your kernel, increasing both RAM and `/boot` storage usage.
