#!/bin/bash

# The font sizes for the display in Argos' menu.
argos_font=11
header_font=13

# Now alsa-sniffing
alsa_device="$(grep -rn RUNNING /proc/asound/card*/pcm*p/sub*/status | head -n1)"
if [ ! -z "$alsa_device" ]; then
  alsa_device="${alsa_device%pcm*}"
  device_info="$(cat "$alsa_device"pcm*p/sub*/hw_params)"
  this_stream="$(cat "$alsa_device"stream*)"
  while IFS= read -r line; do
    case "$line" in
      rate:*)
        this_rate="${line#rate: }"
        this_rate="${this_rate%% *}"
        ;;
      format:*)
        this_format="${line#format: }"
        ;;
      buffer_size:*)
        this_bf="${line#buffer_size: }"
        ;;
    esac
  done <<< "$device_info"
  #get capabilities
  this_details="$(echo "$this_stream" | grep -A 10 "$this_format")"
  while IFS= read -r line; do
    case "$line" in
      *Rates:*)
        this_av_rates="${line#*Rates: }"
      	;;
      *Bits:*)
      	this_bits="${line#*Bits: }"
      	;;
    esac
  done <<< "$this_details"
  echo -e "$this_bits bit / $(( $this_rate / 1000 ))kHz"
else
  echo "no playback"
fi

echo "---"

# main stuff
if [ "$ARGOS_MENU_OPEN" == "true" ]; then #$ARGOS_MENU_OPEN
  if [ ! -z "$alsa_device" ]; then
    device_name="$(echo "$this_stream" | head -n1)"
    this_name="${device_name#* at }"
    this_name="${this_name%% : *}"
    this_desc="${device_name%at*}"
    this_latency=$(( (this_bf * 1000) / this_rate ))
    #get volume stuff
    this_amixer="$(amixer get Master)"
    this_sum=0
    this_count=0
    while IFS= read -r line; do
      case "$line" in
      	*\[off\]*)
      	  this_mute="(muted)"
      	  ;;
        *\[on\]*)
          this_extract="${line#*\[}"
          this_extract="${this_extract%%\%\]*}"
          this_sum=$((this_sum + this_extract))
          this_count=$((this_count + 1))
          this_mute=""
          ;;
      esac
    done <<< "$this_amixer"
    if [ "$count" != "0" ]; then
      this_avgcv=$(( $this_sum / $this_count ))
    else
      this_avgcv="unknown"
    fi
    vol_text="$this_avgcv% $this_mute"   
    #the echoes
    echo "Selected Audio Output:|font=monospace size=$header_font iconName=audio-headphones-symbolic"
    echo "- Device Description: $this_desc|font=monospace size=$argos_font"
    echo "- Device Connection: $this_name|font=monospace size=$argos_font"
    echo "- Average Software Channel Volume: $vol_text|font=monospace size=$argos_font"
    echo "Hardware Sink Status:|font=monospace size=$header_font iconName=emblem-system-symbolic"
    echo "- Sink Audio Buffer Latency: $this_latency ms|font=monospace size=$argos_font"
    echo "- Sink Audio Format: $this_format ($this_bits bit)|font=monospace size=$argos_font"
    echo "- Sink Audio Sample Rate: $this_rate Hz|font=monospace size=$argos_font"
    echo "- Sink Audio Available Rates: $this_av_rates|font=monospace size=$argos_font"
  else
    echo "no ALSA audio playback found|font=monospace size=$argos_font"
  fi
else
 echo "Loading stats...|size=$argos_font"
fi

