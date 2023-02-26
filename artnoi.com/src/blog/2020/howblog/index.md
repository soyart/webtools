Last updated: Aug [2020](/blog/2020/)

This article is about how I _write_ content for artnoi.com. For server configuration, please see [this blog post](/blog/2021/relays/).

# How to artnoi.com

## Using [simple site generator `ssg5`](https://www.romanzolotarev.com/ssg.html)

[ssg5](https://www.romanzolotarev.com/ssg.html) is a [smol](https://www.dictionary.com/e/slang/smol/) (<180 LoC!) static site generator written in POSIX shell. Yes, that _cute_ `sh(1)` shell.

> Think of it like an HTML website assembler machine.

The script eleglantly uses basic UNIX shell tools, like `find(1)`, `grep(1)`, `cpio(1)`, etc. to generate static HTML documents by putting together the header, body, and footer from separate files, ultimately generating a website HTML documents.

Best thing about this small, clever piece of software is that **it also converts Markdown documents to HTML, and then piece them together to create a website** with just said commands.

In addition to assembling the HTML documents, ssg5 also generates `sitemap.xml` for use in `robot.txt`, as well as other stuff.

Note that it needs [Markdown.pl](https://daringfireball.net/projects/markdown) or [lowdown](https://kristaps.bsd.lv/lowdown) for on-the-fly Markdown-to-HTML conversion.

`ssg5` should work on most nix systems with little to no tweaks, just by copying `ssg5` (and optionally `Markdown.pl` or `lowdown(1)`) to your `$PATH`.

> `ssg5` was tested on OpenBSD and macOS, although apparently it also works on my my every box.

For Arch Linux users, Arch by default does not ship with `cpio(1)` so you will have to install it first.

Also, the most recent `lowdown(1)` from AUR is not compatible with `ssg5` due to command syntax change, so Arch user should use Markdown.pl perl script for now.

To generate HTML documents in `html-example.com` directory from Markdown documents in `md-example.com`, run:

    $ ssg5 'md-example.com' 'html-example.com' 'My website' 'http://example.com';

Note that the last argument 'http://example.com' is for `sitemap.xml`.

## [web-tools](https://gitlab.com/artnoi-staple/unix/-/tree/master/web-tools) - my own shell scripts for `ssg5`

I could just run the command above over and over, and then push them to the webserver, but I'm too lazy for this.

So I come up with my scripts `web-tools` that would automate all the processes involved with publishing my site.

There are standalone `web-tools` scripts (e.g. `cleanup.sh` and `sendweb.sh`), and then there is `webtools.sh` which will give you option to run the standalone commands together. Configuration can be done for every `web-tools` script in `webtools.conf`

`web-tools` scripts rely on my existing `sh-tools` by using `sh-tools/bin/source.sh` to source relevant files. **`web-tools` is also strictly `bash`-dependent** because of its extensive use of associative arrays, which is not supported by POSIX shell standards. It should run with shells that support such arrays, like `ksh`, although it is not tested.

I will try to port it to `sh(1)` shell, so that the whole `ssg5`-`web-tools` suite only depends on `sh(1)`.

The following scripts made up `web-tools`:

1. `webtools.conf` - `web-tools` configuration files
2. `webtools.sh` - This one chains all the scripts below together
3. `cleanup.sh` - cleans `.DS_Store` as well as `.files` and `.sync-conflict` files from the website sub-directories. My web directories are synced, so sometimes there are unwanted files from sync conflicts
4. `linkweb.sh` - `ln -sf` to link the site's resources (e.g. `_header.html` used by `ssg5`, or `style.css`)
5. `genhtml.sh` - uses `ssg5` to generate HTML files
6. `sendweb.sh` - uses `scp(1)` to send the HTML files to remote locations

## Server software

Artnoi.com depends on many servers, each doing different tasks, like syncing files from my laptop, monitoring other hosts, relays, proxies, and certificate servers. These servers are running different operating systems, and they communicate under WireGuard VPN. This can be done with almost no performance penalty, since the web pages are smol and static.

I don't use fancy firewalls. I just enable whatever firewall which came with the operating systems, that is `pf` for OpenBSD, and `iptables` for Linux hosts.

### Reverse proxies

OpenBSD's `relayd(8)` and [NGINX](https://nginx.com) are used as load-balancer/reverse proxies.

### Webserver

OpenBSD's `httpd(8)` and [NGINX](https://nginx.com) are used the serve HTML files. There are multiple servers to avoid downtime.

### CA Certificates (for HTTPS)

On OpenBSD host, the OS shipped with `acme-client(1)` so I just used that to get Let's Encrypt certificates. On GNU/Linux hosts, `certbot` is used to obtain CA certificates.

## Other software

#### For [searx.artnoi.com](/searx)

`searx`, `uwsgi`, `morty`, and `filtron` powers [searx.artnoi.com](https://searx.artnoi.com).

[More info](/blog/2021/searx/)

#### `sed(1)`

`sed(1)` is usually used to serially edit hyperlinks in Markdown files, like when moving cheat.artnoi.com to artnoi.com/cheat

#### Syncthing

I use [Syncthing](https://syncthing.net) to sync my files across the servers.

#### Pandoc

I used [Pandoc](https://pandoc.org) (with a `for` loop, obviously) to migrate my old site's HTML files to Markdown. It did not go 100% cleanly.

## Other resources

My `style.css` file is derived from [a random search result for 'minimal css'](https://niklasfasching.de/posts/just-enough-css/), although I removed much of the bloat from the original.
