# Arch Linux cheat sheet
## Pacman
Listing explicitly installed packages

	$ pacman -Qqe;  # Any marked explicitly installed
    $ pacman -Qqen; # Native only (non-AUR)

Listing explicitly installed AUR packages

    $ pacman -Qqem;

Marking a package as explicitly installed, or as dependencies

    $ pacman -D --asexplicit <package> [..packages];
    $ pacman -D --asdeps <package> [..packages];

## Broken Pacman
When `pacman(8)` is broken, either by partial upgrades or mirror errors, and you don't have a spare USB flash drive for the boot ISO, you can manually install `.zst` packages to *temporarily* fix broken dependencies. And no, this is not `pacman -U`, and did not involve the Arch Linux Archive.

In this example, package `glibc` wasn't upgraded properly, so `libalpm` breaks (lib Arch Linux Pacman) now that its run-time dependencies are missing. To get `pacman` back to working in this case, untar `glibc` from package cache (defaults to `/var/cache/pacman/pkg`) to system root:

> Omit `-w` if you don't want interactive prompt for every file.

    $ tar -xvpwf glibc-xxx.tar.zst -C / --exclude '.PKGINFO' --exclude '.INSTALL' --exclude '.MTREE' --exclude '.BUILDINFO';

This will extract `glibc-xxx.zst` to root, and hopefully fixes `pacman` at runtime. If there are more breakages, you may want to repeat the process until you satisfy *all* of `pacman`'s dependencies.

You can use a healthy Arch system to see full `pacman` depedencies with:

    $ pacman -Q $(pactree pacman);

After `pacman` works, remember to sync your local packages with the mirrors and upgrade regularly.
## Arch Linux Suspense and Hibernation

### Kernel parameters: with swap partition
With a proper swap partition, `resume` value can be any type of path to the swap partition, like UUID or other identifier name like this`resume=/dev/mapper/mylvm-swap`.

Now let's add `resume` hook in `mkinitcpio.conf`'s HOOKS sections. I made it run late, just before `filesystems`. And now, generate a new image:

    # mkinitcpio -P;

