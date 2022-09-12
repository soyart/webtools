Aug 6, [2019](/blog/2019/)

# FreeBSD 12.0: Installing dwm on ThinkPad X230
## Introduction

In this tutorial I'll guide you on how to prepare FreeBSD installation for `dwm` on ThinkPad X230. This tutorial will also include how to optimize your system for GUI environment.

### About dwm
`dwm` is a suckless window manager. Being a [suckless utility](https://dwm.suckless.org), it does not have or load configuration file, i.e. the configuration is done by patching the source code, which also means that if you want to reconfigure dwm you WILL have to recompile it. I recommend using FreeBSD ports tree as source for dwm because it'll help us install dwm correctly on a FreeBSD system.

### Hardware-related:

### dbus

Before we proceed make sure that you've installed and enabled `dbus` which is required to run our GUI environment:

    # pkg install dbus;
    # sysrc dbus_enable="YES";

Or you may manually enable it in `/etc/rc.conf` by adding `dbus_enable="YES"` instead of issuing `sysrc` command

### Intel HD 4000 Graphics driver

Now we'll have to install `kms` driver for our video card. X230 has i5-3240M on it which has Intel HD 4000 integrated graphics so `drm_legacy_kmod` should work:

    # pkg install drm_legacy_kmod;

And enable it by adding the following line also in `/etc/rc.conf`

    kld_list="/boot/modules/i915kms"

You also need to add `username` to `video` group by issuing the following command

    # pw group video -m username;

### moused

For the middle-button scroll to work on ThinkPad and with proper cursor accelaration, you may have to add the following to `/etc/rc.conf`

    moused_enable="YES"  
    moused_flags="-A 2.0,2.0 -a 1.2 -V"

### Sound

Add the following entry in `/boot/loader.conf`

    snd_hda_load="YES"

I also personally add this line to `/etc/rc.conf`

    snddetect_enable="YES"
    mixer_enable="YES"

Now reboot FreeBSD for our changes to take effect. I usually do `sudo reboot`
## Installing prerequisite depedencies
### `xorg-minimal` and other depedencies
For a window manager to work, we need a display server. I choose xorg-minimal because it has less disk footprint than the full xorg install. We also need some X11 fonts (In this case, `Dejavu`), `xrdb` to load external config files, X11 font library `libXft`, and finally `libXinerama` for multi-display support. I also want `compton` for display compositing.

    # pkg install xorg-minimal xrdb libXft compton dejavu;

Building dwm

My workflow for patching and building `dwm` is quite easy, I first extract dwm source from `/usr/ports/x11-wm/dwm` and then patch the source in `work` directory. Building must be done in `/usr/ports/x11-wm/dwm` or dwm will fail to build and install properly because FreeBSD supplies the OS-specific Makefile in the ports.
### Extracting dwm

    $ cd /usr/ports/x11-wm/dwm;
    # make extract;
    $ cd work;

This should extract dwm source into `work/dwm-x.y` directory where x.y is dwm version. Take note of dwm version, because it's important to download the correct version of patches.
### Patching and configuring dwm
Now Prepare your patches, find the appropriate version (i.e. the one matching dwm version) and download patches to a convenient location, e.g. `$HOME/dwm.patches/`:

    $ mkdir ~/dwm.patches;
    $ wget ~/dwm.patches/ https://dwm.suckless.org/patches/link/to/dwm-patch.diff;

Patch the source code in `work` directory, I'm using `git apply` here:

    $ git apply ~/dwm.patches/dwm-patch.diff;

If no errors were encountered, you should now be ready to build `dwm`. You must configure dwm before it is built. Now, copy the default config file `config.def.h` to `config.h` and edit the copied `config.h` file with your configuration. We will point to this `config.h` file later during `make install` so that the compiler applies our configuration and patches.

    $ cd  work/dwm-6.2;
    # cp config.def.h config.h;
    # vim work/config.h;

After you are done with editing and patching, it's build time! Go *back to the ports directory of dwm* and build it! **Don't forget to supply `DWM_CONF` flag to point to your patched and customized config.h file other wise it'll fail**. The path can be absolute or relative to the working directory. FreeBSD should present you with its own menu dialog for system-supplied patches (e.g. install `sterm` and `dmenu`, etc.) and you can check the boxes according to your needs.

    $ cd  /usr/ports/x11-wm/dwm;
    # make DWM_CONF=work/dwm6.2/config.h install clean;

If it succeeds, you should now add `.xinitrc` file to your `$HOME` directory to tell X to start dwm. My `.xinitrc` looks like this:

    xrdb -merge $HOME/.Xresources &
    compton --config $HOME/.config/compton/compton.conf &  
    exec dwm;

Note that lines after `exec dwm` will not be executed and hence why I put it at the bottom. After `.xinitrc` is created, start X Server by issuing

    $ startx;

This should source `$HOME/.Xresources` file, start `compton`, and start `dwm`.
