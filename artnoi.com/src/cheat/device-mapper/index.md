# Device mapper cheat sheet

The Linux kernel [device mapper](https://www.kernel.org/doc/html/latest/admin-guide/device-mapper/index.html) framework (DM, or `dm`) includes support for [LVM](http://www.sourceware.org/lvm2) (LVM2), a logical volume manager, and [LUKS](https://gitlab.com/cryptsetup/cryptsetup), a disk encrpytion specification that extends beyond `dm-crypt` present in the DM framework. [Jump to root on LVM and LUKS here](#install)

## LVM (LVM2)

Just like like any volume managers, Linux LVM is used to create multiple logical partitions out of a single hardware disk, or vice-versa. It adds a thin-provisioning layer above the hardware storage device itself, allowing for ease of use and administration. When compared to LUKS, LVM is harder to understand because it introduces 3 more concepts of storage: physical volumes (`pv`), volume groups (`vg`), and the logical volumes (`lv`), especially for novice computer users.

> We first initialize our storage hardware (physical volume, **PV**) for use by LVM with `pvcreate(8)`, then create a _logical_ volume group **VG** on that **PV** with `vgcreate(8)`, and lastly we create a logical volume **LV** on that **VG** with `lvcreate(8)`.

## LUKS (LUKS2)

LUKS provides disk encryption specification that extends beyond plain `dm-crypt`. Most notably, it provides an encryption header which in my case is useful for administration.

> Use `cryptsetup(8)` to setup plain `dm-crypt` or LUKS2 `dm-crypt` on your storage.

When LVM and LUKS are used together, the device mapper framework is able to provide flexible and secure storage solutions for both data storage and the root filesystems. For root filesystems, the boot process must be changed to accomodate the unlocking and unpacking of the device mapper(s). Other alternatives include kick-ass filesystems like ZFS, which also provides logical volume manager, encryption, as well as the filesystem itself.

## Frequently used `cryptsetup` commands

Create a LUKS device:

```shell
cryptsetup luksFormat <DEVICE>;
cryptsetup luksFormat /dev/sdXY;
```

Opening a LUKS device

```shell
cryptsetup luksOpen <DEVICE> <DEVICE MAPPER NAME>;
cryptsetup luksOpen /dev/sdXY myluks;
```

Closing a LUKS device

```shell
cryptsetup luksClose <DEVICE MAPPER NAME>;
cryptsetup luksClose myluks;
```

Dump LUKS information (e.g. key slots):

```shell
cryptsetup luksDump <DEVICE>;
cryptsetup luksDump /dev/sdXY;
```

Backup LUKS header to a file:

```shell
cryptsetup luksHeaderBackup <DEVICE> --header-backup-file <HEADER FILE>;
cryptsetup luksHeaderBackup /dev/sdXY --header-backup-file sdXY.header;
```

Restore LUKS header:

```shell
cryptsetup luksHeaderRestore <DEVICE> --header-backup-file <HEADER FILE>;
cryptsetup luksHeaderRestore /dev/sdXY --header-backup-file sdXY.header;
```

Adding LUKS key:

```shell
cryptsetup luksAddKey <DEVICE>;
cryptsetup luksAddKey /dev/sdXY;
```

Removing LUKS key (in this example, slot 12):

```shell
cryptsetup luksKillSlot <DEVICE> <KEY SLOT>;
cryptsetup luksKillSlot /dev/sdXY 12;
```

<a name="install"></a>

## Installing Linux root on LUKS-on-LVM

### Partitioning and setting up device mapper

> For many reasons including performance, **I recommend LUKS-on-LVM over LVM-on-LUKS**. If you want to use LVM-on-LUKS instead, just reverse the steps: create LUKS devices on hardware partitions first and later create LVM devices on top of LUKS. The `mkinitcpio` hooks are identical for both setups.

First, we create physical partitions with `fdisk`. You can use any partition editing tools you like though. We will use `sda` in this example, and `sda1` will be for our EFI System Partition, and `sda2` for LVM:

```shell
fdisk /dev/sdX;
```

Create unencrypted `FAT32` for EFI (will be mounted at `/boot`):

```shell
mkfs.vfat -F32 -L "BOOT" /dev/sda1
```

Create _physical volume_ for LVM. We will later assign a volume group to this physical volume:

```shell
pvcreate /dev/sda2;
```

Assign _volume group_ to our physical volume:

```shell
vgcreate mylvm /dev/sda2;
```

Create _logical volumes_:

```shell
lvcreate -C y -L 16G -n cryptswap mylvm;
lvcreate -l 100%FREE -n cryptroot mylvm;
```

Encrypt the other partition, and then open it in `/dev/mapper`:

```shell
cryptsetup luksFormat /dev/mylvm/cryptroot;
cryptsetup luksFormat /dev/mylvm/cryptswap;

cryptsetup luksOpen /dev/mylvm/cryptroot root;
cryptsetup luksOpen /dev/mylvm/cryptswap swap;
```

Now we should have our decrypted partition listed at `/dev/mapper/root` and `/dev/mapper/swap`.

Create filesystem(s) (`mkfs`, `mkswap`):

```shell
mkfs.btrfs -L "ROOT" /dev/mapper/root;
mkswap -L "SWAP" /dev/mapper/swap;
```

### Installing Linux

You can follow the distribution guide to encrypted root installation: [Void Linux guide](https://wiki.voidlinux.org/Install_LVM_LUKS_on_UEFI_GPT), [Arch Linux guide](https://wiki.archlinux.org/index.php/Dm-crypt/Encrypting_an_entire_system).

Unless my system fails to boot, I don't follow the guides. I simply encrypt a partition first, then install Arch Linux to it as usual, and lastly configure the boot process which (to me) is the only difference between an encrypted and plain installations. Below is how I usually setup Linux to boot into encrypted root.

### Booting

##### SSD users may want to look this <a href="https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)">Arch Wiki page</a> to allow [discards (TRIM)](https://wiki.archlinux.org/title/Solid_state_drive#TRIM) on dm-crypt device

Configure `/boot` accordingly. We will be using `sd-encrypt` (systemd) for Arch Linux:

```shell
HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt lvm2 filesystems resume fsck)
```

and regenerate the image(s):

```shell
mkinitcpio -P;
```

Note that you can remove `lvm2` hook in `mkinitcpio.conf` if you only use LUKS, i.e. you don't use any LVM logical volumes. Alternatively, be sure to install `lvm2` package, and add `lvm2` hook in `mkinitcpio`, if you wish to install your root filesystem on logical volumes.

#### Configuring boot kernel parameter

I use `systemd-boot` which reads boot kernel parameters from `/boot/loader/entries/*.conf`, but the parameters should also work on any boot loaders. The following example is tested on Arch Linux with `systemd-boot` only.

Also, `rd.luks.options=discard` is used in the examples. Read [this Arch Wiki for dm-crypt TRIM support](<https://wiki.archlinux.org/index.php/Dm-crypt/Specialties#Discard/TRIM_support_for_solid_state_drives_(SSD)>) before considering adding the discard option.

Example 1: LUKS-on-LVM:

```
options	loglevel=3
options	rd.luks.options=discard
options rd.luks.name=<Root LVM UUID>=cryptroot
options rd.luks.name=<Swap LVM UUID>=cryptswap
options	root=/dev/mapper/cryptroot ro
options	resume=/dev/mapper/cryptswap
```

Example 2: LVM-on-LUKS - in this example, the LVM volumes `root` and `swap` is within LVM volume group `cryptlvm`:

```
options loglevel=3
options rd.luks.options=discard
options rd.luks.name=<PART UUID>=cryptlvm
options root=/dev/mapper/cryptlvm-root ro
options resume=/dev/mapper/cryptlvm-swap
```

Let's say from Example 2, the LVM UUID is `dddddd` (d is for disk not dick), and we want to [put the keyfile](https://wiki.archlinux.org/index.php/Dm-crypt/System_configuration#rd.luks.key) to a flashdrive whose UUID is `ffffff` (f is for flash not fuck), then the kernel parameter should be:

```
options loglevel=3
options rd.luks.options=discard
options rd.luks.name=dddddd=cryptlvm
options rd.luks.key=dddddd=<Path to key file>:UUID=fffffff
options root=/dev/mapper/cryptlvm-root ro
options resume=/dev/mapper/cryptlvm-swap

# Fallback to password if keyfile not found
#options rd.luks.options=dddddd=keyfile-timeout=10s
```

One important note is that if you choose to have a keyfile on other device, it must be of the same filesystem type as your root filesystem (e.g. EXT4) otherwise you will have to [include the kernel module for it in the initramfs](https://wiki.archlinux.org/index.php/Mkinitcpio#MODULES).

Example 3: Install on LUKS - in this example, the LUKS device has its own raw partition:

```
options loglevel=3
options rd.luks.options=discard
options rd.luks.name=<PART UUID>=cryptroot
options rd.luks.name=<PART UUID>=cryptswap
options root=/dev/mapper/cryptroot ro
options resume=/dev/mapper/cryptswap
```

or if you use `grub` ( in `/etc/default/grub`):

```
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 rd.luks.options=discard rd.luks.name=UUID=cryptlvm \
    root=/dev/mapper/arch-root resume=/dev/mapper/arch-swap"
```

If you use `grub`, **create `grub.cfg` configuration file afterwards with new parameters**, or you will boot to default `grub` loader that doesn't know how to handle your encrypted root fs:

```shell
grub-mkconfig -o /boot/grub/grub.cfg;
```

## Fedora 32 `fstab`

If your Fedora 32 root option is LUKS-on-LVM option, then the volumes get unlocked and mounted by `plymouth.service`, which requires special device naming in `fstab` (literally: `/dev/mapper/luks-*UUID*`). **Just use the device name provided by your installation `fstab`, because as of writing (Aug 4 2020), the value can NOT be replaced with the mountpoint's actual UUID**, or you will boot into emergency mode complaining that the root is locked. Another note is that `noatime` and `nodiratime` will also fail your boot.

## Closing LVM and LUKS devices

Stopping LVM volume group:

```shell
vgchange -a n ${your_vg_name};
```

You can switch it back on again using:

```shell
vgchange -a y ${your_vg_name};
```

After switching off the volume group, you can close LUKS device with:

```shell
cryptsetup luksClose ${your_LVM_name};
```

Enjoy!
