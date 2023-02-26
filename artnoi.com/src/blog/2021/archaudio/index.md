May 31, [2021](/blog/2021/)

# Arch Linux and USB audio

> TLDR; install `pulseaudio-alsa`

I have multiple high performance USB DAC (Topping D10 and Khadas Tone Board), and when I'm using my workstation, I want the best audio output possible from the machine.

It was a pain in the arse on Mac and Windows to make the DAC operates at the same sample rate as my source audio, e.g. 48KHz vs 44.1KHz.

> I understand that the resampling artifacts should be inaudible, but I don't want it anyway.

On Windows, I would have to use WASAPI plugin on Foobar so that the DACs and the computer syncs the sample rate with the source audio. On Mac, I need external expensive program 'BitPerfect' to do the bit-perfect output to USB DACs.

On **Arch Linux** however, everything is super easy - you just install `pulseaudio-alsa` and boom, you get the DAC working at the right sample rate.

This means that when I watch Blu-ray videos 48KHz audio, the dac operates at 48KHz, and when I'm listening 44.1KHz music, the DAC operates at 44.1KHz.

And it does all this without a single failure - much better than the paid BitPerfect for Mac.

I don't buy into High-res audio, so I haven't tested it yet, but I think it should act the same way.

If you have multiple DACs, you may want to install `pvaucontrol` so that you can graphically switch the audio sinks without having to learn the command-line.
