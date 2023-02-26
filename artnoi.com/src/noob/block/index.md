# Block data storage

## Memory?

> FYI: Volatile memory means that the device loses data the exact moment power is removed (i.e. turned off), while non-volatile (persistent) memory refers to those devices capable of retaining data after power is removed. Example of volatile memory is RAM, and one for non-volatile memory is an SD card.

When we talk about [computer memory](https://en.wikipedia.org/wiki/Computer_memory) or storage, we must be specific, since terms are just so ambiguous in computers.

Memory can mean volatile memory like RAM, or non-volatile (persistent) but read-only like ROM, and storage could just mean how to store your smoking hot computers in summer.

This page is about non-volatile computer memory, which is likely the memory whose size is largest in your systems. It is where you keep your persistent data, i.e. save files.

Before you begin, keep in mind that everything in computers is an abstraction - with files being top-most, and the actual hardware being in the lowest bottom.

> Command examples are not provided here, look for it instead in the main [Linux newbie guide page](/noob/).

## Disk, partition, and filesystem (Linux-centric)

### General use

In general, we first partition the disk (using `fdisk` or equivalents), then create a filesystem on the partition. We then mount the filesystem to our mountpoint, and read/write files from that mountpoint.

Most consumer operating systems (macOS, Windows) automatically detect new block devices and partitions, and mount the filesystems on them automatically, and that's why most people have no idea about mounting filesystems.

### Disk

A _disk_ (and other storage devices) is hardware with which we store our data, usually files. The storage devices store data in blocks (sectors), hence the name _block device_.

On Linux systems, `lsblk` lists the block device names. We can _read_ data from block devices, as well as _write_ data to them directly, like when we use `dd` to write (i.e. _flashing_ or _burning_) a distro install `iso` image to a flash drive. We can also wipe the disk entirely by writing zeroes or random data to it.

But to store data as files on disks in a sane manner, that is, for the files to be conveniently read and written, we need partitions and filesystems.

> Block devices can be found as device files in `/dev`, e.g. `/dev/sda`, `/dev/nvme0n1`, `/dev/mmcblk0`.

### Partition

Partitioning is division of the blocks on a disk into smaller ones for flexibility and manageability. Each partition can have its own separate _filesystem_, which can be _mounted_ separately.

Think of disks as one large grid of empty space. We can _partition_ that giant space into smaller ones, then allocate these divisions for their specific use, and then use the different partitions separately.

Partitions, just like block devices, can be found in `/dev`, e.g. `/dev/sda1`, `/dev/nvme0n1p1`, `/dev/mmcblk0p1`.

### (Optional) Logical volume/ Device mapper

Other than using physical partitions, we can logically manage the disks/partitions into _logical_ partitions.

Usually, these _logical volumes_ are managed by a logical volume manager, e.g. LVM in the Linux kernel, and Core Storage in Apple systems.

These block device virtualization techniques are very useful if you can figure out how to use it, and they also keep our physical partition tables clean and less likely to be re-partitioned which risks losing data.

> In Linux systems, LVM works as a framework under [device mapper](https://en.wikipedia.org/wiki/Device_mapper), and so can be found in `/dev/mapper`, e.g. `/dev/mapper/cryptroot`, `/dev/mapper/WDBlue-raid`

### Filesystem

Filesystem can be ambiguous, as it commonly refers to both the programs used to read/write files, and the on-disk format of data organization used by such filesystem programs.

For example, `EXT4` refer to both the software responsible for handling `EXT4` formatted disk, and also the actual data stored in `EXT4` format on the disk.

To store and read files, the operating systems uses special programs (usually run in kernel space) called filesystems to deal with the files.

These filesystems read and write files for the OS, and the OS abstracts the filesystem layer for other programs when they need to read or write files.

So all the other programs see is files, not the disks or other lower-level abstraction.

Each filesystem programs manage files differently (i.e. each has different on-disk layout, or _format_), although some of them are compatible with one another, as in the case of `EXT` family of filesystems in the Linux kernel.

The filesystems keep track of everything - what files is stored on what blocks, time each file is last written/read, as well as other metadata, like [journals](https://en.wikipedia.org/wiki/Journaling_file_system) and [checksums](https://en.wikipedia.org/wiki/Checksum) for additional data integrity.

Examples of filesystems include `EXT2`, `EXT3`, `EXT4`, `HFS+`, `NTFS`, `XFS`, `ZFS`. Some filesystems (e.g. `ZFS` and `Btrfs`) have logical volume manager built-in.

Due to the role it plays in the operating systems stack (abstracting low-level block layer to higher-level file layer), almost all filesystems run inside the kernel. This is why once the filesystem is mounted, no one (not even the user programs) cares about it in consumer operating systems.

However, if you need high-tech features (compression, encryption), or want to fine-tune performance or redundancy, then you should care very much about the filesystem.

### Mounting the filesystem

To use the filesystems, or to be able to read/write files, the OS will have to mount the filesystems. For example, mounting an `EXT4` filesystem on partition `/dev/sda4` means that the OS is using a program called `EXT4` to handle the `EXT4`-formatted data on `/dev/sda4`, thus providing access to the files in the filesystem.

This is why you usually can't mess with the FS, e.g. using `fsck`, or resizing the FS when the FS is mounted. It is because the filesystem program is actively handling the partition - altering it is not possible on most filesystems, although some modern filesystems like `Btrfs` and `ZFS` can do this.

When you mount a filesystem to a mountpoint, its files is available for access at the mountpoint. For example, if I have mounted a filesystem on my flash drive at `/mnt`, I can now access its files at `/mnt`. Doing `$ ls /mnt;` will list the files contained in the filesystem of the flash drive.

**Filesystems must be mounted** first before users and other programs can _read or write a file in a filesystem_ (as opposed to working on raw block storage like `dd` and `dump`). In UNIX-like systems, the `mount` program and `fstab` works together to mount system partitions at boot time.

### fstab

In simplest terms, `fstab` is a text file containing each _entry_ of filesystem mounts in a line. Each line has 7 fields, and all 7 fields must be specified otherwise the mount fails. [Here is what I think is a good guide](https://wiki.archlinux.org/index.php/Fstab) to (Arch) Linux `fstab`. I always recommend using UUID for [persistent block device naming](https://wiki.archlinux.org/index.php/Persistent_block_device_naming).

`fstab` is the first file I learned to _master_ on UNIX-like systems. It caused headaches, especially boot problems during my early UNIX days as I broke the file by copy-pasting random lines from Google results. In short, **one must master `fstab`**.

> For partitions that are not required to boot, adding `nofail` and `noauto` in the mount options is sometimes recommended to avoid boot failure if such partitions are not available at boot time.

## Why use filesystem instead of writing raw data

Operating systems manages various I/O services for user applicatons, and file storage is one of them. If the OS does not use a filesystem, all user programs must include functions that provide file read/write access. This is where filesystems come in handy - it helps abstract the file layer in our storage stack. The filesystem works together with the [block device](/cheat/noob/block/) driver, usually within the kernel, to provide safe, uniform file read/write access for user programs.

## My recommended filesystems

When deciding filesystems to use, my criteria usually includes:

### Specific requirement

For example, some scenarios require a specific type of FS. One example is the ESP, or the EFI System Partition, which must always be formatted in `FAT`.

### Data integrity

Since FS is what keeps our data safe (as files), we usually don't want it to break. Some great FS also talks with hardware to ensure the spinning rust doesn't fuck up. My top pick for data integrity is `ZFS`, and with its flexible VDEV configuration, I would say it is bulletproof FS. It's called the billion-dollar filesystem after all, y'all!?

### Native support

Having native support for your filesystem guarantees a smooth experience. Examples of native FS on Linux are `EXT4`, and `Btrfs`, while there are `FAT`, `exFAT`, and `NTFS` for the Windows camp.

### Features

Built-in compression, encryption, or journaling can be helpful if you have a particular scenario in mind. I usually end up preferring newer filesystems like ZFS or Btrfs because they have copy-on-Write, friendliness to flash storage, and compression. Some filesystems also include built-in volume manager, which gives huge flexibility in data storage.

My top pick for FS with best features is ZFS, because it does so with minimum risks of losing data as evidence by the test of time.
