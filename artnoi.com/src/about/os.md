# My operating systems

To me no one operating system is perfect. Each is a tool, and thus must be paired with the right job.

Below is my rather unpopular opinions about my prefered operating systems.

## Server

### Networking server - [OpenBSD](https://openbsd.org)

A basic server to me is one that just provides basic "server" functionality, that is, networking infrastructure. Examples of this is a router, load-balancer, VPN nodes, TLS accelerator, reverse proxies, etc. This type of server is usually used for public-facing application.

And because of the nature of their jobs, _security matters **a lot**_ for this type of server. An operating system operating in this capacity _must_ have robust networking stack, i.e. secure/fast firewall, integrated cryptography, safe TLS implementations, and the operating system developers should priotitize security over features.

**This is why my public-facing boxes only run OpenBSD**. OpenBSD is a very robust operating systems, and it feels like it's designed specifically to be used in this role, although this is not the case, as OpenBSD strives to be great for both desktop and server users.

OpenBSD includes all of the classic and safe services you'd expect from a UNIX box (OpenBSD removed telnet support and decrepated other insecure protocols periodically). They have sane defaults (unlike FreeBSD), and everything they ship is of very high quality. For example, if you're deploying a webserver, [OpenBSD's `base` got you covered](/blog/2022/openbsd-webserver/). Here's a list of OpenBSD software I really love and is included in `base`:

- `pf(4)` - the best firewall out there

- `relayd(8)` - a robust L3/L7 relays, can be used as load-balancer or TLS accelarator

- `wg(4)` (not OpenBSD-original) - an OpenBSD implementation of the Wireguard protocol. Very well written, unlike FreeBSD's original, floppy take. [Although now FreeBSD also enjoys a great `wg` implementation overseen by J. Donenfeld](https://lists.zx2c4.com/pipermail/wireguard/2021-March/006494.html).

- OpenSSH - the _only_ great free full implementation of SSH

- `httpd(8)` - simple, HTTP server with TLS support

- `acme-client(1)` - native ACME client

- `unbound(8)` (not OpenBSD-original) - great if you're deploying a DNS server

- `unwind(8)` - great if you just want DNS-over-TLS and not converting your box to a full blown DNS stub resolver

### Application server - [Arch Linux](https://archlinux.org)

I chose Arch over OpenBSD to run the backend code simply because it is a lot more modern. A lot of backend application inftastructure (like Docker, Kubernetes, and other services like Redis and PostgreSQL) is available right from the repo, and they're in their latest versions.

The language support is also great - Arch usually enjoys the latest version of language packages. For compiled languages, Arch is great because it is like any other GNU/Linux targets - so you can deploy any Docker images or Linux binaries easily.

Arch Linux is also flexible enough to be any kind of server you like. In fact, I once used it in the same role as with my OpenBSD box, [but I don't want to risk another attack](/blog/2022/reset/).

The main reasons I use Arch for my application servers are:

- The Arch Wiki

- It can run almost anything

- It can be tweaked to do anything

- It's just another GNU/Linux box

- Newer packages compared to other Linux server distros

### Desktop and software development - Arch Linux

My desktops and laptops have all ports closed all the time, so it's worth to risk a little in exchange for all the modern features of the Linux kernels. In the past I used to used both macOS and Linux for my personal desktop use, since my Wayland-enabled Arch failed to share my screens during meetings. But now this has been fixed, so I no longer use macOS for my personal use.

And because the language support is great on Arch, I can always write in almost any production quality languages with their latest features in Arch.

- The Arch Wiki

- Very good hardware support for consumer applications, like GPU hardware acceleration in DEs and browsers

- AUR is great

Another contender for this use case is [Void Linux](https://voidlinux.org), which is similar to Arch in many regards, including minimalism, DIY, KISS, and other ideas, but does not come with systemd. Instead, Void uses traditional init systems. This is great, especially for desktops, so that we don't have to translate complex systemd unit files for most server applications to traditional init scripts. (Damn, some software even depends heavily on systemd that this made it impossible to run it as a service without systemd proper)

### Work - macOS

My work gave me an Apple-silicon MacBook Air, so I'll have to stick with it. I might be switching to [Asahi Linux](https://asahilinux.org) soon, now that the reverse-engineered GPU driver finally starts working properly. macOS also supports many proprietary software I use in work, like Slack.
