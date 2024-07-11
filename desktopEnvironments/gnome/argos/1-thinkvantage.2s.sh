#!/bin/bash
# This is a script to monitor a thinkpad running fedora
# Link to Argos: https://github.com/p-e-w/argos

###############
## Variables ##
###############

# The font sizes for the display in Argos' menu.
header_font=12
body_font=10
# How many units after the decimal point (for numbers) you want to display in the panel
length=2
# Limits to determine when to change color on battery power
lower_limit=10 #in watts
middle_limit=13
upper_limit=16
# Power profile toggles
performance="tuned-adm profile throughput-performance"
balanced="tuned-adm profile balanced"
power="tuned-adm profile powersave"
# Color codes for bash
red='\033[1;31m'
yellow='\033[1;33m'
green='\033[1;32m'
blue='\033[1;36m'
reset='\033[0m'

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

#Get power info
upower=$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)
charge_state=$(echo "$(echo "$upower" | grep state | awk '{print $2}')")

#Get Temperature from thinkpad hwmon
for each in $(ls /sys/class/hwmon); do
  if [ "$(cat /sys/class/hwmon/$each/name)" == "thinkpad" ]; then
    cpu_temp=$(($(cat /sys/class/hwmon/$each/temp1_input) / 1000))
    gpu_check=$(cat /sys/class/hwmon/$each/temp2_input 2>&1)
    if [[ "$gpu_check" == *"No such device or address"* ]]; then
      gpu_temp="--"
    else
      gpu_temp=$(( $gpu_check / 1000 ))
    fi
    break
  fi
done

#Determine what to display in the panel
if [ $charge_state != "discharging" ]; then
echo -e "$cpu_temp °C" #this displays to the panel if not discharging
else
  watt=$(echo "scale=$length; $(cat /sys/class/power_supply/BAT0/power_now) / 1000000" | bc)
  int=$(printf "%.*f\n" 0 $watt)
  #conditionals for which image to display:
  if [ $int -le $lower_limit ]; then
    text="$blue"
  elif [ $int -gt $lower_limit ] && [ $int -le $middle_limit ]; then
    text="$green"
  elif [ $int -gt $middle_limit ] && [ $int -le $upper_limit ]; then
    text="$yellow"
  else
    text="$red"
  fi
  echo -e "${reset} $text$watt W${reset}  /  $cpu_temp °C" #this displays to the panel when discharging
