#!/bin/bash
energy_rate="$(cat /sys/class/power_supply/sbs-12-000b/current_now)"
temperature="$(cat /sys/class/hwmon/hwmon0/temp1_input)"
temp_display="$(echo "scale=0; $temperature / 1000" | bc) °C"

if [[ "$energy_rate" == *"-"* ]]; then
  display_a="$(echo "scale=2; $energy_rate / 100000" | bc)"
  display="$display_a / $temp_display"
else
  display=$temp_display
fi

echo "$display"
