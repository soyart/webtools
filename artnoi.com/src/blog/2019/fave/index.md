Oct 8, [2019](/blog/2019/)
# Stuff I use (and love)
## Audio
### Headphones
#### Earphones: [Etymotic ER4SR](https://www.etymotic.com/consumer/earphones/er4-new.html)
Arguably the best reference insert earphones (in-ear) in existence (2019). The ER4SR is the latest member (2019) of the ER4 family, which is the world's first insert earphones. The ER4SR has excellent noise sealing thanks to its deep insertion, which feels strange but comfortable, and the sound is just stellar. It is made by one of the most recognized hearing-aid companies in the US (I mean made in US), and the sound profile is based on their understanding of human hearing, hence the deep insertion. It is also some of the world's most accurate sound transducers to human eardrum. The two balanced armature drivers are tuned and matched within incredibly small margin of errors, possibly to the industry's highest standards. If you really want fidelity, i.e. the original sound, just buy one of these and they'll be good for years. I have owned mine since 2018 and have accidentally dropped, stepped on, crushed my car door against it, for multiple times yet only minor scratches are the only damage so far. This is my best audio investment to date.
#### Circumaural Headphones: [Sennheiser HD600](https://www.headphonesty.com/2018/08/review-sennheiser-hd600/)
This iconic headphone from 1997 is one of my best sounding head/earphones, second only to the impossibly neutral-sounding ER4SR. The phones are very comfortable, light, very durable, and very good-sounding. The fidelity when compared to ER4SR is lacking, especially in frequency response, but with some music they are very close. All parts are also servicable, and Sennheiser still sells replacement parts on their website.

