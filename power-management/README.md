# about and background and reasoning and ...

Power management on Linux is something I find that most major distributions don't do too well at automating. For example, Fedora and Ubuntu use powerprofilesctl to set CPU governor and EPP, but require you to manually toggle the button in GNOME's control center. Additionally, there is no good built-in way to toggle turbo boost without using CLI or an external extension. Some DEs also don't even ship with power management, which though reasonable on desktops or servers, is not very good for laptops. Thus, I've wanted a way to have automatic power management for computers.

I do realize there have been projects such as [auto-cpufreq](https://github.com/AdnanHodzic/auto-cpufreq) that do what I am suggesting, but I either have had issues (for auto-cpufreq, my i7 1260p seems to forever be stuck at 0.9 GHz even in performance mode), or they don't allow users to make easy changes on the go (what if I need a boost of performance while off power with TLP?)

What I really need is a way to automate switching between performance, balanced, and powersave modes based on AC status and system load. I don't care whether its powerprofilesctl, tuned, or system76-power, I just need something that can run commands to change power settings. Oh, and turbo boost too.

To that end, system76pm was my first attempt to do so. I had used system76-power previously and just made a check on AC status to toggle either performance or power modes.

The legacy folder contain legacy scripts which are no longer used.

**The current generation of scripts is in ```powerpm-suite```.** The components are below:

1) ```pmtoggle```: pmtoggle stands for "power management toggle", and is essentially a udev rules that writes a file to /tmp/, then populates it with 0 for disconnected from AC, and 1 for connected. **You should install this first, else other components such as powerpm will not work**. To install, go into the folder named pmtoggle and follow the instructions.

2) ```powerpm```: powerpm is a script that waits for ```pmtoggle``` to make changes to the file in /tmp/ and then decides which power profile to apply in response to AC presence. The user can set which commands to run on AC connection and disconnection, which means you can use any power management you want such as power-profiles-daemon, tuned, system76-power, etc. Additionally, it uses notify-send to send notifications on AC status changes. There is the additional option to enable turbo boost toggling (boost on with AC connected, boost off with AC disconnected), and enable/disable the co-activation of the ```turbo-load``` script. To install, go into the folder named powerpm. **Make sure to read the instructions**.

3) ```turbo-load```: turbo-load is a script that changes turbo boost status in response to system load. Often, turbo-boost is on by default and causes massive heat generation when not needed. For example, my i7 1260p can idle at 60 degrees when turbo boost is on, but goes down to 50 when boost is off. What if we could automatically turn on/off boost based on how busy the system is? We can check system load by running ```uptime``` and getting the first value. [This](https://docs.rackspace.com/docs/check-the-system-load-on-linux) was a good resource for me about system load. Thus, if we set a certain threshold load (which could be a percentage of the total load = percentage * total CPU count), then we can turn off turbo boost when the load is under the threshold (computer probably idling or doing less intensive tasks), or turn on turbo boost when the load is over the threshold (computer is probably busy and could use the frequency boost of turbo boost). This percentage probably depends on your preference and core count, so try different values out. ```turbo-load``` can run standalone, but works great in conjunction with ```powerpm```.

# installation and requirements

These scripts rely on some packages. Namely:

- ```inotify-tools```: inotify is used to provide a more efficient alternative to just polling. It triggers commands on response to a monitored file being changed.

- ```notify-send```: notify-send is used to notify users about stuff.

- ```systemctl```: Yep, we use systemd. Unfortunate.

- ```udev```: udev rules in response to hardware changes.

These are the package names on Fedora. For other distros, find the equivalent packages.