Aug 18, [2019](/blog/2019/)

Added Btrfs part Mar, [2021](/blog/2021/)
# Encrypted SSD-friendly storge on Linux using Btrfs

## Introduction
Hi guys. I wrote this to help some friends set up encrypted and high performance Linux data storage on SSDs. The building block is the Linux kernel, LUKS (dm-crypt) for encryption, and Btrfs for data storage and snapshots.

> This article is **not about LVM**, whole-disk encryption, and not booting to encrypted root filesystems, [which you can read about here](/cheat/device-mapper/).

This article is written in 2 parts, (1) LUKS on Linux, and (2) Btrfs filesystem

## **LUKS (Linux Unified Key Setup)**
[LUKS](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup:%22) is disk encryption specification for the Linux kernel. It has many use case, e.g. whole disk encryption and partition encryption. Today we are going to do a simple disk encryption on a disk partition.

LUKS by itself is not a filesystem, so this article must mention a filesystem to make it practical for everyday use, and that is why I will mention Btrfs and EXT4, both of which are native Linux filesystems.

## Btrfs
[Btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) is a modern filesystem for the Linux kernel. It is currently in active development, and most people seem to be divided into 3 groups: (1) those who love it, (2) those who hate it, and (3) those who don't care about it. Of all the features Btrfs has, it can not do encryption.

This is why I always think of LUKS when talking about Btrfs, because modern storage should always be encrypted.

## Set up LUKS or [LUKS-on-LVM, or LVM-on-LUKS](/cheat/device-mapper/)  first
### LUKS: prerequisites
The command we need to create and manage LUKS is `cryptsetup`. Most GNU/Linux distributions already ship with `cryptsetup`. You may be able to use your package manager to install it for you if it's not installed.

We will also need a disk partition. Use `fdisk` or `cfdisk` or any partition editor to create disk partitions for our LUKS:

    # fdisk /dev/sdX;

## LUKS Formatting

Use `lsblk` to get block device name for your fresh GPT partition, in my case it is the 4th partition on storage device "*a*", `/dev/sda4`. Then, issue:

    # cryptsetup luksFormat --verify-passphrase -v /dev/sda4;

Note that `cryptsetup` **command is case-sensitive**. You will then be prompted if you are sure to destroy everything on the partition. After typing uppercase YES, you will be prompted for passphrase which will be used as encryption key.

## Opening (decrypting) LUKS partition

Now that our `/dev/sda4` has been encrypted, we can decrypt it using:

    # cryptsetup luksOpen /dev/sda4 myluks;
    
Where `myluks` is our decrypted device name in `/dev/mapper`, i.e. `/dev/sda4` is now decrypted and mapped to `/dev/mapper/myluks`. You can supply any name for mapper device name.

### Creating and mounting the encrypted EXT4 filesystem

This is only required for the first time you set up an encrypted partition, because although we have `/dev/mapper/enc`, it does not have a filesystem yet. We can create an EXT4 filesystem on the device mapper using simple `mkfs` command:

	# mkfs.ext4 /dev/mapper/myluks;
	
Or Btrfs:

    # mkfs.btrfs /dev/mapper/myluks;
    
After the filesystem is created, we mount the device mapper just as you would do with other filesystems:

    # mount /dev/mapper/myluks /mnt;

See also: [More about Device Mapper, LUKS and LVM](/cheat/device-mapper/)

## Btrfs
 Btrfs is a modern filesystem, featuring **Copy-on-Write (CoW)**, **snapshots**, **compression**, **flash storage-friendly**, and many other features. Btfs currently has no encryption support, but we can always use Linux `dm-crypt` to enable encryption on block storage.

When using SSDs with Btrfs, I usually set the following options in `fstab(5)`: `rw,compress=zstd,noatime,discard,ssd,space_cache,..`

To enable encryption, mount the filesystem with option `compress=`*algo* where *algo* is compression algorithm (zstd, zlib, lzo). If you mounted your LUKS-encrypted Btrfs as per the guide above, unmount and mount it again.

An example `mount` command to enable compression is this command with `zstd` algorithm:

    # mount -t btrfs -o compress=zstd /dev/mapper/mybtrfs /mnt;

will compress new data that is written to out Btrfs (existing data is not recompressed).

 This not only improves I/O performance, but also conserves SSD limited write cycles. In addition to that, Btrfs is also aware that the block storage is on SSD, even when on LUKS and LVM, and its behavior changes to work better on SSD.

 This is why Btrfs is my go-to when it comes to root filesystems. Although I still use ZFS for data storage and snapshotting (and [sending snapshots lol](/cheat/zfs/)).

 ZFS command syntax is also much more practical and memorable, which makes using ZFS weirdly intuitive and *fun* - but I digress.

To compress the entire Btrfs filesystem, **first mount the Btrfs partition with `compress=`*algo***, then use `filesystem defragment` command with compression option `-c`*algo*:

    # btrfs filesystem defragment -r -v -czstd;

Will use `zstd(1)` to compress files stored in the Btfs filesystem sitting on `/dev/mapper/mybtrfs` device.

> Note that `zstd` is most recent compression added to Btrfs. My laptop main root partition (which is everything incl. `/home`, but excl. data on ZFS) shrank from 4-ish GB in size to ~1.8GB with zstd compression!

With 2GB root filesystem, my 512GB SSD is going to outlast my computer useful life lol.
