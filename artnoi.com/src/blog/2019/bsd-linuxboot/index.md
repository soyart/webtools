Aug 3, [2019](/blog/2019/)

# FreeBSD 12.0: EFI dual-boot with GNU/Linux

The FreeBSD installation using the live installer was easy and smooth, except the disk partition part where I decided not to create an EFI partition for FreeBSD, because I hated having 2 EFI partitions on the same disk.

The trick here is to to copy EFI boot program `BOOTx64.efi` (i.e. from the live USB) to the existing EFI partition on my disk, and then use other system's `grub2` to automatically detect the EFI boot program and create a boot entry for our FreeBSD.

So we will use an existing Linux system that you want to dual-boot FreeBSD with to copy the EFI file to the EFI partition, the destination path in the FAT32 partition should be `\EFI\FreeBSD\BOOTx64.efi`.

> As of writing this blog post, I was using Manjaro Linux, which mounts its EFI partition under `/boot/efi`, so I copied `BOOTx64.efi` to `/boot/efi/EFI/FreeBSD/BOOTx64.efi`.

Then I edited the `40_custom` file in `/etc/grub.d` to look something like:

```
# [ /etc/grub.d/40_custom ]

# FreeBSD was installed without creating its own FAT32 EFI partition
# The EFI boot file in this case is located on disk 0, GPT partition 4
# The FreeBSD root filesystem is UFS

menuentry "FreeBSD" --class freebsd --class bsd --class os {
 insmod bsd
 insmod ufs2
 chainloader (hd0,gpt4)/EFI/FreeBSD/BOOTx64.efi
}
```

Then, update `grub` configuration file (on Arch Linux) with:

```shell
sudo update-grub;
```

Manjaro-shipped `grub` should detect FreeBSD installation as 'unknown Linux distrobution'. Then reboot, and your `grub` menu should now present you with an entry for FreeBSD.

> Note: this was written back in 2019 and may no longer be relevant.
