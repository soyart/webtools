Jan 27, [2021](/blog/2021/)
# แนะนำ WireGuard VPN
[See the original English blog post here](/blog/2020/wireguard/)

[ข้ามไปอ่านวิธีตั้งค่า](#guide)
## WireGuard คืออะไร?
ในช่วงปีนี้ VPN เหมือนจะถูกหยิบยกมาพูดกันอย่างแพร่หลายเกินกราฟมากในประเทศไทย อาจจะด้วยสภาวะทางการเมืองและกฎหมายที่ชอบปิดหูปิดตาประชาชน แต่ผมก็ยังเห็นว่าคนไทยยังขาดความรู้ความเข้าใจในเรื่อง VPN ส่วนมากเรื่องที่คนไทยคุยกันคือแอพ VPN ฟรี หรือผู้ให้บริการ consumer VPN ต่างๆ แต่ไม่ยักจะมีใครพูดถึง IPSec, OpenVPN หรือ WireGuard กันซักคน ทั้งที่ซอฟต์แวร์โปรโตคอลพวกนี้แหละโดยเฉพาะ OpenVPN คือ backbone ของ consumer VPN service เพราะฉะนั้นวันนี้ผมจะมาบ่นเรื่อง WireGuard ให้ทุกคนฟังกันครับ

> ตัวอย่างการตั้งค่าอยู่ที่ท้ายบทความครับ

[WireGuard](https://wireguard.com) คือโปรโตคอล VPN แบบใหม่ที่เขียนขึ้นมาเพื่อ Linux kernel โดยเฉพาะ (แต่สามารถใช้บนแพลตฟอร์มอื่นได้)

## เล็กสั้นและฉับไว นั่นแหละ WireGuard
WireGuard เน้นประสิทธิภาพ ความเร็ว ความปลอดภัย และความเล็กของโค้ด WireGuard มีเพียงแค่ 4,000 กว่าบรรทัด (LoC) เมื่อเทียบกับโปรโตคอลคู่แข่งอย่าง OpenVPN ที่ใหญ่มากๆ 70,000++ LoC ที่ยังต้องใช้ไลบรารี่ OpenSSL อีก 500,000 กว่าๆ LoC! โค้ดเบสที่เล็ก ทำให้ WireGuard มี attack surface ที่เล็กกว่า VPN อื่นๆมากๆ และยังมีประโยชน์ทั้งด้านความเร็วของการรับส่งข้อมูลและความสะดวกในการ port ไปใช้บนแพลตฟอร์มที่ไม่ใช่ Linux และที่สำคัญ คือประหยัด system resource ครับ

นอกจากโค้ดที่เล็กมากแล้ว สิ่งที่ทำให้ WireGuard แตกต่างจาก VPN อื่นๆคือความ*ง่าย* (simplicity - [KISS](https://en.wikipedia.org/wiki/KISS_principle)) และ strong cryptography โดย WireGuard ได้เลือก cryptographic cypher ไว้แล้วหลายตัว แต่ละตัวทำหน้าที่เฉพาะตัว และผู้ใช้ไม่สามารถเลือก cypher ได้เอง นอกจากนี้ การจัดการคีย์เช่นการลบหรือเปลี่ยนคีย์ต่างๆยังทำได้ง่าย เนื่องจาก WireGuard ไม่ใช้ trusted authority หรือเซิร์ฟเวอร์กลางในการรับรอง certificate เหมือน OpenVPN ซึ่งหมายความว่าการตั้งค่าต่างๆ เราสามารถทำได้ในไฟล์เดียว จากโฮสต์ไหนก็ได้

WireGuard ใช้หลักการ Crypto routing และ UDP เป็นรากฐาน ทำให้โปรโตคอลใหม่นี้สามารถทำงานได้อย่างปลอดภัยกว่า ประสิทธิภาพสูงกว่า และเสถียรกว่า traditional VPN อย่าง OpenVPN และ IPSec มากๆ เพราะ WireGuard ใช้ UDP (**ผู้ใช้เลือก TCP ไม่ได้**) และถูกเขียนมาอย่างฉลาด การเชื่อมต่อผ่าน WireGuard จึงสามารถ survive สภาวะที่ไม่เอื้ออำนวยได้ดีกว่าโปรโตคอลคู่แข่ง

## อนาคตใหม่แห่งโลก VPN
ความไฮเทคนี้ทำให้นาย Theo De Raddt และ Linus Torvalds (เฮ้ดของ OpenBSD และ Linux kernel ตามลำดับ) ถึงกับต้องร้องว้าวแล้วรีบจัดการ port มาลงแพลตฟอร์มของตัวเอง การที่ WireGuard ได้ไปอยู่ใน Linux kernel เป็นการการันตีว่าโปรโตคอลใหม่นี้ดีจริงและยังมีอนาคตที่สดใสอีกด้วย

จากการใช้งานจริง ผมพบว่า WireGuard มีความเถียรและตั้งค่าโฮสต์ใหม่ได้ง่ายกว่า OpenVPN มากๆ และที่สำคัญที่สุดคือเร็วกว่า ไวกว่า หลุดแล้วต่อติดกลับได้อย่างเสถียรมาก และต้องขอบคุณ WireGuard ที่เป็น UDP-only ที่ทำให้ผมสามารถต่อ VPN หลัง Firewall ที่ต่างๆได้สบายๆ เพราะการเชื่อมต่อผ่าน WireGuard หากมองแค่ชั้น UDP แล้ว Firewall จะเห็นเป็น state-less connection

> ในปัจจุบัน WireGuard ได้ถูกรวมไว้ใน Linux kernel (>5.7) และ OpenBSD (>6.8) เป็นที่เรียบร้อย และ Commercial VPN provider หลายๆเจ้าก็กำลังทำ WireGuard ไว้เป็นออปชันให้ลูกค้าเลือก หากคุณสนใจเรียนรู้เกี่ยวกับ WireGuard ลอง[ดูวีดีโอนี้บนยูทูป จากผู้พัฒนา WireGuard ครับ](https://www.youtube.com/watch?v=88GyLoZbDNw)

ปัจจุบัน นอกจากแอพ stand-alone สำหรับ macOS, iOS, Android, และ Windows แล้ว ซัพพอร์ตสำหรับ WireGuard บน Linux Desktop เองก็ถือว่าดีขึ้นมากและอยู่ในระหว่างการพัฒนาจริงจัง ทั้งใน `systemd-networkd` และ `NetworkManager`

## การติดตั้ง WireGuard บน macOS, iOS, Android, Windows
เราสามารถติดตั้ง WireGuard ได้ง่ายๆบน OS ยอดนิยมต่างๆเช่น macOS, iOS, Android, และ Windows เพียงดาวน์โหลดแอพ WireGuard จาก App Store (ง่ายที่สุด) หรือจาก[เว็บไซต์ WireGuard](https://wireguard.com) การเซ็ทอัพ WireGuard บนแต่ละแพล็ตฟอร์มมีความคล้ายกันมาก โดยผู้ใช้ macOS, iOS, Windows สามารถอ่านการตั้งค่าบน GNU/Linux หรือ OpenBSD เพื่อนำไปประยุกต์ต่อได้

## <a name="guide"></a>การเตรียมการก่อนติดตั้ง WireGuard บน UNIX

> ไม่จำเป็นสำหรับผู้ใช้ที่ใช้ WireGuard ในรูปแบบแอพ

WireGuard จะทำงานได้ก็ต่อเมื่อเราได้ตั้งค่า IP forwarding เป็น `1` หรือ `true` ใน kernel setting (`sysctl(8)`) โดยคีย์เวิร์ดของการตั้งค่า `sysctl` จะแตกต่างกันไปตามแต่ละแพลตฟอร์ม โดยไฟล์ตัวอย่างข้างล่างเป็นการสร้างไฟล์เพื่อตั้งค่า `sysctl` [แบบ *Persistent* สำหรับ GNU/Linux (Arch Linux)](https://wiki.archlinux.org/index.php/Sysctl#Configuration):

	# sysctld='/etc/sysctl.d';
    # mkdir -p $sysctld;
	
	# ipfwd="$sysctld/50-ip_forwarding";
	# touch $ipfwd;
	
	# echo 'net.ipv4.ip_forward=1' >> "$ipfwd";
	# echo 'net.ipv6.conf.all.forwarding=1' >> "$ipfwd";

*Persistent* IP forwarding [สำหรับ OpenBSD](https://www.openbsd.org/faq/pf/nat.html#ipfwd):
    
	# echo 'net.inet.ip.forwarding=1' >> /etc/sysctl.conf;
	# echo 'net.inet6.ip6.forwarding=1' >> /etc/sysctl.conf;

หรือหากคุณต้องการตั้งค่าแบบ one-shot (reboot แล้วเซ็ทติ้งหาย) บน GNU/Linux

    # sysctl -w net.ipv4.ip_forward=1;
    # sysctl -w net.ipv6.conf.all.forwarding=1;

หรือหากคุณต้องการตั้งค่าแบบ one-shot (reboot แล้วเซ็ทติ้งหาย) บน OpenBSD

    # sysctl net.inet.ip.forwarding=1;
	# sysctl net.inet6.ip6.forwarding=1;

> ผู้ใช้ควรเปิด Firewall หลังเปิดใช้งาน IP forwarding

## การติดตั้ง WireGuard บน UNIX

การใช้งาน WireGuard บน UNIX จำเป็นต้องมี

1. kernel module (`wg(4)`) ซึ่งมีอยู่ใน Linux Kernel (>5.7) หรือ OpenBSD kernel อยู่แล้ว

2. user-space utilities (`wg(8)`, `wg-quick(1)`) ซึ่งสามารถติดตั้งได้จากแพ็คเกจ `wireguard-tools`

ติดตั้ง WireGuard (user-space utilities) ด้วย package manager

    # pkg_add wireguard-tools;
    # pacman -S wireguard-tools;
    # dnf install wireguard-tools;
    # apt install wireguard-tools;

ติดตั้ง WireGuard (Linux <5.7 kernel module) ด้วย package manager

    # pacman -S wireguard-dkms;
    # pacman -S wireguard-lts;

## การสร้าง public key pair สำหรับ WireGuard บน UNIX

> ต้องมี superuser privilege เพื่ออ่าน `/etc/wireguard`

คอมมานด์ข้างล่างจะสร้าง key pair `foo.pub` และ `foo.key` ไว้ใน `/etc/wireguard` ด้วย `wg(8)`:

    # cd /etc/wireguard;
	# wg genkey | tee foo.key | wg pubkey > foo.pub;

> หากไม่ใช้ pipeline เอาท์พุทของ `wg(8)` จะออกมาที่ stdout

เพื่อเพิ่มความปลอดภัย เราสามารถสร้าง Pre-shared key (psk) สำหรับ WireGuard ด้วย:

    # wg genpsk;

## การตั้งค่า WireGuard บน GNU/Linux
WireGuard มาพร้อม `bash` สคริปต์ `wg-quick(1)` ที่ช่วย *bring up* อินเตอร์เฟซ `wg(4)` สำหรับ WireGuard VPN บน GNU/Linux

`wg-quick(1)` จะอ่านการตั้งค่าจาก `/etc/wireguard/wgX.conf` (แทน `X` ด้วยชื่ออินเตอร์เฟซ เช่น `/etc/wireguard/wg0.conf`)

การตั้งค่า WireGuard บน GNU/Linux, macOS, iOS, Android, และ Windows ใช้ภาษาที่เกือบจะเหมือนกันในการตั้งค่า (ชื่อ setting field เหมือนกัน) การตั้งค่า WireGuard จะมี 2 ส่วนหลักๆ คิอส่วนของ `[Interface]` สำหรับอินเตอร์เฟซ (ตัวโฮสต์เอง) และ `[Peer]` สำหรับ remote hosts โดยเราสามารถเพิ่ม peer ได้ด้วยการเขียน `[Peer]` เพิ่มขึ้นมา:

    [Interface]
	.
	.
	[Peer]
	.
	.
	[Peer]
	.
	.
	[Peer]
	.
	.

บน GNU/Linux การตั้งค่าของ server และ client จะคล้่ายๆกัน ต่างกันที่ `[Interface]: PostUp`, `[Interface]: PostDown` ซึ่งฝั่ง client ไม่จำเป็นต้องมี หากต้องการเชื่อมต่อแบบ point-to-point

### ตัวอย่าง GNU/Linux client
เซ็ทติ้งข้างล่างเป็นการเซ็ทอัพไคลเอนท์ `10.8.0.14` ที่จะมี 2 peers `10.8.0.1` และ `10.8.0.2` โดยเน็ตเวิร์คเป็นแบบ `10.8.0.0/24`

สำหรับเน็ตเวิร์คนี้ (`10.8.0.0/24`) ต้องกำหนด `[Interface]: Address` (IP address) ของโฮสต์เราเองด้วย CIDR `/24`

สำหรับ `[Peer]: AllowedIPs` ให้ใส่ IP address ของเน็ตเวิร์ค VPN ของเรา ในกรณีนี้คือ `10.8.0.0/24` และ peer IP address เช่น `10.8.0.2/32`

> เติม `0.0.0.0/0` และ `::1/0` ใน `[Peer]: AllowedIPs` หากต้องการให้ peer ไหนเป็น WireGuard default gateway สำหรับทั้ง IPv4 และ v6 (หรือมุดอุโมงค์ไปโผล่ที่ peer นั้นนั่นเอง)

> เซ็ทติ้งข้างล่างมีการใช้ DNS server ในวง WireGuard เอง และใช้ `PreSharedKey` สำหรับ `10.8.0.1`-`10.8.0.14`

    [Interface] # Client
	PrivateKey = uBxlYH6/fdAy4FfJxquw/Jes+jMntIAxC5Tn65Jwpn0=
    Address = 10.8.0.14/24
    DNS = 10.8.0.2, 10.8.0.1
	PostUp = iptables -t nat -A POSTROUTING -o %i -j MASQUERADE
    PostDown = iptables -t nat -D POSTROUTING -o %i -j MASQUERADE

    [Peer]
    EndPoint = 43.69.233.467:55555
    PublicKey = q6n2vXR3NSoy2A6OSBElR95JerCXnJLpdGS8RxuFs1s=
    PreSharedKey = JWZkesHbaSYMzjRcSK4j/Q0wunWYSa4LkTSwxEtzJzM=
    AllowedIPs = 10.8.0.1/32
    #AllowedIPs = 0.0.0.0/0, ::/0
    PersistentKeepalive = 25

    [Peer]
    Endpoint = my.domain.com:22134
    PublicKey = OmhQUrpLIzc1fRxpBRdpLwV63bAiYRHCbX6nV07nYQw=
    AllowedIPs = 10.8.0.2/32
    PersistentKeepAlive = 25

### ตัวอย่าง GNU/Linux server
เซิร์ฟเวอร์ WireGuard ต่างจากไคลเอนท์ ตรงที่เซิร์ฟเวอร์จำเป็นต้องมี `[Interface]: Endpoint`, `[Interface]: ListenPort` เพื่อให้ peer หาตัวเซิร์ฟเวอร์เจอ และคำสั่ง `iptables` (+`ip6tables`) ใน `[Interface]: PostUp`, `[Interface]: PostDown` เพื่อ route ทราฟฟิค (ทั้ง IPv4, v6) ของ peer:

> WireGuard server ในตัวอย่างข้างล่าง ใช้อินเตอร์เฟซชื่อ `eno1` หากคอมพิวเตอร์ของคุณต่อกับอินเตอร์เน็ตได้หลายอินเตอร์เฟซ และต้องการจะใช้ WireGuard บนอินเตอร์เฟซพวกนั้น ให้เพิ่มคำสั่ง `iptables` และ `ip6tables` สำหรับอินเตอร์เฟซนั้นๆด้วย หาชื่ออินเตอร์เฟซได้ด้วย `$ ip a;` หรือ `$ ifconfig;` บน GNU/Linux

    [Interface] # Server
    PrivateKey = APkD7ksO40RWUZDkYU7FwDecqqTS0+rGSbhIHSqSPFk=
    Address = 10.8.0.1/24
    ListenPort = 55555
    PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eno1 -j MASQUERADE;\
	ip6tables -A FORWARD -i %i -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eno1 -j MASQUERADE
    PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eno1 -j MASQUERADE;\
	ip6tables -D FORWARD -i %i -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eno1 -j MASQUERADE

    [Peer]
    EndPoint = 45.76.190.176:51543
    PublicKey = Z432a5ZyKhcbRvbuH6HFPShmiODjLkL/K+rqX6uqaG0=
    PreSharedKey = JWZkesHbaSYMzjRcSK4j/Q0wunWYSa4LkTSwxEtzJzM=
    AllowedIPs = 10.8.0.14/32
    #AllowedIPs = 0.0.0.0/0, ::/0
    PersistentKeepalive = 60

    [Peer]
    Endpoint = my.domain.com:22134
    PublicKey = OmhQUrpLIzc1fRxpBRdpLwV63bAiYRHCbX6nV07nYQw=
    AllowedIPs = 10.8.0.2/32
    PersistentKeepAlive = 25

หลังจากตั้งค่าเสร็จเรียบร้อย ในระบบที่มี Systemd เราสามารถ *enable* (หรือแค่ *start*) เซอร์วิส `wg-quick@wgX.service` ได้ โดย Systemd จะใช้ `wg-quick(8)` เพื่อ bring up/down อินเตอร์เฟซ `wgX` ตัวอย่างข้างล่างจะ *enable* และ *start* เซอร์วิสสำหรับอินเตอร์เฟซ `wg0` (ไฟล์ตั้งค่าอยู่ที่ `/etc/wireguard/wg0.conf`):

    # systemctl enable --now wg-quick@wg0.service;

เราสามารถเช็คการเชื่อมต่อได้ด้วย `wg(8)`:

	# wg;

หรือ:

    # wg show;

หน้าตาของเอาท์พุทก็จะประมาณนี้ครับ (ผมใส่ value มั่วๆนะครับ):

    $ sudo wg;

    interface: wg0
    public key: 4HBWx19Jl5YogSzi+l0akxXBhPVZruwx+zDDv/UEFXI=
    private key: (hidden)
    listening port: 69420

    peer: EJQ2dniqR4J/CnEncl7Mg6pT/co57irBLmG0pVL9XXc=
    endpoint: 122.213.43.23:11210
    allowed ips: 10.5.0.1/32
    latest handshake: 13 seconds ago
    transfer: 1.12 MiB received, 10.24 MiB sent

    peer: +A+LL2YlR0PMqCIJONl+8kMppJpOvfkAEUCegwYEoUk=
    preshared key: (hidden)
    endpoint: 12.23.23.21:55569
    allowed ips: 10.5.0.2/32
    latest handshake: 1 minute, 22 seconds ago
    transfer: 281.91 KiB received, 197.54 KiB sent
    persistent keepalive: every 25 seconds

สามารถดูคู่มือ `wg(8)` ได้หากไม่เข้าใจความหมายของเอาท์พุทครับ

    # man 8 wg;

### ตั้งค่า WireGuard บน OpenBSD (>6.8) ด้วย `hostname.if(5)`

> ผู้ใช้ OpenBSD ทุกคนควรอ่านคู่มือ [`man` สำหรับ `hostname.if(5)`](https://man.openbsd.org/hostname.if.5) และ [`wg(4)`](https://man.openbsd.org/wg.4)

เราสามารถใช้ WireGuard บน OpenBSD ได้ *แม้จะไม่ติดตั้ง user-space tools `wireguard-tools` ซึ่งมาพร้อม `wg(8)` และ `wg-quick(8)`* เพียงแค่เขียนไฟล์ `/etc/hostname.wgX` (แทน `X` ด้วยชื่ออินเตอร์เฟซ):

    # Interface configuration
    wgkey sPXc4K/SXu8oYcEbVentbh7EShxRFR6nccR98GRyX1U=
    wgport 22134
    inet 10.8.0.2/24
    up

    # Adding WireGuard peers
    !ifconfig wg0 wgpeer Z432a5ZyKhcbRvbuH6HFPShmiODjLkL/K+rqX6uqaG0= wgendpoint 10.10.0.1 55555 wgaip 10.8.0.1/32
    !ifconfig wg0 wgpeer Z432a5ZyKhcbRvbuH6HFPShmiODjLkL/K+rqX6uqaG0= wgaip 10.8.0.14/32

หลังจากเขียนไฟล์สำหรับตั้งค่า WireGuard เสร็จ ควรเช็ค `pf.conf(5)` เพื่อดูว่า firewall ทำงานกับ WireGuard ได้ไหม [ผมเคยเขียนบล็อกเกี่ยวกับการตั้งค่า `pf(4)` สำหรับ OpenBSD ไว้แล้วเมื่อปีที่แล้ว](/blog/2020/wireguard.html) โดยทั่วไปเราน่าจะต้องเพิ่มบรรทัดที่หน้าตาคล้ายๆ:

    # pf config for WireGuard
    pass in on egress inet proto udp from any to any port $wgports
    pass out on egress inet from ($wgif:network) nat-to (egress:0)

หลังจากตั้งค่าทุกอย่างเสร็จ ให้ reboot แล้วรออ่าน boot messages เพื่อดูว่าอินเตอร์เฟซ `wgX` ของเรา up หรือเปล่า จากนั้นให้ลองดูสถานะการเชื่อมต่อด้วย:

	# ifconfig -A;

ที่ผมใช้ `ifconfig(8)` แทน `wg(8)` ในการเช็คสถานะ เพราะว่าไม่ต้องการติดตั้ง user-space utilities สำหรับ WireGuard `wireguard-tools` ครับ

> หากไม่มี root provilege แล้ว `ifconfig -A` จะไม่เห็น public keys ของ peers

ต้องอย่าลืมว่าเราสามารถอ่านคู่มือได้ตลอดหากสงสัยว่าไดรเวอร์ `wg(4)` ทำงานยังไงบน OpenBSD ครับ:

    # man 4 wg;

หากคุณติดตั้ง `wireguard-tools` คุณก็สามารพอ่านคู่มือของ user-space utility `wg(8)` ได้ด้วย:

    # man 8 wg;

*ขอให้โชคดีกับ VPN ของตัวเองครับ!*
