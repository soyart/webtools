<h1>ZFS cheat sheet</h1>
## [Arch Linux installation on ZFS root](/blog/2019/zfsarch/)
Installing Arch Linux on a ZFS root helps with system backup thanks to its copy-on-write snapshot capabilities - and if you are running on old hard disk(s), ZFS ensures that data integrity is not compromised, although at the cost of system resource, especially memory. ZFS snapshots are also effective against ransomware attacks.

## Optimum zpool `ashift` value

> Zpool `ashift` property can only be set during pool creation.

There are two methods to determine the `ashift` value

- (1) first is by focusing on compatibility by always using `ashift=12`

- (2) is to use whatever `ashift` value that match your disk physical sector. Use `fdisk -l` to get your physical sector information.

I usually go with `ahift=12`, despite most of my SSDs being 512-byte.

### Using `ashift=12`
Using `ashift=12` is beneficial because most of the newer hard drives out there have 4096 byte (4K) sector, and 4K sector can hold 512-byte sectors just fine. By using `ashift=12` on 512 byte disk, we can rest assured that we can expand or backup the pool out to 4K disks just fine.

[Arch Wiki](https://wiki.archlinux.org/index.php/ZFS#Advanced_Format_disks) recommends people to always use `ashift=12` for this reason, plus some insight that a "vdev of 512 byte disk will not experience performance issues, but a 4k disk using 512 byte sector will".

### Using `ashift` with value matching disk physical sector size
Use `# fdisk -l` or `$ lsblk -S -o NAME,PHY_SEC` to get the disk physical sector size. After we get the sector size, we can then specify (at the pool creation) `-o ashift=9` for 512 byte sector, `ashift=12` for 4k sector (Advanced Format), and `ashift=13` for 8k sector disk (mostly newer SSDs).

I personally recommend that we use `ashift=12` for compatibility reasons.

## Creating ZFS root for Arch Linux
The command below will create a proper ZPOOL and ZFS datasets for Arch Linux root:

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

## Opening and mounting encrypted ZFS datasets
First we import the pool:

    # zpool import <poolName>;
    # zpool import -a; # All available pools

Then we load the encryption key:

    # zfs load-key <dataset>;
    # zfs load-key -a; # All datasets

And lastly we can mount the opened datasets:

    # zfs mount <dataset>;
    # zfs mount -a; # All datasets

## Renaming ZFS datasets
We can just use `zfs rename` to rename datasets. For example, let's say we have an Arch Linux install on a disk, and we have the following ZFS datasets for use with our Arch installation.

    $ zfs list
    NAME                  USED  AVAIL    REFER  MOUNTPOINT
    mypool                4.58G 236G192K none
    mypool/bak            192K  236G     192K   /bak
    mypool/data           3.29G 236G     3.29G  /mypool
    mypool/cache          1.12G 236G     192K   /mypool/cache
    mypool/cache/makepkg  42.2M 236G     42.2M  /var/cache/makepkg
    mypool/cache/pacman   1.08G 236G     1.08G  /var/cache/pacman
    mypool/go              153M 236G     153M   /home/artnoi/go

But what if we want to install another Void Linux install? That would be bad, since `mypool/go` directory would be mounted on the Void install at `/home/artnoi/go` too! And that may break our Void's and Arch's Go toolchain. To prevent that, we can create a new dataset `mypool/archlinux`, and move relavant datasets to be children of `mypool/archlinux`:

    $ sudo zfs create mypool/archlinux;
	$ sudo zfs rename mypool/cache mypool/archlinux/cache;
	$ sudo zfs rename mypool/go mypool/archlinux/go;
	$
	$ zfs list;
    NAME                           USED  AVAIL REFER MOUNTPOINT
    mypool                         4.58G 236G  192K  none
    mypool/bak                     192K  236G  192K  /bak
    mypool/data                    3.29G 236G  3.29G /mypool
    mypool/archlinux               1.27G 236G  192K  none
    mypool/archlinux/cache         1.12G 236G  192K  /mypool/cache
    mypool/archlinux/cache/makepkg 42.2M 236G  42.2M /var/cache/makepkg
    mypool/archlinux/cache/pacman  1.08G 236G  1.08G /var/cache/pacman
    mypool/archlinux/go            153M  236G  153M  /home/artnoi/go

And now we can configure which datasets to mount with `zfs-mount.service`! On Void, we can totally discard `mypool/archlinux`.

## ZFS snapshots
Creating ZFS snapshot is as easy as:

    # zfs snapshot <dataset@name>;
	# zfs snapshot tank@2020-02-01;

And list them with `-t` (type):

    # zfs list -t snapshot;

### Sending ZFS snapshots
ZFS datasets can be sent and received locally, remotely, or incrementally. See this [Oracle guide for sending/receiving ZFS snapshots](https://docs.oracle.com/cd/E18752_01/html/819-5461/gbchx.html).

Simple dataset can be sent with `send` and received locally with `recv` command:

    # zfs send tank@2020-02-01 | zfs recv bak/tank;

Or sent remotely with `ssh`:

    # zfs send tank@2020-02-01 | ssh mynas zfs recv nas/tank;

Or remotely and incrementally with `-i`:

    # zfs send -i tank@2019 tank@2020 | ssh mynas zfs recv nas/tank;

Same with above, but in *shortcut* form:

    # zfs send -i 2019 tank@2020 | ssh mynas zfs recv nas/tank;

My ZFS datasets are encrypted, so to recursively send the raw snapshot to a backup pool I usually use:

    # zfs send -Rwv tank@2020-02-01 | zfs recv -Fv bak/tank;

Note that you can omit `-v` option if you don't want verbose output.
For incremental sending (the recipient pool already contains the base
snapshot):

    # zfs send -Rwvi tank@2020-02-01 tank@2020-02-20 | zfs recv -Fv bak/tank;

## Resizing ZVOL

    # zfs set volsize=4G <dataset>;

## Attaching a storage device to ZPOOL (mirroring)
According to [Orcale's
guide](https://docs.oracle.com/cd/E19253-01/819-5461/gazgw/index.html),
we can add a device to a `zpool` to create a mirror with:

    # zpool attach zeepool <device0> <device1>;
    # zpool attach zeepool sda3 nvme0n1p3;

Or, on Arch Linux where they recommend that you use `/dev/disk-by-id` for persistent storage naming:

    # zpool attach zeepool /dev/disk/by-id/disk0 /dev/disk/by-id/disk1;

After attaching, the magic of ZFS resilvering should mirror (clone) your pool to the new drive. Now that the pool is two-way mirrored, attaching one more device to the pool should create a three-way mirrored pool, and it goes on and on (Note that this won't create a RAID-Z or anything else - just mirrors).

## Sharing ZFS datasets with NFS
> On Arch Linux, install `nfsutils`

NFS sharing of ZFS datasets can be toggled on/off with property `sharenfs`. Just use `zfs set sharenfs` to configure NFS share on ZFS.

Default share:

    # zfs set sharenfs=on tank/mydataset;

NFS share with permissions:

    # zfs set sharenfs="rw=@10.2.0.0/24,ro=@10.3.0.0/24";

This will enable NFS share with read/write permission for 10.2.0.0/24 network, and read-only permission with 10.3.0.0/24 network.