Actually, I have a ton of other headphones, but I only picked one for each type. If you are interested in my subjective opinion on any of [them](headphones.txt), ping me.
### Media Players/Servers
#### [Plex Media Server](https://plex.tv)
I run PMS on my x86 "server" computer, currently the ThinkCentre M93p (i5-4750T). The PMS is configured to provide DLNA for my local network - my family is very happy about it because now they can watch videos from 1997 any time on their any online devices. Because of how impressed my mom is with the DLNA capability, she gave me a green light for the lifetime Plex Pass. The most frequently accessed media files are stored on internal ZFS partition, while other less important files are stored on external USB HDDs, usually formatted with ZFS but the machine running PMS has read/write support for proprietary filesystems that my family drives usually formatted with (HFS+, NTFS, and exFAT)
#### Desktop Music Player: [Raspberry Pi 3B+](https://www.raspberrypi.org) (Volumio)
I use [Volumio](https://volumio.org)-based Raspberry Pi as my daily driver for music players. The Pi has 4 USB ports so you can plug in 3 USB storage devices (one of them is used for USB DAC). Volumio is bit-perfect, i.e. the decoded audio output is exactly the same as the input file, so you don't have to worry about it as sound will depend on your DAC and downstream equipment. Volumio also has network capabilities like AirPlay and internet radio. FYI I disabled all internet radio stations, so the source of my music is either USB drives, NFS shares, or SMB shares.
#### Portable Music Player: [FiiO M6](https://www.fiio.com/m6)
This $150 Android-based player is good for its price. I bought it for Bluetooth codecs (to use with my Sennheiser HD4.50BTNC) and to replace my aging, collectible iPods. It runs on smartwatch CPU and can be slow at times, e.g. when importing music from huge storage cards. I don't use my iPhone for music because of storage concerns.
### Headphone Amplifiers
#### [JDS Labs Atom](https://jdslabs.com/product/atom-amp/)
This $99 amplifier packs one of the [best performing circuitry](https://www.audiosciencereview.com/forum/index.php?threads/review-and-measurements-of-new-jds-labs-atom-headphone-amp.5262/) in headphone amplifiers in an astonishingly lightweight package. In fact, the weight was so low they HAD TO PUT DUMMY WEIGHT inside the plastic case to make it feels more solid/heavy and to prevent it from slipping/moving on the table. The audio performance from the output is stellar, but the build quality is somewhat lacking (though the unit comes with hefty, solid power supply). JDS is among a few in audio industry that actually publishes and endorses audio measurement results for its products.
#### [Massdrop Objective2](https://drop.com/buy/massdrop-o2-amplifier)
This box is the desktop edition of the infamous [Objective2 open source circuit](http://nwavguy.blogspot.com/2011/08/o2-details.html). Desgined by the legendary electrical engineer NwAvGuY back in early 2010s, it was widely regarded as one of the best value in headphone amplifier investment, but now it is being surpassed by newer designs. I highly respect the designer of the O2, NwAvGuY, who created the amplifier after being challenged on online forums that his objective mindset is false and that Hi-Fi audio required expensive, fancy parts. This open source masterpiece debunked audiophools' fantasy claims, and served as source of inspiration for people (who know better) to verify their audio product's performance using objective, scientific measurement. I still keep this amplifier today for its historical importance on the changes it brought to audio communities.
#### [FiiO A5 Portable Amplifier](https://www.fiio.com/a5)
Cheap and well-built/heavy-duty portable amplifier with respectable performance. This Chinese portable amplifier box could drive almost anything to deafening level!
### (USB) DACs
#### [Khadas Tone Board](https://www.khadas.com/tone) VIM EDITION
$99 Chinese bare-board USB/GPIO with [superb fidelity](https://www.audiosciencereview.com/forum/index.php?threads/review-and-measurements-of-wesiontek-khadas-tone-board-dac.4823/), although not without ESS IMD hump inherent on ESS DAC chips. The fact that this is a bare-board DAC has led some audio equipment manufacturers to put it on their products - one of them put it in a sexy black aluminium case charging for over 3x the original price of the board. Although mine (which is VIM Edition) has GPIO pins on it, the board only accepts USB audio connection, i.e. all audio input, either from the GPIO or the USB port, is USB Audio.
#### [Topping D10](https://www.audiosciencereview.com/forum/index.php?threads/review-and-measurements-of-topping-d10-dac.2470/)
$99 Chinese high performance desktop DAC in black, sexy aluminium case. I believe my 2 DACs are the best value in USB DACs in 2019. Topping is good when it comes to performance unlike its Chinese competitors, but they are quite to be worried about when it comes to reliability. I have seen many Topping products failing on audio forums, especially mid-range models, although this particular low cost model (D10) seems to be trouble-free, which is my good luck.
## Computers
### Laptops
#### [ThinkPad X230](https://en.wikipedia.org/wiki/ThinkPad_X_series) (i5-3320M with 16GB DDR3L)
[My FOSS daily driver](/blog/2019/thinkpad/). Built like a tank. Very servicable. Parts are everywhere. the industrial design here is also best-in-class, and I think they (Lenovo and IBM) even put more efforts into designing ThinkPads than Apple does with their Macs. When you open it to service it, you'll know what I mean by "forms follow function". The machine was bought used from the US but I refurbished it myself with new SSDs (both SATA and mSATA), 16GB DDR3L RAM (8x2), keyboards (X230 and X220), palmrests (X230 and X220), IPS screen, trackpad (I use trackpoint, new trackpad is only for cosmetics), CMOS clock, and batteries (3-cell and 9-cell). Spent THB4,200 in machine cost, but wasted over THB7,000 on renovation. Overall I'm very impressed with the experience with this laptop, snappy and sexy even after over 7 years of age in 2019. The machine runs Linux and BSDs.
#### [Another ThinkPad X230](https://en.wikipedia.org/wiki/ThinkPad_X_series) (i5-3210M with 8GB DDR3L)
My second X230 with a slower-clocked, less powerful CPU. This one has better thermals and battery life so I usually use it for light surfing and ssh sessions. I recently sold it to my friend and he could run Heartstone (on Arch via `wine`) just fine.
#### [ThinkPad X220T](https://en.wikipedia.org/wiki/ThinkPad_X_series) (i5-2210M with 8GB DDR3L)
My first convertible notebook, with Wacom digitizer. The display cable is currently bad and I don't have a use for it yet so it justs sit here in my room collecting dust. It came with a very slow 320GB Toshiba HDD that is pain to boot from.
#### [ThinkCentre M93p](https://en.wikipedia.org/wiki/ThinkPad_X_series) (i5-4570T with 16GB DDR3L)
My first tower PC ever in my life at $150 in 2020. It runs Arch Linux on a 1TB HGST HDD and is used as a Plex server, a ZFS backup server, and a secondary Pi-Hole. The box houses 4c4t i5-4590T which is running quite well.
#### [Panasonic Toughbook CF-SX2](https://na.panasonic.com/us/computers-tablets-handhelds/computers/laptops/toughbook-cf-sx2)
A JDM laptop (it's even made in Japan). This one in particular has the same processor as my X230, though it's much lighter. Although running the same CPU, SX2 only supports 8GB of DDR3(L) RAM, while X230 can support up to 16. It does not seem to have UEFI boot, and useful support information on the machine is not readily available on search engines. Its embedded controller update utility (and some battery monitoring firmware) failed to install properly on Windows 10, and Microsoft won't allow downloading a copy of Windows 7 with manufacturer (OEM) Windows License. I do notice the Panasonic laptop is better made than the ThinkPads, but Lenovo still wins when it comes to designing things to be easily servicable. Panasonic parts are also very hard to obtain compared to ThinkPads. Now I installed Windows 10 Pro on it, and will soon dual-boot it with Fedora.
#### [MacBook Pro 2018](https://en.wikipedia.org/wiki/MacBook_Pro) (i5-8259U with Touch Bar)
My overpriced, thin-and-light machine for school/professional use. This one (with T2 chip) cannot run FOSS OSes and thus is only used for my proprietary software needs like MS Office etc and movies. The machine is very snappy, though it will thermal throttle. The hardware is lovely as first, but you will hate it later on. The only good things here are the display quality and trackpad, and integration with iOS which tends to be on my mobile devices. The machine gets hot (~80C) for no reasons, feels like it will break (especially the hinge), with no way of upgrading, and repair bill can get you a luxury belt, or even new laptop of comparable specs. (I fixed the 2016 model screen once and it costed like THB20,000 - which is almost the average price of normal Dell laptops - this 2018 shit is going to cost more as the screen is even more expensive and T2 will make eveverything harder to fix.)
#### [MacBook Pro 2016](https://en.wikipedia.org/wiki/MacBook_Pro) (i5-6267U with Touch Bar)
Same as above, but silver and older.
### Desktop computers
#### [2013 21" iMac](https://en.wikipedia.org/wiki/IMac_(Intel-based)) (non-Retina)
Inherited from family. This one is quite good, runs cool, small footprint, and nice screen. This all-in-one beauty only has FOSS OSes installed on it. But it has Broadcom Wi-Fi so FOSS OSes can sometimes require configuration to get Wi-Fi to work (I have to use Wi-Fi because it is in a room without a router). The only GNU/Linux distribution that Wi-Fi works out-of-the-box is MX Linux (2019).
#### ThinkStation P330 Gen.2
See [this blog for more info on my ThinkStation](/blog/2020/tstation/)
### Single-board Computer
#### Multiple [Raspberry Pi 3B+](https://www.raspberrypi.org)
No introduction needed for this pi. Slow and dated specifications, but software support is the best amoung the SBCs. I killed a board once. But I got like a few more to spare (lol).
#### [Rock Pi 4B+](http://rockpi.org/)
RK3399-based SBC with Gigabit Ethernet. Comes in rough RPI3B+ form factor, although the cases cannot be used interchangably. I run [Armbian](https://www.armbian.com/) on it and it serves as my home's 24/7 backup Pi-Hole.
#### [Khadas VIM3](https://www.khadas.com/vim3)
A311D-based SBC with NPU and good GPU. I'm considering paring it with my Tone Board to create ultimate music box but I think that would be a waste of computing power. Khadas actually provides Ubuntu/Debian image build scripts for VIMs, but I'm too lazy to compile my own image to run on SBCs. Now it runs Ubuntu 18.04 (also [vendor's](https://docs.khadas.com/vim3/FirmwareUbuntu.html)), but I may dual boot it with Armbian or Volumio in the future. Perhaps it will eventually be used as my bedroom video box ([Kodi](https://kodi.tv/))
## Software
### Operating Systems
#### [OpenBSD](https://openbsd.org)
See [this blog for my OpenBSD impression](/blog/2020/openbsd.html).
#### [FreeBSD](https://www.freebsd.org)
FreeBSD is my favorite operating system. It runs on my X230, my VPS server, and one of my Raspberry Pis.
#### [Linux distributions](https://en.wikipedia.org/wiki/Linux_distribution)
Currently I'm using [Arch Linux](https://en.wikipedia.org/wiki/Linux_distribution) as my rolling-release daily driver. Arch runs on my VPS, my home server, and my ThinkPad laptops. My other favorite Linux distribution so far is [Void Linux](https://voidlinux.org), which is an innovative, mininmal, BSD-like distro.
#### [macOS](https://www.apple.com/macos)
It came pre-installed with my MBP 2018. I use this bloated OS to run proprietary applications like MS Office. I remember OS X used to be stable, but now it's not, especially on my modern, T2-equipped machine. Shutdowns and startups are buggy, so is networking, and non-Apple-formatted disks can sometimes cause the system to be very sluggish. This could very well be hardware problems, as MacBook Air and my older 2016 MBPTB do not have startup/shutdown/networking problems. *Note: From 10.15, Apple seems to have fixed the power issue on T2 machines as my computer no longer takes too long to boot with external drives connected and no longer refuses to shutdown after some tasks.* My other complain on this proprietary OS is the lack of 32-bit support (from 10.15). **Apple's increasingly creepy behavior also dissuades me
from using their software.**
### Text Editors
#### [vim](https://www.vim.org)
At first when I came into FOSS community I used [GNU nano](https://www.nano-editor.org/), but when I started to edit more and more long text files, I found vim to be more suited for the jobs thanks to its keybinding and really clean interface.
### Web Browsers
[Firefox](https://firefox.com), [qutebrowser](https://qutebrowser.org), [lynx](https://lynx.browser.org), [surf](https://surf.suckless.org/) on Linux/BSDs and Safari Technology Preview (to conserve battery on my Mac)
Terminal Emulators
[rxvt-unicode](http://rxvt.sourceforge.net/) and [st](https://st.suckless.org) on FreeBSD, rxvt-unicode on Linux distros (I like consistency), and [iTerm](https://www.iterm2.com/) on macOS. If I had to use Xfce desktop, Xfce Terminal does its job well except when copying-pasting to `vim`.
### VPN
#### [WireGuard](https://wireguard.org)
See my [blog article on WireGuard](/blog/2020/wireguard.html) here.
### Filesystem
Preferably **[ZFS](https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/zfs.html)** for data storage if I got plenty of RAM, although I like **HFS+/APFS** for its stability and features (given memory footprint and compatible operating system) for desktop use. I personally don't like **EXT4** as much as other Linux users do, due to its tendency to break now and then (Apple's FS may also break, but the proprietary OS may hide it away from me), but all of my Linux installations sit on EXT4 partitions for easy maintainance and troubleshooting. I host a [cheat sheet page specifically for ZFS](/cheat/zfs/).
### Sync/Storage
#### [Syncthing](https://syncthing.net)
I used to use [NextCloud](https://nextcloud.com) but then grew tired of setting up a LEMP (or FEMP) stack for it, so I now moved to Syncthing which is much more easier to setup. I just throw config files around and the machines just sync
### Office Suite and Statistics
Microsoft Office, [LibreOfice](https://www.documentfoundation.org/), [PSPP](https://www.gnu.org/software/pspp/)
