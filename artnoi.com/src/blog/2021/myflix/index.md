May 1, [2021](/blog/2021/)
# How I replaced Plex with WireGuard and NFS

This article will tell you how you can host your own media library remotely with [WireGuard VPN](/blog/2020/wireguard/) and NFS.

I have been using this configuration for nearly a year, and it is super-nice to be able to stream your own media remotely from a server to anywhere with WireGuard VPN and NFS.

**If your server hardware is not so modern or powerful, following this guide should give better performance than using a Plex server.**

My configuration looks something like this: a file server with the movies and music on its ZFS or Btrfs filesystem sits somewhere remotely on the internet, and my client just access those media files with NFS under WireGuard VPN.

## Steps

- Setup the filesystem - obviously, to store files

> I use ZFS or [Btrfs](/blog/2021/btrfs/) because of its safety and compression capabilities. If you are using external USB drives, you should use ZFS because it works on Linux, FreeBSD, and macOS.

- Setup WireGuard VPN for server-client communication

Refer to [this article](/blog/2020/wireguard/) if you haven't configured WireGuard.

- Setup the NFS share only on WireGuard interface

This can be done by editing `/etc/nfs.conf`, e.g. if your server WireGuard interface is assigned IP address of 10.8.0.1, edit the `host` field in `/etc/nfs.conf` to `host=10.8.0.1`.

For ZFS, you can use `zfs set sharenfs=on` to set NFS share on ZFS datasets, or you can be more specific with `zfs set sharenfs="ro=@192.168.0.0/24, rw=@10.8.0.3/32"`. **Note ZFS datasets don't need their entries in `/etc/exports`, and NFS server service must also be running** for ZFS `sharenfs` property to work.

- Mount the remote NFS share containing your media library

Just mount the remote filesystems as you would normally do. In Windows, enable NFS client and use file explorer to go to the network share location, i.e. `\\10.8.0.1\myshare`.

- Access the remote files as if they were local files!

Depending on your read/write permission, you maybe able to write directly to the NFS share!

## Why not use Plex?

Plex is heavy on the server-side, and Plex by default will transcode your video, which significantly affects playback quality.

If you turn the transcoding off, Plex playback quality will actually get worse because of increased bandwidth, because Plex now has to encapsulate the file content into HTTP to serve to the browsers.

In short, Plex does

- add needless server overhead, e.g. transcoding high-res videos

- add needless client overhead, e.g. running full browser on a bloated web page just to view videos/music

- lower playback quality

- require you to use Plex player instead of your favorite one like `mpv`

If the goal is just to read (or write) remote files, why bother using Plex when you can just use NFS which is now available on Windows too?

## How my setup is better than Plex

With my setup, I'm able to *losslessly* stream 1080p video from a server in Singapore or my home server to any location.

This setup works fine even if the server is not very powerful, while Plex suffers if the connection/IO/graphics is not high enough. In short, this setup is faster, lighter, and more reliable.

The load on client side is also much better, because now you can use any media player to play your video as if the files are local.

Because my setup will make your local machine treats the remote media files as if they were local, you can always add/remove files to your library using the terminal very easily.

You can download the new media files and save them directly to the NFS share.

## How my setup is worse than Plex

My setup lacks a rich metadata, auto media organization, and pretty library view.

But as the local media player treats the file as normal files as if they were on your local storage, you can actually use some software the local machine to organize the library for you.

Believe me, if you organized the media library well enough, which you should, you won't miss Plex at all.

And you also save disk space because now there is no Plex metadata and thumbnails.
