Sep 19, [2020](/blog/2020/)

Last reviewed: Feb, 2021

# artnoi.com is now on OpenBSD!

[After a few days on OpenBSD](blog/2020/openbsd/), I have made my mind to move the webserver from Digitalocean [FreeBSD](https://freebsd.org) VPS (pre-installed on ZFS) to my custom OpenBSD installation on Vultr (Here is a random [guide I found on Google for encrypted installation](https://cryptsus.com/blog/wireguard-vpn-privacy-server-on-a-vultr-cloud-vps-on-openbsd-6.6-with-full-disk-encryption.html?fbclid=IwAR1tRIZ9iXhV2HN3eDp_8Y1nrqjzW14Ko-rxph5lYHdfeOs4pSOkIKqsUUQ)).

The process took me ~30 minutes from spinning up a fresh VM to when everything including HTTPS is ready. Because Poudriere is no longer needed, ports.artnoi.com is no longer available.

## Why OpenBSD?

OpenBSD's base comes **complete** with all the software required to build a secure and simple webserver, namely:

- `httpd(8)` simple webserver

- `relayd(8)` relay and proxy, `httpd` is actually based on `relayd`

- `pf(4)` packet filter, some of the best firewall software

- `wg(4)` small, fast, and secure VPN originally for Linux

- `acme-client(1)` [ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) client

- `openssh(8)` secure remote shell

## httpd vs NGINX

> TLDR: NGINX is used only as my HTTPS front-end for the clients to establish secure connections.

Although I am very impressed with [NGINX](https://nginx.com)'s webserver performance, I find OpenBSD's `httpd(8)` to be just good enough to serve a mostly static text website, so I switched my main webserver from NGINX to `httpd(8)`.

Then I found out that it is currently impossible to change error page on OpenBSD `http(8)`, but that can be mitigated with proxies.

I do however continue to use NGINX to serve [bloated web pages](https://docs.pi-hole.net/guides/nginx-configuration), and as relays (proxies) for my HTTPS front-end. I tried OpenBSD's `relayd(8)` as internet-facing reverse proxy. But because I'm a noob, my `relay.conf(5)` had some _minor_ with TLS, where it seemed my server did not serve all the certificates needed. This was very small, and barely noticable that desktop users won't even notice this, since the incomplete handshake was acceptable to Firefox and Chrome (both of which I believe have root certficates that could actually verify my incomplete certificate).

So I have to use NGINX as my internet-facing reverse proxy for now, though I still put OpenBSD `relayd(8)` behind NGINX to actually proxy connection to the actual webservers, filter incoming HTTP headers, and actively load-balance the hosts through Wireguard tunnel.

## Configuring httpd(8)

### Simple httpd.conf(5)

This configuration is for serving simple HTTP website on non-standard port 8080

```
## GLOBAL configuration

httpd_ip = "127.0.0.1"

# Content types
types {

  # uncomment 'include' line below to use all types
  # include "/usr/share/misc/mime.types"
  application/pdf pdf
  image/png       png
  image/svg+xml   svg ico
  text/css        css
  text/html       html htm
  text/plain      txt

}

## Virtual servers
server "artnoi.com" {
  alias "www.artnoi.com"
  listen on $httpd_ip port 8080
  root "/htdocs/html-artnoi.com"
}
```

Check `httpd(8)` configuration `/etc/httpd.conf` with:

```shell
httpd -n -f /etc/httpd.conf;
```

If you want to run `httpd(8)` as daemon, configure `rc(8)`.

## HTTP with TLS using httpd(8) and acme-client(1)

We can configure HTTPS on OpenBSD `http(8)` with out any external packages. There is an article on [OpenBSD Handbook](https://www.openbsdhandbook.com)

services/webserver/ssl) on how to do this. In short, you first set up `httpd(8)` to be ready to handle [ACME](https://en.wikipedia.org/wiki/Automated_Certificate_Management_Environment) challenges via simple port 80 HTTP. (OpenBSD ships with a production-ready ACME client `acme-client(1)`! How about that!?).

### Configuring acme-client(1)

We will be using _production_ server here

```
authority letsencrypt {
  api url "https://acme-v02.api.letsencrypt.org/directory"
  account key "/etc/acme/letsencrypt-privkey.pem"
}

domain artnoi.com {
  alternative names { www.artnoi.com }
  domain key "/etc/ssl/private/artnoi.com.key"
  domain certificate "/etc/ssl/artnoi.com.crt"
  domain full chain certificate "/etc/ssl/artnoi.com.fullchain.pem"
  sign with letsencrypt
}
```

### Configuring httpd(8) for ACME challenges

Now, configure `httpd(8)` to properly handle ACME challenge connection when we later run `acme-client(1)`. You should read [how Let's Encrypt ACME challenge works](https://letsencrypt.org/how-it-works/).

> Only `server` directive (block) is shown

```
server "artnoi.com" {
  alias "www.artnoi.com"
  listen on $httpd_ip port 80
  root "/htdocs/html-artnoi.com"

  # acme challenge
  location "/.well-known/acme-challenge/$ext_if" {
    root "/acme"
    request strip 2
  }
}
```

### Obtaining Let's Encrypt Certificate

After you are done configuring `acme-client.conf(5)` and `httpd.conf(5)`, use `acme-client(1)` to get challenge the our webserver and obtain Let's Encrypt certificates on OpenBSD:

    # acme-client -v artnoi.com;

Based on our `acme-client.conf(5)`, our certificates should verify both artnoi.com and www.artnoi.com.

If you fail, recheck `pf.conf(5)`, `httpd.conf(5)`, the DNS records for your domains, and the permission of `/var/www/htdocs/.well_known`.

## Enabling HTTP with TLS on httpd(8) (with redirection to HTTPS)

We now need 2 servers in `httpd.conf(5)`, first is the main server listening on 443 for HTTPS, the other listens on port 80 and is specifically for redirecting incoming HTTP to HTTPS.

> Only `server` directives (blocks) are shown, and note the `tls` option on HTTPS `listen` line.

```
server "artnoi.com" {
  alias "www.artnoi.com"
  listen on $httpd_ip tls port 443

  tls {
    certificate "/etc/ssl/artnoi.com.fullchain.pem"
    key "/etc/ssl/private/artnoi.com.key"
  }

  root "/htdocs/html-artnoi.com"

  # acme challenge
  location "/.well-known/acme-challenge/$ext_if" {
    root "/acme"
    request strip 2
  }

}

server "artnoi.com" {
  alias "www.artnoi.com"
  listen on $httpd_ip port 80

  # redirect to https
  block return 301 "https://artnoi.com$REQUEST_URI"
}
```

Right now, httpd(8) should spawn 2 virtual servers, one on port 443 for HTTPS, and one on port 80 for HTTP. The one on port 80 will actually redirect to HTTPS port 443, if the request location is not `.well-known`, which is challenged by ACME certificate servers.

You should be able to renew the certificates without having to change configuratiom, i.e. bring down your small website.

Enjoy!
