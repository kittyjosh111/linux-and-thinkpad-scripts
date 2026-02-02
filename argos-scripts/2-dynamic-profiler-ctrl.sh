#!/bin/bash
# Link to Argos: https://github.com/p-e-w/argos

# The font sizes for the display in Argos' menu.
argos_font=11
header_font=13

# The text displayed in the top bar
top_bar_text="dynamic-profiler-ctrl"

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

echo $top_bar_text
echo "---"
echo "Power Profiles:|iconName=system-run size=$header_font"
echo "Performance Mode|iconName=power-profile-performance-symbolic size=$argos_font bash='dynamic-profiler-ctrl -p performance -t on' terminal=false"
echo "Balanced Mode|iconName=power-profile-balanced-symbolic size=$argos_font bash='dynamic-profiler-ctrl -p balanced -t on' terminal=false"
echo "Power Mode|iconName=power-profile-power-saver-symbolic size=$argos_font bash='dynamic-profiler-ctrl -p power -t off' terminal=false"
echo "Automatic Mode|iconName=view-refresh-symbolic size=$argos_font bash='dynamic-profiler-ctrl -r' terminal=false"
echo "---"
echo "Manual Control:|iconName=applications-utilities-symbolic size=$header_font"
echo "--• Performance Profile|size=$argos_font bash='dynamic-profiler-ctrl -p performance' terminal=false"
echo "--• Balanced Profile|size=$argos_font bash='dynamic-profiler-ctrl -p balanced' terminal=false"
echo "--• Power Profile|size=$argos_font bash='dynamic-profiler-ctrl -p power' terminal=false"
echo "--• Turbo Boost ON|size=$argos_font bash='dynamic-profiler-ctrl -t on' terminal=false"
echo "--• Turbo Boost OFF|size=$argos_font bash='dynamic-profiler-ctrl -t off' terminal=false"
echo "--• Reset to automatic|size=$argos_font bash='dynamic-profiler-ctrl -r' terminal=false"
