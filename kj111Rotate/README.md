**Install:**

- Install ```evtest``` and ```inotify-tools``` with your package manager.

- Move ```kj111Rotate``` to /usr/local/bin. Give it executable perms.

- Move ```kj111Rotate2.service``` to /etc/systemd/system/. Enable and start it with systemctl command.

- If on GNOME, install the gnome extension from here: ```https://extensions.gnome.org/extension/5389/screen-rotate/```. This preserves rotation.

**This script was only tested on Wayland GNOME**

---

**Why?**

Oh boy.

Ever since a random 5.XX kernel update, I had issues with rotation on my Yoga convertibles. The glaring issue was that sometimes, after flipping the screen from the tablet position to the laptop position, I would wish to click on something using the trackpoint buttons. For example, I flip back to laptop mode (keyboard out) after handwriting in xournalpp, then use the trackpoint to click on the save button.

Oftentimes, I would then suffer a crash immediately after pressing the click button. Doesn't matter which display protocol was used, as the error occured in both X11 and Wayland. It also didn't matter which DE I used, as the crash occured in KDE, GNOME, and XFCE.

This sucks when you havent saved your notes from class, and suddenly the DE just crashes and deletes all of your progress from the last hour. It also sucks when upgrading packages, and I've had to manually fix broken files multiple times. It is just annoying and I had to deal with this for over a year, as no one on the internet seemed to have the same issues.

Using gnome-abrt, I would get the same error each time on all the DEs:

