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
