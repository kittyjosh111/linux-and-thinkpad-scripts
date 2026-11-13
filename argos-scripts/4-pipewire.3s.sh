#!/bin/bash

# The font sizes for the display in Argos' menu.
argos_font=11
header_font=13
this_toggle=0

poll="$(pw-top -b -n 1 | grep output | awk '$3 != 0')" #current audio output

if [ -n "$poll" ]; then
  this_toggle=1
fi

if [ $this_toggle -eq 1 ]; then
  bit="$(echo "$poll" | awk '{print $10}')"
  rate="$(echo "$poll" | awk '{print int($12/1000) "kHz"}')"
  echo -e "$bit / $rate"
else
  bit="--"
  rate="--"
  echo "no audio playback"
fi

echo "---"

if [ "$ARGOS_MENU_OPEN" == "true" ]; then
  if [ $this_toggle -eq 1 ]; then
    device="$(echo "$poll" | awk '{print $13}')"
  else
    device="no active audio playback"
  fi

  wpvol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}')
  wpdb=$(echo "60 * l($wpvol) / l(10)" | bc -l)
  vol=$(echo "$wpvol * 100" | bc)
  db=$(printf "%.2f" "$wpdb")

  echo "Active Audio Sink:|size=$header_font iconName=audio-headphones-symbolic"
  echo "- Device: $device|font=monospace size=$argos_font"
  echo "---"
  echo "System Statistics:|size=$header_font iconName=emblem-system-symbolic"
  echo "- Volume Level: $vol / 100.00|font=monospace size=$argos_font"
  echo "- Decibels Relative to FS: $db dB|font=monospace size=$argos_font"
  echo "- Audio Bit Depth: $bit|font=monospace size=$argos_font"
  echo "- Audio Sample Rate: $rate|font=monospace size=$argos_font"
else
 echo "Loading stats...|size=$argos_font"
fi
