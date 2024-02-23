#!/bin/bash
# This is a script to toggle power profiles and turbo boost, intended to replace the built-in GNOME one
# Link to Argos: https://github.com/p-e-w/argos

#power profile scripts. Replace with commands from your power profile manager
performance="tuned-adm profile throughput-performance"
balanced="tuned-adm profile balanced"
power="tuned-adm profile powersave"

#font sizes
header_font=14
body_font=11

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

echo "|iconName=view-app-grid-symbolic"
echo "---"

echo "Toggles Menu|font=monospace size=$header_font"
echo "---"
echo "Power Profiles|font=monospace size=$body_font"
echo "--Performance|bash='$performance' font=monospace size=$body_font terminal=false"
echo "--Balanced|bash='$balanced' font=monospace size=$body_font terminal=false"
echo "--Power|bash='$power' font=monospace size=$body_font terminal=false"
echo "Turbo Boost|font=monospace size=$body_font"
echo "--Activate|bash='echo "0" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo' font=monospace size=$body_font terminal=false"
echo "--Deactivate|bash='echo "1" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo' font=monospace size=$body_font terminal=false"
echo "---"
echo "Touchpad|font=monospace size=$body_font"
echo "--Activate|bash='gsettings set org.gnome.desktop.peripherals.touchpad send-events enabled' font=monospace size=$body_font terminal=false"
echo "--Deactivate|bash='gsettings set org.gnome.desktop.peripherals.touchpad send-events disabled' font=monospace size=$body_font terminal=false"
