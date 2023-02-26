Nov 14, [2020](/blog/2020/)

# Deploy an SSH tarpit with [Endlessh tarpit (honeypot)](https://nullprogram.com/blog/2019/03/22/)

## Why use SSH tarpit?

The main idea of SSH tarpit or honeypot is to trap script-kiddies who try to brute-force attack our servers with some scripts (via [SSH](<https://en.wikipedia.org/wiki/SSH_(Secure_Shell)>), obviously).

`endlessh` will pretend to _establish_ the connection to any incoming SSH connection on the port(s), and then proceed to **send random SSH login banner lines endlessly without triggering a connection timeout on the attacker side**, hopefully to trap unattended attacks inside this loop forever.

## Endlessh on Arch Linux

Install AUR package `endlessh-git`, edit some configuration in `/etc/endlessh.conf`, and start the service `endlessh.service`

> Because of my paranoia that I may have irritated an attacker for taking his precious time away, my `endlessh` is deployed in a chroot jail on the tarpit box to minimize any risks of the attacker taking over any of the two machines.

## Endlessh on Artnoi.com

The source is [available on GitHub](https://github.com/skeeto/endlessh). I am too lazy to patch it for OpenBSD, [which is what my webserver is running](/blog/2020/bsdbox/), therefore I built the software and enabled it a different platform, and have OpenBSD's [`relayd(8)`](https://man.openbsd.org/relayd.8) relay the SSH connections into the box running `endlessh`.

## Using Endlessh on different hosts with proxies

OpenBSD's man page for [`relayd.conf(5)`](https://man.openbsd.org/relayd.conf.5) also has an example for relaying SSH connection. And because of `relayd(8)`, we can just spin up one instance of `endlessh` to listen to multiple ports on the OpenBSD box. If you are not on OpenBSD, feel free to use any software that could proxy TCP connections.

## Using TCP proxy for Endlessh with relayd or NGINX

Simple TCP proxies can be used to redirect connections coming to the host you want to protect to other hosts, or the same hosts but to the port that `endlessh.service` is listening on.

Proxying can help us guard the privileged port 22 without having to actually run Endlessh on that port, although it is the proxy who ultimately will have to run as root to listen on port 22.

In this example, I will show you how to set this proxy up, for both OpenBSD `relay(8)` and [NGINX](https://nginx.com).

### Proxy Endlessh using OpenBSD relayd(8)

You can just copy the ssh example from `relayd.conf(5)` man page. In short, we first define a simple `relayd` protocol to _properly_ relay TCP connections. Then we create a relay using the protocol we defined to relay the connection from listening port to target (the one Endlessh is running on):

> Note: only relavant portion is shown. You probably need to write some more global configuration, define some macros and host table, etc.

    protocol "tcp_relay" {
      tcp { nodelay, socket buffer 65536 }
    }

    relay "sshforward0" {
      listen on $ipv4 port 22 #interface vio0
      protocol "tcp_relay"
      forward to $wg_endlessh port 2222
    }

    # Load-balance
    # Load-balancing will need to specify a table as forward-to host

    relay "sshforward1" {
      listen on $ipv4 port 2222 #interface wg0
      protocol "tcp_relay"
      forward to $wg_endlessh port 2222 mode loadbalance check tcp
    }

### Proxy Endlessh using NGINX

NGINX also has support for TCP relays, but called `stream`. The following configuration will define an upstream (equivalent to OpenBSD `relayd`'s _table_), and create a virtual server listening on port 22 that will proxy stream (SSH connections) to upstream `endlessh`, which expands to 2 hosts.

If I understand correctly, by using `upstream` directive, NGINX should also load-balance the connections instead of just proxying.

    stream {
    upstream endlessh {
      server 127.0.0.1:2222 max_conns=3;
      server 10.8.0.69:2222;
    }

    server {
      listen     22;
      proxy_pass endlessh;
    }

## Visual examples

The only difference between _my_ SSH connection and the others is the destination port, which is not accessible outside of my VPN.

     SSH connections ---> artnoi.com -(relay)-> Endlessh jail server
     My SSH connection -> artnoi.com

## Example output on the attacker side

     $ ssh -v artnoi.com
     OpenSSH_8.4p1, OpenSSL 1.1.1h  22 Sep 2020
     debug1: Reading configuration data /home/artnoi/.ssh/config
     debug1: Reading configuration data /etc/ssh/ssh_config
     debug1: Connecting to artnoi.com [45.32.125.13] port 22.
     debug1: Connection established.
     debug1: Local version string SSH-2.0-OpenSSH_8.4
     debug1: kex_exchange_identification: banner line 0: 1m]+
     debug1: kex_exchange_identification: banner line 1: i^'i
     .
     .

And it goes on and on and on!
