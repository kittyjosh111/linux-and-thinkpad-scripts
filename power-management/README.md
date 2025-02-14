# about and background and reasoning and ...

Power management on Linux is something I find that most major distributions don't do too well at automating. For example, Fedora and Ubuntu use powerprofilesctl to set CPU governor and EPP, but require you to manually toggle the button in GNOME's control center. Additionally, there is no good built-in way to toggle turbo boost without using CLI or an external extension. Some DEs also don't even ship with power management, which though reasonable on desktops or servers, is not very good for laptops. Thus, I've wanted a way to have automatic power management for computers.

I do realize there have been projects such as [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq) that do what I am suggesting, but I either have had issues (for auto-cpufreq, my i7 1260p seems to forever be stuck at 0.9 GHz even in performance mode), or they don't allow users to make easy changes on the go (what if I need a boost of performance while off power with TLP?)

What I really need is a way to automate switching between performance, balanced, and powersave modes based on AC status and system load. I don't care whether its powerprofilesctl, tuned, or system76-power, I just need something that can run commands to change power settings. Oh, and turbo boost too.

To that end, system76pm was my first attempt to do so. I had used system76-power previously and just made a check on AC status to toggle either performance or power modes.

The legacy folder contain legacy scripts which are no longer used.

**The current generation of scripts is in ```powerpm-suite```.** The components are below:

1) ```pmtoggle```: pmtoggle stands for "power management toggle", and is essentially a udev rules that writes a file to /tmp/, then populates it with 0 for disconnected from AC, and 1 for connected. **You should install this first, else other components such as powerpm will not work**. To install, go into the folder named pmtoggle and follow the instructions.

2) ```powerpm```: powerpm is a script that waits for ```pmtoggle``` to make changes to the file in /tmp/ and then decides which power profile to apply in response to AC presence. The user can set which commands to run on AC connection and disconnection, which means you can use any power management you want such as power-profiles-daemon, tuned, system76-power, etc. Additionally, it uses notify-send to send notifications on AC status changes. There is the additional option to enable turbo boost toggling (boost on with AC connected, boost off with AC disconnected), and enable/disable the co-activation of the ```turbo-load``` script. To install, go into the folder named powerpm. **Make sure to read the instructions**.

3) ```dynamic-profiler``` /  ```dynamic-profiler-batt```: these are scripts that read your system load and cpu usage to determine whether to apply a power, performance, or balanced governor + boost preset to your system. For example, having heavy load AND heavy CPU usage will enable a performance preset and turn on turbo boost. If you only have heavy load but not heavy CPU usage, then performance preset is applied, but NOT turbo boost. The *-batt version is meant to run on battery power (by reading pmtoggle), but I am in the process of combining both of them into one, due to how identical the logic for applying presets are. Edit the executables to change the thresholds for applying presets, as well as what commands to actually run in the preset. Default power management backend uses tuned, but you can replace this with system76-power, ppd, etc. Additionally, you can temporarily block this script from applying changes by creating a file named ```dynamic-profiler-lock``` in /tmp. Once this file is removed, the script will resume applying power management changes.

  - Note, dynamic-profiler does what powerpm does, except it has a few seconds of delay and applies dynamic power management. While you can use both at the same time, powerpm is technically not needed to run dynamic-profiler anymore.

# installation and requirements

These scripts rely on some packages. Namely:

- ```inotify-tools```: inotify is used to provide a more efficient alternative to just polling. It triggers commands on response to a monitored file being changed.

- ```notify-send```: notify-send is used to notify users about stuff.

- ```systemctl```: Yep, we use systemd. Unfortunate.

- ```udev```: udev rules in response to hardware changes.

These are the package names on Fedora. For other distros, find the equivalent packages.
