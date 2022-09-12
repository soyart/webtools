Aug 12, 2022

# I reset my infrastructure
In the last 2 days, I noticed that there've been strange *things* going on my servers. My website was taken down because the load balancer could not connect to the backend at my home over Wireguard.

And because my servers' services are built around Wireguard, when it breaks, the entire thing is down, including my home DNS. My family alerted me that our home internet was not working, which meant that the home server could not reach out to my Vultr server.

## Someone broke into my servers..
So I went home and began investigating, and found out that someone has broken into my backend server at home, and they removed the Wireguard keys from my server at home!

Furthermore, the entire ZFS dataset dataset data was missing - that is, the ZFS dataset is still there, but the files are missing. This is very strange and should not happen on its own, so I suspect there was an attacker behind this.

I took my services down, and started going through the logs. What I found is that, the attacker was likely from eastern Europe, and may have attacked me because I was attacking the Russian government and propaganda websites first (back in April).

## My responses
I unpluged the home server, destroyed the VPSs, and replaced all authentication keys - from SSH keys, Wireguard keys, and the user/root passwords. Every *namespace* is also replaced, from the network IP addresses, to usernames, hostnames, and the service ports.

## Pre-attack layout
Before the attack, my infrastructure was dead simple: I have my *own* machines that I used myself (let's call it my user machines), and then I have these *servers* which just runs all the time and unattended.

All of my *user machines* are connected to the servers almost exclusively via Wireguard, and all of these *user machines* have firewalls enabled on all ports and protocols for the incoming connectiom, meaning that they'll drop any incoming packets from the connections they did not initiate. The *user machines* are also not turned on 24/7, and I only use each of them a few hours a day. This kept my *user machines* safe.

This is however different for my servers. Although most of my servers have firewall enabled too on the public interface, there are some ports that needs to be open, e.g. a port for emergency SSH in case Wireguard failed, and the basic webserver ports for the load balancer, or a port that is for Wireguard over DDNS (IP forwarding from the router).

These factors alone would not make my servers so vulnerable, *except for the fact that some of these servers also host the SSH keys for other servers too*. For example, the one in my home holds they key to one of my Vultr Linux VPS. This is a grave mistake, because if an attacker could get into one of these servers, then they could easily login to the others.

## Rebuilding everything
Knowing this, I understand that my Linux servers are all compromised, except for one - the one running OpenBSD.  Nonetheless, I knew I had to destroy all my Vultr servers and unplug the home server, which I did promptly. After taking down the compromised boxes, I started thinking on what to do next.

I still want to host my own website, I hate GitHub pages, but it seems that my old practice of hosting almost everything on random server does not fit well with today's cybersecurity recommendations. I also realized that having all my machines connected in the same Wireguard network is a risk, and I would want to avoid that this time.

So, my new plan is easy, *everything will be separated*.

### Rebuilding the webserver
First, I will setup an OpenBSD VPS server (which I already did yesterday to host artnoi.com). This server will have only 1 purpose - to host artnoi.com. It will only have 3 exposed ports - `80` and `443` (TCP) for the webserver, and a UDP port for Wireguard.

It will not have any IP forwarding enabled, and I will only SSH into it over Wireguard.

I chose OpenBSD for the webserver because of the same old reason - *it works*. OpenBSD ships with `httpd(8)`, `relayd(8)`, and it has robust firewall `pf(4)` and Wireguard driver built into the kernel (`wg(4)`). This means that I need very little extra packages on top of the OpenBSD `base` for building a HTTPS webserver, with Wireguard connection for admin purpose.

### Rebuilding other services
And now I'm done with the webserver. The next part is a general purpose personal server. There are many reasons I need the personal server, first, I need it for tunneling my traffic to it if I needed to, and, to host other services that I'd hate to host on my read hardware.

The hard part is, how do I separate these services into different servers? Will this incur extra hosting costs to me if one server only runs one service? Or do I use containerization to manage all these services separately on one host server?

I think this time, I'll be going with Docker. Although it is not very lightweight, it *should* in theory offers some kind of separation for me, and if the containers are configured properly, it should be secure enough. I'll also get to learn *real* Docker this time.

My plan is that, I'll build another Arch Linux home server on my ThinkCentre, and I will run Docker on the home server. Then, I'll build another small Vultr VPS for small services, like Wireguard tunneling, and BitTorrent downloads.

So before that is done, I'll be busy experimenting with Docker and some mind excercises.
