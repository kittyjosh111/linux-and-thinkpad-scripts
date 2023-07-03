Using GNOME is an everlasting and ongoing battle of power management versus ensuring that GNOME doesn't stutter and give you headaches by being forced to see how choppy the overview animation is. 

I've tried many power management tools including:

1) TLP itself (very choppy, good battery life improvement)

2) Auto-cpufreq itself (less choppy, moderate battery life improvement)

3) TLP and auto-cpufreq (very choppy, great battery life improvement)

3a) Make sure anything to do with cpu in tlp conf is disabled if you use it with auto-cpufreq

However, it seems system76-power is the best in terms of power and performance balance. However, the GNOME extension doesn't work past Gnome 40, and it's troublesome to have to open a terminal when im off to school just to change the power governor.

Thus, let's write a script to toggle the battery and performance modes based on udev rules, checking for AC or battery input.

---

- Move ```system76pm``` to /usr/local/bin. Edit it and assign your username to the USERNAME variable. Give it executable perms.

- Move ```system76pm-suspend``` to /usr/local/bin. Give it executable perms.

- Move ```system76pm-suspend.service``` to /etc/systemd/system/. Enable it. This file makes sure to reload system76pm after waking from suspend, else it defaults back to balanced mode.

- Move ```50-system76pm.rules``` to /etc/udev/rules.d/. Restart udev or your device. This allows system76pm to run on AC connection or disconnection.