fi
echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then

  #Prepare visualizations
  bar_chart() {
    percentage=$1
    filled_length=$(( percentage / 4 ))
    bar="["

    for ((i=0; i<filled_length; i++)); do
        bar+="#"
    done

    for ((i=filled_length; i<25; i++)); do
        bar+=" "
    done

    bar+="]"
    echo "$bar"
  }

  #Get CPU info
  top_get="$(top -bn1 | grep -o -e 'load average.*' -e 'Cpu(s).*')"
  cpu="$(echo "$top_get" | tail -n 1 | awk '{ print $2 '+' $4; }' | bc)"
  int_cpu=$(printf "%.*f\n" 0 $cpu)
  cpu_name=$(cat /proc/cpuinfo | grep "model name" | tail -n 1 | awk -F': ' '{print $2}')
  freq_info=$(lscpu | grep MHz)
  max_freq=$(echo "$(echo "$freq_info" | grep "max" | awk '{print $4}')" | awk '{printf "%.0f", $1}')
  percent_freq=$(echo "$(echo "$freq_info" | grep "scaling" | awk '{print $4}')" | awk -F'%' '{print $1}')
  curr_freq=$(echo "$(( $max_freq * $percent_freq / 100 ))" | awk '{printf "%.2f", $1 / 1000}')

  #Get RAM usage info
  ram_info=$(free -m | grep Mem)
  total_ram=$(echo $ram_info | awk '{print $2}')
  used_ram=$(echo $ram_info | awk '{print $3}')
  percent_ram=$(( $used_ram * 100 / $total_ram ))

  #Get IBM Fan Speed
  fan_level=$(echo $(cat /proc/acpi/ibm/fan | grep level:) | awk '{print $2}')
  if [ $fan_level == "auto" ]; then
    fan_bar="[      - fans auto -      ]"
  elif [ $fan_level == "disengaged" ]; then
    fan_bar="[   - fans disengaged -   ]"
  fi

  fan_speed=$(echo $(cat /proc/acpi/ibm/fan | grep speed:) | awk '{print $2}')
  if [ $fan_speed == 0 ]; then
    fan_speed="OFF"
  else
    fan_speed="$fan_speed RPM"
  fi

  #Check turbo boost status
  if [ $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) == "0" ]; then
    boost="active"
  else
    boost="inactive"
  fi

  #Get battery stats
  curr_charge="$(echo "$upower" | grep "energy:" | awk '{print $2}')"
  curr_cap="$(echo "$upower" | grep "energy-full:" | awk '{print $2}')"
  fact_cap="$(echo "$upower" | grep "energy-full-design:" | awk '{print $2}')"
  batt_health="$(echo "$upower" | grep "capacity" | awk '{print $2}')"
  time_to="$(echo "$upower" | grep "time to" | cut -c 26-45)"
  cycles="$(echo "$upower" | grep "charge-cycles" | awk '{print $2}')"

  #Get load stats
  curr_load="$(echo "$top_get" | head -n 1 | awk '{print $3;}' | tr ',' ' ')"
  load_percent="$(echo "$curr_load * 100 / $(grep processor /proc/cpuinfo | wc -l)" | bc)"

  #Now we do the echos
  echo "🖳 CPU: $cpu_name|size=$header_font font=monospace"
  echo "- Boost $boost, $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor) profile ($curr_freq GHz)|size=$body_font font=monospace"
  echo "- CPU Usage: $(bar_chart $int_cpu) - $cpu%|size=$body_font font=monospace"
  echo "---"
  echo "🎟 Memory: $(echo "$(echo "scale=$length; $used_ram / 1024" | bc)") GB Used / $(echo "$(echo "scale=$length; $total_ram / 1024" | bc)") GB Total|size=$header_font font=monospace"
  echo "- RAM Usage: $(bar_chart $percent_ram) - $percent_ram%|size=$body_font font=monospace"
  echo "---"
  echo "🌡 CPU Temp: $cpu_temp °C / GPU Temp: $gpu_temp °C|size=$header_font font=monospace"
  if [[ ! -z $fan_bar ]]; then
    echo "- Fan Speed: $fan_bar - $fan_speed|size=$body_font font=monospace"
  else
    echo "- Fan Speed: $(bar_chart $(( $fan_level * 100 / 7 ))) - $fan_speed|size=$body_font font=monospace"
  fi
  echo "---"
  echo "⏻ Battery: $curr_charge Wh Left / $curr_cap Wh Total|size=$header_font font=monospace"
  if [[ ! -z $time_to ]]; then
    echo "- $time_to remaining ($charge_state)|size=$body_font font=monospace"
  fi
  echo "- Health: $batt_health of $fact_cap Wh ($cycles cycles)|size=$body_font font=monospace"
  echo "---"
  echo "🗲 Power Profile Toggles:| size=$header_font font=monospace"
  echo "- Toggle Performance Profile (click me)|size=$body_font font=monospace bash='$performance' terminal=false"
  echo "- Toggle Balanced Profile (click me)|size=$body_font font=monospace bash='$balanced' terminal=false"
  echo "- Toggle Power-Saving Profile (click me)|size=$body_font font=monospace bash='$power' terminal=false"
  echo "- Toggle Turbo Boost (click me)|size=$body_font font=monospace bash='if [ $(cat /sys/devices/system/cpu/intel_pstate/no_turbo) == "0" ]; then echo "1" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo; else echo "0" | pkexec tee /sys/devices/system/cpu/intel_pstate/no_turbo; fi' terminal=false"
  echo "---"
  echo "🖧 Other Information:| size=$header_font font=monospace"
  echo "- Host IPv4 Address: $(hostname -i | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n 1)|font=monospace size=$body_font"
  echo "- Sys. Load: $(bar_chart $load_percent) - $curr_load|size=$body_font font=monospace"

else
  #Easter egg, thinkpad time
  echo -e "- Think${red}P${green}a${blue}d${reset} $(echo "$(cat /sys/devices/virtual/dmi/id/product_family)" | awk -F 'ThinkPad ' '{print $2}') -|size=$header_font font=monospace"
fi
