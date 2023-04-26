Mar 5, [2021](/blog/2021/)

<H1>Using Btrfs as root filesystem</H1>
> Jump to [conversion and usage guide](#guide)

Hi guys, today I'll be selling you why you should use [Btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) as your root filesystem, especially if you use SSDs.

By using Btrfs technologies like **Copy-on-Write** and **compression**, we can improve I/O performace as well as minimize write cycles on SSDs.

> With `zstd` compression on Btrfs, my laptop root filesystem shrank from ~4-5GB in size to ~1.7GB.

And if you use Btrfs on top of some encryption scheme like [LUKS](/cheat/device-mapper/), compressed filesystem data is smaller, so encryption performance overhead should also gets smaller.

## Why Btrfs

Apart from CoW, Btrfs also features compression, with support for multiple compression algorithms (`lzo`, `zlib`, and newer `zstd`). Compression improves I/O performance at the cost of CPU time.

> Btrfs is beneficial for SSD users; it minimizes writes and improves I/O speed thanks to CoW and compression.

To use Btrfs, we need userspace utilities `btrfs` and other Btrfs programs. On Arch Linux, they are packaged into `btrfs-programs`.

## Why not ZFS?

Because of ZFS license incompatibility with Linux's GPLv2, [installing root on ZFS is tiring](/blog/2019/zfsarch/), especially when the only bootable Linux system you have is a live USB.

So I was looking for a Linux-native ZFS replacement, that has support for [Copy-on-Write](https://en.wikipedia.org/wiki/Copy-on-write), [snapshots](<https://en.wikipedia.org/wiki/Snapshot_(computer_storage)>), [logical volume management](https://en.wikipedia.org/wiki/Logical_volume_management), [transparent disk encryption](https://en.wikipedia.org/wiki/Full_disk_encryption), and transparent compression as my new root filesystem.

# Btrfs vs ZFS

ZFS originally came from Sun, and Btrfs from Oracle (who ultimately took over Sun). Btrfs is more modern, and Linux-centric, so it can be better integrated into many Linux distros.

In fact, once it is stable enough, Btrfs may eventually replace EXT4 as default root filesystems for many Linux distributions.

Although Btrfs is developed for many hardware architecture, being a native Linux filesystem, it did not have much support on non-Linux operating systems, unlike ZFS which run on some BSDs and macOS.

The command syntax for Btrfs userspace utilities also kinda sucks compared to ZFS `zpool` and `zfs`. ZFS memorable, concise syntax is what makes administering storage a fun thing to do.

Because of the reasons above, I'll continue using ZFS for data storage, but converted my EXT4 roots to Btrfs to get better I/O performance and prolong my SSD useful life.

> TLDR; Btrfs does not replace ZFS for storage, but does fit better as Linux root filesystem.

# Getting started with Btrfs

Btrfs has been included in the Linux kernel for a long ass time, so you can just install the userspace utilities `btrfs-progs` in order to use Btrfs on Linux systems. `btrfs-progs` includes tools that we are going to use later in this page like

- `btrfs-convert(8)` to convert EXT2-4 and ReiserFS to Btrfs - we will use this program to convert our old root FS.

- `btrfs-filesystem(8)` obviously, to manage the filesystem - we will use this to defrag, i.e. compress existing data after conversion.

- `btrfs-subvolume(8)` obviously, to manage Btrfs subvolume - we will use this to delete the old EXT2 backup subvolume created by `btrfs-convert`

There are many other tools that I already use a lot, like

- `btrfs-balance(8)` to balance the FS across devices

- `btrfs-device(8)` to manage devices

- `btrfs-check(8)` to check off-line filesystem

- `btrfs-send(8)` to send Btrfs subvolume

## <a name="guide"></a>Converting old EXT4 root to Btrfs

The EXT4 root filesystem must _not_ be mounted when being converted, so we must boot from other system _if_ that EXT4 root is the only bootable root filesystem on the device.

> Most live installers ship with `btrfs-convert` program that we will use, so you may just boot from any live ISOs to perform FS conversion.

If you have multiple root filesystems that you can boot to to convert the target filesystem, make sure that the alternative root has userspace utilities for Btrfs installed. On Arch Linux, the package name is `btrfs-progs`.

> Backup all data first, bc why not?

Now that you have `btrfs-progs`, convert EXT4 to Btrfs with `btrfs-convert`:

```shell
btrfs-convert <BLOCK_DEV_PATH>;
```

Test mounting the converted Btrfs filsystem and determine if the conversion went cleanly.

If it went well, you can safely destroy the backup EXT2 subvolume `/ext2_saved` with `subvolume delete`:

```shell
btrfs subvolume delete /ext2_saved;
```

## Booting into Btrfs root

Btrfs is not supported by `fsck(8)`, so you may want to embed `btrfs` binary to perform filesystem check during boot. On Arch Linux, simply add this `BINARIES` line in `mkinitcpio.conf(5)`:

```shell
BINARIES=('/usr/bin/btrfs')
```

And `fsck` hook may be removed in `HOOKS` section.

Because Btrfs is native to Linux, booting Linux into Btrfs root is easy, and nowhere near as tricky as booting to ZFS.

> I'm not sure about this, but it seems to be the case - if you used `sd-encrypt` hook for LUKS with a key file in a separate partition (like a USB flash drive), that separate partition must have matching filesystem with your root (Btrfs).

### Btrfs compression

Mounting Btrfs with option `compress=`_alg_ will enable [transparent file compression](https://btrfs.wiki.kernel.org/index.php/Compression) on that filesystem.

In my experience, `zstd` works _best_; the root filesystem shrank from ~4-5GB to ~1.7GB.

`zstd` is new compression algo originally developed at Facebook. Facebook also uses Btrfs and `zstd` extensively in their data centers.

Mounting with `zstd` compress option:

```shell
mount -o compress=zstd <DEVICE> <MOUNTPOINT>;
```

Note that only new files written after mounting with `compress=`_alg_ will be compressed. To compress the whole (previously uncompressed) filesystem with `zstd`, use `filesystem defragment -czstd` command:

```shell
btrfs filesystem defragment -r -v -czstd <MOUNTPOINT>;
```

This should rewrites the blocks with `zstd` compression enabled.

After the compression processes, we can use `compsize(8)` to view compression ratio (an equivalent `$ zfs get ratio;`):

```shell
compsize -x <mountpoint>;
```

This is the `compsize(8)` output for my laptop Btrfs root:

```
# compsize -x /;
Processed 92883 files, 56460 regular extents (58681 refs), 55854 inline.
Type       Perc     Disk Usage   Uncompressed Referenced
TOTAL       40%      1.5G         3.8G         4.1G
none       100%      332M         332M         367M
zstd        35%      1.2G         3.5G         3.8G
prealloc   100%      9.9M         9.9M          10M
```

### fstab(5) entry for Btrfs on SSD

This is my `fstab(5)` option for Btrfs root on SSD:

```
rw,compress=zstd,noatime,discard=async,ssd,space_cache,subvolid=5,subvol=/
```

## Labelling Btrfs

You can rename (label) your Btrfs root with `btrfs filesystem label`:

```
# btrfs filesystem label <mountpoint> <newlabel>;
```

Or, if it's unmounted:

```
# btrfs filesystem label <device> <newlabel>;
```

## Btrfs snapshots

In Btrfs, a snapshot is a subvolume sharing data with other subvolume using Btrfs Copy-on-Write technology.

Create a Btrfs CoW snapshot with:

```shell
btrfs subvolume snapshot <SRC> <DST/NAME>;
```

Example: a read-only (`-r`) snapshot taken from root subvolume `/` stored at `/rootbak`:

```shell
btrfs subvolume snapshot -r / /rootbak;
```

[Just like ZFS snapshots](/cheat/zfs/), Btrfs snapshots can be sent and received. However, **only read-only Btrfs snapshots** can be sent and received.

To send a snapshot, use `send` command. For example, sending and receiving snapshots locally on the same computer:

```shell
btrfs send /rootbak | btrfs receive /backup;
```

Also just like ZFS, Btrfs can also send incremental snapshots (with `-p` _parent_):

```shell
btrfs send -p /rootbak /rootbak_new | btrfs receive /backup;
```

## Disabling Copy-on-Write

To disable CoW for new files, use mount option `nodatacow`. This will disable CoW and compression, albeit only for new files.

To disable CoW on specific files or directories, add `C` to their attributes:

> Note that on Btrfs you should only perform this on empty directories. You have been warned.

```shell
chattr +C <path>;
```

That's it frens, good luck!
