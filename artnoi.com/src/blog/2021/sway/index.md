Jan 21, [2021](/blog/2021/)

# Moving from X11 to Wayland (with `swaywm`)

So I just installed a tiny new Arch Linux emergency root for [my ThinkPad T14](/blog/2020/t14/), but this time even though I know I need graphical environment to more efficiently troubleshoot my real root, I don't feel like installing X this time. It's too long of a process to setup X with all the hardware acceleration I want, and I want minimum number of packages installed on this system.

## Why move from something that works?

The [X Window System](https://en.wikipedia.org/wiki/X_Window_System) has been with us since the year of our Lord 1984, and the latest X protocol version (X11) has remain unchanged since 1987. It is a beast from the time before personal computers were cool and abundant, that is, it was designed for large servers with multiple terminals connected rather than a laptop with built-in screen. With that in mind, we can now understand why X is designed the way it is, and why we should transition away from it.

> X11 programs have to be written such that they usually include redundant and useless interprocess communication between the X server, the X client, and recently the X compositor. Extra work has to be done to avoid screen-tear, and because of how X server memory and buffer works, there is a security implications in X software. These reasons alone convinced me to try to move away on X.

Everyone has been talking about how [Wayland](https://wayland.freedesktop.org/) is the next big thang that will eventually replace X, and it has been over 10 years since Wayland started, so I'm curious to see if Wayland is ready for UNIX desktops yet in 2021.

## Wayland: new, yet familiar mindset

Wayland, unlike X, does not use a server-cilent model. Wayland is not even a program that you run as your display server - in fact, it's just a protocol for the Wayland clients and the Wayland compositors. **Yep, in Wayland, the Wayland compositor and the display manager becomes one**, from the hardware input and assigning buffer space for each Wayland clients. This greatly reduces expensive processes present in the currently mainstream X11.

> Does this ring any bells? If it does, it is because most other display server implementations out there have been like that for decades (Apple Quartz, Microsoft DWM, Google SurfaceFlinger). Even the lowly Windows variants have had this technology (although I believed much more bloated) for so long.

Simply install `XWayland` to enable most X11 apps to run on Wayland, though I believe there must be some X11 programs which refuse to run well on Wayland. At least, both GNOME and KDE officially support and embrace Wayland now, with Fedora and Ubuntu being shipped default with Wayland. I'm fortunate enough that I have made most of my workflows terminal-based or scriptable, such that I don't even have any other GUI (ie. X11) app except the browsers.

> The only GUI apps I use are full web browsers like `librewolf`, which is luckily based on Wayland-compatible Firefox, and graphical menu launchers like `dmenu(1)` or `rofi(1)` for which there are many Wayland alternatives. This means I had no need for `XWayland` for now.

## Wayland: compositor with window management and event handling

On system with X, you will have to install the X server and other X tools and libraries, then install an X window manager, and perhaps an X compositor to help blend the pixels. Well, we don't do that here. In Wayland, we simply installed a Wayland compositor/window manager, and the clients compatible with the protocol. Under Wayland protocol, the compositor handles compositing (obviously), keyboard/mouse events, and window management - all in one program.

On Arch Linux, there are so many Wayland compositor alternatives available on the [AUR](https://aur.archlinux.org), some of which [sucks much less](https://suckless.org/philosophy). But I ultimately chose `sway` not because the binary package availability, but the fact that is seems to be pretty well-supported and widely used at this time, which is important for such recent technology.

## Wayland: Sway

[Sway](https://swaywm.org) is a Wayland _tiling_ compositor based on `wlroots`, which is Wayland building block library on which many other Wayland compositors are based on. Sway is designed as a Wayland replacement for [i3](https://i3wm.org).

> As of this writing, Sway is my largest window manager at ~5-6 MiB in size (`i3-gaps` is ~2-3 MiB, and my `bspwm+sxhkd` is 270+142 KiB), but remember that Sway has to do all the heavy lifting of what the X server typically does, plus compositing and window management, and even `XWayland` support.

For some reasons, Sway runs much more efficiently (and also noticably cooler) than the _suckless_ (X11) [`dwm`](https://suckless.org/dwm).

## My current Sway setup

I currently use Sway with `swaylock` (Wayland screenlocker), `swayidle` (idling manager), and `wofi` (Wayland `rofi`/`dmenu` replacement). I first experimented with `bemenu`, but after struggling with it to work correctly with my old `dmenu`-based scripts, I switched to `wofi` which works like a charm. Sway's official graphical terminal emulator is Alacritty, which happened to be my go-to X11 terminal for almost a year, so [that's one less config file to write](https://gitlab.com/artnoi-staple/unix/-/tree/master/dotfiles/general/config/alacritty).

Everything I plan to use on Wayland works flawlessly so far - except when killing (exiting) `sway`, which sometimes produces funny errors, [although that might have had something to do with the way my status script works and forks](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/general/config/dwm/dwmbar.sh).

> To enable [**AMD** video hardware acceleration](https://wiki.archlinux.org/index.php/Hardware_video_acceleration) on Wayland on Arch Linux, I installed `libva-mesa-driver`, `mesa-vdpau`, and `libvdpau` - and everything works out of the box. If you want to have it on X too, install `xf86-video-amdgpu`.

### `dmenu` replacement without `XWayland`

I use `wofi(1)`, a `wlroots` based `rofi(1)` replacement. Because I have made my mind _not_ to install `XWayland`, `dmenu` won't run on my setup.

And because I already have my trusty `dmenu`- scripts to do various things across many machines, and I don't feel like maintaining 2 different versions of the same scripts just for Wayland, I had to come up with a way to make my old scripts work with `wofi`. I choose to use shell variables and aliases to launch `wofi -d` as `dmenu`, so there are a few files I have to edit.

> Note that you can skip all this mess because by default, `wofi` will run with `-d` when invoked as symlink to `/usr/bin/dmenu`. However, I want to make it work with the shell variables too, in case my future menu launchers won't have this behaviour.

First, I have this line in my shell initialization scripts (e.g. `.profile` or `.kshrc`):

```shell
[ "$XDG_SESSION_TYPE" = 'wayland' ]\
    && export WAYLAND=1\
    && export MOZ_ENABLE_WAYLAND=1;
```

And then, in my shell `aliases` file:

```shell
[ -n "$WAYLAND" ]\
    && alias dmenu='/usr/bin/wofi -d'\

alias sway='export WAYLAND=1 && MOZ_ENABLE_WAYLAND=1 && sway';
```

Which should assign alias `dmenu` to `wofi -d` (`dmenu`-compatible mode for `wofi`).

The alias tweak above should work just fine, but to be safe, I also edit my `dmenu` scripts to source the alias file just before the line containing `dmenu`. An example is my `dmenufirefox.sh`:

```shell
#!/bin/sh

aliases="$HOME/.config/shell/aliases";
[ -r $aliases ]\
    && . $aliases;

bookmark="$HOME/bin/priv/firefox.bookmarks";
url="$(dmenu -i -p 'Enter URL or file' < "$bookmark")";

[ -n "$url" ]\
    && firefox.sh "$url";
```

Another example is my dmenugoogle.sh, which now does not work as expected due to `wofi` lacking stdin input:

```shell
#!/bin/sh

aliases="$HOME/.config/shell/aliases";
[ -r $aliases ]\
    && . $aliases;

search_term="$(dmenu -i -p 'Google search:' | tr ' ' '+')";

[ -n "$search_term" ]\
    && firefox.sh "https://google.com/search?q=$search_term";
```

All this should enable the scripts to have correct aliases to `wofi -d` _only_ when on Wayland.

### Sway: simple text status bar

Wayland ships with a simple Wayland-only status bar `swaybar`. I was too lazy to install and setup a new Wayland status bar programs (e.g. `waybar`), so I tweaked my `dwmbar.sh` (for `dwm`, a suckless X window manager) to work under `swaybar` too! This is my _bar_ (`swaybar`) configuration in `.config/sway/config`:

```
bar {
  position top
  status_command dash ${HOME}/.config/dwm/dwmbar.sh
  colors {
    background #111111
    inactive_workspace #32323200 #32323200 #5c5c5c
  }
}
```

And this is how the main() function in `dwmbar.sh` that will run on X11 (`dwm`) or Wayland (`sway`) sessions:

```shell
main() {

while true; do

  # $WAYLAND is exported from $HOME/{.kshrc, .bash_profile}

  [ -z $WAYLAND ]\
      && xsetroot -name "$(get_status)"\
      && arg='&'\
      || echo "$(get_status)";

  # Status update interval
  sleep 5;

done;

}

main ${arg};
```

### Sway: screen lock with `swaylock`

I have settings in `logind.conf(5)` to have my laptop suspended when lid is closed. I then created a Systemd service `swaylock@.service` to lock the Wayland screen after system suspense, which looks something like this:

```
[Unit]
Description=Lock Wayland screen after sleep using swaylock for user %i
Before=sleep.target

[Service]
User=%i
Environment=DISPLAY=:0
ExecStartPre=swaymsg "output * dpms off"
ExecStart=/usr/bin/swaylock

[Install]
WantedBy=sleep.target
```

To enable it for _user_ `foo`, run:

```shell
systemctl enable swaylock@foo.service;
```

All of the files shown in this blog post are hosted on [my GitLab repo](https://gitlab.com/artnoi-staple/unix).

## So, should I move to Wayland?

Yes indeed! Despite many setbacks, Wayland appeals to me simply with its technical aspects. Although most of Wayland implementations out there have _not_ yet reached the maturity level of X11 yet in 2021 (as evidenced by some bugs) but overall it is pretty usable, and much more energy-efficient which is important to laptop users like me. My laptop runs a few degree (2-3C) cooler on Wayland.

In case you missed, GNOME and KDE have already made up their mind and try their best to port their components to Wayland, and we also have `XWayland` for other X11 apps.

> With most major graphical software projects (the DEs, the browsers, the file managers, etc.) promoting the shift to Wayland and at this rate of progress, I idiotically suspect the day when X is replaced would take place before 2030.

_That's it guys, enjoy!_
