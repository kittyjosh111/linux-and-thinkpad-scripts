# dynamic-profiler

This system is meant to provide a mix between the manual power profiles switching found in common tools such as power-profiles-daemon or system76-power, along with automatic toggling between them based on CPU usage and system load. Hence, its a sort of "dynamic tuning" or "dynamic profiler".

```dynamic-profiler``` really only needs three parts to work correctly: The ```dynamic-profiler``` script and ```dynamic-profiler.conf``` configuration file in this repository, along with the ```pmtoggle``` system found in the parent folder [here](https://github.com/kittyjosh111/linux-and-thinkpad-scripts/tree/main/power-management/powerpm-suite/pmtoggle). All the other files (systemd services, ```dynamic-profiler-ctrl```, etc.) are optional to the core functionality of ```dynamic-profiler``` and are meant as QOL scripts.

It is important to note that ```dynamic-profiler``` does NOT replace your standard power profile manager, rather it tells that manager how to change between profiles automatically. As such, you SHOULD NOT mask or disable your power profile manager (tuned, ppd, system76-power, etc.). You will in fact be required to find the commands to make your power profile manager switch between profiles in order to fill out the configuration file.

Also, this script is meant to be used on Intel CPUs that support turbo boost. If your CPU doesn't support this (low-end / AMD CPUs), you can try to edit ```dynamic-profiler``` to skip over the turbo boost section. That would probably mean deleting the second part of the while loop at the end of the script.

## install

1. Install pmtoggle from this repo. It was in the parent folder of this directory.

2. Copy ```dynamic-profiler``` and ```dynamic-profiler-ctrl``` to /usr/local/bin/ or wherever you store executables. Make sure they have executable permissions. Technically, using ```dynamic-profiler-ctrl``` is optional, as it is meant for monitoring and manual usage.

3. Copy dynamic-profiler.conf to /etc/. If you don't want to do that and instead keep the config somewhere else, you need to pass in the file's new location to ```dynamic-profiler``` and edit the fourth line in ```dynamic-profiler-ctrl```. Just put in the path to the config file when starting ```dynamic-profiler```.

4. Edit the conf file. There are descriptions of what each variable means inside the conf file. All values are required to be filled. Defaults were tested on an X1 Yoga Gen 3.

5. Copy the systemd files to /etc/systemd/system/ if you want to use systemd. Enable and start them.

## manual control via ```dynamic-profiler-ctrl```

Despite its name, ```dynamic-profiler``` can be run in manual mode, giving you the option to specify which profile / turbo boost setting to use, much like how powerprofilesctl does.

If you want a nice CLI interface to control manual mode, you can simply use ```dynamic-profiler-ctrl``` to issue commands.

```The following arguments are recognized by dynamic-profiler-ctrl:
  -p | --profile | profile [VALUE]:
    Manually activate a profile. Accepted values are performance, balanced, or power.
    Leave blank to view dynamic-profiler stats.  
  -t | --turbo | turbo [VALUE]:
    Manually activate/deactivate turbo boost. Accepted values are on or off.
  -r | --reset | reset :
    Resets dynamic-profiler to automatic control.
```

The outputs and usage of this command are meant to be inspired by the outputs/usage of powerprofilesctl and tuned-adm.

So for example, if you want to lock dynamic-profiler to powersave and turn on turbo boost, you would issue the following command: ```dynamic-profiler-ctrl -p powersave -t on```.

However, you are not required to use ```dynamic-profiler-ctrl``` for manual mode. In fact, that script is merely a fancy wrapper to write files into /tmp/ that ultimately control ```dynamic-profiler```. If you want to control manual mode "manually", here is how that works:

1. Determine if you want to lock profile-switching to one profile, and/or if you want to toggle turbo boost on or off.

 - To lock and manually control the power profile:

  - First create a "lock file" that prevents the script from switching between profiles. To do so, execute this command: ```touch /tmp/dynamic-profiler-lock-governor```.

  - Then, create a file that explicitly tells the script which profile to use. To do so, create a file called "/tmp/dynamic-profiler-manual-governor" that has the name of the profile inside it. As a reminder, profile names are "performance", "balanced", or "powersave". Thus, if you want to manually set performance mode, you would execute this command: ```echo "performance" | tee /tmp/dynamic-profiler-manual-governor```. Remember to change "performance" to the profile name you want.

 - The steps to manually control turbo boost are almost the same:

  - First create a "lock file" that prevents the script from toggling turbo boost. To do so, execute this command: ```touch /tmp/dynamic-profiler-lock-turbo```.

  - Then, create a file that explicitly tells the script whether to turn on or off turbo boost. To do so, create a file called "/tmp/dynamic-profiler-manual-turbo" that has either "on" or "off" as its contents. For example: ```echo "on" | tee /tmp/dynamic-profiler-manual-turbo``` turns on turbo boost, but remember to change "on" as needed.

2. To disable manual control and return to automatic management, remove any lock or manual files you created. So, either ```rm /tmp/dynamic-profiler-lock*``` or ```rm /tmp/dynamic-profiler-manual*``` or both.

If you need to see examples of these commands, you can actually read the contents of ```dynamic-profiler-ctrl```, as that's what is going on beneath the hood.

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

### sluggishness on resume

I've noticed on Fedora that my laptops feel sluggish after waking from suspend, and further testing showed that the max frequency of the CPUs somehow got lowered during suspension. It seems to only happen after longer suspends, but a fix is to manually set the frequency to some high number like 9999 to force the cpus back to normal. While I think the GPU faces the same problem, I don't know how to manually perform such a trick, so dynamic-profiler will just force the performance profile / turbo boost on when the script begins, before applying dynamic tuning. Hopefully this helps alleviate slugishness after resumes with the included dynamic-profiler-restart.service systemd service.

### debugging

If you want to debug, you can set ```DEBUG_LOG``` to 1. This prints a line with load delta, cpu usage, and turbo status each time the script goes to apply a profile. (LOAD DELTA: -4, CPU: 3, NO_TURBO: 1). Load deltas are reported in hundredths (15 = 0.15 difference).
