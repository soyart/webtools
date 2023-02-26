Aug 3, [2019](/blog/2019/)

# FreeBSD 12.0: Enabling Wi-Fi on ThinkPad X230

## ThinkPad X230 WiFi on FreeBSD 12.0 (Intel Centrino Advanced-N 6025 network card)

During FreeBSD installation you should be prompted to configure IPv4 and IPv6 for your network interfaces. I have never successfully configured any wireless interfaces with this menu during installation, be it on my 2013 iMac or on this Lenovo machine, so I expected it to fail and just connect the laptop via Ethernet first to configure em0 interface to fetch and install FreeBSD patches with `freebsd-update`.

> You don't need working Ethernet in order to get WiFi working, just finish the installation normally **without** configuring `wlan0` and reboot. Yes, we will manually configure the WiFi to work after we reboot into our freshly installed FreeBSD 12.0.

## When to enable `ntpd`

Upon successful boot, if there is no internet connection and if you set `ntpd` to 'enabled' during installation, then the `ntpd` daemon will complain a lot and mess up with your serial console output, so I recommend not to enable `ntpd` yet before you setup your wireless networking. You can always enable ntpd later as easily as by adding an entry in `/etc/rc.conf` file or issuing `sysrc` command.

### Getting hardware information:

Upon reboot, check your network interface cards by issuing (as root):

     # sysctl net.wlan.devices;

On X230, the command should return `iwn0` (Intel Centrino Advanced-N 6025).

### Edit `/etc/rc.conf`:

Now that we know which device will be our `wlan0` interface, we will edit the `/etc/rc.conf` file so that `iwn0` is configured as `wlan0`, and set the correct regulation for our wireless connection (check your own country code and regulatory domain, for example FCC for US, ETSI for UK, APAC for TH), and that after the handshake we would like to use DHCP.

> You can explicitly choose static IP but for the sake of simplicity I will go for DHCP. If you choose to go without DHCP, make sure to supply your network, subnet, and default gateway addresses.

     # [ /etc/rc.conf ]

     wlans_iwn0="wlan0"
     create_args_wlan0="country TH regdomain APAC"
     ifconfig_wlan0="WPA SYNCDHCP"

[](step3)

### Edit `/boot/loader.conf`:

Now that we know the device, add the following entries to `/boot/loader.conf` file to tell FreeBSD to load the relevant wireless networking modules (we actually won't need to tell it to load the drivers or firmware because it is usually loaded for us, but I'll just leave them commented out here in case it's useful for other people):

     # [ /boot/loader.conf ]

     #if_iwn_load="YES"
     #iwn6000fw_load="YES"
     #iwn6000g2afw_load="YES"
     #iwn6000g2bfw_load="YES"
     #iwn6050fw_load="YES"
     wlan_scan_ap_load="YES"
     wlan_scan_sta_load="YES"
     wlan_wep_load="YES"
     wlan_ccmp_load="YES"
     wlan_tkip_load="YES"

### WPA2 authentication

We're almost done, except that we have not yet populated our WPA configuration file with our SSID (Wi Fi name) and PSK (pre-shared key or your typical WiFi password). Now add the following entry to `/etc/wpa_supplicant.conf`:

     # [ /etc/wpa_supplicant.conf ]

     ctrl_interface=/var/run/wpa_supplicant
     ctrl_interface_group=wheel

     network={
       ssid="YOURWIFI"
       scan_ssid=1
       psk="YOURPASSWORD"
     }

### Reboot

Reboot now, the next boot's splash screen should tell us if `iwn0` is already loaded or not - if not and the connection failed, try adding the lines with driver loading statements from above to `/boot/loader.conf` and reboot and see if it works. If `iwn0` is loaded but there is no wlan0 carrier anyway, try editing `/etc/wpa_supplicant.conf` and `/etc/rc.conf` and reload `netif` by issuing (as root):

     # service netif restart;

## Unrelated: How to dualboot UEFI FreeBSD and Linux with one EFI partition using GRUB2

The FreeBSD installer has guided steps so the installation was easy and smooth, except the disk partition part where I decided not to create an EFI partition for FreeBSD, because I hated having 2 EFI partitions on the same disk.

The trick here is to to copy EFI boot program `BOOTx64.efi` (i.e. from the live USB) to the existing EFI partition on my disk, and then use other system's `grub2` to automatically detect the EFI boot program and create a boot entry for our FreeBSD.

So we will use an existing Linux system that you want to dual-boot FreeBSD with to copy the EFI file to the EFI partition, the destination path in the FAT32 partition should be `\EFI\FreeBSD\BOOTx64.efi`.

> As of writing this blog post, I was using Manjaro Linux, which mounts its EFI partition under `/boot/efi`, so I copied `BOOTx64.efi` to `/boot/efi/EFI/FreeBSD/BOOTx64.efi`.

Then I edited the `40_custom` file in `/etc/grub.d` to look something like:

     # [ /etc/grub.d/40_custom ]

     # FreeBSD was installed without creating its own FAT32 EFI partition
     # The EFI boot file in this case is located on disk 0, GPT partition 4
     # The FreeBSD root filesystem is UFS

     menuentry "FreeBSD" --class freebsd --class bsd --class os {
       insmod bsd
       insmod ufs2
       chainloader (hd0,gpt4)/EFI/FreeBSD/BOOTx64.efi
     }

Then, update `grub` configuration file (on Arch Linux) with:

     $ sudo update-grub;

Manjaro-shipped `grub` should detect FreeBSD installation as 'unknown Linux distrobution'. Then reboot, and your `grub` menu should now present you with an entry for FreeBSD.

> Note: this was written back in 2019 and may no longer be relevant.
