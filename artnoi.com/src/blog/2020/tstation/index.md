Aug 2, [2020](/blog/2020/)

# Lenovo ThinkStation P330 (30CYF22Y00) Workstation

So I just bought a new desktop workstation tower (30CY - P330 Gen.2) from Lenovo, and it left me with mixed feelings despite being a well-built machine. Before I start rambling, note that this is my most respected computer to date, and most of issues are due to the fact that the machine has both iGPU (on the i7-9700) and dGPU (Nvidia P400) and several display output ports.

## Maintenance and servicing

The machine comes with 3-year next-day on-site support package. Lenovo also publishes [P330 Gen.2 Tower Hardware Maintenance Guide](https://download.lenovo.com/pccbbs/thinkcentre_pdf/p330_2nd_gen_tower_hmm.pdf). You only need to remove 2 thumb screws to open the machine for service.

## Stock configuration

Stock memory and storage-wise, my machine came with 1 module of 16GB DDR4 2666MHz CL17 SK Hynix memory installed, a 512GB NVMe SSD and a 1TB 7200rpm HDD (both disks are WD Blue). Included were Think mouse and desktop keyboard with stupid fuction key layout. I replaced the memory module right away, but chose to keep the WD Blue disk drives.

## My configuration

The tower is powered by 250W PSU, Intel i7-9700 CPU, and a dedicated Nvidia Quadro P400 graphics. The memory bank has 4 UDIMM slots for 2666MHz DDR4 non-ECC memory which are now populated by **64GB (4x16GB) Kingston HyperX Fury Black DDR4 2666MHz CL16 (HX426C16FB3/16) kits**. The tower supports multiple storage cages, which now house a standard 1TB 3.5" WD Blue HDD, a 2TB 2.5" Toshiba HDD (in "ThinkCentre 2.5 Storage Kits" I bought from eBay), a 500GB 2.5" SATA WD Blue SSD (I chucked it in the empty FLEX bay without anything securing the SSD - gamers do this all the time), and a 500GB M.2 NVMe WD Blue SSD with **total storage of 4TB (3TB HDD + 1TB SSD)**. I got a compatible M.2 Intel Wi-Fi module for it, but because the particular tower lack the Wi-Fi shield unit, the card could not be installed securely. (Note: the Lenovo support engineer [Thailand] suggested that I use a paper/plastic makeshift Wi-Fi shield to keep it in place)

## Recommended FRUs/CRUs

My recommended accessories for the tower are **ThinkCentre 2.5 Storage Kits (4XF0P01009)** which include (1) a native 2.5" drive mounting bracket, and (2) a 2.5-3.5 converter tray which can then be placed inside the standard 3.5" mounting bracket included with the tower. The kit components are high enough to house 2.5" drives of all thickness (7, 9, 9.5, 12.5mm). One can buy the kit and add 2 2.5" drives to the system in <5 minutes. The other recommended part is the **dust shield (02CW383, 5M10U49719)** which has seemingly minimal effects on cooling. (I don't notice any significant temperature difference with the dust filter on)

## Video output

My specific configuration has 3 mDP, 2 DP, and 1 onboard DP display ports. The mDP ports are provided by the Nvidia card, while 2 DP ports on the back are provided by the mainboard via a cable. On Windows (the only OS so far to handle this display configuration properly, without even a screen tear) all of the ports can provide video output. On Fedora 32 Workstation and most other Linux distros I tested (Arch Linux, Pop_OS!), only the mDP ports can output image.

## CPU Thermals

My tower is not using stock thermal grease because I _accidentally_ and stupidly tried to plug a DP to HDMI dongle directly on the board connector which sits very close to the heatsink. The heatsink blocked access to the release mechanism, which I had to squeeze in order to get it out - so I had to remove the heatsink and reapply my thermal paste. I first used Arctic MX4 long-life paste, but then decided to change the paste to **Gelid GC Extreme**. The end result is nearly identical for both boutique thermal paste.

The 8c/8t 9700 non-K **CPU idles around 29-33C (8-core averaged)**, however, doing `stress -c 8` will quickly make the temp jump to the mid 70s in split second, and **it seems the stock cooling system (even with OC thermal paste) CANNOT maintain the 4.7GHz boost on all cores**.

The BIOS would allow the CPU to turbo and stay in the 80s for some time, but when it senses that the task is not going to finish soon, it will drop the frequency and runs at 3.6GHz base clock at 60s degree instead. On my usage however, I could not get it above 60C, even when building `dkms` modules on Arch Linux which on my other Think computers would have maxed out the temperature limit already. Another note is that the stock thermal grease was seemingly better applied - before I had to reapply the paste (with GC Extreme and Arctic MX4), I remember the machine was idling 29-31C and rarely went over 45C with desktop use, but again this might just be a _placebo effect_. Perhaps new heatsinks and fans are needed for this 9th-gen Intel thermonuclear workstation.

## Linux support

I run [Arch Linux](https://archlinux.org) and [Fedora 32 (Workstation)](https://getfedora.org) on the tower. Everything has worked out of the box just fine so far on Linux. I should note that even embedded controller (BIOS) updates can be done right on Fedora thanks to Lenovo-Red Hat (now part of IBM who also owned the Think brand) business partnership.

### Nvidia Quadro P400 Linux drivers

> Both `nvidia` and `nouveau` work on Quadro P400.

On my main Arch Linux install (GNOME), I use `nvidia` because VDAPU video hardware acceleration is only available with the proprietary driver (VAAPI for `nouveau` did not work for me). `nvidia` also appears to be much more stable - with `nouveau`, the screen randomly freezes on both Fedora and Arch Linux. On my emergency root, I use `nouveau` because [Sway](https://swaywm.org/) does not support `nvidia`.

> There's a catch however, if you use mDP-HDMI adaptor like I do, when `nvidia` module is loaded during booting process, the screen goes black. I have to **reconnect the HDMI adaptor to get image**. This little bug previously led me to think `nvidia` does not work with Quadro P400.

### Support for other Nvidia cards

More powerful low-end Quadro cards like P620, P1000, etc. can be installed in the P330 without much modification or worries about the clearance, but I think these older, cheaper Quadro cards will only work properly on Windows.  
The best alternatives would thus be the GTX cards, especially newer ones which have better software support in the open-source world. I've read on Lenovo forums that 1000-series and 1600-series reference-design cards might fit, as well as the RTX 2070 cards, but these heavier full-sized graphic cards would require chassis part from Lenovo to be securely attached to the system.

## Possible upgrades

I'm thinking about buying a 550W PSU, a new graphics card (unfortunately only Nvidia cards are officially qualified on the platform)\*, and some new Noctua fans and heatsink for better thermal and acoustic performace.
