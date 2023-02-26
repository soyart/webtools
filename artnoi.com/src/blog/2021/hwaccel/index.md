Dec 6, [2021](/blog/2021)

# Hardware graphics acceleration on Arch Linux

Whenever I set up a new Arch Linux installation on a new hardware, I always had to go through the Arch Wiki and other resources to check out how to enable hardware acceleration for that new hardware, be it an Intel, AMD, or NVIDIA. So I decided to compile those instructions in this article.

Note that my hardware is pretty current and I have zero interests to include instructions for older hardware in this compilation.

As always, you should not trust me. Instead, read the [Arch Wiki](https://wiki.archlinux.org/title/Hardware_video_acceleration)

> Note: I use Wayland (GNOME)

## Verifying with mpv

Your installation might actually have everything properly set up without manual intervention, which is usually the case with Intel graphics. To verify that hardware acceleration is working, run `mpv` with `--hwdec` flag:

    $ mpv --hwdec=auto <FILE>;

## OpenGL implementation

Install package `mesa`

## NVIDIA graphics (>= 8-series)

### Proprietary NVIDIA driver

Install package `nvidia-utils`. Nouveau is slow and buggy on my only NVIDIA card, which happens to be a Pascal Quadro from 2017. Note that this package only works for 8-series and newer cards.

### VDPAU

Install packages `libvdpau`

### Kernel parameter

Add this option to your kernel parameter:

    nvidia-drm.modeset=1

### Update your initramfs (`/etc/mkinitcpio.conf`)

Add the following modules to hook `MODULE`:

    MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

## AMD graphics

### OpenGL

Install package `mesa`

### X11

Install package `xf86-video-amdgpu`

### VA-API

Install package `libva-mesa-driver`. Verify with `vainfo` from `libva-utils`.

### VDPAU

Install package `mesa-vdpau` and `libvdpau_va_gl`. Verify with package `vdpauinfo`. Then, depending on `vdpauinfo` output, you might want to override VDPAU driver if it's invalid. In my case, VDAPU uses `libvdpa_nvidia.so`.

To override this driver and use correct driver for your AMD graphics, use `VDPAU_DRIVER` env. For example, my machine with Vega GPU (Renoir) uses Mesa Gallium driver:

    export VDPAU_DRIVER=va_gl

### VDPAU backend for VA API

Install package `libva-vdpau-driver`

### Update your initramfs (`/etc/mkinitcpio.conf`)

Add the following modules to hook `MODULE`:

    MODULES=(amdgpu radeon)

IIRC, these kernel modules are already in the default kernel. For more info on AMDGPU, see [this wiki page](https://wiki.archlinux.org/title/AMDGPU#Video_acceleration)

## Intel graphics

See [Arch Wiki](https://wiki.archlinux.org/title/Hardware_video_acceleration)

## Firefox hardware acceleration

See [Arch Wiki](https://wiki.archlinux.org/title/Firefox#Hardware_video_acceleration)
