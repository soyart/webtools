Dec 15, [2020](/blog/2020/)

# ThinkPad T14 (Gen 1) - R7 4750U

## My first AMD computer

This is my 69th (actually maybe 4th or 5th) ThinkPad laptops I have owned, and the first brand new one. But owning a brand new ThinkPad does not excite me compared to the fact that this is my first AMD machine. My x86 computers have always featured Intel CPUs. From the Core2 era to i7-9700 in my [ThinkStation P330 Gen 2](/blog/2020/tstation/). This is why today I will stress a bit on performance, something I rarely talked about in the past when it comes to ThinkPad (I was busy preaching how the Think mentality is so great).

## Ryzen 7 4750U - thermals

The **8c/16t 4th gen Zen2 APU** runs very cool thanks in large part to TSMC's well-matured 7nm process. Unless I'm pushing it (e.g. playing 4K videos or building the Linux kernel with AMD (anti-Intel) optimizations), I could not get the machine to heat up over 50-55c depending on the room temperature, which now is 27-34c these days in Bangkok. On really hard workload, I see the temperature sitting in the high 70s. FYI, my (Intel) 2018 MacBook Pro always goes crazy hot (90-ish C) whenever my load hits, and the Mac only has 4 cores.

## Ryzen 7 4750U - performance

> Ah yes, the threads!

On Linux, my T14 scored 5,200/20,800 on Geekbench 4 CPU test using the generic x86-64 Linux kernel, while the exact same machine only scored 4,500/19,000 on the same benchmark. **Note that the memory slot is still empty**, leaving room for future performance boost (from dual-channel memory) by the time I upgrade it with a SODIMM DDR4.

## Ryzen 7 4750U - power consumption

I have not measured power consumption yet, but it's actually not bad for a 8c/16t CPU + beefy 7-core iGPU with a 14" screen. I usually get home with 50%-70% of battery left after 3-6 hours of use before I recharge it for the next day.

## CPU overall

Overall it is a more powerful low-power-CPU laptop, and it gaps most contemporary Intel laptop offerings in most areas, except in one where it is actually lagging behind Team Blue by a noticeable margin, which is memory performance. But again, that maybe my own problems for not having populated the empty DIMM slot yet.

## Linux support and optimizations

Everything has been running great so far, except the fact that my build only seems to detect 2 CPU thermal sensors. This is not a huge issue, but usually when I use ThinkPad, everything GNU/Linux just worked. I understand that this issue is from AMD or the software side and not from Lenovo. Damn, it even has 'Linux sleep mode'.

