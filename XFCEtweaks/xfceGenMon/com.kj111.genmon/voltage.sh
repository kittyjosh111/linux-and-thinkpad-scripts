#!/bin/bash
# This is a script to monitor if the caps lock is on or off. Think about GNOME extensions.The icon changes when the caps lock is activated or not.
# In genmon prefs, set period to 0 for instant icon changes.

length=1

#logic behind which icon to show depending on status of caps lock. sed is used to filter and search for the term caps in xset output
let "len=$length + 1"
let "del=$len + 1"
numerator=$(cat /sys/class/power_supply/BAT0/power_now | cut -c 1-$len)
let "denominator=10**$length"
echo -e " -"$(echo "$numerator/$denominator" | bc -l | cut -c 1-$del)"V "
