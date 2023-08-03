Using GNOME is an everlasting experience of cursing at strange issues, marveling at simplicity, but more frequently, an ongoing battle of resource management versus ensuring that GNOME doesn't stutter and give you headaches by being forced to see how choppy the overview animation is. 

Let's focuse on power. I've tried many power management tools including:

1) TLP itself (very choppy, good battery life improvement)

2) Auto-cpufreq itself (less choppy, moderate battery life improvement)

3) TLP and auto-cpufreq (very choppy, great battery life improvement)

3a) Make sure anything to do with cpu in tlp conf is disabled if you use it with auto-cpufreq

However, it seems system76-power is the best in terms of power and performance balance. Low power usage and better performance than TLP? However, the GNOME extension doesn't work past Gnome 40, and it's troublesome to have to open a terminal when im off to school just to change the power governor. Maybe I don't need that toggle. Maybe I just care whether I'm connected to a power source or not.

After all, the GNOME extension "Guillotine" allows me to make buttons that execute scripts, creating a jank replacement to the system76 extension.

Thus, let's write a script to toggle the battery and performance modes based on udev rules, checking for AC or battery input.

---

**Install:**

- Move ```system76pm``` to /usr/local/bin. Edit it and assign your username to the USERNAME variable. Give it executable perms. If you are not using gnome, feel free to comment out the USERNAME variable and the two lines that use it.

- Move ```system76pm-suspend``` to /usr/local/bin. Give it executable perms.

- Move ```system76pm-suspend.service``` to /etc/systemd/system/. Enable it. This file makes sure to reload system76pm after waking from suspend, else it defaults back to balanced mode.

- Move ```50-system76pm.rules``` to /etc/udev/rules.d/. Restart udev or your device. This allows system76pm to run on AC connection or disconnection.

---

```system76pm``` is a script that checks to see if you are on AC power. If so, the system76-power profile performance is activated, and GNOME animations are enabled. If you are not, that means you are on battery, thus system76-power profile battery is activated, and GNOME animations are disabled. If you want more performance on this mode, you can edit the script to use balanced rather than battery.

```system76pm-suspend``` solves the issue that system76-power automatically reverts to balanced after waking from suspend. That doesn't help as either I really need to squeeze out power from the battery when I'm not near an AC, or the balanced mode causes choppy graphics when I am on AC. Thus, this script is basically a copy of system76pm, but waits a few seconds for the system to come back online before executing.

```50-system76pm.rules``` is a udev rule that activates whenever the power source changes, whether from AC to battery or vice versa. This is helpful so that changes the power source can trigger system76pm, and thus change the power profile and animations near-instantaneously.

```system76pm-suspend.service``` is a systemd service that executes upon waking from suspend. This is what triggers system76pm-suspend in order to change the power profile from balanced to something else.
