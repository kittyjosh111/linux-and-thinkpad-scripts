# linux-and-thinkpad-scripts
These are custom scripts I have used when running linux, as well as some specific fixes to Thinkpad problems. Seeing that there may be a day I need to reference these scripts or redeploy them on a new computer, this repository will hold the various scripts I have found useful.

The folder name indicates what type of scripts or guides is contained within. If certain scripts were specific to one device, the folder name will be the name of the device, categorized by model. For example, the ```thinkpads``` directory contains scripts specific to thinkpads, and the ```P16s``` folder contains files speciic to the Thinkpad P16s.

# devices and distros

The scripts were used on the following distros:
1) Fedora Linux 36-43
2) PostmarketOS Edge (for the chromebook specific scripts)

Most scripts should work on other distros, but specifics of installation may change.

scripts were developed, tested, and mostly deployed on the following devices:
1) ThinkPad P16s (Intel) Gen 1 (2022)
2) ThinkPad X1 Yoga Gen 3 (2018)

Additionally, scripts in ```chromebook-duet``` were tested on:
1) Lenovo IdeaPad Duet Chromebook 10.1 (google-krane)

The OS utilized was PostmarketOS v23.12, edge, installed with pmbootstrap

# various scripts

There are a variety of scripts or guides included here including
1) Running a QEMU Android machine
2) Conversion script for DaVinci Resolve
3) General power-management with choice of backend (system76-power, ppd, tuned, etc)
4) Toggling governors for ARM-style CPUs (ex Helio P60t has 4x Cortex-A73s and 4x Cortex-A53s)
5) etc.

# thinkpad problems fixed

The scripts attempt to address the following issues:

1) Trackpoint sensitivity too high on Lenovo trackpoint keyboards
2) X11 Screen flickering on an X1 Yoga
3) Touchscreen right clicks
4) Trackpoint and trackpad being disabled upon resuming from sleep in linux
5) Thinkpad yoga device rotation crash
6) PostmarketOS' powerprofilesctl not having any effect
