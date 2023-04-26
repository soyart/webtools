April 13, 2022

# Introducting [stubborn resolver](https://github.com/artnoi43/stubborn)

So after 6 months into this new software engineering job, I finally managed to balance my work with my schedule. As a result, I have had much more free (and high quality) time.

One of the things I usually do in these available moments is to **distract myself from work by working on my own code**. This greatly helps me gain coding and designing experience.

And last month, I began working on my new Go project - an attempt to imitate [stubby](https://dnsprivacy.org/dns_privacy_daemon_-_stubby/) (I have been using `stubby` since like 2019 or 2020), but this time with caching!

## What is stubborn and how do I use it?

stubborn is a _caching_ DNS stub resolver, with only [DoT](https://en.wikipedia.org/wiki/DNS_over_TLS) or [DoH](https://en.wikipedia.org/wiki/DNS_over_HTTPS) outgoing traffic. This is done to protect user privacy and for fun. It uses in-memory key-value cache, and can read UNIX-style `/etc/hosts` file or a [proprietary JSON hosts file](https://github.com/artnoi43/stubborn/blob/main/config/table.json.example) for local network lookup table.

### Installing stubborn

Assuming that you already have Go installed on your system, you can just use `go install` to install `stubborn` to your `bin` directory:

```shell
go install github.com/artnoi43/stubborn/cmd/stubborn@latest
```

The above command should install `stubborn` executable in `$HOME/go/bin`, and pulls any build time depedencies down with it. If running `stubborn` is what you want, the command above should be enough. Just be sure to add the `bin` directory to your shell `$PATH`.

If you only want the source code, use `go get`:

```shell
go get github.com/artnoi43/stubborn/cmd/stubborn@latest
```

After you have saw and finished cursing `stubborn` source code, you can build it with:

```shell
cd /tmp/stubborn # cd to your source root
go build ./cmd/stubborn
```

The above command will produce `stubborn` binary in your working directory.

`stubborn` supports only 2 outbound protocols - DoT and DoH. To run stubborn with either, use `-c` flag (case-insensitive):

```shell
stubborn -c dot # Will spawn DoT client
stubborn -c doh # Will spawn DoH client
```

### Why stubborn is so huge?

> Short answer: `stubborn`, like the other 102% of all my projects, is written in Go, which is a statically compiled language.

With static linking by default in Go, imported code gets compiled into _one big chunk of binary_ plus some Go runtime code (e.g. the GC or garbage compiled). You can see the list of Go modules used in this project in its [`go.mod` file](https://github.com/artnoi43/stubborn/blob/main/go.mod). I swear I tried to minimize the libraries used.

Static linking makes Go applications appear to have much larger disk footprint than a C program. However, although stubborn is ~10MB when built, it is actually much smaller than some other C-based DNS resolvers that uses a lot of dynamic linking.

And because by default nothing is dynamically linked in Go, you can run this application without having to worry about the depedencies.

### Yeah I get it, Go is statically linked, but why the source is so large?

Well, it started out small, but I decided to restructure it according to uncle Bob's clean architecture. `stubborn` is also very easy to implement new features or new infrastructure, just like my other project [todong](https://github.com/artnoi43/todong) which supports 2 data store types, and 4 web frameworks! All configurable with just a line in the config file.

This view is in stark contrast to my previously held view that software should be suckless, i.e. being minimalists and focus on peak efficiency. Now I don't enjoy reading hacky code that's fast but configurable. Today I enjoy code than can be maintained and picked up by others easily. And extensibility (which means proper isolation) is now one of my top priorities.

### Configuring stubborn

I intend to replace stubby with stubborn in some of my machines, so I decided to prefix the configuration path at `/etc/stubborn`. This makes my life easier when configuring my spaghetti server services.

There are 2 files - (1) `/etc/stubborn/config.yaml` and (2) `/etc/stubborn/table.json`. These default locations can be changed in `/cmd/etc.go`.

`config.yaml` configures stubborn behaviors, and `table.json` supplies stubborn with a key-value table to be used as local network domain lookup table.

### Running stubborn

If stubborn is in your path, just run `$ stubborn`. If `$GOPATH/bin` is not in your `$PATH`, you can `cd` to `$GOPATH/bin` and just run `./stubborn`.

Either way, this is stupid. Who the fuck would launch this command every time a system comes up? That's because as of this writing, I have not packaged stubborn as service yet. It's just a Go program now, though in the future I plan to include a systemd unit file for stubborn.

So now, just bear with it and run it in the old-fashioned way.

## Why DNS resolver?

I'll admit it - the first geeky thing that drew me to tech was setting up my own DNS resolvers as ads blockers. During 2019-2020, I had been crazy with setting up _my own_ DNS servers everywhere.

On most of my Linux computers, I usually have three (yes, 3) DNS programs running to meet my goals, which is predominantly ads blocking (and some privacy concerns).

Before `stubborn`, my DNS server setup usually looks like this:

```
dnsmasq[:53] -> pihole[:5369] -> stubby[:6953] -> 1.1.1.1
<listens>       <blocks ads>     <outgoing>     <upstream>
```

So I use the caching resolver `dnsmasq` on the standard port 53 as the listener. This is where my other client computers ask and get replies from.

From there, `dnsmasq` in turn asks `pihole`, which acts as a blackhole for shitty domain names. `pihole` also has caching feature, because `pihole` is actually `dnsmasq` + ad blocking + web UI (if you installed it).

You can actually have `pihole` asks the upstreams for answers, but unfortunately, `pihole` did NOT support encrypted outbound queries at the time when I was a DNS simp, which is a big no-no for me. Here comes stubby - a non-caching privacy-first DNS resovler with DNSSEC support. I've been very happy with `stubby`, so I just gave up on having encrypted outbound traffic from `pihole`.

People usually say that they can just use `systemd-resolved` or some NetworkManager plugins for this to work, but I really hate working with those Linuxy software from RedHat. These _more integrated_ Linux tools are actually very difficult to wrap your head around, and I feel like they are highly coupled. Using `dnsmasq` as NetworkManager's resolver requires you to edit a lot of config files and dig deep into each component, and the worst thing is they fuck with `/etc/hosts` or `/etc/resolv.conf`, which usually requires you to install stupid packages like `systemd-resolvconf` or `openresolv` just for managing these files.

This is why I prefer running these 3 separate simple DNS resolvers. All you need to do is configure the listen addresses and the upstream addresses for each program, and boom, they _just_ work together perfectly.

In other words, I like to fuck with DNS, and that's why I wanted to try writing my own shitty version of `stubby`. I'm testing `stubborn` on some of my home servers now, and so far it worked great I did not feel any differences compared to using `stubby`.