```../src/evdev.c:138: evdev_update_key_down_count: Assertion `device->key_count[code] > 0```

I don't know how to fix that. Apparently it is some issue with libinput. A more detailed log is attached at the end of the README. Hopefully it attracts attention or something for that lone wanderer who happens upon a similar issue.

But that led me to suspect some issue with how evdev or libinput interacted with the screen rotation. My hypothesis and guiding though behind this script is that if I were to manually control which devices are on or off during switches between tablet mode, I may be able to avoid these issues with the DE crashing.

Since I run Wayland on my tablets, I do not know if this script works on X11. But if you're X11 setup works, there wouldn't be a need to apply this script, would there be.

While X11 has xinput, wayland has no obvious way to disable hardware devices. However, libinput can list devices (for example, ```ThinkPad Extra Buttons```). Evtest (not installed by default) can in fact "grab" a device, which logs the events out (here, monitor for SW_TABLET_MODE) and as a side effect, makes it not respond to user input.

Thus, here I use evtest to block the autorotate script from turning off the keyboard and other devices, then manually turn them off from this script instead.

On Thinkpads, the ```Thinkpad Extra Buttons``` control the sensor for entering or exiting tablet mode. If we run evtest --grab on this device and output to a file in /tmp, we the user (and any other script) can look through this file and monitor for changes.

If we enter tablet mode, we get an output that resembles this:
```
Event: time 1690923246.781422, type 5 (EV_SW), code 1 (SW_TABLET_MODE), value 1
Event: time 1690923246.781422, -------------- SYN_REPORT ------------
```

If we exit tablet mode, we get similar output:
```
Event: time 1690923246.781422, type 5 (EV_SW), code 1 (SW_TABLET_MODE), value 0
Event: time 1690923246.781422, -------------- SYN_REPORT ------------
```

Notice the ```value 0``` or ```value 1```. This can be used to determine whether the tablet has entered tablet mode or not. Thus, if we enter tablet mode, we run evtest --grab on both the TrackPoint and TouchPad to "turn them off". We should note down their PID though, so we can terminate the grab and thus return input to the user upon exiting tablet mode. In effect, when the device exits tablet mode, we kill the evtest process grabbing the TrackPoint and TouchPad, thereby restoring functionality.

Couple this with systemd, and we can run this script on startup.

One more note, if we run --grab when tablet mode has already been entered (```value 1```), then the trackpoint and touchpad get disabled until the next time you login to the session NOT in tablet mode. We overcome this issue by first running ```evtest``` to monitor the state of tablet mode. If we detect tablet mode, we will halt the grab until the user exits tablet mode.

---

**Debugging**

The script logs events. Run ```systemctl status kj111Rotate2.service``` to view logs. We will look through an example now.

```
● kj111Rotate2.service - launcher for kj111Rotate service
     Loaded: loaded (/etc/systemd/system/kj111Rotate2.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Tue 2023-09-12 10:51:31 PDT; 44s ago
   Main PID: 80434 (kj111Rotate)
      Tasks: 4 (limit: 9286)
     Memory: 1.0M
        CPU: 387ms
     CGroup: /system.slice/kj111Rotate2.service
             ├─80434 /bin/bash /usr/local/bin/kj111Rotate
             ├─80572 evtest --grab /dev/input/event9
             ├─80598 inotifywait --monitor --format "%e %w%f" --event modify,create /tmp/kj111Rotate
             └─80599 /bin/bash /usr/local/bin/kj111Rotate

Sep 12 10:51:37 yoga kj111Rotate[80598]: Setting up watches.
Sep 12 10:51:37 yoga kj111Rotate[80598]: Watches established.
Sep 12 10:52:10 yoga kj111Rotate[80599]: -Tablet Mode Enabled
Sep 12 10:52:10 yoga kj111Rotate[80599]:   -Trackpoint disabled. Process ID is 80793!
Sep 12 10:52:10 yoga kj111Rotate[80599]:   -Touchpad disabled. Process ID is 80794!
Sep 12 10:52:10 yoga sudo[80794]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/evtest --grab /dev/input/event4
Sep 12 10:52:10 yoga sudo[80793]:     root : PWD=/ ; USER=root ; COMMAND=/usr/bin/evtest --grab /dev/input/event10
Sep 12 10:52:13 yoga kj111Rotate[80599]: -Tablet Mode Disabled
Sep 12 10:52:13 yoga kj111Rotate[80599]:   -Trackpoint enabled. Process 80793 was killed!
Sep 12 10:52:13 yoga kj111Rotate[80599]:   -Touchpad enabled. Process 80794 was killed!
```

Lines 1 and 2 are from inotify finishing setup of its watch.

Then notice line 3. This line indicates that the computer has entered tablet mode. The next few lines tell us that the script has disabled both the TrackPoint and TouchPad, giving us their PIDs as well. If you need to manaully stop these processes because your trackpad or trackpoint don't work, just run ```kill -9 XXX```, where XXX is the PID number.

Lines 6-7 are just a result of systemd using root perms to run the evtest command.

Lines 8 and onward tell us that the computer exited tablet mode. Thus we need to give back control over the TrackPoint and TouchPad. The script just terminates the PID from earlier on and logs it in, so that you can debug.

---

This is the error that plagues normal screen rotation for my machine. It is completely unrelated to this script.


```       Message: Process 5134 (gnome-shell) of user 1000 dumped core.
                
                Module libopensc.so.8 from rpm opensc-0.23.0-3.fc38.x86_64
                Module opensc-pkcs11.so from rpm opensc-0.23.0-3.fc38.x86_64
                Module p11-kit-trust.so from rpm p11-kit-0.25.0-1.fc38.x86_64
                Module libgiognutls.so from rpm glib-networking-2.76.1-1.fc38.x86_64
                Module libnss_resolve.so.2 from rpm systemd-253.7-1.fc38.x86_64
                Module libnss_mdns4_minimal.so.2 from rpm nss-mdns-0.15.1-8.fc38.x86_64
                Module libnss_myhostname.so.2 from rpm systemd-253.7-1.fc38.x86_64
                Module libgiognomeproxy.so from rpm glib-networking-2.76.1-1.fc38.x86_64
                Module libgtop-2.0.so.11 from rpm libgtop2-2.41.1-1.fc38.x86_64
                Module libgioremote-volume-monitor.so from rpm gvfs-1.50.5-2.fc38.x86_64
                Module libmpg123.so.0 from rpm mpg123-1.31.3-1.fc38.x86_64
                Module libopus.so.0 from rpm opus-1.3.1-12.fc38.x86_64
                Module libvorbisenc.so.2 from rpm libvorbis-1.3.7-7.fc38.x86_64
                Module libFLAC.so.12 from rpm flac-1.4.3-1.fc38.x86_64
                Module libgsm.so.1 from rpm gsm-1.0.22-2.fc38.x86_64
                Module libsndfile.so.1 from rpm libsndfile-1.1.0-6.fc38.x86_64
                Module libpulsecommon-16.1.so from rpm pulseaudio-16.1-4.fc38.x86_64
                Module libpulse-mainloop-glib.so.0 from rpm pulseaudio-16.1-4.fc38.x86_64
                Module libpulse.so.0 from rpm pulseaudio-16.1-4.fc38.x86_64
                Module libgvc.so from rpm gnome-shell-44.3-1.fc38.x86_64
                Module libcrypt.so.2 from rpm libxcrypt-4.4.36-1.fc38.x86_64
                Module libaccountsservice.so.0 from rpm accountsservice-23.11.69-2.fc38.x86_64
                Module libgeocode-glib-2.so.0 from rpm geocode-glib-3.26.4-3.fc38.x86_64
                Module libgweather-4.so.0 from rpm libgweather4-4.2.0-2.fc38.x86_64
                Module librsvg-2.so.2 from rpm librsvg2-2.56.2-1.fc38.x86_64
                Module libpixbufloader-svg.so from rpm librsvg2-2.56.2-1.fc38.x86_64
                Module libgdm.so.1 from rpm gdm-44.1-1.fc38.x86_64
                Module libgeoclue-2.so.0 from rpm geoclue2-2.7.0-1.fc38.x86_64
                Module libmalcontent-0.so.0 from rpm malcontent-0.11.1-1.fc38.x86_64
                Module libibus-1.0.so.5 from rpm ibus-1.5.28-6.fc38.x86_64
                Module libcrypto.so.3 from rpm openssl-3.0.9-2.fc38.x86_64
                Module libkeyutils.so.1 from rpm keyutils-1.6.1-6.fc38.x86_64
                Module libkrb5support.so.0 from rpm krb5-1.21-2.fc38.x86_64
                Module libcom_err.so.2 from rpm e2fsprogs-1.46.5-4.fc38.x86_64
                Module libk5crypto.so.3 from rpm krb5-1.21-2.fc38.x86_64
                Module libkrb5.so.3 from rpm krb5-1.21-2.fc38.x86_64
                Module libnghttp2.so.14 from rpm nghttp2-1.52.0-1.fc38.x86_64
                Module libgssapi_krb5.so.2 from rpm krb5-1.21-2.fc38.x86_64
                Module libpsl.so.5 from rpm libpsl-0.21.2-2.fc38.x86_64
                Module libsoup-3.0.so.0 from rpm libsoup3-3.4.2-2.fc38.x86_64
                Module libgnome-bg-4.so.2 from rpm gnome-desktop3-44.0-1.fc38.x86_64
                Module libsharpyuv.so.0 from rpm libwebp-1.3.1-1.fc38.x86_64
                Module libjbig.so.2.1 from rpm jbigkit-2.1-25.fc38.x86_64
                Module libwebp.so.7 from rpm libwebp-1.3.1-1.fc38.x86_64
                Module libcairo-script-interpreter.so.2 from rpm cairo-1.17.8-4.fc38.x86_64
                Module libwayland-egl.so.1 from rpm wayland-1.22.0-1.fc38.x86_64
                Module libtiff.so.5 from rpm libtiff-4.4.0-5.fc38.x86_64
                Module libtracker-sparql-3.0.so.0 from rpm tracker-3.5.3-2.fc38.x86_64
                Module libepoxy.so.0 from rpm libepoxy-1.5.10-3.fc38.x86_64
                Module libgtk-4.so.1 from rpm gtk4-4.10.4-1.fc38.x86_64
                Module libupower-glib.so.3 from rpm upower-0.99.20-3.fc38.x86_64
                Module libgnome-bluetooth-3.0.so.13 from rpm gnome-bluetooth-42.5-3.fc38.x86_64
                Module libspa-journal.so from rpm pipewire-0.3.76-1.fc38.x86_64
                Module libspa-support.so from rpm pipewire-0.3.76-1.fc38.x86_64
                Module libgvfscommon.so from rpm gvfs-1.50.5-2.fc38.x86_64
                Module libgvfsdbus.so from rpm gvfs-1.50.5-2.fc38.x86_64
                Module libdconfsettings.so from rpm dconf-0.40.0-8.fc38.x86_64
                Module libpciaccess.so.0 from rpm libpciaccess-0.16-8.fc38.x86_64
                Module libedit.so.0 from rpm libedit-3.1-45.20221030cvs.fc38.x86_64
                Module libdrm_intel.so.1 from rpm libdrm-2.4.114-2.fc38.x86_64
                Module libdrm_nouveau.so.2 from rpm libdrm-2.4.114-2.fc38.x86_64
                Module libdrm_amdgpu.so.1 from rpm libdrm-2.4.114-2.fc38.x86_64
                Module libelf.so.1 from rpm elfutils-0.189-3.fc38.x86_64
                Module libdrm_radeon.so.1 from rpm libdrm-2.4.114-2.fc38.x86_64
                Module libsensors.so.4 from rpm lm_sensors-3.6.0-13.fc38.x86_64
                Module iris_dri.so from rpm mesa-23.1.4-1.fc38.x86_64
                Module libxshmfence.so.1 from rpm libxshmfence-1.3-12.fc38.x86_64
                Module libxcb-sync.so.1 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-present.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-dri3.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libwayland-client.so.0 from rpm wayland-1.22.0-1.fc38.x86_64
                Module libxcb-xfixes.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-dri2.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libglapi.so.0 from rpm mesa-23.1.4-1.fc38.x86_64
                Module libEGL_mesa.so.0 from rpm mesa-23.1.4-1.fc38.x86_64
                Module libbrotlicommon.so.1 from rpm brotli-1.0.9-11.fc38.x86_64
                Module libogg.so.0 from rpm libogg-1.3.5-5.fc38.x86_64
                Module libvorbis.so.0 from rpm libvorbis-1.3.7-7.fc38.x86_64
                Module libdatrie.so.1 from rpm libdatrie-0.2.13-5.fc38.x86_64
                Module libicudata.so.72 from rpm icu-72.1-2.fc38.x86_64
                Module libgmp.so.10 from rpm gmp-6.2.1-4.fc38.x86_64
                Module libhogweed.so.6 from rpm nettle-3.8-3.fc38.x86_64
                Module libnettle.so.8 from rpm nettle-3.8-3.fc38.x86_64
                Module libtasn1.so.6 from rpm libtasn1-4.19.0-2.fc38.x86_64
                Module libunistring.so.5 from rpm libunistring-1.1-3.fc38.x86_64
                Module libidn2.so.0 from rpm libidn2-2.3.4-2.fc38.x86_64
                Module libbrotlidec.so.1 from rpm brotli-1.0.9-11.fc38.x86_64
                Module libbz2.so.1 from rpm bzip2-1.0.8-13.fc38.x86_64
                Module libexpat.so.1 from rpm expat-2.5.0-2.fc38.x86_64
                Module libevdev.so.2 from rpm libevdev-1.13.1-1.fc38.x86_64
                Module libmtdev.so.1 from rpm mtdev-1.1.6-5.fc38.x86_64
                Module libuuid.so.1 from rpm util-linux-2.38.1-4.fc38.x86_64
                Module libxcb-xkb.so.1 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-util.so.1 from rpm xcb-util-0.4.1-2.fc38.x86_64
                Module libltdl.so.7 from rpm libtool-2.4.7-6.fc38.x86_64
                Module libtdb.so.1 from rpm libtdb-1.4.8-1.fc38.x86_64
                Module libvorbisfile.so.3 from rpm libvorbis-1.3.7-7.fc38.x86_64
                Module libGLX.so.0 from rpm libglvnd-1.6.0-2.fc38.x86_64
                Module libGLdispatch.so.0 from rpm libglvnd-1.6.0-2.fc38.x86_64
                Module libxml2.so.2 from rpm libxml2-2.10.4-1.fc38.x86_64
                Module libgraphite2.so.3 from rpm graphite2-1.3.14-11.fc38.x86_64
                Module libthai.so.0 from rpm libthai-0.1.29-4.fc38.x86_64
                Module libtinfo.so.6 from rpm ncurses-6.4-3.20230114.fc38.x86_64
                Module libicuuc.so.72 from rpm icu-72.1-2.fc38.x86_64
                Module libicui18n.so.72 from rpm icu-72.1-2.fc38.x86_64
                Module libblkid.so.1 from rpm util-linux-2.38.1-4.fc38.x86_64
                Module libseccomp.so.2 from rpm libseccomp-2.5.3-4.fc38.x86_64
                Module libxkbregistry.so.0 from rpm libxkbcommon-1.5.0-2.fc38.x86_64
                Module libgnutls.so.30 from rpm gnutls-3.8.0-2.fc38.x86_64
                Module liblz4.so.1 from rpm lz4-1.9.4-2.fc38.x86_64
                Module libzstd.so.1 from rpm zstd-1.5.5-1.fc38.x86_64
                Module liblzma.so.5 from rpm xz-5.4.1-1.fc38.x86_64
                Module libcap.so.2 from rpm libcap-2.48-6.fc38.x86_64
                Module libp11-kit.so.0 from rpm p11-kit-0.25.0-1.fc38.x86_64
                Module libgck-2.so.0.0.0 from rpm gcr-3.92.0-2.fc38.x86_64
                Module libpixman-1.so.0 from rpm pixman-0.42.2-1.fc38.x86_64
                Module libxcb-shm.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-render.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libXrender.so.1 from rpm libXrender-0.9.11-2.fc38.x86_64
                Module libfreetype.so.6 from rpm freetype-2.13.0-2.fc38.x86_64
                Module libjpeg.so.62 from rpm libjpeg-turbo-2.1.4-2.fc38.x86_64
                Module libpng16.so.16 from rpm libpng-1.6.37-14.fc38.x86_64
                Module libGLESv2.so.2 from rpm libglvnd-1.6.0-2.fc38.x86_64
                Module libgbm.so.1 from rpm mesa-23.1.4-1.fc38.x86_64
                Module libinput.so.10 from rpm libinput-1.23.0-2.fc38.x86_64
                Module libdrm.so.2 from rpm libdrm-2.4.114-2.fc38.x86_64
                Module libSM.so.6 from rpm libSM-1.2.3-12.fc38.x86_64
                Module libXau.so.6 from rpm libXau-1.0.11-2.fc38.x86_64
                Module libxcb-res.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb-randr.so.0 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libxcb.so.1 from rpm libxcb-1.13.1-11.fc38.x86_64
                Module libX11-xcb.so.1 from rpm libX11-1.8.6-1.fc38.x86_64
                Module libxkbcommon-x11.so.0 from rpm libxkbcommon-1.5.0-2.fc38.x86_64
                Module libxkbfile.so.1 from rpm libxkbfile-1.1.1-2.fc38.x86_64
                Module libXcursor.so.1 from rpm libXcursor-1.2.1-3.fc38.x86_64
                Module libICE.so.6 from rpm libICE-1.0.10-10.fc38.x86_64
                Module libXinerama.so.1 from rpm libXinerama-1.1.5-2.fc38.x86_64
                Module libpipewire-0.3.so.0 from rpm pipewire-0.3.76-1.fc38.x86_64
                Module libudev.so.1 from rpm systemd-253.7-1.fc38.x86_64
                Module libgudev-1.0.so.0 from rpm libgudev-237-4.fc38.x86_64
                Module libxkbcommon.so.0 from rpm libxkbcommon-1.5.0-2.fc38.x86_64
                Module liblcms2.so.2 from rpm lcms2-2.15-1.fc38.x86_64
                Module libcolord.so.2 from rpm colord-1.4.6-4.fc38.x86_64
                Module libwacom.so.9 from rpm libwacom-2.7.0-1.fc38.x86_64
                Module libXi.so.6 from rpm libXi-1.8.1-1.fc38.x86_64
                Module libXtst.so.6 from rpm libXtst-1.2.4-2.fc38.x86_64
                Module libXrandr.so.2 from rpm libXrandr-1.5.2-10.fc38.x86_64
                Module libXcomposite.so.1 from rpm libXcomposite-0.4.5-9.fc38.x86_64
                Module libXdamage.so.1 from rpm libXdamage-1.1.5-9.fc38.x86_64
                Module libXext.so.6 from rpm libXext-1.3.5-2.fc38.x86_64
                Module libGL.so.1 from rpm libglvnd-1.6.0-2.fc38.x86_64
                Module libEGL.so.1 from rpm libglvnd-1.6.0-2.fc38.x86_64
                Module libwayland-server.so.0 from rpm wayland-1.22.0-1.fc38.x86_64
                Module libfontconfig.so.1 from rpm fontconfig-2.14.2-1.fc38.x86_64
                Module libpangoft2-1.0.so.0 from rpm pango-1.50.14-1.fc38.x86_64
                Module libpangocairo-1.0.so.0 from rpm pango-1.50.14-1.fc38.x86_64
                Module libfribidi.so.0 from rpm fribidi-1.0.12-3.fc38.x86_64
                Module libharfbuzz.so.0 from rpm harfbuzz-7.1.0-1.fc38.x86_64
                Module libpango-1.0.so.0 from rpm pango-1.50.14-1.fc38.x86_64
                Module libjson-glib-1.0.so.0 from rpm json-glib-1.6.6-4.fc38.x86_64
                Module libcairo-gobject.so.2 from rpm cairo-1.17.8-4.fc38.x86_64
                Module libreadline.so.8 from rpm readline-8.2-3.fc38.x86_64
                Module libmozjs-102.so.0 from rpm mozjs102-102.12.0-1.fc38.x86_64
                Module libdbus-1.so.3 from rpm dbus-1.14.8-1.fc38.x86_64
                Module libatk-1.0.so.0 from rpm at-spi2-core-2.48.3-1.fc38.x86_64
                Module libatspi.so.0 from rpm at-spi2-core-2.48.3-1.fc38.x86_64
                Module libpcre2-8.so.0 from rpm pcre2-10.42-1.fc38.1.x86_64
                Module libffi.so.8 from rpm libffi-3.4.4-2.fc38.x86_64
                Module libselinux.so.1 from rpm libselinux-3.5-1.fc38.x86_64
                Module libmount.so.1 from rpm util-linux-2.38.1-4.fc38.x86_64
                Module libz.so.1 from rpm zlib-1.2.13-3.fc38.x86_64
                Module libgmodule-2.0.so.0 from rpm glib2-2.76.4-3.fc38.x86_64
                Module libgnome-desktop-4.so.2 from rpm gnome-desktop3-44.0-1.fc38.x86_64
                Module libXfixes.so.3 from rpm libXfixes-6.0.0-5.fc38.x86_64
                Module libsecret-1.so.0 from rpm libsecret-0.20.5-3.fc38.x86_64
                Module libnm.so.0 from rpm NetworkManager-1.42.8-1.fc38.x86_64
                Module libsystemd.so.0 from rpm systemd-253.7-1.fc38.x86_64
                Module libgcr-4.so.0.0.0 from rpm gcr-3.92.0-2.fc38.x86_64
                Module libpolkit-gobject-1.so.0 from rpm polkit-122-3.fc38.1.x86_64
                Module libpolkit-agent-1.so.0 from rpm polkit-122-3.fc38.1.x86_64
                Module libX11.so.6 from rpm libX11-1.8.6-1.fc38.x86_64
                Module libgraphene-1.0.so.0 from rpm graphene-1.10.6-5.fc38.x86_64
                Module libmutter-cogl-12.so.0 from rpm mutter-44.1-2.fc38.triplebuffer.x86_64
                Module libcairo.so.2 from rpm cairo-1.17.8-4.fc38.x86_64
                Module libgdk_pixbuf-2.0.so.0 from rpm gdk-pixbuf2-2.42.10-2.fc38.x86_64
                Module libst-12.so from rpm gnome-shell-44.3-1.fc38.x86_64
                Module libgnome-shell-menu.so from rpm gnome-shell-44.3-1.fc38.x86_64
                Module libmutter-12.so.0 from rpm mutter-44.1-2.fc38.triplebuffer.x86_64
                Module libgirepository-1.0.so.1 from rpm gobject-introspection-1.76.1-1.fc38.x86_64
                Module libmutter-cogl-pango-12.so.0 from rpm mutter-44.1-2.fc38.triplebuffer.x86_64
                Module libmutter-clutter-12.so.0 from rpm mutter-44.1-2.fc38.triplebuffer.x86_64
                Module libgjs.so.0 from rpm gjs-1.76.2-1.fc38.x86_64
                Module libatk-bridge-2.0.so.0 from rpm at-spi2-core-2.48.3-1.fc38.x86_64
                Module libglib-2.0.so.0 from rpm glib2-2.76.4-3.fc38.x86_64
                Module libgobject-2.0.so.0 from rpm glib2-2.76.4-3.fc38.x86_64
                Module libgio-2.0.so.0 from rpm glib2-2.76.4-3.fc38.x86_64
                Module libshell-12.so from rpm gnome-shell-44.3-1.fc38.x86_64
                Module gnome-shell from rpm gnome-shell-44.3-1.fc38.x86_64
                Stack trace of thread 5153:
                #0  0x00007f569e08c844 __pthread_kill_implementation (libc.so.6 + 0x8e844)
                #1  0x00007f569e03babe raise (libc.so.6 + 0x3dabe)
                #2  0x0000564747b52946 dump_gjs_stack_on_signal_handler (gnome-shell + 0x4946)
                #3  0x00007f569e03bb70 __restore_rt (libc.so.6 + 0x3db70)
                #4  0x00007f569e08c844 __pthread_kill_implementation (libc.so.6 + 0x8e844)
                #5  0x00007f569e03babe raise (libc.so.6 + 0x3dabe)
                #6  0x00007f569e02487f abort (libc.so.6 + 0x2687f)
                #7  0x00007f569e02479b __assert_fail_base.cold (libc.so.6 + 0x2679b)
                #8  0x00007f569e034147 __assert_fail (libc.so.6 + 0x36147)
                #9  0x00007f569bfddd85 evdev_update_key_down_count (libinput.so.10 + 0x16d85)
                #10 0x00007f569bfdddbc evdev_pointer_post_button.lto_priv.0 (libinput.so.10 + 0x16dbc)
                #11 0x00007f569bfe74d5 debounce_handle_event (libinput.so.10 + 0x204d5)
                #12 0x00007f569bfecb51 fallback_interface_process.lto_priv.0 (libinput.so.10 + 0x25b51)
                #13 0x00007f569bfdd2de evdev_device_dispatch.lto_priv.0 (libinput.so.10 + 0x162de)
                #14 0x00007f569bfd8f78 libinput_dispatch (libinput.so.10 + 0x11f78)
                #15 0x00007f569e395bda meta_event_dispatch (libmutter-12.so.0 + 0x195bda)
                #16 0x00007f569e74148c g_main_context_dispatch (libglib-2.0.so.0 + 0x5c48c)
                #17 0x00007f569e79f648 g_main_context_iterate.isra.0 (libglib-2.0.so.0 + 0xba648)
                #18 0x00007f569e740a8f g_main_loop_run (libglib-2.0.so.0 + 0x5ba8f)
                #19 0x00007f569e38fedd input_thread (libmutter-12.so.0 + 0x18fedd)
                #20 0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #21 0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #22 0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5136:
                #0  0x00007f569e108b5d syscall (libc.so.6 + 0x10ab5d)
                #1  0x00007f569e79674d g_cond_wait (libglib-2.0.so.0 + 0xb174d)
                #2  0x00007f569e70c13b g_async_queue_pop_intern_unlocked (libglib-2.0.so.0 + 0x2713b)
                #3  0x00007f569e771563 g_thread_pool_spawn_thread (libglib-2.0.so.0 + 0x8c563)
                #4  0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5134:
                #0  0x00007f569e10335d __poll (libc.so.6 + 0x10535d)
                #1  0x00007f569e79f5b9 g_main_context_iterate.isra.0 (libglib-2.0.so.0 + 0xba5b9)
                #2  0x00007f569e740a8f g_main_loop_run (libglib-2.0.so.0 + 0x5ba8f)
                #3  0x00007f569e2d54ca meta_context_run_main_loop (libmutter-12.so.0 + 0xd54ca)
                #4  0x0000564747b51f87 main (gnome-shell + 0x3f87)
                #5  0x00007f569e025b4a __libc_start_call_main (libc.so.6 + 0x27b4a)
                #6  0x00007f569e025c0b __libc_start_main@@GLIBC_2.34 (libc.so.6 + 0x27c0b)
                #7  0x0000564747b52265 _start (gnome-shell + 0x4265)
                
                Stack trace of thread 5140:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5139:
                #0  0x00007f569e10335d __poll (libc.so.6 + 0x10535d)
                #1  0x00007f569e79f5b9 g_main_context_iterate.isra.0 (libglib-2.0.so.0 + 0xba5b9)
                #2  0x00007f569e740a8f g_main_loop_run (libglib-2.0.so.0 + 0x5ba8f)
                #3  0x00007f569e9484b2 gdbus_shared_thread_func.lto_priv.0 (libgio-2.0.so.0 + 0x11a4b2)
                #4  0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5166:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569d2b684d _ZN7mozilla6detail21ConditionVariableImpl4waitERNS0_9MutexImplE (libmozjs-102.so.0 + 0x8b684d)
                #3  0x00007f569d2b79b5 _ZN7mozilla6detail21ConditionVariableImpl8wait_forERNS0_9MutexImplERKNS_16BaseTimeDurationINS_27TimeDurationValueCalculatorEEE (libmozjs-102.so.0 + 0x8b79b5)
                #4  0x00007f569cc0c7fd _ZN2js12HelperThread10ThreadMainEPNS_18InternalThreadPoolEPS0_ (libmozjs-102.so.0 + 0x20c7fd)
                #5  0x00007f569cc35e8b _ZN2js6detail16ThreadTrampolineIRFvPNS_18InternalThreadPoolEPNS_12HelperThreadEEJRS3_S5_EE5StartEPv (libmozjs-102.so.0 + 0x235e8b)
                #6  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #7  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5146:
                #0  0x00007f569e10335d __poll (libc.so.6 + 0x10535d)
                #1  0x00007f569e79f5b9 g_main_context_iterate.isra.0 (libglib-2.0.so.0 + 0xba5b9)
                #2  0x00007f569e73eb13 g_main_context_iteration (libglib-2.0.so.0 + 0x59b13)
                #3  0x00007f56980525c5 dconf_gdbus_worker_thread (libdconfsettings.so + 0x75c5)
                #4  0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5141:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5151:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5143:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5152:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5147:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5164:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569d2b684d _ZN7mozilla6detail21ConditionVariableImpl4waitERNS0_9MutexImplE (libmozjs-102.so.0 + 0x8b684d)
                #3  0x00007f569d2b79b5 _ZN7mozilla6detail21ConditionVariableImpl8wait_forERNS0_9MutexImplERKNS_16BaseTimeDurationINS_27TimeDurationValueCalculatorEEE (libmozjs-102.so.0 + 0x8b79b5)
                #4  0x00007f569cc0c7fd _ZN2js12HelperThread10ThreadMainEPNS_18InternalThreadPoolEPS0_ (libmozjs-102.so.0 + 0x20c7fd)
                #5  0x00007f569cc35e8b _ZN2js6detail16ThreadTrampolineIRFvPNS_18InternalThreadPoolEPNS_12HelperThreadEEJRS3_S5_EE5StartEPv (libmozjs-102.so.0 + 0x235e8b)
                #6  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #7  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5148:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5165:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569d2b684d _ZN7mozilla6detail21ConditionVariableImpl4waitERNS0_9MutexImplE (libmozjs-102.so.0 + 0x8b684d)
                #3  0x00007f569d2b79b5 _ZN7mozilla6detail21ConditionVariableImpl8wait_forERNS0_9MutexImplERKNS_16BaseTimeDurationINS_27TimeDurationValueCalculatorEEE (libmozjs-102.so.0 + 0x8b79b5)
                #4  0x00007f569cc0c7fd _ZN2js12HelperThread10ThreadMainEPNS_18InternalThreadPoolEPS0_ (libmozjs-102.so.0 + 0x20c7fd)
                #5  0x00007f569cc35e8b _ZN2js6detail16ThreadTrampolineIRFvPNS_18InternalThreadPoolEPNS_12HelperThreadEEJRS3_S5_EE5StartEPv (libmozjs-102.so.0 + 0x235e8b)
                #6  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #7  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 9009:
                #0  0x00007f569e10335d __poll (libc.so.6 + 0x10535d)
                #1  0x00007f563b9aa526 poll_func (libpulse.so.0 + 0x35526)
                #2  0x00007f563b993694 pa_mainloop_poll (libpulse.so.0 + 0x1e694)
                #3  0x00007f563b99e153 pa_mainloop_iterate (libpulse.so.0 + 0x29153)
                #4  0x00007f563b99e218 pa_mainloop_run (libpulse.so.0 + 0x29218)
                #5  0x00007f563b9ae751 thread (libpulse.so.0 + 0x39751)
                #6  0x00007f563b950d7b internal_thread_func (libpulsecommon-16.1.so + 0x60d7b)
                #7  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #8  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 12589:
                #0  0x00007f569e108b5d syscall (libc.so.6 + 0x10ab5d)
                #1  0x00007f569e797040 g_cond_wait_until (libglib-2.0.so.0 + 0xb2040)
                #2  0x00007f569e70c103 g_async_queue_pop_intern_unlocked (libglib-2.0.so.0 + 0x27103)
                #3  0x00007f569e70c256 g_async_queue_timeout_pop (libglib-2.0.so.0 + 0x27256)
                #4  0x00007f569e771f3f g_thread_pool_thread_proxy.lto_priv.0 (libglib-2.0.so.0 + 0x8cf3f)
                #5  0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #6  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #7  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5163:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569d2b684d _ZN7mozilla6detail21ConditionVariableImpl4waitERNS0_9MutexImplE (libmozjs-102.so.0 + 0x8b684d)
                #3  0x00007f569d2b79b5 _ZN7mozilla6detail21ConditionVariableImpl8wait_forERNS0_9MutexImplERKNS_16BaseTimeDurationINS_27TimeDurationValueCalculatorEEE (libmozjs-102.so.0 + 0x8b79b5)
                #4  0x00007f569cc0c7fd _ZN2js12HelperThread10ThreadMainEPNS_18InternalThreadPoolEPS0_ (libmozjs-102.so.0 + 0x20c7fd)
                #5  0x00007f569cc35e8b _ZN2js6detail16ThreadTrampolineIRFvPNS_18InternalThreadPoolEPNS_12HelperThreadEEJRS3_S5_EE5StartEPv (libmozjs-102.so.0 + 0x235e8b)
                #6  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #7  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5137:
                #0  0x00007f569e10335d __poll (libc.so.6 + 0x10535d)
                #1  0x00007f569e79f5b9 g_main_context_iterate.isra.0 (libglib-2.0.so.0 + 0xba5b9)
                #2  0x00007f569e73eb13 g_main_context_iteration (libglib-2.0.so.0 + 0x59b13)
                #3  0x00007f569e73eb69 glib_worker_main (libglib-2.0.so.0 + 0x59b69)
                #4  0x00007f569e76f983 g_thread_proxy (libglib-2.0.so.0 + 0x8a983)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                
                Stack trace of thread 5142:
                #0  0x00007f569e0871d9 __futex_abstimed_wait_common (libc.so.6 + 0x891d9)
                #1  0x00007f569e089b79 pthread_cond_wait@@GLIBC_2.3.2 (libc.so.6 + 0x8bb79)
                #2  0x00007f569091302d cnd_wait (iris_dri.so + 0x11302d)
                #3  0x00007f56908c3eeb util_queue_thread_func (iris_dri.so + 0xc3eeb)
                #4  0x00007f5690912f5c impl_thrd_routine (iris_dri.so + 0x112f5c)
                #5  0x00007f569e08a907 start_thread (libc.so.6 + 0x8c907)
                #6  0x00007f569e110870 __clone3 (libc.so.6 + 0x112870)
                ELF object binary architecture: AMD x86-64
```
