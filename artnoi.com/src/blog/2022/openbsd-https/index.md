Aug 13, 2022

# Hosting a HTTPS website with OpenBSD `httpd`, and optionally `relayd`

[After my old servers were compromised](/blog/2022/reset/), the first thing I do is to setup a new OpenBSD webserver. This makes sense, because of how OpenBSD is wonderfully suited for this task. The fact that the operating system ships with HTTP server, a well written `relayd(8)` for level-3 redirection and level-7 relays, a robust firewall (`pf(4)`), a robust VPN driver built into the kernel (`wg(4)`), and finally, a native ACME client `acme-client(1)`!

Out of the box, OpenBSD is perfect right at the beginning for being a secure webserver! Ever since I first wrote the [tutorial to create an OpenBSD webserver in 2020](/blog/2020/openbsd-server/), nothing (in the eye of the users) about the software has changed, but one thing has changed - I have more experience now. When I first wrote that article, I was not working in tech industry, did not write any programs other than shitty shell scripts, and tended to overengineer stuff.

This time, it'll be different. Everything will only be added if needed. Before we dive to the config files, let's first discuss my desired HTTP server behavior.

## Desired `httpd(8)` behavior

I want only 1 main virtual server, that is, **there'll be only 1 virtual server that does the actual serving of HTML files**. Other virtual servers are for redirecting subdomains **back to the main virtual servers**.

I also want `httpd(8)` to be somewhat more secure than my old front-end reverse proxy, NGINX. In OpenBSD, `httpd(8)` is run as user `www` by default. It does not matter if you run the webserver on the previleged ports or not - `httpd` will (by default) chroot `/var/www`, and will only see files in there. If `httpd` is compromised, then only the files user `www` has write permission to will be affected.

My main requirement is to have subdomains, and all those subdomains share the same ACME certificate. All those subdomains are only for user convenience, and `httpd(8)` subdomain vurtual servers should redirect to the main virtual server.

In the final stage, I want my webserver to

- Main webserver is on host `artnoi.com`, where we have the `root` directive for our HTML files.

- Redirect all HTTP traffic to HTTPS

- Handle HTTP ACME auth in `/.well_known/acme-challenge` despite other locations being redirected to HTTPS

- Redirect `www.artnoi.com` to `artnoi.com`

- For subdomains other that `www`, do redirections like `artnoi.com/cheat/foo` to `artnoi.com/cheat/foo`

## Using only `httpd(8)` for standard HTTP

You must first setup a simple webserver on your box and obtain ACME certificates/key for your domain and subdomains. To do just that, setup a simple webserver just for ACME auth:

    # httpd.conf

    prefork 5

    # This virtual server can also handle ACME auth in HTTPS
    server "artnoi.com" {
    	alias "www.artnoi.com"
    	alias "artnoi.com/cheat"
    	alias "noob.artnoi.com"
    	alias "zv.artnoi.com"

    	listen on * port 80

    	location "/.well-known/acme-challenge/*" {
    		root "/acme"
    		request strip 2
    	}
    }

Now, configure `acme-client.conf(5)` such that we can use 1 ACME _fullchain_ certificate for all subdomains:

    # acme-client.conf
    authority letsencrypt {
    	api url "https://acme-v02.api.letsencrypt.org/directory"
    	account key "/etc/acme/letsencrypt-privkey.pem"
    }

    domain artnoi.com {
    	alternative names { www.artnoi.com artnoi.com/cheat noob.artnoi.com zv.artnoi.com }
    	domain key "/etc/ssl/private/artnoi.com.key"
    	domain full chain certificate "/etc/ssl/artnoi.com.crt"
    	#domain certificate "/etc/ssl/artnoi.com.crt"
    	#domain full chain certificate "/etc/ssl/artnoi.com.fullchain.pem"
    	sign with letsencrypt
    }

Normally, `relayd` would look for the following keypair: `/etc/ssl/private/$name.key` and `/etc/ssl/$name.crt`. But if we did not use `domain full chain certificate` as `/etc/ssl/name.crt`, some clients like `curl` might complain that our certificate is not good enough. This is why re omitted `domain certificate`, and use `domain full chain certificate` for our `artnoi.com.crt` file.

Now, start `httpd(8)` and run `acme-client(1)`:

    # httpd -n && rcctl start httpd;
    # acme-client -v artnoi.com;

You can now proceed to setup a full HTTPS webserver if ACME challenge was successful and you got the certificates/key configured in `acme-client.conf` in `/etc/ssl`.

## Using only `httpd(8)` to serve HTTPS

