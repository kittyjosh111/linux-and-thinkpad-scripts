#!/bin/bash
# This is a script to monitor the current watts drawn by the device. There was once a GNOME extension that could do this, but went unmaintained.
# In genmon prefs, set period to 0 for instant icon changes.

length=1

#logic behind how to calculate voltage draw
numerator=$(cat /sys/class/power_supply/BAT0/power_now)
let "denominator=10**6"
voltage=$(echo "scale=$length ; $numerator / $denominator" | bc)
echo "$voltage W"
