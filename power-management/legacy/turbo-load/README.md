# install

- Move ```turbo-load.service``` to /etc/systemd/system/. Enable it. For example: ```sudo systemctl enable --now turbo-load```. Check systemctl status for errors.

- Move ```turbo-load``` to /usr/local/bin. **Open it up in an editor and review the values for ```THRESH_PERCENT```, ```TOGGLE_GOVERNOR```, ```OVERLOAD```, and ```UNDERLOAD``` as needed.** Here are the config options and what they mean:

  - ```THRESH_PERCENT```: Set this to be the decimal form of the percent of total system load you want to hit before turning on turbo boost. For example, 7.5% of my 16 core system allows me to watch youtube without turbo boost activating, but run Handbrake with turbo boosting. This is where you should experiment with values and see what sits with you. Then, the decimal form of 7.5% is 0.075, so thats what THRESH_PERCENT is set to.

  - ```TOGGLE_GOVERNOR```: Set this to 1 if you want to run a script as well once system load goes over or under the THRESH_PERCENT system load. Default is 0, which disables it.

    - ```OVERLOAD```: Only works if TOGGLE_GOVERNOR is enabled. Triggers when system load goes **over** THRESH_PERCENT. Defaut is powerprofilesctl set performance.

    - ```UNDERLOAD```: Only works if TOGGLE_GOVERNOR is enabled. Triggers when system load goes **under** THRESH_PERCENT. Defaut is powerprofilesctl set balanced.