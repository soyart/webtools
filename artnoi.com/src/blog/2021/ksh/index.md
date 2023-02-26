Jan 9, [2021](/blog/2021/)

# My many shells on Arch Linux

I use 3 shells on Arch Linux. First is `bash`, because it is required by base, and many packages tend to rely on bash-dependent scripts. Another shell on my systems is the one and only `dash`. This fully POSIX-compatible yet very tiny shell is used as symlink to `/bin/sh` in hope that it would increase system performance in the background. The third shell is any `loksh`, a Linux port of OpenBSD's KornShell (`ksh`). This fork of KornShell seems like the best choice for me compared to other KornShell options available in the Arch Wiki.

## But why `ksh`? Why don't just use the POSIX shells?

After [moving my webserver to OpenBSD](/blog/2020/bsdbox/), I found that most of my scripts are full of _bashisms_. While purging bashisms from my scripts and trying to conform to POSIX standards, I noticed that POSIX shells do not actually support arrays, let alone associative arrays which are used too expensively in my scripts. This is big, sad, bad news, since I could no longer use the very fast `dash` to execute my old scripts. I know there's a way to hack around this, but I was too tired to change all my scripts to NOT use arrays.

So I looked for another standardized shell, not `bash` because I'm too cool. My quick criteria would be a shell with full POSIX support, with additional array and associative array support, and preferably a shell used by people I admire (lol). And then I figured out that I have been using one for a while, albeit on OpenBSD. The shell is KornShell (`ksh`), a _de facto_ descendant of the original Bourne shell.

> `ksh` had been one of the most popular UNIX shells; today, it is [OpenBSD](https://openbsd.org) default interactive shell along side the traditional UNIX `sh`.

`bash` was surely good more than good enough, but the fact that it requires external libraries (despite the much larger code base), coupled with it being used much more widely, makes `bash` a more interesting shell to be attacked.

`ksh` has native support for both indexed and associative arrays, and are smaller and less popular than `bash`, which makes it interesting to me.

## But which `ksh`?

There are 3 flavors of `ksh`-like packages on Arch Linux repos. `mksh` and `ksh` is available from the `community` repo, while `loksh` (Linux OpenBSD `ksh`, targeting `musl`) can be built using AUR and `makepkg`.

I don't want to use the `ksh` package because it has the largest storage footprint. Whenever I have to choose between 2 software projects that do exactly the same thing, I always go with the smaller implementations. Remember, the smaller one loads faster.

So I first tried `mksh` and `loksh`, and ultimately chose `loksh` due to its smaller size and the fact that the `PS1` prompts can be written with a backslashed-escaped special character (e.g. '\u' expands to $USER). Another reason behind the selection was [my admiration of OpenBSD](/blog/2020/openbsd/). OpenBSD is really an operating system development powerhouse.

> They say life is about choice, but sometimes, the choices are overwhelming, and it is especially true if you use operating systems that respect your freedom to choose, like Arch and Gentoo Linux, or even the BSDs. This is in stark contrast to the shitty consumer operating systems (yes, Windows and macOS are pieces of horse shit), where these rich yet poor users are deprived of their freedom, choices, and their privacy.
