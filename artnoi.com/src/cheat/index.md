# Cheat sheet for myself

[Other cheat sheets](#others) are also available

## Combining `find(1)` with `rm(1)`

`find(1)` is a very powerful UNIX tool. This example shows how we can find
and remove unwanted files recursively:

```shell
find <PATH> -name <NAME> -exec rm -f {} \;
```

The example below will recursively remove file(s) `.DS_Store`,
starting from the working directory:

```shell
find . -name '.DS_Store' -exec rm -f {} \;
```

## Using `lsof` to discover process running on a port

```shell
# macOS, and probably BSD
lsof -n -i TCP:6379;

# GNU/Linux
lsof -i :6379;
```

## POSIX shell parameter expansion

People should know parameter expansion to avoid invoking (abusing) `cat(1)`,
`awk(1)`, `sed(1)`, and `grep(1)`.

However, when people use shell parameter expansion, they use non-POSIX syntax,
i.e. `bash`-specific syntax, which is not portable.

> The examples are for POSIX-compliant shell like UNIX `sh(1)` and `dash(1)`.
> If you are using `bash(1)` and don't care about portability,
> see [reference manual for `bash(1)` shell](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html).
> You can also see `dash` man pages for POSIX parameter expansion.

### String length

```shell
FOO="foo";

echo ${#FOO}; # 3
```

### Substring: prefix removal with '#' ('##')

The variable name used in this demo will be `STR` with value `"foobar"`:

```shell
STR='foobar';
```

Remove last 3 characters:

```shell
echo ${STR#???}; # "bar"
```

Remove 'foo' from start:

```shell
echo ${STR#foo}; # "bar"
```

Remove 'fo' (smallest pattern):

```shell
echo ${STR#f*o}; # "obar"
```

Remove 'foo' (largest pattern):

```shell
echo ${STR##f*o}; # "bar"
```

### Substring: suffix removal with '%' ('%%')

The variable name used in this demo will be `STR` with value `"foobar"`:

```shell
STR='foobar';
```

Remove first 2 characters

```shell
echo ${STR%??}; # "foob"
```

Remove 'bar' pattern from end:

```shell
echo ${string%bar}; # "foo"
```

Remove pattern expands to 'obar':

```shell
echo ${string%o*r}; # "fo"
```

Remove pattern expands to 'oobar':

```shell
echo ${string%%o*r}; # "f"
```

The example below will move (i.e. rename) all files with `.text` extension to
`.txt` with a shell `for` loop (e.g. `token.text` -> `token.txt`):

```shell
for f in *".text";
do
    mv "${f}" "${f%.text}.txt";
done;
```

The example below will move all files starting with substring `gh` to be
starting with `github` instead (e.g. `gh_key` -> `github_key`):

```shell
for f in "gh"*;
do
    mv "${f}" "github${f#gh}";
done;
```

### Substitution

I usually just use 2 of the many substitutions:

- `${parameter:-word}` - use word as default value if `parameter` is null

- `${parameter:=word}` - assign word as default value if `parameter` is null

These and their other variants are super-useful, and I wish I knew about these sooner.

Let's see some simple examples so you understand why these are useful:

```shell
string0='test'; # string1 is still null
```

Use `string0` value if `string1` is null

```shell
# string1 is still null

echo ${string1}; # no output

echo ${string1:-$string0}; # "test"
```

Assign `string0` value if `string1` is null

```shell
echo ${string1:=$string0}; # ouputs "test", as well as assign "test" to string1

echo ${string1}; # outputs "test"
```

## Redirecting shell output

> `2>&1` redirects stderr to stdout

Discarding output and error messages:

```shell
foo > /dev/null 2>&1;
```

Writing to both stdout and file `out.txt`:

```shell
foo 2>&1 | tee out.txt;
```

## Using `dd(1)`

Writing a disk image from `image.iso` to USB flash drive `/dev/sdc`:

```shell
dd bs=4M if=image.iso of=/dev/sdc status=progress oflag=sync;
```

Writing a key file with 2048 random bytes from special random character device `/dev/random`:

> In this case, use of `/dev/random` is [prefered](https://man7.org/linux/man-pages/man4/random.4.html) over `/dev/arandom` and `/dev/urandom`.

```shell
dd bs=512 count=4 if=/dev/random of=<DEST> iflag=fullblock;
```

If you want a 4096-byte-long key file, use `count=8`.

## Mounting disk images

On _modern_ GNU/Linux systems, we can mount partition images with option `loop`:

```shell
mount -o loop image.iso /mnt;
```

## macOS

### `updatedb` on macOS

```shell
sudo /usr/libexec/locate.updatedb;
```

### Modifying macOS system files

As of Catalina (10.15), the system files reside in their own encrypted read-only partition.

So if you wish to modify system files, disabling SIP alone is not enough - you will also have to remount the system partition with _write_ permission:

```shell
mount -uw / && killall Finder;
```

### macOS native ramdisk (HFS+)

Ramdisks are perfect for temporary storage. I have had a habit where I edit my text files exclusively in `/tmp`.

It's a shame OS X does _not_ ship with tmpfs OOTB. Nonetheless, we can still create a HFS+ ramdisk (of size 4GB) using utilities from the base install:

```shell
diskutil erasevolume HFS+ 'RAM Disk' `hdiutil attach -nomount ram://8388608`;
```

Yes, the 5th argument is in back ticks.

> Hint: use the following value to specify block size: 524288 for 256MB, 1048576 for 512MB, 2097152 for 1GB, 4194304 for 2GB.

## NFS-related

### Windows 10 Pro NFS client

You must first enable NFS client. You can do it in Powershell with:

```PowerShell
Enable-WindowsOptionalFeatures -FeatureName ServicesforNFS-ClientOnly, ClientForNFS-Infrastructure -Online -NoRestart
```

Or from Control Panel > "Programs" > "Turn Windows features on or off" > "Services for NFS" > "Client for NFS".

After you enabled NFS client, you can just use File Explorer to go to your remote location, e.g. `\\10.8.0.1\myshare` or use `NewPSDrive` to mount the NFS share:

```PowerShell
New-PSDrive -Name "Z" -Root "\\10.8.0.1\myshare" -Persist -PSProvider "Filesystem"
```

Or use `mount` (which is alias to `New-PSDrive`) and fill up the argument by line.

`Name` is desired Windows drive letter, and `Root` is the remote location, e.g.:

```shell
mount
Name: Z
PSProvider: Filesystem
Root: \\10.8.0.1\myshare
```
You can list the shares with `Get-PSDrive` and unmount it with `Remove-PSDrive`.

### OpenBSD NFS client

Try mounting with option `-o tcp`. Also, recheck export list on the host, e.g. `foo`: `showmount -e foo`, and make sure to have NTP time sync enabled with the correct timezone.

## OpenBSD configuraton

### [hostname.if(5)](https://man.openbsd.org/hostname.if.5) for [wg(4)](https://man.openbsd.org/wg): WireGuard point-to-point connection

See also: [WireGuard on OpenBSD](https://artnoi.com/blog/2020/wireguard/).

```
# Interface configuration
wgkey yourPrivKey=
wgport 6969
inet 10.8.1.4/24
up

# WireGuard peers
!ifconfig wg0 wgpeer peer1pubkey= wgendpoint 192.168.2.3 5555 wgaip 10.8.1.1/32
!ifconfig wg0 wgpeer peer2pubkey= wgendpoint example.com 9696 wgaip 10.8.1.2/32
!ifconfig wg0 wgpeer peer3pubkey= wgaip 10.8.1.3/32
```

### [pf.conf(5)](https://man.openbsd.org/pf.conf) for [wg(4)](https://man.openbsd.org/wg)

```
# pf.conf(5) for WireGuard

pass in on egress inet proto udp\
    from any to any port 6969

pass out on egress inet\
    from (wg0:network) nat-to (egress:0)
```

### [relayd.conf(5)](https://man.openbsd.org/relayd.conf.5): relaying SSH connection

```
protocol "myssh" {
    tcp {
        nodelay
        socket buffer 65536
    }
}

relay "sshforward" {
    listen on www.example.com port 2222
    protocol "myssh"

    forward to shell.example.com port 22
}
```

### [relayd.conf(5)](https://man.openbsd.org/relayd.conf.5): redirecting DNS connection

    redirect "dns" {

      listen on dns.example.com\
        tcp port 53

      listen on dns.example.com\
        udp port 53

      forward to <dnshosts>\
        port 53 check tcp
    }

### httpd(8) with TLS (HTTPS)

See [this blog](/blog/2020/openbsd-server/).

### Installing OpenBSD with full-disk encrpytion on [Vultr](https://vultr.com)

See [this blog](/blog/2020/openbsd/).

## GNU/Linux only

### systemd drop-in configuration

Drop-ins are parsed and overrides global configuration. The files are read alphabetically, so file `00-override` loads before `100-override`, i.e. `00` is overridden by `100`.

### systemd service failure

If `# systemctl status` returned _degraded_, we can issue:

```shell
systemctl reset-failed;
```

to fix the failed units.

### systemd (journald) auth.log

```shell
journalctl SYSLOG_FACILITY=10;
```

### Persistent `iptables` dropping incoming traffic

On Arch Linux, Systemd service `iptables.service` will load configuration `/etc/iptables/ipatbles.rules` on startup if the service is enabled. The file originally has blank fules.

To configure `iptables` such that it drops all incoming connections (in a usable way), change the configuration to:

> From [superuser.com](https://superuser.com/questions/427458/deny-all-incoming-connections-with-iptables)

```
*filter

:FORWARD DROP [0:0]

:OUTPUT ACCEPT [623107326:1392470726908]

:INPUT DROP [11486:513044]

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

-A INPUT -i lo -j ACCEPT

-4 -A INPUT -p icmp -j ACCEPT
-6 -A INPUT -p ipv6-icmp -j ACCEPT

# Add exception rules here
#-A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
#-A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
#-A INPUT -p tcp -m tcp --dport 443 -j ACCEPT

COMMIT
```

Also, enable the service (otherwise you would have to use `iptables-restore` each time you reboot):

```shell
systemctl enable --now iptables;
```

### Changing storage device designation, e.g. sdX1 to sdX4

Look for answer edited/posted by users **drs** and **Joao S Veiga** on [unix.stackexchange.com](https://unix.stackexchange.com/questions/18752/change-the-number-of-the-partition-from-sda1-to-sda2)

### Force unmounting after a chroot operation

After exitting from a `chroot` environment, if you find yourself unable to unmount certain mountpoints (target busy, etc), try following the [Linux LVM guide below](#my-other-cheat-sheet-links) first if your chroot environment is on LVM.

If all else failed, and you want to _force_ unmount the mountpoint, issue:

```shell
umount -lf /mountpoint;
```

This will [_force detach filesystem from fs heirarchy, and cleanup all references to the filesystem as soon as it's not busy_](https://unix.stackexchange.com/questions/61885)

### Console backlight

Most distributions place their console brightness configuration in `/sys/class/backlight/xxx/brightness`

## certbot (with NGINX)

Certbot can be used to automatically get new certificates and update your NGINX configuration to enable HTTPS in one command.

To obtain certificates (including the subdomains), and have Certbot modify your NGINX configuration, run:

```shell
certbot --nginx -d <DOMAIN_0> [-d <DOMAIN_1>];
```

To see certificate information, run:

```shell
certbot certificates;
```

To force-renew certificates _without reinstalling_ the certificates (i.e. the NGINX configuration would _not_ be modified), run:

```shell
certbot certonly --force-renewal -d <DOMAIN>;
```

Or, if you have setup webroot:

```shell
certbot certonly --webroot -w <WEBROOT_DIR> -d <DOMAIN_NAME>;
```

On Arch Linux with NGINX, include this snippet in your NGINX configuration to enable webroot:

```
location ^~ /.well-known/acme-challenge/ {
    allow all;
    root /var/lib/letsencrypt/;
    default_type "text/plain";
    try_files $uri =404;
}
```

The snippet above should be put in a `server` block
that listens on standard HTTP port 80.

For NGINX to serve HTTPS, add the following snippet to `server` block
listening on port 443.

```
ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

include /etc/letsencrypt/options-ssl-nginx.conf;
ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;
```

On FreeBSD, the package recommends putting the following line
in `/etc/periodic.conf` so that certbot will renew certificates periodically:

```
weekly_certbot_enable="YES"
```

Artnoi.com used both `cron` and `periodic.conf` schedulers when it was running
on FreeBSD and NGINX. Now it runs [OpenBSD](https://artnoi.com/blog/2020/openbsd-server/).

## Screenshots on Sway

My prefered way to do this is to use 2 separate programs to take screenshots,
(1) `slurp` for selecting a region, (2) `grim` for actually capturing the image:

> The man page suggests that `-o <OUTFILE>` can be used to specify output file,
> however, my experience in October 2022 was that `-o` flag does not work,
> and you can just supply the outfile name as last argument.

```shell
grim -g "$(slurp -d)" /tmp/scrot.png
```

Or, if you want to redirect the output to stdout to `wl-copy`:

```shell
grim -g "$(slurp -d)" - | wl-copy -t 'image/png';
```

This will capture the screenshot selected and piped to `wl-copy`.

## <a name="others"></a>My other cheat sheet links

[Arch Linux cheat sheet](/cheat/arch/)

[Arch Linux ZFS root](/blog/2019/arch-zfs/)

[ZFS cheat sheet](/cheat/zfs/)

[Device Mapper - LUKS and LVM](/cheat/device-mapper/)

[Git cheat sheet](/cheat/git/)

## [My cheat sheet links for noob friends](/noob/)

[Storage (disks, etc.)](/noob/block/)

[Booting the computer](/noob/boot/)

[Minimal UNIX desktop](/noob/desktop/)

[Vim for noobs](/noob/vim/)
