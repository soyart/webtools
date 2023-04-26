Oct 12, [2020](/blog/2020/)

# The problems with work computers

[Now that I work at a securities company](/blog/2020/employed/), I get to work using real _enterprise_ networked workstations (They give me 3 HP workstations and 6+1 screens) protected by _enterprise_ firewalls. **I am however very dissapointed with the company's computing decisions** - which not only are **unsafe**, but also very hilarious from the prospective of IT security. Such incomprehensibly brainless decisions and rules include:

## They use Windows 10 for 99% of the times

Windows is horrible because it treats the users like idiots. You can't even choose your root filesystem in Windows 10. On top of the poor design, Windows 10 is an anti-security operating system. My office use Windows as their workstation operating system. I won't, in my life, trust Windows computers to handle the transactions worth billions of bath. The trading software they use is very old, from the DOS days, so I think `wine` should already support that and the switch to Linux or BSD is just a few steps away.

The firewall and network infrastructure is also on Windows I guess, since the internet performace has been very slow, and the IT team is more like "Windows 10 support team". **They (IT dept.) apparently can't do command-line, and could not even configure commercial AIX on our IBM servers correctly. In Thailand, very few people know how to use Linux/BSD and the command line, mostly because they hate to read comprehensive English documentation and guides, and the good command line guides are never written in Thai**.

## They won't allow us to change the very bad email password

Well, this might be good practice if they gave us randomly generated unique password every once in a while to prevent users from setting up easy-to-break passwords. But this is not the case, as email account passwords they give us are all the same (at least in my department) and the passwords are not random at all - instead, part of the password is already hinted throughout the computers. This is computer security nightmare.

## They won't let us have Admin account on our computers

This is understandable - some users are just way too dangerously stupid to be left with such privileges. But as someone who takes security very seriously myself, not having the admin privilege means that I can't fix anything timely by myself. Without the admin privilege I can't even set the display color profile. This greatly limits the computer's possible use cases.

## They block arbitary websites

They block almost everything from [freeciv.org](http://freeciv.org), [UrbanDictionary](http://urbandictionary.com), [GitHub](https://github.com), [GitLab](https://gitlab.com), [Gmail](https://gmail.com) to this website ([artnoi.com](/)). Why block GitHub though if the users don't have compilers and admin accounts on their Windows? Also, users who visit GitHub are more likely to be computer security-literate than, say, average employees who choose "august" as their August password or even the IT managers themselves. If they choose to ban such websites, perhaps they should also block ads and trackers, which they don't. (This maybe due to the fact that most websites now complain if you have ad-blockers on and may prompt the employees to request IT assistance more unneccessarily frequently).

## They don't physically secure the computers

They don't allow me to open the machine to inspect the god-damn work computers that is only locked and secured by a thumb screw. What if someone put microphones or some weird stuff in there? If I come to the office a bit early, I could have bugged any of the machines there. My department head warned me that the IT dept will be really upset if someone open up the computer cases. **Well, if they really care if someone open up the machines, why don't they just physically lock them up in the first place?** Isn't this a standard practice for financial company's work computers? Goddamn, I hate these stupid decisions.

[My home workstation](/blog/2020/tstation/) is physically locked with a padlock, its disks encrypted on the filesystem level and locked in the BIOS. None of these measures are deployed at my office.- anyone could have opened up the machine, stolen the disks, and read data right out of the stolen storage or put compromised one in there. The fact that Windows allow executables to execute virtually from anyway with just a double-click made me paranoia now that I know the storage is not protected at all in the first place.

## They don't allow me to add more RAM, but allow people to plug their phones to the computers

Yes, they don't allow me to add more RAM to my work machine (which does memory swaps to disks all the time, and thus killing the SSD), yet allow others to bring their own Chinese webcams, keyboards, and mice. They also permit employees to plug smartphones (which is technically small-sized computers) to the work computers.

## The IT team is not very resourceful

I understand that it is their responsibility to keep our network "safe" and secure. But I don't think the IT managers understand computers well enough to the code and hardware. **They are more like point-and-click kiddies who just passed their Cisco certification license, but never wrote a C program or a bash script. They are those who only rely on commercial software and just pay for support - just like my college faculty's IT people**. Even the solution used is the same for both my college and work, e.g. FORTINET and VNC remote etc. Oh, and when they say they will _remote_ in, they don't even `ssh`, instead, they use the VNC remote desktop to do point-and-click configuration, simply because they don't know how to use command-line, and as result exposed all their installation processes (file location etc.) to me. At home, I could deploy and reconfigure software remotely to my home computers and no one would even notice.