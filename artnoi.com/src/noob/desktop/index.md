# My Arch Linux X11 desktop setup

> See this [blog post](/blog/2021/sway/) for my Sway (Wayland) setup

## dotfiles
See my [dotfiles git repository](https://gitlab.com/artnoi-staple/unix/dotfiles) for my dotfiles.
## Why do you have to write about your own desktop?
Arch's DIY mentality means that you can create your own destop environment from the various software packages, and thus to configure the desktop, one would have to study various programs in the Arch wiki. This means that finding documentation specific for one's own desktop setup is very difficult.

I have multiple computers, so I think it is not unwise to document my own desktop setups for future reference. This guide is divided into 2 parts - Wayland and X Windows System.

## My Wayland desktop components

1. **Wayland compositor**: `sway` - volume control and brightness control is configured as hotkeys in `sway` [configuration](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/general/config/sway/config).

2. **Taskbar**: `swaybar`, this status bar uses the same shell configuration as my X11 `dwm` [dwmbar.sh](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/general/config/dwm/dwmbar.sh). This configuration can be used in both `dwm` and `sway`. It needs my whole dotfile to function properly tho, because it uses `WAYLAND` enviroment variable which is exported from [.kshrc](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/general/.kshrc) or [.bash_profile](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/general/.bash_profile).

3. **Launcher**: `wofi`, which is Wayland `dmenu` and `rofi` replacement. I have `dmenu` aliased to `wofi -d` (which is `dmenu`-compatible mode) so that I can still use my `dmenu`-based script.

## My X Windows desktop components
The components are the display server, the window manager, the compositor, the menu launcher, and the applets.

1. **Display server**: X Window System (from `xorg-server` package)

2. **Window managers**: `bspwm` (tiling), `openbox` (stacking)

3. **Compositor**: `picom` (formerly `compton`)

4. **Taskbar**: `tint2`

5. **Applets**: `xfce4-power-manager`, `volumeicon`

## X configuration
Arch's `xorg-*` packages are sane enough to run on most hardware without configuration. However, on very new hardware, sometimes the default configuration is not optimized for the hardware, resulting in artifacts or screen tear, as I have experienced in my new [T14 (AMD) laptop](/blog/t14/). This is why most of my X configuration is about hardware. Below are some of my X configs in `/etc/X11/xorg.conf.d`
### X config: change input method (languages) with alt+space
    # 00-keybord.conf
    Section "InputClass"
      Identifier "system-keyboard"
      MatchIsKeyboard "on"
      Option "XkbLayout" "us,th"
      Option "XkbModel" ""
      Option "XkbVariant" ""
	  Option "XkbOptions" "grp:alt_space_toggle"
    EndSection
### X config: AMDGPU
    # 20-amdgpu.conf
	Section "Device"
      Identifier "AMD"
      Driver "amdgpu"
      Option "TearFree" "true"
      Option "DRI" "3"
    EndSection

    Section "Screen"
	  Identifier "MyScreen"
	  DefaultDepth 30
    EndSection
### X config: Synaptics
	# 70-synaptics.conf
	Section "InputClass"
      Identifier "touchpad"
      Driver "synaptics"
      MatchIsTouchpad "on"
      Option "TapButton1" "1"
      Option "TapButton2" "3"
      Option "TapButton3" "2"
      Option "VertEdgeScroll" "on"
	  Option "VertTwoFingerScroll" "on"
      Option "HorizEdgeScroll" "on"
      Option "HorizTwoFingerScroll" "on"
      Option "CircularScrolling" "on"
      Option "CircScrollTrigger" "2"
      Option "EmulateTwoFingerMinZ" "40"
      Option "EmulateTwoFingerMinW" "8"
      Option "CoastingSpeed" "0"
      Option "FingerLow" "30"
      Option "FingerHigh" "50"
      Option "MaxTapTime" "125"
    EndSection

## Compositor
The compositor is used (usually with window manager) for display compositing to perform funny effects. I don't like fancy compositing, so [my `picom.conf`](https://gitlab.com/artnoi-staple/unix/-/blob/master/dotfiles/linux/arch/picom.conf) is actually a few lines.

## Window managers
### Bspwm
`bspwm` is a lightweight tiling window manager. **It only manages windows, and does nothing else, not even handling keyboard hotkeys.** Instead, the hotkeys and their associated commands are handled by a seperate program, usually `sxhkd`.

When `bspwm` is used in `.xinitrc`, the window manager first reads it config files `bspwmrc` and `autostart`.

#### Basic `bspwm` configuration
`bspwmrc` stores `bspwm`-specific configurations, and it is essentially a shell script with several `bspc` lines. To configure `bspwm` window manager options, edit `bspwmrc` file. To edit hotkey options, edit `sxhkdrc` file.

`autostart` stores shell script for programs that will be autostarted with `bspwm`, like the compositor and other applets.
### OpenBox
OpenBox is a lightweight stacking window manager. OpenBox can be configured graphically with `obconf`, although it does not support advanced configurations. You will have to edit the config files for OpenBox if you need advanced customization.

#### Basic `openbox` configuration
`rc.xml` stores general configurations, like the hotkeys, while `menu.xml` stores right-click menu configurations.

`autostart` works like `bspwm`'s `autostart`.
## Launcher
### `dmenu`
I use `demenu` as interactive launchers. I map hotkeys to several shell scripts like `dmenugoogle`, `dmenufirefox`, and `dmenupower`. Configuration to the various `dmenu` scripts can be done by editting the `dmenu*` files, or editting `sxhkd` to map new hotkeys for the script on `bspwm`, and `rc.xml` on `openbox`.

`dmenu*` scripts are [provided in `sh-tools/bin`](https://gitlab.com/artnoi-staple/unix/-/tree/master/sh-tools/bin).
## Taskbar (status bar?)
I use `tint2` as a top taskbar. The applets are on the task bar.

In addition to the applets, I also add [my own shell script for `tint2` to display CPU temperature and fan speed](https://gitlab.com/artnoi-staple/unix/-/tree/master/dotfiles/general/.config/tint2).
## Applets
The applets usually work correctly out-of-the-box, requiring no config to work. Nonetheless, you will have to config it to enable its features.

`volumeicon` does not enable the `XF86Audio*` hotkeys, which made it pretty useless on first run. You can configre it graphically, or edit its config (`~/.config/volumeicon`) with:

    [Hotkeys]
    up_enabled=true
    down_enabled=true
    mute_enabled=true
    up=XF86AudioRaiseVolume
    down=XF86AudioLowerVolume
    mute=XF86AudioMute

`xfce4-power-manager` by default does not put laptop in suspense after lid close. This can be easily configured graphically.

## Starting X
## `startx`
`startx` will use `xinit` to start an X session. The `xinit` program will read its configuration from `.xinitrc`, which usually store another program name, like a window manager like `bspwm`.

### `.xinitrc`
The file `~/.xinitrc` is used by `xinit` when it is starting the X server. We usually put our target windows manager or desktop environment here. So, to switch window manager on the next X session, simply edit `.xinitrc` file.

### `.xinitrc` example
Let's say the content of `.xinitrc` looks like this:

    [[ -f $HOME/.Xresources ]] && xrdb $HOME/.Xresources &
    exec bspwm;

The flow of actions will look like this:

1. `xinit` starts the X server, and executes command for`.xinitrc`, which in this case is only sourcing `.Xresources` and `exec bspwm`

2. `bspwm` is started and it looks for its own configuration files in `~/.config/bspwm`

3. `bspwm` executes its config script `bspwmrc`, and the `autostart` files

4. `bspwm` starts itself, and via `autostart`, the compositor `picom` and the applets (and other programs you put in `autostart`)

5. The commands in `autostart` file may execute extra scripts, like my `tint` CPU temperature and fan speed script.

6. Boom, we have the GUI (if all went well)

The same is also true for OpenBox, and many other minimal window managers.
