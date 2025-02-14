# dynamic-profiler

This script has 3 parts: the main executable, the config file, and the systemd file. The main script requires pmtoggle to run correctly. While older versions of the script also required powerpm, this is no longer necessary.

Based on your CPU usage and system load (measured every 4 seconds), the main executable will decide whether to apply a Performance, Balanced, or Power preset. Turbo Boost is also applied based on CPU usage.

## install

1. Install pmtoggle from this repo.

2. Copy dynamic-profiler to /usr/local/bin/. Make sure it is executable.

3. Copy dynamic-profiler.conf to /etc/. If you don't want to do that and instead keep the config somewhere else, you need to pass in the file's new location to the main executable (dynamic-profiler).

4. Edit the conf file. There are descriptions of what each variable means inside the conf file. All values are required to be filled.

5. Copy the systemd file to /etc/systemd/system/ if you want to use systemd. Enable it and start it.

## manual control

to temporarily disable and manually control dynamic-profiler, follow these steps:

1) Lock dynamic-profiler. Do this by creating a file ```/tmp/dynamic-profiler-lock```. The filename must match that exactly. You can use command ```touch /tmp/dynamic-profiler-lock```.

2) To control turbo boost manually, create either ```/tmp/dynamic-profiler-turbo-on``` to turn it on, or ```/tmp/dynamic-profiler-turbo-off```. You can use the touch command again.

3) To control power governor by calling whichever commands you've set in the config file, create a file ```/tmp/dynamic-profier-manual``` and write the word "performance", "balanced", or "power" in it. You can do this for example with ```echo "performance" | tee /tmp/dynamic-profiler/manual```

4) To disable manual control and return to automatic management, remove the lock file. So, ```rm /tmp/dynamic-profiler-lock```

## more details

The following goes into more detail about the script and the config.

### background

My previous attempts at power management used a variety of different power management tools. Namely, these were power-profiles-daemon, system76-power, and tuned. This is still the case for dynamic-profiler, so you can think of this script as an automation for your chosen power management backend, rather than a full-on replacement. The problems I had with system76pm and powerpm were a lack of versatility. While they excelled at automatically applying power profiles depending on AC status (main point of system76pm / powerpm), I wanted a way to have this script automatically change power profiles based on system stats. This is kind of what mainstream OSes seem to do (Windows won't lock your cpu to the highest performance when there's nothing running), though I don't know nearly enough about those systems to say for sure. However, I still want a way to manually lock a power profile in and change it myself, similar to what the default GNOME / KDE power profile setups do.

Dynamic-profiler is as the name suggests, dynamic. Depending on CPU usage and system load, it will automatically change power profiles or apply turbo boost (like auto-cpufreq). You can also create a lock file to disable dynamic profiles, and create files in /tmp/ to manually tell the script whether to change profiles or manage turbo boost. Then, you can keep these in a GUI button and effectively restore the GUI button functionality found on default DEs.

### inspiration from ppd (performance, balanced, and power)

Following the naming convention of ppd, we dedicate three "profiles" from which the script can run. These are:
 
- ```PERFORMANCE```: for maximum performance, think of "powerprofilesctl set performance" 

- ```BALANCED```: for balanced performance and power-saving, think of "powerprofilesctl set balanced" 

- ```POWER```: for power-saving, think of "powerprofilesctl set powersave" 

Each of these "profiles" can be set in the config file. There is one set of these three profiles for AC mode (AC_PERFORMANCE, etc.) and one set for Battery mode (BAT_PERFORMANCE, etc.). These profiles are supposed to contain commands to run. So for example, you could set AC_BALANCED to "tuned-adm profile balanced".

Now that we have "profiles", we need a way to know when to switch between them. We do this by reading the change in system load over four seconds (reading at 4 seconds - reading at 0 seconds), as well as the current CPU usage. 

### the legacy of turbo-load (load and cpu usage)

For system load, we set the variable ```LOAD_DELTA_THRESHOLD``` to act as a threshold which tells the script to change the current profile when passed. For CPU usage, we use ```LOWER_CPU_THRESHOLD``` as the threshold value which changes the profile to a more power-saving profile when passed. ```UPPER_CPU_THRESHOLD``` is to change the profile to a higher performance profile. With these values:

- If the calculated change in load after 4 seconds is greater than ```LOAD_DELTA_THRESHOLD```, we set the profile to performance mode, no matter what. This allows a sort of "burst" in performance that could be useful for short-running actions such as opening an application.

- Else if the calculated change in load after 4 seconds is postive AND the CPU usage is greater than or equal to ```UPPER_CPU_THRESHOLD```, we apply the PERFORMANCE profile.

- Else if the calculated change in load after 4 seconds is postive AND the CPU usage is less than ```LOWER_CPU_THRESHOLD```, we apply the BALANCED profile.

- Else if the calculated change in load after 4 seconds is negative AND the CPU usage is greater than or equal to ```UPPER_CPU_THRESHOLD```, we apply the BALANCED profile.

- Else if the calculated change in load after 4 seconds is negative AND the CPU usage is less than or equal to ```LOWER_CPU_THRESHOLD```, we apply the POWER profile.

- Else, in all other cases, we just keep the last applied profile.

Since the system load calculation takes 4 seconds and the CPU usage reading takes 1 second, there is a 5 second delay between each time the profile gets applied. Thus, starting an intensive application might be slow at first, but should start speeding up after 5 seconds.

Again, the conf files has values for the above variables, with one set for AC mode, and one set for Battery mode. CPU thresholds should be as a percent (45% = 45), and load deltas should be decimals (0.75, etc.).

### more legacy from turbo-load (turbo boost management)

Finally, we look again to CPU usage to determine whether to apply turbo boost. If the current CPU usage is higher than the threshold value we set in ```TURBO_CPU_THRESHOLD```, then we turn turbo boost on. If not, we turn it off. Simple.

Again, the conf file has one ```TURBO_CPU_THRESHOLD``` for AC mode and one for battery mode.

### debugging

If you want to debug, you can set ```DEBUG_LOG``` to 1. This prints a line with load delta, cpu usage, and turbo status each time the script goes to apply a profile. (LOAD DELTA: -4, CPU: 3, NO_TURBO: 1). Load deltas are reported in hundredths (15 = 0.15 difference).