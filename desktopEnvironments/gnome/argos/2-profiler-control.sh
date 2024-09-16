#!/bin/bash
# Link to Argos: https://github.com/p-e-w/argos

###############
## Variables ##
###############

# The font sizes for the display in Argos' menu.
header_font=12
body_font=10

# The text displayed in the top bar
top_bar_text="Power"

# Power profile toggles
performance="tuned-adm profile throughput-performance"
balanced="tuned-adm profile balanced"
power="tuned-adm profile powersave-fix"

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

echo $top_bar_text
echo "---"

#Now we do the echos
echo "🗲 Manual Controls:| size=$header_font font=monospace"
echo "- Performance Profile|size=$body_font font=monospace bash='touch /tmp/dynamic-profiler-lock && $performance' terminal=false"
echo "- Balanced Profile|size=$body_font font=monospace bash='touch /tmp/dynamic-profiler-lock && $balanced' terminal=false"
echo "- Power-Saving Profile|size=$body_font font=monospace bash='touch /tmp/dynamic-profiler-lock && $power' terminal=false"
echo "- Toggle Turbo Boost|size=$body_font font=monospace bash='touch /tmp/dynamic-profiler-lock && if [ $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) == "0" ]; then echo "1" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo; else echo "0" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo; fi' terminal=false"
echo "---"
echo "🗲 Automatic Controls:| size=$header_font font=monospace"
echo "- Reset Dynamic Profiler|size=$body_font font=monospace bash='rm /tmp/dynamic-profiler-lock' terminal=false"
