Oct 22, [2020](/blog/2020/)
# Deploying WireGuard on [OpenBSD](https://openbsd.org) and [Arch Linux](https://archlinux.org)
## My WireGuard impression
I have been using [WireGuard](https://www.wireguard.com/) on Arch Linux, macOS, and iOS since June 2020, and have been very satisfied with the results so far. WireGuard is (as per its author) *next-generation* VPN protocol, and it is considered a *blasphemy* in VPN world. WireGuard only operates on Layer 3, only uses UDP, and does not allow users to choose their cryptography of choice (instead, WireGuard enforces very strong cryptography - visit the [project website](https://wireguard.com) for more info). The main idea of WireGuard is [crypto routing](https://www.wireguard.com/#cryptokey-routing).

This means that its code base is relatively much smaller than other VPN code, thus porting to other platforms can be done much more effectively despite being originally designed for the Linux kernel. Its speed, reliability, security, and how it appears state-less to the outsiders is what makes WireGuard very interesting choice for those looking for a way to encrypt their traffic.

This guide covers the basic interface configuration on both operating systems, as well as the corresponding firewall rules, `pf(4)` for OpenBSD, and `iptables(8)` (and optionally `ufw(8)`) for Arch Linux.
## WireGuard on OpenBSD
OpenBSD is [my webserver operating system](/blog/2020/bsdbox/) - **it comes complete** with all the server tools I need. WireGuard functionality was also available on OpenBSD as external packages `wireguard-go` and `wireguard-tools`. Just recently, the OpenBSD developers decided they would include WireGuard code into their base networking stack with their 6.8 *Release*, removing the need for external packages. This means that OpenBSD is even more complete as a server operating system for me. Next is how we can configure the `wg(4)` interface (or `tun(4)` in pre-6.8 OpenBSD).

Note: WireGuard servers which act as VPN routers must have IP routing enabled, if you are only using Wireguard to connect peers, then you can skip this step:

    # touch /etc/sysctl.conf
	# echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf

This should make the configuration persistent on next boots.
### OpenBSD 6.8 - native WireGuard
WireGuard was [ported to base as `wg(4)`](https://man.openbsd.org/wg) in OpenBSD 6.8, which means that `wireguard-go` package is now outdated. This means now **one can configure `wg(4)` interface directly from `hostname.wgX` (via `ifconfig(8)`) file without having to use WireGuard user-space tools**.

I upgraded to 6.8 a few days ago, and promptly removed `wireguard-go` and `wireguard-tools` to minimize the number of external packages. To configure WireGuard on OpenBSD, add the following information to `hostname.wgX` file, for example `hostname.wg0`. I only relied on the manual page for `wg(4)` to set this interface up, but here is another guide I write as a quick reminder for myself.

In this example, **we will NOT use any WireGuard packages, so `wg genkey`, `wg pubkey`, etc. must be done on other machines**. The example will use 10.9.0.0/24 network. The `hostname.wg0` interface configuration ([see `hostname.if(5)`](https://man.openbsd.org/hostname.if.5)) file for OpenBSD 6.8 should look like this:

    # /etc/hostname.wg0
	
	# Interface configuration
	wgkey yourPrivateKey=
	wgport yourListenPort
	inet 10.9.0.1/24
	up
	
	# Adding WireGuard peers
	!ifconfig wg0 wgpeer dfjsldkfldsk=  wgendpoint example.com 11210 wgaip 10.9.0.2/32
	!ifconfig wg0 wgpeer adfjdksjdsdf=  wgaip 10.9.0.3/32 # this peer doesn't have endpoint

**Note that `wgpeer` values are the peer public keys**. For the lines starting with `!`, [`netstart(8)`](https://man.openbsd.org/netstart) will run the command after the `!`. See the man pages for `wg(4)`.

After you are done with `hostname.wg0` file, try bringing up the interface with

    # sh /etc/netstart wg0;

After editting the file, reboot, and at the next boot we can check the `wg0` interface by using `ifconfig(8)`: `# ifconfig -A`. If `ifconfig -A` is not run as root, you will not see the public keys. OpenBSD with WireGuard included in the kernel is surely a bless for me.
### Pre 6.8 - using `wireguard-go` and `wireguard-tools`
The VPS I use to run this website is on OpenBSD ([originally 6.7](/blog/2020/bsdbox/)), and WireGuard is also available on the platform as installable packages `wireguard-go` which is the WireGuard implementation in Go, and `wireguard-tools` which provides user-space WireGuard tools like `wg-quick(8)` (`wireguard-tools` depends on `bash` - FYI) etc.

With the packages, we can generate our keys locally:

    # wg genkey | tee foo.key | wg pubkey > foo.pub
	# wg genpsk > foo.psk

To configure the VPN interface on OpenBSD 6.7 where WireGuard is not yet available in the kernel, we will have to write both [`hostname.tunX` (`hostname.if(5)`)](https://man.openbsd.org/hostname.if.5) file to configure the [`tun(4)`](https://man.openbsd.org/tun.4) interface as well as a WireGuard configuration file (i.e. the file in `/etc/wireguard`), and also `rc.conf.local(8)` to start the `wireguard_go` service. [This is the guide by Jasper (the porter)](https://jasper.la/posts/wireguard-on-openbsd/) to WireGuard I followed when I was running 6.7. I personally prefer OpenBSD 6.8's approach to WireGuard which is much simpler.
### [pf(4)](https://man.openbsd.org/pf.4) configuration
`pf(4)` (packet filter) is OpenBSD's *firewall* that is so good it is ported to many other operating systems, most notoriously FreeBSD and its derivatives ([pfSense](https://pfsense.org), macOS, iOS, etc.). On OpenBSD, `pf(4)` is usually interacted with via `pfctl(8)`.

It took me a few hours until I could figure out the filter rules for WireGuard (yes, I am that dumb). **I recommend that you first start from basic configuration, then test the connection, and start building the firewall up from there**. Below is a working configuration for my use case - the server is able to both reach other endpoints, and other clients can also reach the server's endpoint. Here, I will demonstrate how to build the firewall rules up from the basic. The following example uses [*macros* and *lists*](https://www.openbsd.org/faq/pf/macros.html) to build the rules. If `# pfctl -n -f /etc/pf.conf` throws errors, it may be from failure to expand these lists and macros.

My goal is to have a firewall that silently drops all non-WireGuard packets other than the ones I explicitly allow. I first determine which interfaces would be skipped by `pf(4)` in `pf.conf(5)`:

	# /etc/pf.conf
	wgif = "{ wg0, wg1 }" # maybe 'tunX' on OpenBSD pre-6.8
	skif = "{ lo0, $wgif }"
    
	# skip packet filtering on these
	set skip on $skif 

Then I set the default block policy to `drop`, and enter my first two rules `block all`, and `block in quick urpf-failed`. This should set our default policy to block all traffic on all interfaces sans the skip inferfaces `$skif` (which expands to `lo0`, `wg0`, and `wg1`), and all incoming traffic that failed URPF (Unicast reverse path forwarding) test.

In `pf.conf(5)`, *last matching rule wins*, so it's nice to put the `block all` line before any `pass` rules:
    
	# silently drop traffic
	set block-policy drop

    # default is to block all traffic
	block all
	
	# block incoming traffic that failed urpf 
	block in quick urpf-failed

I then open some external ports for WireGuard (`wgports` 32624 and 42836) to all UDP traffic for WireGuard, and also other rules I want to apply to non-WireGuard interfaces:

	# wireguard needs open udp port(s) for listening
	wgports = "{ 32624, 42836 }"
	pass quick log proto udp to port $wgports
	
	# open tcp ports, such as ssh and webserver
	tcpports = "{ 22, 80, 443 }"
    pass quick log proto tcp to port $tcpports
	
	# dns lookups
	pass quick out proto udp to port 53

Then, I added the following line for `pf(4)` to properly handle WireGuard traffic, as well as NAT. Although most of the times `pf.conf` *actions* can be arbitarily positioned, this time `proto udp` must come after `pass in on egress inet`:

    # pf config for WireGuard
	pass in on egress inet proto udp from any to any port $wgports
    pass out on egress inet from ($wgif:network) nat-to (egress:0)

And test the configuration, as well as actually reload the firewall rules with `pfctl(8)`:

    # pfctl -n -f /etc/pf.conf # dry-run
	# pfctl -f /etc/pf.conf

Now you can try the connection by pinging other hosts in the WireGuard network.
## WireGuard on Arch Linux
Because WireGuard is originally designed for the Linux kernel, and is now part of the kernel since version 5.7, we only need to install `wireguard-tools` which provide `wg(8)` and `wg-quick(8)`:

    # pacman -S wireguard-tools

If you use non-default Linux kernel, you may have to install a corresponding WireGuard kernel module, e.g. `wireguard-dkms` or `wireguard-lts`.

Then, we simply write a text configuration file (for example, `wg0.conf` in `/etc/wireguard`). You can just follow the guide on the [Arch Wiki](https://wiki.archlinux.org/index.php/WireGuard). After the connection is working, we can persistently enable the connection as a `systemd(1)` service like so:

    # systemctl enable --now wg-quick@wg0.service

Note that on Arch, `@wg0.service` part refers to `/etc/wireguard/wg0.conf` file, i.e. if you have `/etc/wireguard/server.conf` the service name is `wg-quick@server.service`. After the service is running, we can check the connection status by issuing: `# wg`.
### `iptables(8)` and `ufw(8)`
Also, we need to put the commands to set firewall rules for both IPv4 and IPv6 in `PostUp` and `PostDown` section in your WireGuard configuration in order to properly set up the connection (note that the following configuration features 2 example interfaces `em0` and `em1`):

    # Adding iptables rules (-A) for wg0 after bringing the interface up
	PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; \
	iptables -t nat -A POSTROUTING -o em0 -j MASQUERADE; \
	ip6tables -A FORWARD -i wg0 -j ACCEPT; \
	ip6tables -t nat -A POSTROUTING -o em0 -j MASQUERADE; \
	iptables -A FORWARD -i wg0 -j ACCEPT; \
	iptables -t nat -A POSTROUTING -o em1 -j MASQUERADE; \
	ip6tables -A FORWARD -i wg0 -j ACCEPT; \
	ip6tables -t nat -A POSTROUTING -o em1 -j MASQUERADE
    
    # Deleteing iptables rules (-D) for wg0 after bringing the interface down
	PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; \
	iptables -t nat -D POSTROUTING -o em0 -j MASQUERADE; \
	ip6tables -D FORWARD -i wg0 -j ACCEPT; \
	ip6tables -t nat -D POSTROUTING -o em0 -j MASQUERADE; \
	iptables -D FORWARD -i wg0 -j ACCEPT; \
	iptables -t nat -D POSTROUTING -o em1 -j MASQUERADE; \
	ip6tables -D FORWARD -i wg0 -j ACCEPT; \
	ip6tables -t nat -D POSTROUTING -o em1 -j MASQUERADE

I then use `ufw` to easily configure open UDP port (in this example `42836`) for WireGuard:

	# ufw allow 42836/udp

With this configuration, your Arch WireGuard should be able to do crypto routing and NAT-ing.
## My usage of WireGuard
I do everything almost always under WireGuard connection, except of course the webserver outgoing connection. All of my services, e.g. DNS lookups, Plex, Syncthing, and NFS all are done over the `wgX` interface(s). I also optionally have another interface `wgY` specifically for routing all of my traffic over VPN to overseas endpoints.

Here is some good use cases of WireGuard as a point-to-point VPN, i.e. (virtually) directly connecting two hosts. My [Syncthing](https://syncthing.net) configuration explicitly requires WireGuard connection for peer discovery, transfer, and web GUI. Another example is DNS-over-VPN. In my case, my home [ThinkCentre](/blog/2020/covid-19/) is configured a fully encrypted nameserver - it uses `stubby` (DNS-over-TLS) as a stub resolver, and [Pi-Hole](https://pihole.com) (`dnsmasq`) as DNS server. With WireGuard, I could remotely access my home DNS server, get the ad-blocking functionality, as well as encrypt my *otherwise plain-text* port 53 DNS queries. Unless `stubby` is down, no one should be able to see my DNS requests.

> One advantages of WireGuard over plain connection is how godly it can survive network timeouts - if I `ssh` over WireGuard, I could shut my [notebook](/blog/2019/thinkpad/) lid and when I open it back up, and the connection would still be there.

## Conclusion
WireGuard is a great VPN tool - it is easy to understand, easy to use, easy to setup on new devices. Adding a new peer only requires copy-pasting a few lines of configuration. On top of that, it is fast, secure, and available to almost all popular computing platforms. From my experience, its speed (both transfer and handshake) and robustness far surpassed OpenVPN, and these points are especially important when your remote hosts is far away. This is why I see no reason why one should use something else, unless it is a requirement by the organization to use other VPN protocols. 
