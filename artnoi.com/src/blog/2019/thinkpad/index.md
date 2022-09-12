Last edited: Sep 2020
# My first Think product: ThinkPad X230
## Why I left the Apple camp
Despite having always been exclusively Apple computer user, I have always wanted a cheap, used laptop with great Linux/BSD support, and in 2019, I decided this was the perfect time to get a respectable, non-Apple laptop with great [free](/blog/2019/whyfoss/) operating system support. *After doing some YouTube research (lol) I decided to only get a used ThinkPad, as the line was used extensively by programmers I admire*.

I then chose some candidates, most were 2nd-3rd generation (Lenovo) ThinkPads (T420, T430, T530, X220, X230) because they offer quite nice combination of cost, dated designs (desirable), performance, and power consumption. I ended up with the X-series because my lifestyle requires some degree of portability from my laptop. I came over a good deal on eBay for the X230, and I went for it. The machine came with nasty keyboard (full of crumbs) and 85% overall condition, which is quite nice for $160 or so.
## Design and build quality
> *If you analyse the function of an object, it's form often becomes obvious."
- F.A.Porsche*  

I was very, very accustomed to Apple products and their clean, minimalist industrial design. I had always believed that my expensive, luxury laptop is a premium machine, so it is quite fragile like a Patek watch, i.e. I did not care if my Mac is very hard to open, very non-modular, or very prone to failure (as in the case of the keyboards on my 2016 and 2018 MBPs). After using this X230 for a month, I changed my mind about how a computer should be designed and built - I now value durability, well-thought design, modularity, availability of parts, ease of repair, and useful designs. A luxury computer for me now is a machine that works and lasts, and doesn't get in my way. I used to think designing a computer was just similar to designing other consumer products - but now that I value my computing and computers more, I think **my machine should be very well-built, well-engineered, durable enough I don't have to worry about it dropping/falling/etc, while still being minimalist enough that it doesn't distract me from my work**. The moment you open your old ThinkPads to service them, you know what a good design is. Because of this modularity and ease of servicing, I find myself stocking a pile of parts (e.g. bezels, covers, palmrest, keyboards, trackpads, etc) to renovate and service the machine (and the costs now had exceeded the amount I paid for my X230).
## Hardware and original condition
The laptop houses an **Intel i5-3320M** mobile-class, dual-core, hyperthreaded processor which I can happily assure you that the performance you get from this mobile CPU is very respectable, more so than my old 2015 MacBook Air which has similar 5th-gen i5 but the Mac CPU is ultrabook-class (worst for a Core i CPU, and the 13" MacBook Pro still uses U-class CPU today). Yes, the 3320M still outperforms 5250U. My X230 came with 8GB Samsung DDR3L memory, a TN-panel screen, 3-cell external battery, and a 128GB Toshiba SATA SSD.
## Upgrading X230 hardware
I later upgraded memory to 16GB DDR3L (Crucial), replaced the old disgusting TN panel with an IPS screen, equipped it with a brand-new, healthy 9-cell original battery, installed new keyboard and palmrest, and upgraded storage to 500GB (WD Blue SATA SSD, 250GB, and Samsung EVO 860 mSATA SSD, 250GB). After the upgrade, I find myself always wanting to reach for the ThinkPad instead of my more expensive, lighter, and more *usable* 2018 MacBook Pro.
## Operating systems and disk configuration
Currently all my root filesystems reside on slower mSATA Samsung SSD (running at SATA 2 speed) while I usually leave the SATA 2.5-inch drive bay empty, because the mSATA one consumes less power, and the Samsung drive I/O is not slow at all for my usage, maybe because my software is not bloat (lol).
### [Arch Linux](https://en.wikipedia.org/wiki/Linux_distribution)
My daily driver. Highly customizable and configurable. There are 2 Arch installations on the X230, [one on LUKS](https://cheat.artnoi.com/lvm) and [one on ZFS](/blog/zfsarch.html).
### [Void Linux](https://voidlinux.org)
My old X230 staple. I installed it on LUKS and LVM, though I no longer use Void.
### [FreeBSD](https://freebsd.org) (Release)
My first OS to be installed on the X230. X230 has excellent support on FreeBSD.
## User experience
**Superb!** Aside from inferior screen and battery life, this $160+$200 7-year-old laptop is more pleasing to use than my overpriced ($2,000) 2018 MacBook Pro - the ThinkPad has better construction, much better keyboard, and much better software (because I installed and configured everything myself). It also boots really fast, much faster than my MacBook Pro. This is mainly because of software but since my Mac was sold as a hardware/software package with no alternative OS so I think it's quite fair to compare the two. The weight and dimension difference doesn't affect the portability so much, after all this *was* 2012's ultraportable laptop computer.
## Footnotes
### (Damaged) X220 7-row keyboard
**WARNING:** As of 2019, classic keyboard BIOS patch [thinkpad-ec](https://github.com/hamishcoleman/thinkpad-ec) will NOT work on X230 with 1.77 firmware installed. So today (Oct 17 2019), I installed ThinkPad classic keyboard (X220 keyboard) on my X230 without isolating the internal connector pins as per the [ThinkWiki recommendation](http://www.thinkwiki.org/wiki/Install_Classic_Keyboard_on_xx30_Series_ThinkPads) - and thus the keyboard was over-heating and hit with excessive current which damaged my middle button. As a result, trackpoint scrolling doesn't work, and this has ruined my experience on this computer. I use the terminal all day and this issue had made my life a bit harder. But after all, **typing on the classic keyboard feels much better**, and I can still use arrow keys or page-up/down keys to scroll through documents. And as of Oct 2019, Lenovo has started signing its BIOS updates with digital signature which prevents me from patching the BIOS for the new keyboard - which means that some keys are not working as of now. Volume keys, brightness keys (F8-9 instead) still works so I actually don't have much to complain. However, my school work requires me to do a lot of web browsing, and not having my middle-button working properly can get in my way while I'm working, so **I swtiched back to X230 keyboard**.
### Damaged middle scroll key: my workaround
1.  Use arrow keys - works for most apps
2.  Map some keys in software, e.g. `.Xresources`

### My X230: Technical Specifications
-   CPU: Intel i5-3320M
-   Network: Intel 8259 Gigabit
-   Wireless: Intel Centrino 6250
-   SSD Storage: WD Blue SATA (250G)B + EVO 860 mSATA (250GB)
-   Memory: Crucial 16GB, 1600MHz DDR3L (1.25V)
-   Display: 1366x768 IPS Panel

#### Modification(s)
-   OEM Backlit Keyboard
-   OEM X220 Keyboard
-   OEM X220, X230 Palmrests
-   OEM Screen Panel(from TN to IPS)
-   OEM Screen Bezel
-   OEM Front Cover
-   Original 9-cell Battery

#### Geekbench4
[Here](https://browser.geekbench.com/user/artnoi) is the Geekbench 4 results of my computers
