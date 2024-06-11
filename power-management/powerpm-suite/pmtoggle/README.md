# install

- Move ```pmtoggle``` to /usr/local/bin. For example: ```sudo cp powerpm /usr/local/bin/```

- Move ```99-pmtoggle.rules``` to /etc/udev/rules.d/.

- Reboot to apply the new udev rules.

# implementation and logic

Udev can monitor for changes in ```power_supply```. Quite useful to tell if we are on battery or connected to external power. Once we have a udev rule in place, we can then use it to trigger another script that writes a file to /tmp/ which carries a value of 0 or 1, representing battery and external power, respectively. This is how ```pmtoggle``` works.

Since we now have a file in /tmp/ that automatically updates in response to power supply changes, we can use other scripts to read for changes in this file and act accordingly. One such implementation is ```powerpm```.

Additionally, pmtoggle only toggles in response to AC changes. It does not itself affect power profiles, thats up to scripts like ```powerpm```.