> Note that the `root` directive is relative to `/var/www`.

    prefork 5

    public_interface = "vio0"
    public_ip = "139.180.157.32"

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

    # This virtual server "artnoi.com" is the main virtual HTTPS server
    # to which all other subdomain virtual servers redirect to.
    #
    # This virtual server can also handle ACME auth in HTTPS
    server "artnoi.com" {
    	alias "www.artnoi.com"
    	listen on $public_interface tls port 443
    	root "/htdocs/www.artnoi.com"

    	tls {
    		certificate "/etc/ssl/artnoi.com.fullchain.pem"
    		key "/etc/ssl/private/artnoi.com.key"
    	}
    }

    # This virtual "artnoi.com" server serves 2 purposes
    # 1. Handle ACME auth for subdomains
    # 2. Redirect non-ACME connection to HTTPS
    #
    # This virtual server is for "artnoi.com"/"www.artnoi.com",
    # so redirection simply returns https://$HTTP_HOST$REQUEST_URI.
    server "artnoi.com" {
    	alias "www.artnoi.com"
    	listen on $public_interface port 80

    	location "/.well-known/acme-challenge/*" {
    		root "/acme"
    		request strip 2
    	}
    	location * {
    		block return 301 "https://$HTTP_HOST$REQUEST_URI"
    	}
    }

    # These other subdomain virtual webservers are different than the one above,
    # because we want to change the request host and URI too, and that new request
    # should point to our main virtual server "artnoi.com" on 443.
    #
    # "http://artnoi.com/cheat/foo" should be redirected to 'https://artnoi.com/cheat/foo'
    server "artnoi.com/cheat" {
    	listen on $public_interface port 80

    	# Redirect to the virtual server above for ACME challenges
    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}

    	location * {
    		block return 301 "https://artnoi.com/cheat$REQUEST_URI"
    	}
    }

    # "http://noob.artnoi.com/foo" should be redirected to 'https://artnoi.com/noob/foo'
    server "noob.artnoi.com" {
    	listen on $public_interface port 80

    	# Redirect to the virtual server above for ACME challenges
    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}

    	location * {
    		block return 301 "https://artnoi.com/noob$REQUEST_URI"
    	}
    }

    # "http://zv.artnoi.com/foo" should be redirected to 'https://artnoi.com/noob/foo'
    server "zv.artnoi.com" {
    	listen on $public_interface port 80

    	# Redirect to the virtual server above for ACME challenges
    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}

    	location * {
    		block return 301 "https://artnoi.com/noob$REQUEST_URI"
    	}
    }

Now, while this configuration works, something is missing - we haven't configure proper HTTP headers. This will leave both the users and servers vulnerable to man-in-the-middle or other attacks

## Using `httpd(8)` with `relayd(8)` to modify HTTP headers and TLS acceleration

For our server to serve with secure HTTP request headers, we can use `relayd` to do that job. This means that, instead of having `httpd(8)` listening on port `80` and `443` for both HTTP and HTTPS request, we can use `relayd` as the frontend first (for both HTTP and HTTPS), and have it modify our HTTP headers as it relays the request to `httpd(8)`!

For this, we need to

1. Make `httpd(8)` listen on an internal HTTP address, e.g. `127.0.0.1:8888`

2. Set `relayd(8)` to listen on both 443 (TLS/HTTPS) and 80 (HTTP), and forward the connections to `127.0.0.1:8888` where our `httpd(8)` is listening

Let's start with updating our `httpd.conf(5)` virtual server blocks to listen HTTP on `127.0.0.1:8888` instead:

### Updating `httpd.conf(5)`

> Note: you can see that there's no `tls` directive in `httpd.conf(5)` anymore.

    prefork 5
    this_server = "127.0.0.1"
    internal_httpd_port = "8888"

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

    server "artnoi.com" {
    	alias "www.artnoi.com"
    	listen on $this_server port $internal_httpd_port
    	root "/htdocs/html-artnoi.com"

    	location "/.well-known/acme-challenge/*" {
    		root "/acme"
    		request strip 2
    	}
    }

    server "artnoi.com/cheat" {
    	listen on $this_server port $internal_httpd_port

    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}
    	location * {
    		block return 301 "https://artnoi.com/cheat$REQUEST_URI"
    	}
    }

    server "noob.artnoi.com" {
    	listen on $this_server port $internal_httpd_port

    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}
    	location * {
    		block return 301 "https://artnoi.com/noob$REQUEST_URI"
    	}
    }

    server "zv.artnoi.com" {
    	listen on $this_server port $internal_httpd_port

    	location "/.well-known/acme-challenge/*" {
    		block return 301 "http://artnoi.com$REQUEST_URI"
    	}
    	location * {
    		block return 301 "https://artnoi.com/noob$REQUEST_URI"
    	}
    }

Restart `httpd(8)`. It should now be listening on port `8080`.

### Updating `relayd.conf(5)`

