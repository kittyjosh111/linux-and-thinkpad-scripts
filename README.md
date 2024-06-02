# linux-and-thinkpad-scripts
These are custom scripts I have used when running linux, as well as some specific fixes to Thinkpad problems. Seeing that there may be a day I need to reference these scripts or redeploy them on a new computer, this repository will hold the various scripts I have found useful.

The folder name indicates what type of scripts or guides is contained within. If certain scripts were specific to one device, the folder name will be the name of the device, categorized by model. For example, the ```thinkpads``` directory contains scripts specific to thinkpads, and the ```P16s``` folder contains files speciic to the Thinkpad P16s.

# devices and distros

The scripts were used on the following distros:
1) Fedora Linux 36-40

It should work on other distros, but specifics of installation may change.

scripts were developed, tested, and sometimes remain on the following devices:
1) ThinkPad P16s (Intel) Gen 1 (2022)
2) ThinkPad X1 Yoga (OLED) Gen 1 (2016)
3) ThinkPad E540 (Intel) i5 4200M (2014)
4) ThinkPad Yoga 370 / ThinkPad X380 Yoga (2017, 2018)

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

---

# summary of each folder

- ```androidQemu```: Summary of steps to create an android virtual machine with QEMU that has acceptable video performance necessary to run certain apks. Also has a section to customize the resolution android runs at, which may impact performance and clarity.

- ```davinciResolve```: DaVinci Resolve is a cross-platform video editor that is feature rich. On Linux, it is especially valuable due to better GPU implementation, offering a smoother and stabler experience when compared to Kdenlive's experimental GPU support. On linux, DaVinci Resolve can only import certain format of videos, so a conversion script is required to convert your videos into ones that the software can read. ```drfree``` can be run as a script, or installed to somewhere in your $PATH.

- ```desktopEnvironments```: Scripts specific to certain DEs. For example, there are custom keyboards for GNOME extensions in the gnome subdirectory, or polling monitor scripts for XFCE's genmon plugin in the xfceGenMon subdirectory.

- ```kj111Rotate```: My custom script and systemd service to block GNOME from applying its own rotation service in favor of manually disabling/enabling the trackpoint and touchpad based on tablet mode status. This is designed specifically to the ThinkPad X1 Yoga, and only tested on GNOME Wayland.

- ```miscScripts```: Extra, unfinished, or other general files that don't fit elsewhere. For example, an experimental script to convert pdfs into pngs, or configs for changing YouTube links to invidious with the Redirector extension.

- ```peripheralDevices```: Scripts targeting specific external hardware including the ThinkPad Trackpoint Keyboard (USB).

- ```system76pm```: Script and systemd service aimed to make ```system76-power``` more automatic. ```system76-power``` has been much more efficient than ```power-profiles-daemon``` on my ThinkPad Yogas, but it always defaults to Balanced. ```system76pm``` will change between Performance and Battery modes depending on if you are connected to AC power, and will toggle animations on or off on GNOME.

- ```thinkpads```: Configs specific to ThinkPads. Example include thinkfan configs for the P16s to make it run at tolerable noises, or a script to unload/reload rmi_smbus, thus reloading the clunkpad buttons after suspend.

- ```chromebook-duet```: Configs specific to the google-krane (itself based on google-kukui). Ran on postmarketOS GNOME and Phosh.
