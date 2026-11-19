This dir contains scripts or configs relating to pipeiwre, gearing for a hifi setup.

For pw-rate-set, I know that we can use pipewire configs in ~/.config/pipewire/pipewire.conf.d/, but I don't want to do that. Rather, I'd like a script running in the background that can force rates for the highest rate stream.

Nevertheless, I provide a simple config tested on a Moondrop Dawn Pro (up to 384 kHz).

I also include a script that monitors the bit and rate of pipewire, which can read ALSA files for more accurate numbers, and defaults back to PipeWire for bluetooth or other cases.
