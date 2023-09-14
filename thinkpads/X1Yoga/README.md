In this folder...

- ```isdv4-5087.tablet``` is a custom libwacom tablet file to make my OLED X1 Yoga's panel recognizable as a wacom tablet. This then allows me to fix the sensitivity of my Bamboo Ink pen through GNOME's GUI.

- ```thinkfan.conf``` is what you think it is. I've set it to always run fan speed 1 because it is really distracting to hear the fans suddenly spin up from speed 0 every time it hits the trigger temperature.

- ```X11flicker``` is a file to stop flickering on the Yoga when it is in portrait mode. It does make animations choppier, but hey, no flickers. Truthfilly, I've just used wayland on the Yoga.

---

1) With XFCE, I don't need the trackpoint keyboard scripts anymore, as XFCE can remember the trackpoint sensitivity from mouse settings. That is pretty useful. For now, I've set my internal trackpoint and the external keyboard one to acceleration 3.
2) On XFCE, ther is no built in auto rotate feature found in distributions like GNOME. KDE had an auto rotate script somehwere on Github. Thus, searching for and modifying a script on the internet was the only way to get XFCE working. Autorotate using the script in XFCETweaks directory from root of this repo.
3) Oled-shmoled works phenomenally better than icc-brightness. It's responsive and actually nice to use. Use that instead of the icc scripts from now on.