Because the APU has quite a lotta threads (16) and 7-core RX Vega graphics (which makes it quite an _oomphed_ ultrabook/laptop CPU/APU especially when compared to Intel's offerings), I wanted to try to get the most out of it from both the computational (CPU) and graphical (GPU) performance. I would say that the 4750U would still fit great in a mobile workstation.

### Zen2 - Linux kernel optimization

The Linux kernel has multiple Zen2 specific optimization options available, as well as `AMDGPU` kernel module. On Arch Linux, the AUR package `linux-znver2` is available for Zen2 computers, and `amd-ucode` microcode update is available from `core` repo.

#### Building kernel on another Arch machine

I hate to watch my laptop building large programs (e.g. the kernel), so I wanted to find a way offload the build to other capable machines, preferably a headless x86 server. But this laptop is my only AMD computer, _so I need to use Intel computers to build AMD-optimized kernels_.

Using Intel machines should work just fine, unless you are autistic like I am and want to customize kernel modules further (mostly just disabling unused modules that I know for sure will not load). This is tricky, because with [LKM](https://en.wikipedia.org/wiki/Loadable_kernel_module), the same Arch root filesystem loads different kernel modules on different hardware platform, and thus a simple `make localmodconfig` will not work. So I had to find a way to let my Intel-based build system know what modules are needed to boot the target AMD machine.

##### Kernel 0 (K0) - vanilla AUR `linux-amd-znver2`

To offload compiling of my custom kernel to my ThinkCenter, I first built the _vanilla_ -AMD-znver2 kernel (let's say it's named K0 here) on my ThinkCenter. After package `*.zst` files are created, I copied the files to my AMD laptop ramdisk `/tmp`, and tested the K0 kernel by using `# pacman -U *.zst` (be sure to include the specific Linux headers) to install it to boot with all the `dkms` module.

##### Testing K0 and creating config template for K1, K2, K3 etc.

After I'm successfully booted from K0 kernel, I exported my K0 `lsmod` output to my ThinkCenter, and edit the `prepare()` section in `PKGBUILD` file (`.cache/yay/linux-amd-znver2` if you use `yay`) with `make LSMOD=/path/to/target/lsmod/output localmodconfig` (default should be `make olddefconfig`) and use `makepkg -s` to build new kernel K1. My kernel building is done on ZFS datasets, so I can roll back any broken builds into a working one. After the new kernel is built, I copied and installed it on my AMD laptop and reboot to see if there's any problem. If no problems were found on K1 kernel, I then tried to customize the kernel further (to K2, K3, K4, etc.). However, after major version upgrade, I usually find myself having to start from K0 again. Git branches are used to manage versions.

### Linux hardeware graphics acceleration

> I usually only use VA-API on Wayland.

#### Wayland

On Arch Linux, install the following package:

    # pacman -Syu libva-mesa-driver;

On [Arch Wiki](https://wiki.archlinux.org/title/Hardware_video_acceleration), it is suggested that newer AMD GPUs (like the one on the laptop) should use `mesa-vdpau` instead of `libva-mesa-driver`, **however**, for `mpv --hwdec=auto` to work out of the box _without configuring anything_, you must install `libva-mesa-driver`.

#### X11

I (and you should too) started by reading the [Arch Wiki on AMDGPU](https://wiki.archlinux.org/index.php/AMDGPU) first. Then, I installed `xf86-video-amdgpu` and `libva-mesa-driver`+`mesa-vdpau`+`libvdpau` for OpenGL (`mesa`) hardware acceleration.

> To mitigate screen tear on `AMDGPU` and also enable 10-bit color support, add this configuration `20-amdgpu.conf` to `/etc/X11/xorg.conf.g`:

    Section "Device"
    	Identifier "AMD"
    	Driver "amdgpu"
    	Option "TearFree" "true"
    	Option "DRI" "3"
    EndSection

    Section "Screen"
    	Identifier "asdf"
    	DefaultDepth 30
    EndSection

#### Firefox

If you use Firefox, follow Arch Wiki guide to enable AMDGPU acceleration under X11. I wrote a simple script [firefox.sh](https://gitlab.com/artnoi-staple/unix/sh-tools/bin/firefox.sh) that will launch Firefox in such a mode, but only after you applied the configuration first.

## The laptop

The machine comes with 512 NVMe SSD (a Samsung, or some OEM who uses Samsung NAND/controller), 16GB Onboard DDR4 3200 memory, and multiple readers (fingerprint, uSD, and Smart Card). Networking includes Realtek Gigabit Ethernet, Intel AX200 (MVM) WiFi 6 + Bluetooth adaptor. An 65W USB-C power adaptor was included. All of the hardware worked wonderfully under Arch Linux vanilla packages, except for video hardware acceleration mentioned above. I have not yet tested other Linux distributions or operating systems.

### Deal

It retails for THB 49,990 but because I pre-ordered, I got it for THB 32,900. Lenovo Wireless Think mouse and a carry bag were provided by the retailer free of charge.

### The TrackPoint and Trackpad

Seriously, there is nothing to write home about. Trackpad is still awful, and the TrackPoint works as always. With larger screens, I prefer a mouse to the TrackPoint, but if I had to work on-the-go then the TrackPoint would suffice.

### The ThinkPad keyboard

Ah yes, it's the same old keyboard since my 2013 X230. Typing on these ThinkPad keyboards feels great - I love everything about the character keys in this keyboard (which stays relatively unchanged from X230), while I'm not actually a fan of its function keys (which kept changing).

### ThinkPad backlit Keyboard with illuminating LEDs

I don't actually miss the ThinkLight that much, and this newer version of backlit keyboard has better coating (less likely to get sticky and greasy) than older backlit _chiclet_ keyboard.

### ThinkPad construction

Solid build as always with a ThinkPad. However, it is getting slimmer and slimmer each day, and this year my T14 got so thin that I got nervous from feeling weird body-flex when holding it horizontally with one hand. The soft rubberized surface is also durable enough for normal usage, though I feel it will get fucked up over time (like most 2nd-hand ThinkPad). Magic eraser (abrasive sponge) may help with little scratches, although don't use it very often.

### 50Wh Battery

T14 has 50Wh LiPo battery, so it is what it is when you pair it with 8c/16t CPU with 7c iGPU.

### 14" Multitouch Screen

My specific laptop got a multi-touch FHD 300-nits IPS screen which I have to admit looks okay. I'm not sure why, but the colors look very sharp and accurate on Windows than it is on Linux distros. I can live with it quite happily, and the fact that there is no glare helps the dimmer display like this one fight outdoor reflectons a lot. I enjoyed watching anime using terminal on this 14" screen tho.

### BIOS updates

Lenovo always provides up-to-date BIOS and firmware for Think products. My machine came with BIOS version 1.25, and now Lenovo already releases 1.27, so I promptly installed it. The BIOS updates (Lenovo) and the firmware (non-Lenovo, e.g. SSD firmware) can be done "graphically" using Windows or Fedora, or you can write the BIOS update `iso` image to a flash drive and boot from it to update. Note that the flash drive method does not include firmware updates, only the system BIOS.

## Verdict

Just buy, unless you own 2018-2020 laptop of the same calibre, because if so, you should be better off with the upcomping 7nm Zen 3 (Ryzen 5000) computers which the nerds have speculated 10-20% IPC increase and minor clockspeed improvement. Another candidate is the 4650U version of T14, which is identical to this machine, except it has 2 less physical cores and thus should give better battery life and thermals.