### Kernel parameters: with swapfile
If you use a [swapfile](https://wiki.archlinux.org/index.php/Swap#Swap_file), then `resume` and `resume_offset` kernel parameter option are needed. 
#### Swapfile on Btrfs
Linux swapfiles cannot be on Btrfs with CoW attributes.

So if you want CoW on your root system, but also want to use swapfile on the root system, you'll have to create a new Btrfs subvolume and disable its CoW attributes:

> Users of other popular Linux non-CoW filesystems such as EXT4 can skip (1) and (2), and they don't need `../swapvolume/..`, they can just use `/swapfile`.

	## 1. New subv
    #
	# btrfs subv create /swapvolume;

	## 2. Disable CoW
	#
	# chattr +C /swapvolume;

    ## 3. Create file and format to swap
    #
    # SWAPFILE='/swapvolume/swapfile';
	#
	# dd if=/dev/zero of="$SWAPFILE";
    #
	# mkswap -U clear "$SWAPFILE";

    ## 4. Try swapon and, if OK, update fstab
    # swapon "$SWAPFILE";
    #
    # echo "$SWAPFILE none swap defaults 0 0" >> /etc/fstab;


Now we have a good swapfile, now let's tell our bootloader to pass the new `resume` and `resume_offset`.

This time, `resume` is the UUID of the device on which the filesystem with the swapfile is. In my case, `swapfile` is in Btrfs subvolume `/swapvolume`, which, being a logical volume, shares the same UUID as its parent `/`. So `resume` for me is going to be the UUID of my Btrfs filesystem.

`resume_offset` is offset of the swapfile.

Getting file offset on a filesystems **other than Btrfs** can use this command to find the value for `resume_offset` of file `/swapfile`:

    # filefrag -v '/swapfile';
	Filesystem type is: fb69
    File size of /swapfile is 4294967296 (1048576 blocks of 4096 bytes)
     ext:     logical_offset:        physical_offset: length:   expected: flags:
       0:        0..       0:      38912..     38912:      1:            
       1:        1..   22527:      38913..     61439:  22527:             unwritten
       2:    22528..   53247:     899072..    929791:  30720:      61440: unwritten
    
    In this case, the `resume_offset` is 38912.
    
    With Btrfs, the whole thing is a mess, and `filefrag` won't help you. Instead, you'll need to grab a small C program source code off GitHub, and use it to determine your `resume_offset`:
        
    ## You should review the source code before proceeding :)
    # URL="https://github.com/osandov/osandov-linux/blob/master/scripts/btrfs_map_physical.c";
    #
	# PROGNAME='btrfs_map_physical';
    # cd /tmp;
    # curl $URL > $PROGNAME;
    # gcc -O2 -o "$PROGNAME" "${PROGNAME}.c";
    # chmod +x $PROGNAME
    # mv $PROGNAME /usr/local/sbin/;
    # "$PROGNAME" /swapvolume/swapfile
   	ILE OFFSET  EXTENT TYPE  LOGICAL SIZE  LOGICAL OFFSET  PHYSICAL SIZE  DEVID  PHYSICAL OFFSET
    0            regular      4096          2927632384      268435456      1      4009762816
    4096         prealloc     268431360     2927636480      268431360      1      4009766912
    268435456    prealloc     268435456     3251634176      268435456      1      4333764608
    536870912    prealloc     268435456     3520069632      268435456      1      4602200064
    805306368    prealloc     268435456     3788505088      268435456      1      4870635520
    1073741824   prealloc     268435456     4056940544      268435456      1      5139070976
    1342177280   prealloc     268435456     4325376000      268435456      1      5407506432
    1610612736   prealloc     268435456     4593811456      268435456      1      5675941888

This time, `resume_offset` boot parameter is the `PHYSICAL_OFFSET` of `FILE OFFSET 0`, which is 4009762816. After you put both kernel parameters in your bootloader entry, you're done. That should be it for resuming to swapfile.
        
### Resume to ZFS
I have both dm-crypt and encrpyted ZFS root filesystems, but I can only got the dm-crypt root to resume properly, because the `resume` initramfs hook would just skip ZFS swap ZVOL and complained that it could not find the resume device when actually the ZPOOL had not been unlocked. I could not use a separate dm-crypt swap partition either, because I want TRIM support for my filesystems, and that requires `systemd` and `sd-encrypt` hook which in turn breaks ZFS encryption (as of June 21, 2020).
### Suspend/hibernate on lid-close
For Arch to suspend/hibernate on laptop lid-close event, I had to do the following:

-   System-wide/console  
First, start by configuring `logind.conf` and see if it works.

-   GUI: basic suspend  
If suspense on console works, now it should also work on X by issuing `# systemctl suspend` on an X terminal.

-	GUI: suspend and lock GUI (X/Wayland) screen (`slock`, `swaylock`)  

### Using systemd service to activate screen lock on sleep
We can use a basic systemd service to execute a screen locker before `suspend.target`.

Below is an example I copied from the Arch Wiki [slock page](https://wiki.archlinux.org/index.php/Slock) and my `swaylock@.service` for Sway (a Wayland window manager):

    #/etc/systemd/system/slock@.service
    [Unit]
    Description=Lock X session using slock for user %i
    Before=sleep.target

	[Service]
    User=%i
    Environment=DISPLAY=:0
    ExecStartPre=/usr/bin/xset dpms force suspend
    ExecStart=/usr/bin/slock

	[Install]
    WantedBy=sleep.target

    #/etc/systemd/system/swaylock@.service
    [Unit]
    Description=Lock X session using slock for user %i
    Before=sleep.target

    [Service]
    User=%i
    Environment=DISPLAY=:0
    ExecStartPre=swaymsg "output * dpms off"
    ExecStart=/usr/bin/swaylock

    [Install]
    WantedBy=sleep.target

And this is my own similar service, albeit with `swaylock`:

	# /etc/systemd/system/swaylock@.service
    [Unit]
    Description=Lock X session using slock for user %i
    Before=sleep.target

    [Service]
    User=%i
    Environment=DISPLAY=:0
    ExecStartPre=swaymsg "output * dpms off"
    ExecStart=/usr/bin/swaylock

    [Install]
    WantedBy=sleep.target

And enable the service(s):

    # systemctl enable slock@username.service;
    # systemctl enable swaylock@username.service;

Substitute *username* with user running the desktop.

## Arch Linux Bit-perfect USB Audio
Install `pulseaudio-alsa` and your USB audio output should be bit-perfect, that is, the USB DAC changes sample rates according to your audio source.

It should now output 48KHz when watching videos, and 44.1KHz for CD audio.

## Pacman: Essential Package List (Updated June 2020)
My usually installed packages. Package names prepended '#' indicate that the packages are no longer relevant **to me**, i.e. I no longer want to use them. The X and graphics section needs some revision.

    $ cat pkg-list
    # for: Arch Linux x86-64

    # base+boot
    base base-devel man-db vim mkinitcpio efibootmgr

    # disks
    lvm2 dosfstools #parted #cfdisk

    # hardware
    crda lm_sensors smartmontools #tlp #acpi #acpid

    # networking
    iwd stubby dnsmasq ufw wireguard-tools #wireguard-dkms 

    # networking utils
    dnsutils openresolv nfs-utils nmap speedtest-cli #iperf3

    # classics
    make git bash-completion patch mlocate rsync openssh #lsof #lshw #which #tree

    # kernels
    linux-firmware linux* linux*-firmware linux*-headers

    # security
    gnupg #arch-audit #clamav #lynis

    # basic X (gui)
    xorg-server xorg-xinit xorg-xrdb xorg-xsetroot
	
	# OpenGL # see below for compatible driver packages
	mesa 
	
	# OpenGL X drivers (AMDGPU)
	xf86-video-amdgpu mesa-driver
	# OpenGL X drivers (Intel iGPU)
	xf86-video-intel
	# OpenGL X drivers (Nvidia)
	xf86-video-nouveau #nvidia #nvidia-utils

	# VA/VDPAU
	libvdpau libva-libvdpau-driver libvdpau-va-gl
	
	# AMDGPU VA/VDPAU
	libva-mesa-driver libvdpau mesa-vdpau
	# Intel iGPU VA/VDPAU
	libva-intel-driver #intel-media-driver
	# Nvidia VA/VDPAU
	libva-mesa-driver nvidia-utils

    # basic X WMs and menu bar
    bspwm sxhkd tint2 #openbox

    # X applets
    xfce4-power-manager volumeicon pavucontrol pulseaudio-alsa

	# NetworkManager (deprecated - use iwd instead)
	#NetworkManager #networkmanager-applet

    # X utils
    dmenu alacritty slock

    # X fonts
    ttf-dejavu ttf-liberation ttf-inconsolata

    # post-install
    pkgconf newsboat scrot stress w3m syncthing bc #calc

    # post-install (essential desktop apps)
    firefox mpv sxiv mupdf #vlc

    # ios
    libimobiledevice #ifuse

    # aur
    ttf-sipa-dip gotop #htop-temperature #ttf-th-sarabun-new

## DNS-over-TLS and DNSSEC
> Maybe out of date (as of Sep, 2022)

The following DoT with DNSSEC guide may have been outdated. Currently, I'm using `systemd-resolved` which has DoT forwarding, although I also keep an `unbound` service up and running.

### Components and how they work together
I use `stubby` as a DNS-over-TLS stub resolver (listens on 127.0.0.1 port 53535), and `dnsmasq` as the caching system DNS resolver (listen on 127.0.0.1 port 53). This means that when my machines perform DNS lookups, they first consult their `hosts.conf` file, then `dnsmasq`'s cache. If the target address is not cached by `dnsmasq` which is our system resolver, `dnsmasq` will query `stubby`, which in turn will query DNS lookups to the DNS servers in the internet via DNS-over-TLS, with DNSSEC.
### `stubby` configuration
First, let's configure `stubby` to **listen on port `53535`** and **enable DNSSEC**:

    # /etc/stubby/stubby.yml
    #
    #
    
	listen_addresses:
      - 127.0.0.1@53535
      - 0::1@53535
    
	#
    #
	
	dnssec: GETDNS_EXTENSION_TRUE
	
	#
	#

### `dnsmasq` configuration
Then, let's configure `dnsmasq` to use `stubby` as the stub resolver:

    # /etc/dnsmasq.conf

    no-resolv
    #proxy-dnssec
    listen-address=::1,127.0.0.1

	# stubby listen address (localhost:53535)
    server=127.0.0.1#53535
	
	# other servers
	server=10.8.0.2
	server=10.8.0.69
    
	all-servers

### Using NetworkManager+dnsmasq with stubby on Arch Linux
As a *laptop* NetworkManager Arch user, I found that `stubby+dnsmasq` solution does not work as reliably as my wired systems. From my own experience, the systemd `dnsmasq.service` and `stubby.service` services usually fail after reconnections if started separately by systemd on Wi-Fi connections. I then searched the Arch Wiki for how to get NetworkManager to spawn and manage `dnsmasq` as its DNS resolver to avoid the latter crashing after network switching/reconnections, and found a simple working solution.

To have NetworkManager manage `dnsmasq`, edit the following files in `/etc/NetworkManager`:

    # /etc/NetworkManager/conf.d/dns.conf
    [main]
    dns=dnsmasq

    # /etc/NetworkManager/dnsmasq.d/dnsmasq-stubby.conf
    no-resolv
    all-servers
    #proxy-dnssec
    server=10.9.0.2
    server=10.9.0.1
    server=127.0.0.1#5300
    listen-address=::1,127.0.0.1

Now test `dnsmasq` config file(s) with:

    $ dnsmasq --test --conf-file=/dev/null --conf-dir=/etc/NetworkManager/dnsmasq.d;

If it is OK, we are safe to start the services:

    # nmcli general reload;
    # systemctl enable stubby --now;

Enjoy!

