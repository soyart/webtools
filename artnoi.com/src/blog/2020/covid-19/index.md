# COVID-19 Journals

My random rant during the 2020 lockdown. It is mostly about computers and not really about the outbreak.

### April 10, 2020

I am working/studying from home for the third week in Bangkok, Thailand due to the COVID-19 pandemic crisis. While browsing YouTube, I found out about [Rosetta@home and crunch-on-arm](https://boinc.bakerlab.org), so I decided to lend my Rock Pi 4B's (RK3399) computing power for science. I tried to get my Khadas VIM3 up and running the project as well, but my new Ubuntu ARM installation keeps crashing after minutes due to some swap-related problems, which I believed is hardware-related. I tried to reflash the board with the old flasher software `khadas-burn-tool` which used to work perfectly, but today fails to unpack any OS images, so I had to abandon the board for now. And because my VIM3 is down for now, I bought a Lenovo ThinkCentre M93p "Tiny" (4570T 2c4t) to replace it as a Linux home server. If the PC runs well and cool like the ThinkPads, I may buy an i5-4790T (4c4t) to beef up my new M93p.

### April 12, 2020

The number of COVID-19 cases worldwide is now 1.79M, and 2551 in my country. New cases fall below 100 per day in my country for about two days thanks to massive social distancing (Thai government tries to minimize interpersonal contact between its citizens to "flatten the curve", by using closures, lockdowns, curfews, and banning alcohol sales during Thai new year for 10 days lol) but still I doubt if they have tested enough people each day. Our king continues to impress, and his artistic actions are reported worldwide, especially in Western media. And out of boredom, I searched the Facebook marketplace and found a good deal on a local Lenovo ThinkPad X230 (3210M, mine is 3320M). The machine is in excellent cosmetic condition, so I just had to buy it. The laptop should arrive soon.

### April 18, 2020

Both of my Think computers had arrived days before today, and I had set up the ThinkCentre M93p Tiny to run Arch Linux on EXT4 HDD. It is now being used as a Syncthing/Plex/NFS/ZFS backup station for my home. The new ThinkPad X230 (with 3210M) would be used as my lower-powered laptop, though it is safe to say it is not low-powered at all - it could run Heartstone game on Wine very smoothly on Ubuntu 18.04 on LVM-LUKS SSD and on 8GB speed/power mixed RAM (no dual-channel) while running barely over 60c! I never knew it was going to be this capable, so I wonder what I could pull out of my other X230 with the higher-clocked 3230M. Next month I will decide if the M93p Tiny needs the quad-core upgrade - the hyperthreaded dual-core 4570T seems to be running a bit hot under BOINC+Plex load (70-80c but never actually exceeds 81c).

### May 1, 2020

Today is May day, 2020, and I finally got my Khadas VIM3 working properly again after swapping a Windows HDD into one of my x86 computers and flashing the eMMC using `Amlogic Burn Tool` on Windows, after many failures on Ubuntu 16.04 and 18.04 hosts. The VIM3 is now running Ubuntu 18.04 server with 4.9 kernel and is used mainly as a BOINC client and a 24h terminal (lol) to my ThinkCentre server downstairs.

### May 18, 2020

Out of pure boredom, I tried to use `postfix` as an SMTP for my personal email artnoi@artnoi.xyz. However, on FreeBSD, I could not get `cyrus-sasl` to work properly due to bugs in FreeBSD's OpenSSL. Thus, the email is not secured, and is sent/received in plain text on default port 25.

### Jun 1, 2020

So I have been setting up an Arch Linux VPS for some networking experiments. Thanks to my provider who allows booting from my own `iso` image, I was able to install Arch on LUKS. After successfully setting up `Pi Hole` + `nginx`, I realized that having my Pi Hole out in the wild while remaining unencrypted may leave my Arch VPS vulnerable as an open resolver which may be used by "bad guys". So I changed my mind about how to do this (secure DNS) - if I should not query my DNS over unencrypted traffic then I will do it under my point-to-point VPN. I will put up a firewall on port 53 on all interfaces, but it will be left open under VPN. Thus, DNS requests will only be sent through the tunnel. But it's late now so I don't think I will just sleep now and deal with VPN later.

### Jun 4, 2020

Today I setup `openvpn` on my Arch VPS and succesfully tried to query the server under VPN connection. I also ditched `cloudflared` for `stubby` instead, so now instead of querying DNS-over-HTTPS (DoH) to Cloudflare's DNS, the box will now be querying DNS over TLS which are more widely supported by nameservers

### Jun 9, 2020

After getting comfortable with my own VPN, I started to notice how complicated it is to operate OpenVPN long-term with many clients (i.e. signing, renewing, and distributing keys and certificates). So I searched for new VPN solution and found **WireGuard**, which has _very much_ smaller code base (smaller better) than OpenVPN and is available on my non-Linux platforms (BSDs, iOS, macOS). Getting WireGuard to work is pretty easy and simple sans the fact that documentation is very scarce. Now WireGuard has replaced OpenVPN in my network stack.

### Jul 1, 2020

The COVID-19 lockdown measures are officialy relaxed today, although the Thai government insists that all Bangkok metro and skytrain passengers be digitally tracked on every single journey. Back to computers. My 4C4T Intel i5-4590T arrived some days ago - and it did certainly impress me with thermals and overall performance. Idle termperature drops from 50-51c to mid 40s, while loaded temperature (i.e. when running `BOINC` on all cores or when compiling software) also drops from high 70s (usually 77-79c) to mid 60s (63c-67c). I will publish some Phoronix benchmark later, but this quad-core CPU really amazes me compared to its hyperthreaded dual-core sibling that I replaced. In addition to the upgraded CPU and RAM, I also replaced the old 500GB HGST system hard disk drive with 500GB Crucial MX500 SSD. I succesfully migrated Arch Linux server installation to SSD without any loss of data - and this time I choose to fully encrypt the entire system (dm-crypt + ZFS), and created a USB key for unattended reboots. To do this, I first created ZFS snapshots for my data pool, and then made multiple _file-level_ for both my EXT4 rooti and the data ZFS pool. I then created the partitions and set everything up on the new SSD (dm-crypt and encrypted ZFS), mount everything to the right place and then transfer the files using `rsync` and editting some boot files (`fstab` and kernel parameters for example) plus rebuilding the initramfs. After it booted and ran fine (i.e. passed my highly n00b reliability tests) I destroyed the unneccessary system backups. So this is my [Geekbench 4 result](https://browser.geekbench.com/v4/cpu/15595338) (TBH GB4 is just yet another prietary garbage) after getting new CPU and SSD. One sad thing is I still have not found a job, but I think it is time that I do something to improve myself. So from today on I will try to study how-to devops as well as other essential computer skill like python and SQL. I think this is it for the COVID-19 journals guys, be seeing you!
