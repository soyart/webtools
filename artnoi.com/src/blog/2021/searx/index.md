Feb 3, [2021](/blog/2021/)

Dear readers, you may have noticed that recently a strange Searx link has been added the website header. Yup, that is my public Searx instance - and you can use it, or even host your own too! My Searx instance is properly set up, with `filtron` and `morty` hardening the instance.

# Replace Google Search with [Searx](https://searx.me)
I have never had good search results from DuckDuckGo, and after operating my own website, could not bring myself to trust DuckDuckGo, so I decided to try to host my own instance of Searx.

## Searx
Searx is a privacy-centric metasearch engine used by many boomer nerds. You should read [this user documentation](https://searx.github.io/searx/user/own-instance.html#how-does-searx-protect-privacy) for what it can and cannot do. In very short term, Searx tries to annonymize your internet searches.

## Installing and configuring
I have a spare Arch Linux VPS with [WireGuard VPN](/blog/2020/wireguard/) configured, so I figured I could use that VPS to host my private search engine. On Arch Linux, Searx is available from the [AUR](https://aur.archlinux.org) so we can simply install it with any AUR helper (in this case, `yay`, but I had moved to `paru`):

    $ yay -S searx;

My Searx setup uses `UWSGI` to run its webapp instance. Edit `/etc/uwsgi/searx.ini` to configure system settings like listen ports, UID and GID, CPU count, etc. Also, edit `/etc/searx/setting.yml` to configure Searx settings. After you are done with configuration, start and enable it with:

    # systemctl enable --now uwsgi@searx;

Now you can privately search the web by accessing your private search engine at the address, for example, `10.0.1.1:8888` (default HTTP port for UWSGI Searx is 8888). Now this should work for private networks.

## Using Searx
You can use your own instance or the [many public instances](https://searx.space) of Searx. Before using Searx, I highly recommend that you first configure your Searx to suite your needs. If you do host your own instance, you can configure default settings for your instance at `/etc/searx/settings.yml`, *or* you can do it in browser and use the cookies to store your settings instead. Note that the latter method is not persistent - as it depends on your browser cookies for setting values.

Also, you should learn the [Searx's easily memorable search syntaxes](https://searx.github.io/searx/user/). Once you've become accustomed to the syntaxes, and your Searx page has been properly customized, Searx will become even more powerful than Google Search, without even collecting one bit of your personal data.

## Integrating Searx search to browsers
Firefox-based browsers can be configured to use Searx instance by visitting the instance and clicking the green add icon on the search bar. Alternatively, you can write your own Searx search URL to the seach settings in Firefox.

For example, to use `artnoi.com/searx` as default search engine on Firefox, add the search query URL to Firefox search settings: `https://artnoi.com/searx/search?q=%s`

## Hosting Searx on the internet
At first, I only wanted my own private search engine, but now that I find Searx very useful and powerful, I want to open it up for other people to use too. I usually show (i.e. demo) it to my smarter friends.

I advise you to take a look at a [protected NGINX Searx instance on the project website](https://searx.github.io/searx/admin/installation-nginx.html#a-nginx-searx-site) before openning your Searx to the internet. In short, you should at least configure a *result proxy* (`morty`), as well as some application-level firewall (`filtron`).

In my case, the entire `artnoi.com` is behind some reverse proxies (OpenBSD's `relayd(8)` and NGINX). One of these reverse proxies is used to establish HTTPS sessions with clients, and further connections from there are relayed under WireGuard VPN across different hosts from Singapore to Bangkok. In addition to the relays, both OpenBSD's `relayd(8)` and NGINX can be used as load balancer across the servers.

> If the Searx host is accessible from the internet (e.g. [my currently public Searx instance](https://artnoi.com/searx)), it is very important to properly secure your Searx instance with encryption (VPN or HTTPS).

Additionally I can also access non-HTTPS Searx under WireGuard VPN. If I don't want other people connecting to my Searx, I can just simply remove the relays.

Host everything guys!
