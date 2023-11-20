Nov 20, [2023](/blog/2023/)

# Introducing ALI and ali-rs

[ALI](https://github.com/soyart/ali) is my latest big project,
arising from my itch to create something like cloud-init but
with very focused goals in mind.

The result is a somewhat small but very simple mechanism
for preparing a new Arch Linux system. ALI was first meant
to be a big web of shell scripts, but later evolved to just
a declarative YAML specification.

It is designed based on my own experience of maintaining
Arch Linux systems as hobby and at my previous job.

While cloud-init is more fully-featured, it can be an overkill
for personal use, and the feedback we get from applying
the changes with cloud-init is not instant - you'd need
to reboot to re-apply cloud-init manifests.

[ali-rs](https://github.com/soyart/ali-rs) is the reference
implementation for ALI, with manifest validation and other
features aimed at simplifying and standardizing Arch Linux installations.

Users can use ALI and ali-rs to create somewhat reproducible
Arch Linux systems.

## ALI vs cloud-init or autoinstall

**The most clear difference between ALI and cloud-init is that
ALI is just a YAML specification**, while cloud-init is a full-fledged
platform for configuring Linux machines for the cloud and come
with its own set of mostly Python tools.

Unlike cloud-init and autoinstall, ALI does not aim to
always create a full, bootable system. Parts of the declaration
can be omitted, and ALI can be used to just bootstrap a new
chroot environment.

This allows ALI users to use ALI to create an Arch Linux system
anywhere, on a real disk with a bootloader, or as chroot mountpoints.

Users can even just use ALI to partition their disks for them,
while the users perform the actual installation.

Or users can manually partition the disks before using ALI to
populate/configure the systems.

Another difference is that cloud-init is run at boot time,
right before the system fully boots, while ALI, as a standard,
does not have this limitation.

## ali-rs

After the spec is published, I began working on the implementation.
[ali-rs](https://github.com/soyart/ali-rs) is that implementation,
written in Rust because [I wanted to learn the language](/blog/2023/try-rust/).

This implementation is a single binary Rust program,
and it fully supports all of ALI features.

ali-rs is currently 70-80% done, with all of ALI features implemented
but not yet completely tested. I occasionally use it to install
Arch Linux to new Vultr VPS.

ali-rs has manifest validation built-in and enabled by default,
which means that, if there's no bug, ali-rs would never wipe your
data on existing block devices. This makes it safe to use on
non-clean slate scenarios.

In addition to arbitary shell commands, ali-rs also features its own
sub-language called [hooks](https://github.com/soyart/ali-rs/blob/master/HOOKS.md),
which are just simple text interface for configuring Arch Linux systems
in an opinionated way. This means that even though ALI does not have
boot features, users still have the means to provide bootloader
configuration programmatically via shell scripts or ali-rs hooks.

