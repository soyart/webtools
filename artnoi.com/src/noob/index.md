# Cheat sheet for n00bs

[Other cheat sheets](#others) are also available

## UNIX manual pages (`man(1)` pages)
It is best to first read the manual with `man(1)`. See also: [usage](https://en.wikipedia.org/wiki/Man_page#Command_usage).

#### Arch Linux `man(1)` pages
Arch Linux's `base` metapackage by default does not ship with `man(1)`,
although the package manual pages are already packaged and installed on the system by `pacman`.

To use `man(1)`, install `man-db` packages:

```shell
pacman -S man-db;
man ls; # see manual pages for ls(1)
```

## Users and groups

### Changing one's own password

```shell
passwd <USERNAME>;
```

You can put your own `username` or you can just omit it.

### Changing other user's password

```shell
passwd <USERNAME>;
```

### Switching user (with new user's password)

```shell
su <USERNAME>;
```

`su` defaults to root user and will ask for the root password, i.e. if `<USERNAME>` is not specified.

### Switching to root using `sudo(8)` (using `sudo` requires the admin user's password, not root password)

```shell
sudo -i;
```

## Files and permissions

### Using `ls(1)` to print a 'long' (detailed) output

```shell
ls -l;
```

### Changing permissions (or 'modes') with `chmod(1)`

```shell
chown <OWNER>:<GROUP> <PATH>;
```

### Changing file permissions

```shell
chmod <MODE> <PATH>;
```

> Hint: Use `-R` option to use `chmod(1)` or `chown(1)` recursively: `# chown -R artnoi:artnoi /home/artnoi/Downloads`

Note that the modes can be either

1.  [Numerical](https://www.cyberciti.biz/faq/unix-linux-bsd-chmod-numeric-permissions-notation-command) which can be [calculated](https://chmod-calculator.com) or memorized easily (e.g. `600` for private files, `755` for normal files)
2.  `drwxrwxrwx` = directory(`d`) + user(`rwx`) + group(`rwx`) + others(`rwx`)

### Examples: changing file permission with `chmod(1)`

Adding _execute_ permission to file `foo`

```shell
chmod +x foo;
```

Removing _write_ permission to file `foo`

```shell
chmod -w foo;
```

Adding _write_ permission to all files in directory `bar`

```shell
chmod -R +w bar;
```

Adding _read and wite_ permission to all files in directory `bar` **for owner's 'group' members**

```shell
chmod -R g+rw bar;
```

Removing _write, read, and execute_ permission to all files in directory `bar` **for 'others' (world)**

```shell
chmod -R o-rwx bar;
```

## Arch Linux package management

> See also: [manual for `pacman(8)`](https://man.archlinux.org/man/pacman.8)

Arch Linux official package manager is `pacman(8)`.
The program has a few majors operations, namely `-S` (`--sync`) for syncing from the repos,
`-Q` for querying the local database, `-R` (`--remove`) for removing packages,
and `-D` (`--database`) for database operation.

These major operations, when used in shortened forms, are in uppercase.

### Searching and querying package info

#### Searching for packages using regexp (`-s`, or `--search`)

Search option will use the [regular expression](https://en.wikipedia.org/wiki/Regular_expression) to search for packages. `-S` means that `pacman` will search on the repos, while `-Q` will make it search the local database.

```shell
pacman -Ss tmux; # search mirrors
pacman -Qs tmux; # search local db
```

#### Getting package information (`-i`, or `--info`)

Note that `-i` option will use **exact match** (not regexp) to find the package information.

```shell
pacman -Si tmux;
pacman -Qi tmux;
```

#### Listing all files from packages

```shell
pacman -Ql tmux;
```

### Completely removing a package

```shell
pacman -Rns <PACKAGE>;
```

### Syncing package database and upgrade

```shell
pacman -Syyu;
```

(Note the double 'y') This may be done after switching repos, i.e. from Thai servers to Korean ones.

### Configuring `pacman.conf(5)`

`pacman`'s main configuration file is stored in `/etc/pacman.conf`, with additional configuration files in `/etc/pacman.d` directory. One file that we may want to edit a little bit often is `/etc/pacman.d/mirrorlist` which stores information about repo servers.

### Getting block device information

The commands below can be used to view block device information. `blkid` needs root privilege though.

```shell
lsblk <DEVICE>;    # Standard lsblk output
lsblk -f <DEVICE>; # More detailed output
blkid <DEVICE>;    # Equivalent to lsblk -f, but needs privilege
```

Note that if you specify `<DEVICE>`, `lsblk(8)` and `blkid(8)` will only display information related to the specified device. In other words, omit `<DEVICE>` to get information from all block devices. Another note is that block devices can be both:

1.  Normal block devices - which can be found in `/dev/`, and usually in _sda, sdb2, vda, vdb1, mmcblk0, mmcblk0p3_ formats
2.  Device mapper - which can be found in `/dev/mapper`

### Editting normal block device partitions

```shell
fdisk <DEVICE>;
cfdisk <DEVICE>;
```

For logical volume, please see `lvm(8)` man pages.

### Mounting/unmounting filesystem

Mounting is done with `mount(1)`:

```shell
mount <DEVICE> <MOUNTPOINT>;
```

Unmounting is done with `umount(1)`, and only the source device or mountpoint is needed:

```shell
umount <DEVICE>;
umount <MOUNTPOINT>;
```

### Creating (formatting) LUKS device

```shell
cryptsetup luksFormat <DEVICE>;
```

### Openning (unlocking) LUKS device

```shell
cryptsetup luksOpen <DEVICE> <NAME>;
cryptsetup luksOpen <DEVICE> <NAME> --key-file <PATH>;
```

Now, your dm-crypt device should be available at `/dev/mapper/<NAME>`

### Creating filesystem with mkfs(8)

A coresponding `mkfs`._type_ utility is used to create a filesystem on Linux.

**EXT4**

```shell
mkfs.ext4 <DEVICE>;
```

**EXT4 with no journal (lighter on systems)**

```shell
mkfs.ext4 -O "^has_journal" <DEVICE>;
```

**FAT32 (using FAT)**

```shell
mkfs.fat -F32 <DEVICE>;
```

**FAT32 (using VFAT)**

```shell
mkfs.vfat -F32 <DEVICE>;
```

Example - Creating and mounting a LUKS-encrypted EXT4 filesystem on partition `/dev/vda3`:

```shell
cryptsetup luksFormat /dev/vda3;
cryptsetup luksOpen /dev/vda3 foo;
mkfs.ext4 /dev/mapper/foo;
mount /dev/mapper/foo /mnt;
```

### EXT4 defrag (HDD)

Use `e4defrag(8)` to defrag an _EXT4 filesystem on a hard disk drive_ on-line. Note that You need root privileges to defrag system files

### Disk tuning

#### SSD TRIM

`fstrim(8)` can be used to _trim_ (i.e. discard) unused blocks on solid-state storage. The discard potentially has some benefits as it may prolong SSD lifespan and increases performance on disks that are almost full. Only SSDs should be trimmed.

#### EXT2, EXT3, EXT4 filesystem setting

> The EXT2-4 family of filesystems has been a staple in the Linux kernel for decades. Its most recent member, EXT4, is still very prevalent in desktop Linux users who usually like the fact that it made specifically for their kernels. EXT4 is stable, reliable, and well supported, although its lack of other modern features like compression, encryption, etc has led me to skip using it on my computers for some years now.

Use `tune2fs(8)` to configure EXT2, EXT3, and EXT4 filesystems. For example, `# tune2fs -O "^has_journal" /dev/mapper/crypt-home` will disable journaling on a EXT4 filesystem residing on block device `/dev/mapper/crypt-home`.

#### ZFS

> ZFS is the _last word_ in filesystems. It was originally developed by Sun (Oracle), and is one of the most incredible filesystem in many ways. It can do **Copy-on-Write**, **snapshots**, **compression**, **encryption**, **volume management (i.e. software RAID)**, and many other amazing things to ensure your data is safe.

Due to its incompatible license, ZFS was not included in the Linux kernel. Instead, a separate ZFS Linux kernel module is usually used to provide ZFS on Linux computers.

#### Using zfs(8) and zpool(8).

Use `zfs set` and `zpool set` to configure ZFS storage. Also, see [this cheat sheet](/cheat/zfs/).

### Btrfs

> Btrfs is yet another featureful filesystem, featuring **Copy-on-Write (CoW)**, **snapshots**, **compression**, **volume management**, and many other features. Btfs currently has no encryption support, but we can always use Linux `dm-crypt` to enable encryption on block storage.

See this [blog post for Btrfs](/blog/2021/btrfs/)

### fstab(5)

In simplest terms, `fstab(5)` is a text file containing each _entry_ of filesystem mounts in a line. Each line has 7 fields, and all 7 fields must be specified otherwise the mount fails. [Here is what I think is a good guide](https://wiki.archlinux.org/index.php/Fstab) to (Arch) Linux `fstab`. I always recommend using UUID for [persistent block device naming](https://wiki.archlinux.org/index.php/Persistent_block_device_naming).

> For partitions that are not required to boot, adding `nofail` and `noauto` in the mount options is sometimes recommended to avoid boot failure if such partitions are not available at boot time.

### Basic SQL

Below is an SQL snippet for beginners

```sql
DROP TABLE orders;
DROP TABLE products;
DROP TABLE customers;

CREATE TABLE customers (
    id INT NOT NULL AUTO_INCREMENT,
    lname VARCHAR(255) NOT NULL,
    fname VARCHAR(255),
    city VARCHAR(255) DEFAULT "bkk",
    CONSTRAINT id_lname_unique UNIQUE(id, lname),
    PRIMARY KEY (id)
);

CREATE TABLE products (
    id INT NOT NULL AUTO_INCREMENT,
    pname VARCHAR(255),
    price INT NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE orders (
    id INT NOT NULL AUTO_INCREMENT,
    cust_id INT,
    prod_id INT,
    PRIMARY KEY (id),
    FOREIGN KEY (cust_id) REFERENCES customers(id),
    FOREIGN KEY (prod_id) REFERENCES products(id)
);

INSERT INTO customers (id, fname, lname, city) VALUES (1, "Artnoi", "Phan", "bkk");
INSERT INTO customers (id, fname, lname) VALUES (2, "Prem", "Phan");
INSERT INTO customers (fname, lname) VALUES ("Palita", "Phan");
INSERT INTO products (pname, price) VALUES ("ThinkPad", 30000);
INSERT INTO products (pname, price) VALUES ("ThinkCentre", 20000);
INSERT INTO products (pname, price) VALUES ("ThinkStaion", 40000);
INSERT INTO orders (id, cust_id, prod_id) VALUES (1, 1, 1);
INSERT INTO orders (cust_id, prod_id) VALUES (1, 2);
INSERT INTO orders (cust_id, prod_id) VALUES (1, 3);
INSERT INTO orders (cust_id, prod_id) VALUES (2, 2);

# Most expensive product
SELECT P.pname FROM products P where P.price = (SELECT max(price) FROM products);

# All customers who have ordered something
SELECT O.id AS order_id, C.id, fname, P.pname, P.price FROM customers C RIGHT JOIN orders O on C.id = O.cust_id LEFT JOIN products P ON O.prod_id = P.id;

# All customers who have bought ALL 3 products
SELECT C.id AS Cust_ID, C.fname AS Cust_name, sum(P.price) AS Total FROM customers C, products P
WHERE C.id IN
(SELECT DISTINCT C.id FROM customers C RIGHT JOIN orders O on C.id = O.cust_id LEFT JOIN products P ON O.prod_id = P.id WHERE P.id = 1)
AND C.id IN
(SELECT DISTINCT C.id FROM customers C RIGHT JOIN orders O on C.id = O.cust_id LEFT JOIN products P ON O.prod_id = P.id WHERE P.id = 2)
AND C.id IN
(SELECT DISTINCT C.id FROM customers C RIGHT JOIN orders O on C.id = O.cust_id LEFT JOIN products P ON O.prod_id = P.id WHERE P.id = 3);
```

## <a name="others"></a>

[Arch Linux cheat sheet](/cheat/arch/)  
[Arch Linux ZFS root](/blog/2019/zfsarch.html)  
[ZFS cheat sheet](/cheat/zfs/)  
[Device Mapper - LUKS and LVM](/cheat/device-mapper/)  
[Git cheat sheet](/cheat/git/)

[Storage (disks, etc.)](/noob/block/)  
[Booting the computer](/noob/boot/)  
[Minimal UNIX desktop](/noob/desktop/)  
[Vim for noobs](/noob/vim/)
