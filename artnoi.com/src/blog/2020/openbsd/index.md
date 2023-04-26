Sep 13, [2020](/blog/2020/)

# My OpenBSD first impression

I have admired the [OpenBSD](https://openbsd.org) project for some time, and even once installed it on my iMac but later gave up due to my n00bness. All of my previous attempts on encrypted installs were usually failed due to my lack of understanding of how `fdisk(8)` and `disklabel(8)` work on OpenBSD. After a night of reading the [disk setup guide](https://www.openbsd.org/faq/faq14.html), I was ready for OpenBSD encrypted installation. Because all my computers are now using SSD storage, I would hate to experiment an encrypted OS install on my own hardware as it would exhaust my write cycles. So I practiced installations on Vultr's VPS (in total I created 2 instances). Note that Vultr only support legacy boot for their VPS.

After I started using it for a few days and was welcomed by [Theo De Raddt](https://en.wikipedia.org/wiki/Theo_de_Raadt) in the system mail, I really think the operating system is satisfyingly beautiful and well put together. There are many aspects (listed below) of OpenBSD which I feel is best-in-class:

### Documentation

The config files and `man` pages contain very useful information and guides. The documentation (for OpenBSD's components) is also very rich and informative. Heck, they even write _really good_ examples for most of their config files, and even better ones in `/etc/examples`. This level of attention to detail is unheard of to me. Linux may get more developer time, but OpenBSD definitely get more developer's (as well as user's) love.

Being the first _complete operating system_ to embrace the full-disclosure mentality means that OpenBSD also publishes its errata. They also provide anonymous CVS for their source version control. To me, these two points are very impressive for security and educational purposes.

If you are smarter than I am then you can solely rely on the `man` pages for most day-to-day tasks, but if that didn't help, you can always visit the [official FAQ](https://www.openbsd.org/faq), the more polished [handbook](https://www.openbsdhandbook.com) or external guides.

### Design and innovation

I feel like this is a better BSD than my old favorite FreeBSD. After watching many YouTube videos on [Theo De Raddt](https://en.wikipedia.org/wiki/Theo_de_Raadt) and OpenBSD's mitigation (the intense audit process, `pledge()` and other random randomization), I was very impressed with the engineering behind the system and its sub-components. Now that `wireguard-go` is available in OpenBSD's official repository, I hope they will replace IPsec with Wireguard in their network stack soon.

### In-house software

[LibreSSL](https://www.libressl.org), `openssh(8)`, `httpd(8)`, `pf(4)`, `doas(1)`, and `openrsync(1)` are some of the examples of how to **properly reinvent the wheel**. This is how we know Theo is such a cool programmer: he won't accept bad code. These sub-components are so great they are used in other operating systems.

## Drawbacks

This might be a drawback for some folks: as a _research_ operating system for computer security, and the fact that Theo only accepts free firmware (bye-bye Nvidia and Wi-Fi), OpenBSD is slow to adopt new technology, especially proprietary technology (they will have to reverse-engineer to make things work). If you are on laptops, keep in mind that hyperthreading will be disabled, and some of the hardware may not work. Also, security has performance impact (For example Hyperthreading/SMT is disabled in OpenBSD), and the filesystem is slow. OpenBSD also has less number of ported software compared to FreeBSD. Documentation of non-OpenBSD software is also less abundant than, say, Linux or FreeBSD.

## Conclusion

OpenBSD is, to me, a perfect operating system to build simple and secure UNIX networking boxes (e.g. a router, a name server, mail server or a simple webserver). It is however, not suitable for full-fledged desktop use, due to the reasons cited above. Its security-focused theme and unique proposition in the OS world will definitely attract more advanced UNIX computer users. If you are into good code, sane default configs, and DIY mindset, deploying OpenBSD on production is undoubtedly a good old way to learn computers. I too am considering moving my website from FreeBSD to the [OpenBSD box](/blog/2020/bsdbox/), as OpenBSD already ships with complete and high quality web stack, namely `httpd(8(`, `relayd(8)`, and its own [acme-client(1)](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) ACME client.

## OpenBSD encrypted installation guide

### Prerequisites

At the installer, select `shell` (only the original `sh` shell is available on the installer, although OpenBSD's default shell is `ksh`) to prepare the system for installation. Let's first initialize `sd0`:

```shell
cd /dev && sh MAKEDEV sd0;
```

and fill it with random data to randomize the whole disk:

```shell
dd if=/dev/urandom of=/dev/disk/rsd0c bs=1M;
```

Note that, `c` is a special partition identifier that points to whole disk. On OpenBSD, the `a` partition is always the root, `b` the swap, and `c` the whole disk.

### Partitioning

#### Note: This is only for legacy boot systems.

I first used `fdisk(8)` to write to the partition table:

```shell
fdisk -iy sd0;
```

And then used `disklabel(8)` (in interactive-editor mode) to partition the disk:

```shell
disklabel -E sd0;
```

We can now add `a` partition on `sd0` that will occupy all (hence `*` size) available space left on `sd0`. The resulting `sd0a` will be used to house our encrypted "softraid" FS in the `disklabel` prompt:

```
a a
size: [2490031] *
FS type: [4.2BSD] RAID
sd0*> w
sd0> q
```

Now that `sd0a` `disklabel` partition is created, we can now use `bioctl(8)` to configure and create RAID out of `sd0a`:

```shell
bioctl -c C -r 8192 -l /dev/sd0a softraid0;
```

This should create `sd1` softraid device `softraid0`. The `bioctl(8)` option `-c C` denotes that our RAID will use `crypto` cypher instead of the traditional RAID level. We can now exit the shell so as to return to the installer:

```shell
exit;
```

At the installer prompt, don't forget to choose `sd1` RAID device instead of `sd0` raw disk. Now you can continue with basic OpenBSD installation.

Enjoy OpenBSD!
