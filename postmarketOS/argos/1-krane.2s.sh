#!/bin/bash
# This is a script to toggle power profiles and turbo boost, intended to replace the built-in GNOME one
# Link to Argos: https://github.com/p-e-w/argos

#power profile scripts. Replace with commands from your power profile manager
performance="p60t-stat -g performance"
power="p60t-stat -g ondemand"
refpuls="rm -rf /home/*/.config/pulse/"
waydr="waydroid session stop"

#font sizes
header_font=14
body_font=11

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################
echo "- Lenovo"
echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then

echo "Power Profiles|font=monospace size=$header_font"
echo "Performance|bash='$performance' font=monospace size=$body_font terminal=false"
echo "Ondemand|bash='$power' font=monospace size=$body_font terminal=false"
echo "---"
echo "Extra Toggles|font=monospace size=$header_font"
echo "Refresh Pulse|bash='$refpuls' font=monospace size=$body_font terminal=false"
echo "Stop Waydroid|bash='$waydr' font=monospace size=$body_font terminal=false"
echo "---"
echo "TouchPad Stats|font=monospace size=$header_font"
echo "Activate TP|bash='gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled' font=monospace size=$body_font terminal=false"
echo "Deactivate TP|bash='gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled' font=monospace size=$body_font terminal=false"
#echo "---"
#echo "$(cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)"

fi