One trick here is that we will not be specifying `tls keypair "artnoi.com"` here. This is because by default, `relayd(8)` looks for file `/etc/ssl/private/${ip_addr:port}.key` and `/etc/ssl/{ip_addr:port}.crt` for each `listen` directive. Since we will have `relayd(8)` listen on public IP address `69.69.69.69`, we'll have to symlink the private key and full chain certificate for the address.

    # # Use full chain cert (.pem) as 69.69.69.69.crt
    # ln -s /etc/ssl/{artnoi.com.fullchain.pem,69.69.69.69.crt}
    # ln -s /etc/ssl/private/{artnoi.com,69.69.69.69}.key

This will allow us to omit `tls keypair ..` in `relayd.conf(5)`. And after the webserver is running, we can now create a `relayd.conf` configuration that looks something like this:

    public_interface = "69.69.69.69"
    this_box = "127.0.0.1"

    httpd_port = "8888"

    table <httpd> { $this_box }
    table <dns_hosts> { $this_box }

    http protocol "httpfilter" {
    	# set recommended tcp/tls options
    	tcp { nodelay, sack, socket buffer 65536, backlog 100 }
    	tls { no tlsv1.2 }

    	# Return HTTP/HTML error pages to the client
    	return error
    	match header append "X-Forwarded-For" value "$REMOTE_ADDR"
    	match header append "X-Forwarded-By" value "$SERVER_ADDR:$SERVER_PORT"
    	match header append "Keep-Alive" value "$TIMEOUT"

    	# See https://securityheaders.com to check and modify headers as needed below
    	match response header remove "Server"
    	match response header set "Content-Security-Policy" value "default-src 'self'; style-src 'self'; img-src 'self'; base-uri 'self'; frame-ancestors"
    	match response header set "X-Frame-Options" value "deny"
    	match response header set "X-XSS-Protection" value "1; mode=block"
    	match response header set "X-Content-Type-Options" value "nosniff"
    	match response header set "Referrer-Policy" value "no-referrer"

    	match response header set "Feature-Policy" value "accelerometer 'none'; camera 'none'; geolocation 'none'; gyroscope 'none'; magnetometer 'none'; microphone 'none'; payment 'none'; usb 'none'"
    	match response header set "Permissions-Policy" value "fullscreen=(), geolocation=(), microphone()"
    	match response header set "Strict-Transport-Security" value "max-age=31536000; includeSubdomains; preload"

    	match query hash "sessid"
    	block path "/cgi-bin/index.cgi" value "*command=*"

    	#pass request quick header "Host" value "artnoi.com" forward to <httpd>
    	#pass request quick header "Host" value "www.artnoi.com" forward to <httpd>
    	#pass request quick header "Host" value "artnoi.com/cheat" forward to <httpd>
    	#pass request quick header "Host" value "noob.artnoi.com" forward to <httpd>
    	#pass request quick header "Host" value "zv.artnoi.com" forward to <httpd>
    	#pass request quick header "Host" value "chat.example.com" forward to <synapse>
    }

    relay "www4secure" {
    	listen on $public_interface port 443 tls
    	protocol httpfilter
    	forward to <httpd> port $httpd_port mode loadbalance check tcp
    }

    relay "www4" {
    	listen on $public_interface port 80
    	protocol httpfilter
    	forward to <httpd> port $httpd_port mode loadbalance check tcp
    }

With these configurations, `relayd(8)` now acts as both TLS accelerator, HTTP headers filter, and reverse HTTP proxy for `httpd(8)`. We can replicate the backend webservers a lot of times, and all we have to do is to add newer webservers to our `relayd.conf(5)` in the table `<httpd_servers>`.

## Misc.

You can check validity of your configurations with `-n` flag, e.g. `httpd -n`, which will test the default `/etc/httpd.conf`. To test a specific file, you can combine `-n` with `-f`, e.g. `relayd -n -f /etc/relayd-ng.conf`.

### Wireguard VPN

Since OpenBSD ships with `wg(4)`, we can basically write a `hostname.if(5)` file and create the network interface for our Wireguard connection. In this example, I'll be using `wg1`, so the configuration file is `/etc/hostname.wg1`:

    # /etc/hostname.wg1
    # Interface configuration
    wgkey 6HTy5ej5gg2nN4rocwhinQx+XtIQ9SDa7vH3dIfTr1E=
    wgport 6969
    inet 192.168.69.1/24
    up

    # Wireguard peers
    !ifconfig wg1 wgpeer wizxPD/5eTb0qyEx2uHtWCPDZ9EM4aLVLX4JcW4ui2k= wgendpoint 10.10.0.1 51543 wgaip 192.168.69.2/32
    !ifconfig wg1 wgpeer d4hwbjlHKlUE6kyq/4ZEKnroD6LDfetE8op6bUk6KGo= wgpsk 6ibR/T+WzbztlqdPKVs5Nbho7Q/riD3Hy1rNEKPuD+0= wgaip 192.168.69.3/32
