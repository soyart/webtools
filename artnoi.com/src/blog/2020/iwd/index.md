Dec 21, [2020](/blog/2020/)

# Switching to `iwd(8)`

## My use case

I usually connect my laptops with either (1) Wi-Fi, (2) iOS tethering, and (3) Ethernet. The last one seems to work out of the box on most Linux distribution fresh installs, but the first two don't necessarily. Speaking of Wi-Fi, usually, one would use `wpa_supplicant` or one of its peers to manually manage wireless networks, or full-fledged network managers like Systemd `systemd-networkd`, Red Hat's `NetworkManager`, Arch Linux `netctl`, etc., to automatically handle the wireless network connections.

## Replacing [NetworkManager](https://wiki.archlinux.org/index.php/NetworkManager)

I have been a fan of NetworkManager since installing my [Void Linux](https://voidlinux.org) installation last year, because it eliminated the lengthy process of setting up the wireless networks. On Arch, I still used it on my laptop/desktop installations, as it works great with `nm-applet`, a systray utility that sits on my status bar. However, after some decisions, I decided to ditch NetworkManager and its applet altogether to switch myself to using `iwd(8)` (`iwctl(1)`) full time.

## Why `iwd(8)`?

`iwd` is much more lightweight, and it is not difficult to use at all. The storage footprint alone justifies my transition. In addition, it also does one thing and does it better than NetworkManager. Since Ethernet interface(s) usually work(s) out of the box, and I only need the full-fledged NetworkManager to bring up the wireless interfaces (and config its credentials), and nothing else, why not replace it with something whose only purpose is to setting up wireless networks?

## Using `iwd(8)`

`iwd` daemon can controlled by `iwctl(1)`, and `iwctl(1)` can be used in both interactive command-line mode (think GNU `fdisk(8)`) and _traditional_ non-interactive command-line mode. The `iwd(8)` daemon itself can be run as a background daemon.

First, enable the daemon:

    # systemctl enable --now iwd

Then, use `iwctl(1)` to bring up interactive shell to control the daemon:

> Note `iwctl` in interactive mode also has Tab autocomplete

    # iwctl

At the prompt, get the device list (wireless adaptors/cards) with:

    [iwd]# device list

Let's say we have `wlan0` interface, we can use it in station mode to find nearby available networks:

    [iwd]# station wlan0 get-networks

Connect to the access point if your desired AP's SSID shows up on previous commands:

    [iwd]# station wlan0 connect "MY_HOME_WIFI"

The commands above can also be used in non-interactive mode, which is useful for shell scripting:

    # iwctl device list
    # iwctl station wlan0 get-networks
    # iwctl station wlan0 connect "MY_HOME_WIFI"

## `iwd(8)` configuration

> See also: [Arch Wiki on `iwd(1)`](https://wiki.archlinux.org/index.php/Iwd)

If you only followed the instructions above on fresh Arch machine, you should be able to verify your AP's PSK (password) with the wireless router, but you will NOT get any IP address on that interface (and thus no internet). This is because by default, `iwd(8)` only manage "wireless" interfaces, and not the interface's IP addresses or other options like routing and DNS server. Those actions must be performed by other programs, e.g. NetworkManager or `systemd-networkd` (shipped in Arch's `base`). In this example, we will use `systemd-networkd` to help during DHCP lease.

To have `iwd` configure the wireless interfaces to _usable_ state, add these lines to `/etc/iwd/main.conf`:

    [General]
    EnableNetworkConfiguration=true

This should get `iwd` to configure IP addresses, routes, and obtains relevant DNS server information from the wireless network's DHCP server.

## iOS USB/Wi-Fi tethering

The main idea is to (1) pair the iOS device, and (2) get the IP address (DHCP lease) from the iOS device. Without NetworkManager or network managing daemons in place, DHCP lease may break, causing our machine to lose internet connection. If that happens, simply renew the DHCP lease.

> I disabled Bluetooth on my laptop, and I use `systemd-networkd` will be used instead of other DHCP clients, because it is already in Arch `base`.

iOS Wi-Fi tethering should already work if you were successful with `iwd`. If you plan to use wired tethered networks, you will need iOS device driver support. First, install `libimobiledevice` to provide driver support for wired tethering:

    # pacman -S libimobiledevice

After the package is installed, pair the device:

    $ idevicepair pair

Then, try to figure out the interface name for the iOS-connected USB interface (usually `enp7s0f3u2c4i2`):

    # ip a

If the interface still has no IP address, use any DHCP client to acquire new lease (in this case, `systemd-networkd` or `networkctl` on `enp7s0f3u2c4i2`):

    # networkctl renew enp7s0f3u2c4i2

And recheck your IP address. If the interface finally got its own IP address from the iOS device, then you should be able to connect to the internet. Remember the steps, or even better, the main idea behind connecting to iOS hotspots.

### `systemd-networkd` and iOS tethering

If you are lazy like I am, then you probably want to have `systemd-networkd` automatically manage the interface and its DHCP lease. To do just that, add a `.network` config file in `/etc/systemd/network` (in this case `20-ios-usb.network`):

    [Match]
    Name=enp7s0f3u2c4i2

    [Network]
    DHCP=yes

That should do the trick, though sometimes it fails, but you can always do `networkctl(1)` to renew DHCP lease.
