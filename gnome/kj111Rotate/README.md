Oh boy.

Ever since a random 5.XX kernel update, I had issues with rotation on my Yoga convertibles. The glaring issue was that sometimes, after flipping the screen from the tablet position to the laptop position, I would suffer a crash on either X11 or Wayland. This sucks when you havent saved your notes from class, and suddenly the DE just crashes and deletes all of your progress from the last hour. It also sucks when uploading large files to my cloud server. It is just annoying and I had to deal with this for over a year, as no one on the internet seemed to have the same issues.

I've tried removing packages, removing extensions, reinstalling, switching the DE, but nothing worked. In fact, on XFCE, KDE X11 and Wayland, and GNOME X11 and Wayland, I would get the same error each time:

```evdev_update_key_down_count: Assertion `device->key_count[code] > 0```

I don't know how to fix that. Apparently it is some issue with libinput.

But that led me to suspect the rotation script of the DE had some issues with my Yogas. Thus, I here I use evtest to block the autorotate script from turning off the keyboard and other devices, then manually turn them off at user discretion.

On Thinkpads, the ```Thinkpad Extra Buttons``` controls the sensor for turning on or off tablet mode. If we run evtest grab on this device and output to a file in /tmp, we can have a script read whether the device has entered or exited tablet mode. Then, we can use evtest to grab events from the trackpoint and touchpad, thereby "turning them off". When the device exits tablet mode, we kill the evtest process, thereby restoring functionality.

Couple this with systemd, and we can run this script on startup.

**This script was only tested on Wayland GNOME**

To install, copy kj111Rotate to ```/usr/local/bin``` and the systemd service to ```/etc/systemd/system/```
