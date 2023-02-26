Jan 30, [2021](/blog/2021/)

# Pi-Hole คืออะไร

[Pi-Hole](https://pi-hole.net) เป็นหลุมดำที่บล็อคโฆษณาในระดับ DNS จึงไม่จำเป็นต้องมีการเชื่อมต่อที่ไม่จำเป็นไปที่เซอร์เวอร์โฆษณา ทำให้ Pi-Hole ช่วยเพิ่มความเร็วในการดาวน์โหลดหน้าเว็บ และทำงานได้เร็วกว่าการบล็อคโฆษณาแบบปกติบนบราวเซอร์มากๆ

> ชื่อ Pi-Hole มากจากคอมพิวเตอร์ (SBC) Raspberry Pi และหลุมดำ Black hole เนื่องจากผู้ใช้นิยมติดตั้ง Pi-Hole ลงบน Raspberry Pi (หรือ SBC อื่นๆ) เพราะคอพิวเตอร์จิ๋วพวกนี้ประหยัดไฟและราคาถูกครับ

# Pi-Hole ขั้นเทพ

ช่วงนี้ผมเริ่มเห็นคนไทยพูดคุยเรื่อง Pi-Hole มากขึ้นตามกลุ่ม hobbyist บนเฟซบุ๊ค แต่หลายๆคนยังใช้ Pi-Hole แบบเบสิคๆอยู่ วันนี้ผมเลยจะมาแนะนำวิธีทำ Pi-Hole ให้ปลอดภัยมากขึ้นครับ แต่ที่สำคัญกว่าคือเซ็ทอัพครั้งนี้สามารถทำได้บนหลายฮาร์ดแวร์และซอฟต์แวร์แพลตฟอร์มมากๆครับ

## อะไรทำให้เทพ?

ในทุกๆเซอร์เวอร์ที่ผมรัน Pi-Hole หลักๆเลยผมมักจะ:

- ทำให้ Pi-Hole คุยกับ client [ผ่าน WireGuard VPN เท่านั้น](/blog/2021/wireguard-th/)

- ใช้ TLS stub resolver อย่าง `stubby(1)` ที่สามาถทำ [DNS-over-TLS (DoT)](https://en.wikipedia.org/wiki/DNS_over_TLS) พร้อมกับ [DNSSEC](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) เพื่อมารับช่วงต่อจาก Pi-Hole ครับ ถ้าจะให้พูดแบบทางการคือ DNS requests จะถูก wrap ด้วย TLS อนจะถูกส่งออกไปที่เซอร์เวอร์ DoT เพื่อความปลอดภัยที่สูงขึ้นครับ

- (เฉพาะเครื่องที่ต้องการติดตั้ง web interface เท่านั้น) แทนดีฟอลต์เว็บเซอร์เวอร์ `lightppd(8)` ด้วย [`nginx(8)`](https://nginx.com) (why not?) หากเลือกเส้นทางนี้เราจะต้องติดตั้ง `php-fpm` เพิ่ม และต้องเขียนไฟล์ตั้งค่าขึ้นเองสำหรับ PHP และ NGINX (why not อีกนั่นแหละครับ)

> หลังจากเราทำการติดตั้งซอฟต์แวร์เพิ่มเติมและตั้งค่าใหม่ตามนี้แล้ว DNS requests ของเราจะปลอดภัยขึ้นเยอะมากครับ เพราะ (1) ฝั่ง in-bound (จาก client) ก็มาแบบ VPN (2) ฝั่ง out-bound จะถูกส่งออกไปแบบ TLS เอาง่ายๆก็คือหากมีคนดักฟังหรือมี man-in-the-middle แล้วเค้าจะไม่เห็น DNS query ของเราเลยครับ

> และหากคุณเลือกที่จะใช้ WireGuard คุณก็จะสามารถใช้ Pi-Hole ได้ทุกที่บนอินเตอร์เน็ต แม้คุณจะอยู่นอกบ้าน หรือใช้เครื่อข่าย cellular ก็ตาม (ต้องใช้ DDNS หากไม่มี public IP address เป็นขอตัวเองครับ) อย่างที่ผมใช้ คือตั้งพีซี ThinkCentre เครื่องนึงไว้เป็นเซอร์เวอร์ WireGuard และ Pi-Hole โดยเฉพาะ ทำให้ผมสามารถบล็อคแอดได้ทุกที่ และคิวรี่อย่างปลอดภัย ใต้ร่ม VPN ครับ

## เตรียมความพร้อมก่อน _start_ เซอร์วิสต่างๆ

> ผมแนะนำให้ผู้ใช้ Pi-Hole อ่านหน้า [Arch Wiki เกี่ยวกับ Pi-Hole](https://wiki.archlinux.org/index.php/Pi-hole#Configuration)

### 1. WireGuard VPN และ Firewall

[ติดตั้งและตั้งค่า WireGuard VPN](/blog/2021/wireguard-th/) หรือ VPN อื่นๆ รวมถึง Firewall ต่างๆ

### 2. TLS stub resolver (ด้วย `stubby(1)`)

> ทำไมต้องมี `stubby(1)`?
> ถ้าจะให้ตอบแบบง่ายคือเพื่อให้ DNS queries ที่ออกจาก Pi-Hole เป็นแบบ [DNS-over-TLS](https://en.wikipedia.org/wiki/DNS_over_TLS) เพื่อความเป็นส่วนตัวและความปลอดภัยครับ เพราะ Pi-Hole หรือ `dnsmasq(8)` ไม่สามารถทำ DNS-over-TLS ได้ โดยการทำ DNS-over-TLS ก็มี trade-off นั่นคือ latency นั่นเอง การตั้งปริมาณ Pi-Hole DNS cache ให้เหมาะสมกับการใช้งานจึงสำคัญ

ติดตั้ง `stubby(1)` ด้วย package manager ในตัวอย่างนี้ผมจะใช้ `pacman` ของ Arch Linux

    # pacman -S stubby;

ตั้งค่า `stubby(1)` ที่ `/etc/stubby/stubby.yml` โดยเราสามารถแก้ไขตามที่ต้องการ [ตามที่ Arch Wiki แนะนำ](https://wiki.archlinux.org/index.php/Stubby)ได้เลยครับ ผมมักจะตั้งค่า DNSSEC และ policy ให้ strict ครับ แต่คุณเลือกได้ตามใจเลย แค่อย่าลืมแก้ไข `listen_address` ใน `stubby.yml` ให้ `stubby` ฟัง DNS requests ที่ loopback address (inet = `127.0.0.1`, inet6=`::1`) port อื่นที่ไม่ใช่ `53` นะครับ เพราะ Pi-Hole จะฟังที่พอร์ต `53` พอดีครับ **แล้วก็ต้องปิดเซอร์วิสอื่นๆที่ฟังอยู่ที่พอร์ต `53` ด้วยครับไม่งั้น Pi-Hole จะสตาร์ทไม่ติดเพราะพอร์ตไม่ว่าง**

ในตัวอย่างนี้จะใช้พอร์ต `5369` สำหรับ `stubby(1)` จึงต้องแก้ฟิล์ด `listen_address` ให้เป็น:

    listen_addresses:
      - 127.0.0.1@5369
      -  0::1@5369

อย่าลืมเว้นวรรค indent ให้ถูกต้องนะครับ ไม่งั้นไฟล์ `.yml` จะใช้งานไม่ได้ หลังจากเขียนไฟล์เสร็จ ลองเทสต์ว่าใช้ได้รึป่าวด้วยการรัย `$ stubby;` ครับ หากไม่มี error ก็ enable หรือ start `stubby.service` ได้เลยครับ:

    # systemctl enable --now stubby;

หลังจากนั้น ให้ทดสอบการเชื่อมต่อแบบ DNS-over-TLS ด้วยการ query ไปที่ listen address ของ `stubby.service` ครับ:

    $ dig @localhost -p 53690 artnoi.com;

แล้วรอดูว่าได้ answer ถูกต้องไหม หากถูกต้องก็ข้ามไปสเตปต่อไปได้เลยครับ

### 3. NGINX แทน lighttpd

ติดตั้ง `php(1)` และ `php-fpm(8)` และ `nginx(8)`:

    # pacman -S php php-fpm nginx-mainline;

จากนั้น ให้แก้ไขไฟล์ตั้งค่า `/etc/php.ini` `/etc/nginx/nginx.conf`

#### `/etc/php/php.ini`

ตามที่ Arch Wiki แนะนำ โดยย่อๆ คือเพิ่ม `extensions` (จำเป็น) และ `open_basedir` (ไม่ใส่ก็ได้แต่ผมใส่เพื่อความปลอดภัยครับ และถ้าคิดจะใส่แล้วก็ควรใส่ให้ครบครับ) ในไฟล์ `php.ini`

    # /etc/php/php.ini

    [...]
    extension=pdo_sqlite
    [...]
    extension=sockets
    extension=sqlite3
    [...]
    open_basedir = /srv/http/pihole:/run/pihole-ftl/pihole-FTL.port:/run/log/pihole/pihole.log:/run/log/pihole-ftl/pihole-FTL.log:/etc/pihole:/etc/hosts:/etc/hostname:/etc/dnsmasq.d/02-pihole-dhcp.conf:/etc/dnsmasq.d/03-pihole-wildcard.conf:/etc/dnsmasq.d/04-pihole-static-dhcp.conf:/var/log/lighttpd/error.log:/proc/meminfo:/proc/cpuinfo:/sys/class/thermal/thermal_zone0/temp:/tmp

> `open_basedir` จะจำกัดการเข้าถึงไฟล์ซิสเต็มของ PHP ทำให้อุ่นใจว่าจะไม่มีโปรแกรม PHP ไปอ่านหรือเขียนไฟลฺ์นอกเหนือจาก path ที่กำหนดไว้ใน `open_basedir` ครับ

> บน VPS จะไม่มีโฟลเดอร์ `/sys/class/thermal/*` หากติดตั้ง Pi-Hole และเว็บอินเตอรฺ์เฟซบน VPS ผมไม่แนะนำให้ใส่ `/sys/class/thermal/thermal_zone0/temp` ใน `open_basedir` ครับ

#### `/etc/nginx`

เขียนไฟล์ตั้งค่าเว็บเซอร์เวอร์ `nginx.conf` ซึ่งเราไปดูจาก [Arch Wiki](https://wiki.archlinux.org/index.php/Pi-hole#Nginx_instead_of_Lighttpd) หรือจะดู[ไกด์ของ Pi-Hole](https://docs.pi-hole.net/guides/webserver/nginx/)เลยก็ได้ครับ หลักๆเลยคือเราจะแก้ไขไฟล์ตั้งค่า `nginx.conf` สำหรับการตั้งค่าทั่วไปของ NGINX และไฟลฺ์ `conf.d/pihole.conf` สำหรับการตั้งค่า NGINX เพื่อเสริฟ Pi-Hole

หลังจากเขียนไฟล์เสร็จแล้วเราต้อง[แก้ไขเซอร์วิสไฟล์ตาม Arch Wiki](https://wiki.archlinux.org/index.php/Pi-hole#Nginx_instead_of_Lighttpd) สำหรับ PHP Fast Process Manager `php-fpm.service`

    # systemctl edit php-fpm.service;

แก้ไข (override) `php-fpm.service` ด้วยการเติม `ReadWritePaths` ไปในช่วง `[Service]` ซึ่งจะสัมพันธ์กับ `open_basedir` ใน `php.ini`:

    [Service]
    ReadWritePaths = /srv/http/pihole
    ReadWritePaths = /run/pihole-ftl/pihole-FTL.port
    ReadWritePaths = /run/log/pihole/pihole.log
    ReadWritePaths = /run/log/pihole-ftl/pihole-FTL.log
    ReadWritePaths = /etc/pihole
    ReadWritePaths = /etc/hosts
    ReadWritePaths = /etc/hostname
    ReadWritePaths = /etc/dnsmasq.d/
    ReadWritePaths = /proc/meminfo
    ReadWritePaths = /proc/cpuinfo
    ReadWritePaths = /sys/class/thermal/thermal_zone0/temp
    ReadWritePaths = /tmp

> บน VPS จะไม่มีโฟลเดอร์ `/sys/class/thermal/*` หากติดตั้ง Pi-Hole และเว็บอินเตอรฺ์เฟซบน VPS ผมไม่แนะนำให้ใส่ `/sys/class/thermal/thermal_zone0/temp` ใน `ReadWritePaths` ครับ

## Enable เซอร์วิสที่เกี่ยวกับ Pi-Hole และ Pi-Hole web interface

หลังจากแก้ไขทุกไฟล์เรียบร้อยครบทุกไฟล์ตาม Arch Wiki แล้ว เราก็ enable เซอร์วิสต่างๆทิ้งไว้ แล้วรีบูทครับ:

    # systemctl enable pihole-FTL.service nginx.service php-fpm.service;
    # reboot;

> ไม่ต้องรีบูทก็ได้นะครับ ใช้ `systemctl enable --now` แทนได้ หากไม่สามารถเริ่มเซอร์วิสได้ ให้ลองเช็ค Arch Wiki ซ้ำอีกรอบครับ ส่วนมากที่ผมพลาดจะเป็นการตั้งค่า PHP

## ตั้งค่า Pi-Hole DNS

พอบูทขึ้นมาเสร็จแล้ว ตั้งค่าพาสเวิร์ดของ admin web interface ด้วย:

    $ pihole -a -p;

แล้วตั้งค่า default DNS upstream ไปที่ listen address ของ `stubby`:

    $ pihole -a setdns '127.0.0.1#53690';

แล้วอัพเดทบล็อคลิสต์ (gravity)

    $ pihole -g;

แก้ `/etc/resolv.conf` บนเครื่อง Pi-Hole ของเรา ให้ใช้ localhost พอร์ต 53 สำหรับ resolve โดเมน (address สำหรับเครื่องเราเองคือ `127.0.0.1` หรือ loopback address สำหรับเครื่อง Pi-Hole เองครับ):

    # echo '127.0.0.1' > /etc/resolv.conf;

หากคุณใช้ `openresolv` ผมคงไม่ต้องอธิบายว่าต้องทำยังไง ถูกไหมครับ? 5555

## เริ่มใช้งาน Pi-Hole DNS และ web interface

เราสามารถเข้าถึง web interface ผ่าน web browser ที่ IP address ของ Pi-Hole ครับ ซึ่งถ้าหากคุณใช้ WireGuard ตามที่ผมแนะนำในข้อหนึ่ง คุณก็สามารถใช้ WireGuard IP address เพื่อโหลดหน้าเว็บผ่าน VPN ได้ครับ ลองเข้าไปเซ็ทอัพอะรดูก่อนครับ

พอเสร็จแล้วก็ลอง query ไปที่ Pi-Hole ของเรา:

    $ dig @localhost artnoi.com;

หรือคิวรี่ผ่าน VPN ในที่นี่ขอสมมติว่า WireGuard IP ของ Pi-Hole คือ `10.0.0.1`

    $ dig @10.0.0.1 artnoi.com;

โดยเราสามารถตั้งค่า WireGuard บนเครื่อง client ให้ใช้ DNS server เป็น Pi-Hole ได้ด้วยการเปลี่ยน `[Interface]: DNS = $PiHoleWGIP` เช่นในกรณีนี้ที่สมมติว่า WireGuard VPN network มี IP address เท่ากับ `10.0.0.0/24`:

    [Interface]
    PrivateKey = eNf8P2Jx8UvBYLOmK2ToaUBrLNOpaByqWcv+GeWQ/20=
    Address = 10.0.0.2/24
    DNS = 10.0.0.1

เพียงเท่านี้ ทุกครั้งที่คุณเชื่อมต่อเครือข่าย VPN ของคุณ เครื่องคุณก็จะใช้โฮสต์ 10.0.0.1 ที่มี Pi-Hole อยู่แล้ว ไว้ใช้เป็น Ad-blocking DNS sinkhole over VPN ครับ
