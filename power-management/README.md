# background and reasoning

Turns out there's a lot of power management scripts or packages available. Each seem to have their own pros and cons, whether it be from the integration of GNOME with power-profiles-daemon, or the extreme power-saving capabilities of system76-power. However, ootb most of these power management scripts don't seem to change automatically in response to power source changes, and it isn't really convenient to have to open a terminal and enter a command every time I connect and disconnect from an external power source. Simply put, if I am on power, I want maximum performance. If I am not connected to power, I want the most power-saving features activated.

Sounds like one of TLP's options. And yet, I want to be able to manually switch off from power-saver to balanced if I need that extra boost in performance on the go. So while TLP is more advanced and has finer control over disk, processor, graphics, etc, I don't see myself using all of them, and I would still appreciate the ability to manually give more performance on the go, which I don't think TLP can do that easily.

Besides, GNOME refuses to render animations well on any power profile other than the equivalent of power-profiles-daemon's Performance profie. While it would look nice to have functioning animations while I am in power-saver mode, it is also extremely unbearable to watch how choppy these animations end up being. Thus, it would be great to have a script to toggle animations on GNOME in addition to automatic power-profile switching.

# install

- Move ```pmtoggle``` from the folder "pmtoggle" to /usr/local/bin.

- Move ```99-pmtoggle.rules``` from the folder "pmtoggle" to /etc/udev/rules.d/.

- Move ```powerpm``` from the folder "powerpm" to /usr/local/bin. Open it up and edit the values for ```AC_ON```, ```AC_OFF```, ```TURBO``` as needed. If later you find out that certain commands from powerpm are not being run properly as root, specify ```USERNAME``` with your usename and comment out the provided value for it.

- Move ```powerpm.service``` from the folder "powerpm" to /etc/systemd/system/. Enable it. Check status to see if you need to implement the aforementioned fix.

- If your power management backend automatically sets a profile every time the computer wakes from lock/suspend (system76pm does this), you may also need to move ```powerpm-restart.service``` into /etc/systemd/system. Also enable this.

- Reboot to apply the new udev rules and test out the systemctl activation.

# implementation and logic

Udev can monitor for changes in ```power_supply```. Quite useful to tell if we are on battery or connected to external power. Once we have a udev rule in place, we can then use it to trigger another script that writes a file to /tmp/ which carries a value of 0 or 1, representing battery and external power, respectively. This is how ```pmtoggle``` works.

Since we now have a file in /tmp/ that automatically updates in response to power supply changes, we can use other scripts to read for changes in this file and act accordingly. One such implementation is ```powerpm```.

```powerpm``` takes in a command to run when disconnected and connected to external power. Internally, these variables are ```AC_OFF``` and ```AC_ON``` respectively. You can then supply whichever power management backend you want, and I have tested power-profiles-daemon, tuned-adm, and system76-power. Find out the command to trigger you equivalent of power-saver, battery, and performance, then put them into ```AC_OFF``` and ```AC_ON```.

If ```/tmp/pmtoggle``` is 0, that means we are in battery mode, and ```AC_OFF``` is run. On the other hand, ```AC_ON``` is run if ```/tmp/pmtoggle``` is 1.

```powerpm``` can also be configured to toggle turbo boost (tested on intel only). Oftentimes, disabling turbo boost saves power and makes the machine run quieter, making a useful change to do when disconnected from external power. Some scripts already have control over turbo boost, including system76-power.

By default, ```powerpm``` does not alter turbo boost whether you are on battery or connected to external power. By setting the variable ```TURBO``` to a non-zero value in ```powerpm```, you can make it turn boost off on battery power, and turn boost on when connected to external power.

Finally, if ```powerpm``` detects you are running on GNOME, it will attempt to turn off animations if you are on battery power, and re-enable them when connected to external power. This attempts to remove the problem of choppy animations on power-saving modes by just removing them altogether.

# other notes

If you want to manually change power profiles, you can still do so using the command line or a GUI extension such as Guillotine / Command Center on GNOME. ```powerpm``` will not change the power profile automatically until the next time you connect or disconnect from power, so keep in mind that the profile switch only happens on each connect/disconnect from external power, and won't be checked at other times.