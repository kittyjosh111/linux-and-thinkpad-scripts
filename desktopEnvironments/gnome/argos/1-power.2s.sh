#!/bin/bash
# This is a script to monitor the current watts drawn by the device. It also displays battery info when pressed.
# This is a modification of my XFCE genmon script to add more functionality for use with Argos on GNOME.
# Link to Argos: https://github.com/p-e-w/argos

length=1 #Adjust this to how many decimal points you want to have after the tens place.

#logic behind how to calculate voltage draw
numerator=$(cat /sys/class/power_supply/BAT0/power_now)
let "denominator=10**6"
voltage=$(echo "scale=$length ; $numerator / $denominator" | bc)
echo "$voltage W"
echo "---"

#argos click menu thing
if [ "$ARGOS_MENU_OPEN" == "true" ]; then
  upower="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
  echo "Charging State:          $(echo "$upower" | grep state | cut -c 26-41)" #state
  echo "Current Energy:          $(echo "$upower" | grep energy: | cut -c 26-30) Wh" #energy
  echo "Current Voltage:         $(echo "$upower" | grep voltage | cut -c 26-30) V" #voltage
  echo "Time Remaining:       $(echo "$upower" | grep "time to empty" | cut -c 26-30)" #time to empty
  echo "---"
  echo "Current Capacity:       $(echo "$upower" | grep energy-full: | cut -c 26-35)" #energy-full
  echo "Factory Capacity:       $(echo "$upower" | grep energy-full-design: | cut -c 26-35)" #energy-full-design
  echo "Battery Capacity:       $(echo "$upower" | grep capacity | cut -c 26-30)%" #capacity
  echo "Charge Cycles:              $(echo "$upower" | grep charge-cycles: | cut -c 26-30)" #charge-cycles
else
  echo "Loading..."
fi
