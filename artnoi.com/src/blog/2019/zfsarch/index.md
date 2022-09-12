Nov 18, [2019](/blog/2019/)

# Installing Arch Linux on ZFS Root

Last Updated: June, 2020  

## Introduction

Good day. Today I will be guiding you on how to do Arch Linux installation on the Zettabyte Filesystem.

Please note that this article was written back in 2019 and may no longer be relevant. Also, always double check with the [Arch Wiki](https://wiki.archlinux.org/index.php/Install_Arch_Linux_on_ZFS).

### [Arch Linux](https://archlinux.org)
Arch Linux is a minimal Linux distribution with simplicity (think [KISS principles](https://en.wikipedia.org/wiki/KISS_principle)) and practicality in mind. Arch is focused on binary packages, but also comes with useful build tool to compile from source (namely `makepkg`), much like the BSD ports, and the fact that the distribution ships with both Free and non-Free software makes Arch extremely technically versatile and politically neutral.

> This KISS-inspired attitude of the Arch creators, packagers, maintainers, and users implies that the Arch software catalog is rich, highly configurable, and *vanilla*.

Arch is notorious for being hard to install and maintain, while in fact, it is the simplest one - there is clear documentation/explanation on the Arch wiki for you for every single installation/configuration step, unlike other user-friendly Linux distros that hide complexcity with abstraction - leading to more complexity and confusion to the users.

> Because of its minimalism, customizibility, and rich documentation, Arch Linux is an ideal distribution if you like to tinker around your computers. I have been using Arch for a while, but it had always been installed on `EXT4` partitions.

### [The Zettabyte Filesystem (ZFS)](https://en.wikipedia.org/wiki/ZFS)
ZFS is a next-generation, enterprise-grade filesystem originally developed by Sun. Unlike tradidional filesystems, ZFS integrates logical volume management, encryption, compression, RAID functionality, and other cool features all under one project. ZFS is solid, stable, and easy to use.

ZFS design is focused on data integrity, and scalability, and the command-line interface to ZFS is pleasant to operate. ZFS has gained more mainstream interests after sysadmins discovered that [ZFS block-level snapshots could be used to revert the file-level encryption put in place by recent malicious ransomware attacks](https://www.youtube.com/watch?v=XimxSb00F9w).

There're many flavors of ZFS, but today we'll be using [OpenZFS on Linux](https://zfsonlinux.org) which on Arch Linux is provided by `zfs-linux`, `zfs-linux-lts`, or `zfs-dkms` package depending on the kernel.

Anyone who has used ZFS (even for non-root partitions) should already now the basics of ZFS and its commands ([`zpool`](https://linux.die.net/man/8/zpool) and [`zfs`](https://linux.die.net/man/8/zfs)). Arch users who installs their own system on ZFS root should at least know what are ZFS zpool and datasets, basic properties, and how to mount ZFS datasets using either legacy mounting (`fstab` and `mount -t zfs`) or `zfs mount`.

### Approach and basic requirement
We will be basically partitioning (`fdisk`) and preparing the ZFS filesystem for our root. After the filesystem is configured, we will then install (i.e. using `pacstrap -i`) `base`, `base-devel`, and `mkinicpio`, and some other Arch basic packages. After base install is done, we will `ch-root` to do basic configuration and prepare our `/boot` so that our `/boot` knows how to boot to our Arch ZFS root.

### Requirements

-   **One `amd64` (`x86-64`) Linux computer** with `pacman` or access to Arch Bootstrap Image ([mirrors](https://www.archlinux.org/download/)) **with a ZFS implementation installed**. Alternatively, you can prepare a custom `archiso` USB stick with [ZFS pre-installed](https://github.com/eoli3n/archiso-zfs).

-   Free disk space, preferably unmanaged GPT disk partitions (i.e. `/dev/sdXY`)

-   Internet connection

-   [(U)EFI](https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface) boot - which equates a seperate `FAT32` **E**FI **S**ystem **P**artition (the ESP will be mounted at `/boot`)

-   `systemd-boot` (UEFI only) will be used

## Disk preparation
### Disk partitioning
Before we go ahead and install Arch, let's first prepare our disk(s) for the installation.

We need a FAT32 `/boot` partition and a minimum of 1 partition for our zpool I find using `fdisk` the easiest and most convenient way to partition a GPT disk:

    # fdisk /dev/sdX;

Replace *sdX* with your storage device name, or if you want some visualization:

    # cfdisk /dev/sdX;

The easiest disk layout should be a small (~250MiB) `VFAT` partition as our `ESP` (`/boot`), and a large `Solaris Root`-type partition for our zpool. This means that we will be using only one zpool for our root, and thus the system only needs to import one single pool during the boot processes - eliminating the need to enable ZFS-related [systemd](https://en.wikipedia.org/wiki/Systemd) daemons to import extra pools (since there is none).

### ZFS preparation
### Create ZFS zpool
As of June 2020, `zpool create -o $zpool_property -O $zfs_property` command can be used to create *master* dataset properties that can be automatically inherited by all children datasets (i.e. without having to use `zfs create -o $zfs_property` afterwards). For example, the command below will create a pool "zroot" with correct properties well suited for an Arch Linux root. Note that SSD users may want to add `-O autotrim=on`.

    # zpool create -f -o ashift=12 -o autoexpand=on -R /mnt \
                 -O acltype=posixacl \
                 -O relatime=on \
                 -O xattr=sa \   
                 -O dnodesize=legacy \
                 -O normalization=formD \
                 -O mountpoint=none \
                 -O canmount=off \   
                 -O devices=off \  
                 -O compression=lz4 \    
                 -O encryption=aes-256-gcm \
                 -O keyformat=passphrase \
                 -O keylocation=prompt \
             zroot /dev/disk/by-id/id-to-partition-partx;

> Note: Use `# fdisk -l` or `$ lsblk -S -o NAME,PHY-SEC` to determine your disk sector size and specify `ashift` value accordingly (512 byte =`ashift 9`, 4096 byte (4k) = `ashift 12`) for optimum performance, **although the Arch Wiki recommends using `ashift=12` ALWAYS for compatibility with 4k sector disks in case the pools need to be moved**. Also, `noatime` may be used instead of `relatime` if you really want to minimize disk reads and writes.

### Create ZFS dataset(s)

    # zfs create -o mountpoint=none zroot/ROOT;
    # zfs create -o mountpoint=legacy zroot/ROOT/default;
    # zfs create -o mountpoint=none zroot/data;
    # zfs create -o mountpoint=legacy zroot/data/home;

Note that if you create datasets with `mountpoint` explicitly set (as in this example), you will need to add `fstab` entries for each legacy ZFS mountpoints. Preferably, use `genfstab` to generate proper `fstab` entries. Also, for the dataset containing your `/var/log`, you will need to enable option `acltype=posixacl` otherwise you may have problem with `journald`.

ZFS loves RAM so I think we're gonna need a large swap partition, so let's create a zvol for our swap within our master dataset:

    # zfs create -V 8G -b $(getconf PAGESIZE) \
		-o logbias=throughput \
		-o sync=always \
		-o primarycache=metadata \
		-o com.sun:auto-snapshot=false \
		zroot/enc/swap;

And prepare the zvol as swap partition:

    # mkswap -f /dev/zvol/{path/to/your/zvol swap dataset};

>As of June 2020, I could not get Arch to "resume" on ZFS VDEVs or LUKS swap partition.

After all root datasets are configured, set `bootfs` property for our zpool:

    # zpool set bootfs=zroot/enc/ROOT/default zroot;

**Now our zpool `zroot` is ready.**
#### Export and import your pool to convenient location
You'll now have to export and re-import the pool to a convenient location like `/mnt` or `/install`:

    # zpool export zroot;
    # zpool import -d /dev/disk/by-id -R /install -l zroot;

This should import zpool `zroot` and its children to `/install` as root. If you set `mountpoint=legacy`, you will need to mount the dataset manually, i.e. using standard `mount` command.
## Arch Linux Installation
### Mount your install directory
Now that our ZFS layout is cool and good (and imported), let's first mount the other partitions/datasets such that it is final (i.e. mount your recently created `FAT32` ESP partition to `/install/boot`, `zroot/enc/ROOT/var` to `/var`, and `zroot/data/home` to `/home`). In my case, because my children datasets have `mountpoint` property set to `legacy`, I will need to mount it using legacy `mount` command:

    # mount /dev/sdxY /install/boot;
    # mount -t zfs zroot/ROOT/var /install/var;
    # mount -t zfs zroot/data/home /install/home;

### Use `pacstrap` to bootstrap basic packages
From this step on, you'll need a Linux computer capable of strapping Arch packages. If you don't have access to one, the easiest way to get yourself a proper, working Arch `pacman` without having to reboot to a live image is to [download](https://www.archlinux.org/download/) the Arch bootstrap image and chroot into it to use the image's `pacman` and `pacstrap` script. Now that you can get your hand on `pacman`, issue:

    # pacstrap -i /install base base-devel mkinitcpio vim;

Now `base`, `base-devel`, `mkinitcpio`, and `vim` should be installed to `/install`
### Edit important files..
The same boring stuff..

    # ln -sf /usr/share/zoneinfo/Asia/Bangkok /etc/localtime;
    # cp /etc/resolv.conf /install/etc/;
    # vim /install/etc/{fstab,mkinitcpio.conf};
    # vim /install/etc/{hostname,hosts};
    # vim /install/etc/{locale.gen,locale.conf};
	# vim /install/etc/systemd
    # vim /install/etc/vconsole.conf;

>Note: Now is the good time to configure `mkinitcpio.conf`, so that we don't have to come back when we generate
[initrd](https://en.wikipedia.org/wiki/Initial_ramdisk) using `mkinitcpio`. The `HOOKS` line should look like this:

    HOOKS=(base udev autodetect modconf block keyboard zfs filesystems)

### chroot

After you're done editing some template files, now it's time to chroot into our new Arch installation and configure the system as root:

    # arch-chroot /install;

Or run the following commands to prepare the mountpoint if you don't have `arch-chroot`:

    # mount --bind /install /install;
    # mount -t proc /proc proc;
    # mount --make-rslave --rbind /sys sys;
    # mount --make-rslave --rbind /dev dev;
    # mount --make-rslave --rbind /run run;
    # chroot /install;

### Re-mount the filesystem
Mounted directories are often emptied/unmounted after chroot, so we can remount them by issuing **(in this install jail environment)**:

    # mount -a;

or, if you don't have `/etc/fstab` populated yet (you probably should btw):

    # mount -t zfs zroot/enc/default/var /var;
    # mount -t zfs zroot/enc/data/home /home;
    # mount /dev/sdxY /boot;

## Configuring Arch Linux for ZFS-on-root
Now that our partitions are properly mounted to installation directory,
we can begin configuring Arch Linux. I usually do the following steps in
order:

### Initialize `pacman` keys
    # pacman-key --init;
    # pacman-key --populate archlinux;

### Import `archzfs` and `archzfs-kernels` repo's key(s)

If you install Arch on ZFS, you will have to enable `archzfs` and `archzfs-kernels` repositories to avoid upgrade issues. Grab the repo's `keyid` from [Arch Linux Unofficial User Repositories](https://wiki.archlinux.org/index.php/unofficial_user_repositories) (as of last edit it is `F75D9D76`), then import the key by its `keyid`, check its fingerprint, and finally locally sign the key:

    # pacman-key --recv-keys keyid;
    # pacman-key --finger keyid;
    # pacman-key --lsign-key keyid;

### Configure `pacman` and add `archzfs` and `archzfs-kernels` to its repositories

    # vim /etc/pacman.conf;
    # vim /etc/pacman.d/mirrorlist;

Now your repos in `pacman.conf` should look like this:

    [archzfs]
    Server = https://archzfs.com/$repo/x86_64
    [archzfs-kernels]
    Server = https://end.re/$repo/
    ..
    [core]
    [extra]
    ...

After you're done editing `pacman.conf` and `mirrorlist`, update and sync your local package database:

    # pacman -Syyu;

### Install kernel, firmware, and ZFS

Now that we have our package tree synced with `archzfs` and `archzfs-kernels` repositories, we are ready to install [kernel](https://wiki.archlinux.org/index.php/Kernel) and [ZFS](https://wiki.archlinux.org/index.php/ZFS) packages. Unless you choose the kernel-independent `zfs-dkms` package, you will have to match the Linux kernel with the ZFS package. I personally always install the kernel together with `crda` package and CPU microcode so that I will have them right after the next reboot. For selection, most of the time I choose less fancy kernels like the [LTS kernel](https://www.kernel.org/category/releases.html) and pair it with `zfs-dkms`:

    # pacman -Syu crda linux-firmware linux-lts linux-headers zfs-dkms intel-ucode;

or if you really *hate* to build the generic [dkms](https://wiki.archlinux.org/index.php/Dynamic_Kernel_Module_Support) modules, **you can install a certain specific `ZFS` package that matches your kernel**:

    # pacman -Syu crda linux-firmware linux-lts linux-headers zfs-linux-lts intel-ucode;

### Configure the boot partition
#### Populate `/boot`
Now that the system in our `/` is configured, let's set up `/boot` - Re-check `/etc/mkinitcpio.conf` - **To be safe, regenerate the images**:

    # mkinitcpio -P;

This should create our init images at `/boot` with ZFS hooks. Now our "root" part is complete, let's setup the bootloader.

#### Install a bootloader - `systemd-boot` in this case

You can try `grub`, but it was buggy and harder to config for encrypted ZFS root so I opted for `systemd-boot` instead. Note that **`systemd-boot`** is EFI-boot only, which means it can only boot from **ESP** (a FAT32-formatted partition) `/boot` partition

    # bootctl --path=/boot install;

which will create a boot entry with default name "Linux Boot Manager".

If you want custom entry name, try:

    # efibootmgr -v; # to list detailed, numbered boot entries
    # efibootmgr -b $bootnum -B # remove $bootnum entry with '-B'
    # efibootmgr -c\ # create new EFI boot entry
		-d /dev/sdX \ # disk X
		-p Y \ # partition Y
		-l "EFI\systemd\systemd-bootx64.efi" \ # EFI boot file
		-L "CUSTOMNAME"; # EFI entry name

Where X and Y corresponds to your boot partition containing our systemd-boot

#### Configure bootloader:

Create a file for `systemd-boot` in `/boot/loader/entries`. Mine (`zarch.conf`) looks something just like this (omit the line for Intel microcode if you have not installed `intel-ucode` package, and also omit the second options line if you want Bluetooth and webcam enabled):

    title   Arch Linux on encrypted ZFS
    linux   /vmlinuz-linux
    initrd  /intel-ucode.img
    initrd  /initramfs-linux.img
    options zfs=zroot/ROOT/default rw
	options resume=UUID=UUIDofNORMALswap
    options module_blacklist=btusb,bluetooth,uvcvideo

>Please note that as of June 2020, **I could not get Arch (on ZFS root) to "resume" on ZFS VDEVs or LUKS swap partition due to `mkiitcpio` hook conflict**. This may change if the `sd-zfs` is able to decrypt ZFS encryption or if `resume` works as it should (now it is triggered before the pool is decrypted). Standard swap partitions work just fine for hibernation.

>**Also, if you use LTS kernel (or Zen kernel), you will have to append `-lts` (or `-zen`) to `linux` and `initrd` lines accordingly**. After we finished editing `/boot/loader/loader.conf`, our Arch installation should be done and ready to boot. Exit from your chroot, unmount everything, and prepare to reboot. You may also want to turn off your swap partition for smoother reboot:

    # exit;
    # swapoff -a;
    # umount -lf /install;
    # zfs unmount -a;
    # zfs export zroot;

### Now triple check everything. Reboot, and have fun.
When you successfully reboot, and Arch Linux is succesfully initialized, you should be prompted to provide encryption key for `zroot` which will be used for unlocking the encrypted datasets. If all is good, you should next be greeted by a login screen. After successful login and some standard sanity checks, your Arch installation is successful. Note that if you want to have other non-root (i.e. data) zpools imported at boot, you will need to set `cachefile` property of your data pools to `cachefile=/etc/zfs/zpool.cache` and use `systemctl` to enable relevant `systemd` units:

    # zpool set cachefile=/etc/zfs/zpool.cache <pool name>;
    # systemctl enable zfs-import-cache.service zfs-import.target zfs-mount.service zfs.target;

### Importing non-root pool at boot with ZFS root
>**My root pool has `cachefile` property EXPLICITLY DISABLED** for now. Otherwise, I can't get ZFS systemd services to import and mount other zpools.

If you need your system to import other zpool (say, an encrypted data pool *datapool*) at boot, you will need disable your root pool `cachefile` property, and prepare a systemd unit to do `zfs load-key` for our data pool *datapool*. My solution to an encrypted root pool + an encrypted data pool is to let initramfs import and mount the root pool (`cachefile=none`), while the encrypted data pool is to be imported by `zfs-import-cache.service` (`cachefile=/etc/zfs/zpool.cache`) and decrypted+mounted by the custom systemd `zfs-load-key@.service`. My setp-by-step guide to make this to work is:

-   Remove old `/etc/zfs/zpool.cache`:

         # rm /etc/zfs/zpool.cache;

-   And let `zpool set` command recreate the cache file:
      
        # zpool set cachefile=/etc/zfs/zpool.cache datapool;

Now we should see the new cache file if we do:
    
    $ ls /etc/zfs;

-   I usually disable and re-enable the 4 ZFS-related services at this point.

-   Edit and enable `ZFS-load-key@datapool.service`. Note that you should hard-code the pool name within the service - it won't work if you use something like `zfs load-key -a` or `zfs mount -a` in the service. You can copy my template for custom systemd unit [zfs-load-key@datapool.service](https://gitlab.com/artnoi-staple/dotfiles/-/blob/master/linux/arch/systemd/zfs-load-key@.service)

### Caveats
-   **DO NOT forget `rw` kernel parameter for our zroot** in `/boot/loader/entries/*.conf`, otherwise you won't be able to login.

-   **ONLY put ZFS datasets with `mountpoint` set to legacy in `fstab`**.

### Notes
-   As a well-meaning Arch user, **I encourage you to read and follow the steps from the [latest Arch wiki pages on ZFS on root](https://wiki.archlinux.org/index.php/Installing_Arch_Linux_on_ZFS)**. Most of my guides below are based from the Arch wiki, but with my own configuration added. (Because I followed it)

-   **ZFS is heavy on RAM**, so it is not ideal for older computers.

-   The commands used in this tutorial are prepared for most consumer SSDs, and some of the settings (disk or non-disk) are my own preferences

-   You can setup Arch Linux on ZFS differently of course. For example my friend favors the method of first installing Arch Linux on an EXT4 root and then configuring ZFS and migrating to the new root - eliminating the need to do most of the work in `ch-root` environment, but my method minimizes writes to my SSDs by only write once, compressed and encrypted.
    
That's it.
