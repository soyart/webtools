Feb 26, [2021](/blog/2021/)

I have some spare time, so I decided to write how I put this website together with all the proxies.

# Building HTTPS relays and reverse proxies for artnoi.com

I have been using [my OpenBSD box](/blog/2020/bsdbox/) to serve this website since last year, and it has been running strong. However, using only `httpd(8)` to serve this website also has one downside - _downtime_, which is quite annoying when you have to do some maintenance tasks.

I thought about adding another webserver, but then I realized if I was going to make my web stack more complex than needed, why _not_ build a load-balancer or reverse proxies too this time, so that I don't have to worry about downtime when one of the webservers is taken down.

The addition of [searx.artnoi.com (artnoi.com/searx)](/searx) neccessitates the need for a result proxy `filtron` and image proxy `morty`, which is exactly what NGINX is typically used as reverse proxies for.

> [Searx documentation about `filtron` and `morty`](https://searx.github.io/searx/admin/installation-nginx.html#nginx-searx-site)

## Overview

The diagram of what I had in mind looks something like this:

    # Redirect to HTTPS
    HTTPS clients: http://artnoi.com
    > HTTPS proxy	:80 HTTP 301 https://artnoi.com

    # Relays and reverse proxies
    HTTPS clients: https://artnoi.com
    > HTTPS proxy	:443
    > Load balancer :8082
    > Webservers	:8080 HTTP 200 OK

Non-Searx part can be configured with the design above very easily, and one OpenBSD machine can do this. I knew OpenBSD ships with its own `relayd(8)`, but that would mean my entire webstack would rely solely on OpenBSD utilities (which is a good thing).

_But_ I cannot do the Searx part on OpenBSD unless I installed Python and other crazy $h!t packages on my OpenBSD to run Searx.

Because I want to not install any extra software at all on OpenBSD, and the fact that I may be even too noob to patch this to run on OpenBSD, _I will do the Searx part on Arch Linux_.

OpenBSD will be the main webserver, and `relayd(8)` will also be used **to make it seem more complicated than it should be**, because why not? The web is bloat, bruh!

## OpenBSD relayd(8)

[OpenBSD](https://openbsd.org) ships with `relayd(8)`, a simple relay daemon that can dynamically redirect incoming connections to target hosts. It can be configured with `relayd.conf(5)` pretty easily, and the manual page contains many useful examples for relaying and redirecting different connections.

But when I tried `relayd(8)`, although it could do the relays and redirections just fine, I had some minor problems with TLS, and this escalated further when I tried adding new webservers (e.g. the one doing [searx.artnoi.com](/searx) on different hosts to the relays.

Obtaining a certificate was a headache, and more so when serving it, e.g. renaming or linking the certificate to the actual IP address of the interface is tiring.

So I had to find something else, but could not found anything satisfying except for NGINX

> TL;DR - For now, `relayd` is not used as HTTPS proxy, but HTTP and other TCP/UDP connections (e.g. [SSH](/blog/2020/endlessh/)).

## [NGINX](https://nginx.com)

OpenBSD also provides binary package for [NGINX](https://nginx.com), a widely-used webserver and proxy software. NGINX has advantages in that it is cross-platform and thus configuration can be copied over from one system to another without much efforts.

So I use my Arch Linux VPS (let's call it host 0) as NGINX HTTPS proxy, since I don't want to install extra packages on my OpenBSD VPS (let's call it host 1). So now, the diagram looks something like this

> Domain artnoi.com resolves to Host 0's public IP address

    HTTPS client: https://artnoi.com
    > NGINX HTTPS proxy	(Host0):443
    > relayd proxy		(Host1):8082
    > Webservers  (Host1,Host2):8080 HTTP 200 OK

    HTTPS client: https://artnoi.com/searx
    > NGINX HTTPS proxy (Host 0):443
    > filtron 			(Host 0):4004
    > Searx instance	(Host 0):8888 HTTP 200 OK

Many ACME client software has support for NGINX, so I can quickly obtained certficates using any means comfortable to me.

### NGINX - obtaining Let's Encrypt certificate with certbot

I used bloated `certbot` as ACME client. And I configured a `webroot` for ACME, and use NGINX as HTTPS frontend on my NGINX configuration. I chose to have one certificate for all of my domains.

The result is one server block that would establish HTTPS connections for all of my domains - artnoi.com, www.artnoi.com, cheat.artnoi.com, noob.artnoi.com, searx.artnoi.com, artnoi.xyz, searx.artnoi.xyz.

You can write a dummy configuration just for ACME challenges, or use webroot method to avoid downtime. I write a separate ACME webroot configuration for NGINX which will later be included by production configuration:

    # /etc/nginx/production/letsencrypt/webroot

    # webroot is /var/lib/letsencrypt
    location ^~ /.well-known/acme-challenge/ {
      allow all;
      root /var/lib/letsencrypt/;
      default_type "text/plain";
      try_files $uri =404;
    }

Also, make sure that `/var/lib/letsencrypt` is ready as webroot:

    # webroot='/var/lib/letsencrypt';
    # mkdir -p "${webroot}/.well-known";
    # chgrp http "$webroot";
    # chmod g+s "$webroot";

### NGINX as HTTPS reverse proxies

After NGINX reverse proxy establishes HTTPS connections with the certificates, it then proxies the HTTP connection _in plain text_ but under WireGuard VPN to `relayd(8)` on port 8082, whose load-balancing configuration is much simpler.

My website is static HTML pages, which is served mainly by OpenBSD httpd(8), and a backup Arch Linux webserver at home. But there's also Searx instance running on [/searx](/searx), which needs `filtron` and `morty` for search sanitation. The Searx instance, `filtron`, and `morty`, all three are on the same Linux host.

My final configuration has 2 server blocks, one listening on 80 for HTTP requests and ACME challenges, and the other on port 443 for HTTPS.

I wrote a separate file for serving HTTPS, and it will be included by the server block listening on port 443:

    ssl_certificate /etc/letsencrypt/live/artnoi.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/artnoi.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

And this is my 2 `server` blocks:

    server {

      # Reverse proxies for artnoi.com and its subdomains
      set $servername '';
      set $servername '${servername} artnoi.com www.artnoi.com artnoi.xyz';
      set $servername '${servername} cheat.artnoi.com zv.artnoi.com noob.artnoi.com';
      set $servername '${servername} searx.artnoi.com searx.artnoi.xyz';
      server_name $servername;

      # Redirects subdomain to location

      if ($host = artnoi.xyz) {
        return 301 https://artnoi.com;
      }

      if ($host = zv.artnoi.com) {
        return 301 https://artnoi.com/noob;
      }

      if ($host = noob.artnoi.com) {
        return 301 https://artnoi.com/noob;
      }

      if ($host = cheat.artnoi.com) {
        return 301 https://artnoi.com/cheat;
      }

      if ($host = searx.artnoi.com) {
        return 301 https://artnoi.com/searx;
      }

      if ($host = searx.artnoi.xyz) {
        return 301 https://artnoi.com/searx;
      }

      location /robot.txt {
        return 444;
      }

      location / {
        proxy_pass http://10.7.0.10:8082;
      }

      # artnoi.com/searx - Filtron and Searx
      location /searx {

        # filtron listens on 4004 and forward to 8888
        proxy_pass         http://127.0.0.1:4004/;

        proxy_set_header   Host             $http_host;
        proxy_set_header   Connection       $http_connection;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header   X-Scheme         $scheme;
        proxy_set_header   X-Script-Name    /searx;
      }

      # For Searx
      location /searx/static {
        alias /usr/lib/python3.9/site-packages/searx/static;
      }

      # Result proxy for Searx
      location /morty {
        # morty listens on 3000
        proxy_pass         http://127.0.0.1:3000/;

    	proxy_set_header   Host             $http_host;
    	proxy_set_header   Connection       $http_connection;
    	proxy_set_header   X-Real-IP        $remote_addr;
    	proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
    	proxy_set_header   X-Scheme         $scheme;
      }

      listen 443 ssl http2;
      include production/https/artnoi.com.conf;
    }

    server {

      # For webroot certbot (.well-known)
      include production/letsencrypt/webroot.conf;

      # HTTP-to-HTTPS redirects
      if ($host = artnoi.com) {
        return 301 https://$host$request_uri;
      }

      if ($host = www.artnoi.com) {
        return 301 https://$host$request_uri;
      }

      if ($host = noob.artnoi.com) {
        return 301 https://$host$request_uri;
      }

      if ($host = zv.artnoi.com) {
        return 301 https://$host$request_uri;
      }

      if ($host = cheat.artnoi.com) {
        return 301 https://$host$request_uri;
      }

      if ($host = artnoi.xyz) {
        return 301 https://artnoi.com;
      }

      if ($host = searx.artnoi.com) {
    	return 301 https://$host$request_uri;
      }

      if ($host = searx.artnoi.xyz) {
    	return 301 https://artnoi.com/searx;
      }

      listen 45.76.190.176:80;
      return 404;
    }

### relayd(8) as load-balancer

First, let's define our relay protocols. Both NGINX and relayd can do TCP relays (`stream` in NGINX configuration), but here we will be using plain-text HTTP as intended. I wrote my `httpfilter` protocol (relay rules) in a separate file `/etc/relayd.httpfilter.conf`:

> Don't just copy and paste. The HTTP [security headers](https://securityheaders.com) can break your website if not done properly.

    http protocol "httpfilter" {

      ## https://securityheaders.com
      ## Client HTTP request header
      match request header set "Connection"\
        value "close"
      match request header set "X-Forwarded-For"\
        value "$REMOTE_ADDR"
      match request header set "X-Forwarded-By"\
        value "$SERVER_ADDR:$SERVER_PORT"
      match header set "Keep-Alive"\
        value "$TIMEOUT"

      match query hash "sessid"

#match hash "sessid"

      ## https://securityheaders.com
      ## Server HTTP response header
      match response header\
        remove "Server"
      # NGINX already handles that
      #match response header set "Strict-Transport-Security"\
      #  value "max-age=31536000; includeSubDomains; always"
      match response header set "X-Frame-Options"\
    	value "SAMEORIGIN"
      match response header set "X-XSS-Protection"\
    	value "1; mode=block"
      match response header set "X-Content-Type-Options"\
    	value "nosniff"
      match response header set "Referrer-Policy"\
    	value "strict-origin"
      match response header set "Content-Security-Policy"\
    	value "default-src 'self'; font-src 'self'; style-src 'self'; base-uri 'none'; form-action 'self'; frame-ancestors 'none'"
      match response header set "Feature-Policy"\
    	value "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'"
      match response header set "Permissions-Policy"\
        value "accelerometer=(); camera=(); geolocation=(); gyroscope=(); magnetometer=(); microphone=(); payment=(); usb=()"

      pass
      block path "/cgi-bin/index.cgi" value "*command=*"

      # set recommended tcp options
      tcp { nodelay, sack, socket buffer 65536, backlog 100 }
    }

The following relayd(8) configuration listens on WireGuard IP 10.7.0.10 port 8082 and forward the connections to `<web_hosts>` table in HTTP:

    ## Macros
    lo_addr="127.0.0.1"
    wg_addr="10.7.0.10"

    ## Tables
    table <web_hosts> { $lo_addr $wg_tcenter }

    ## Global options
    interval 6
    log state changes

    # get httpfilter from file
    include "/etc/relayd.httpfilter.conf"

    relay "www4" {
      listen on $wg_addr port 8082
      protocol "httpfilter"
      forward to <web_hosts> port 8080\
        mode loadbalance check http "/" code 200
    }

## httpd(8) configuration

Now we can use a simple non-HTTPS configuration for `httpd(8)` in the `server` section:

    server "artnoi.com" {
      alias "www.artnoi.com"
      listen on $httpd_ip port 80
      root "/htdocs/html-artnoi.com"
    }

That's it guys!
