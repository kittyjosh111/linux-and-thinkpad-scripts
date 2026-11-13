#!/bin/bash

# The font sizes for the display in Argos' menu.
argos_font=11
header_font=13

#wpctl and pw-dump sniffing
this_sink="$(wpctl list audio sinks | grep '*')"
this_id="$(echo $this_sink | awk '{print $1}')"
this_dump="$(pw-dump $this_id)"

#get basic needs for now
this_json="$(echo "$this_dump" | jq -r '.[] |
  select(.type == "PipeWire:Interface:Node") |
  .info.state,
  .info.params.Format[0].rate,
  .info.params.Format[0].format
')"
readarray -t this_array <<< $this_json
is_active="${this_array[0]}"
this_rate="${this_array[1]}"
this_format="${this_array[2]}"

#run main echo
if [ "$is_active" == "running" ]; then
  echo -e "$this_format / $(( $this_rate / 1000 ))kHz"
else
  echo "no playback"
fi

echo "---"

#now we can do more processing heavy-lifting
if [ "$ARGOS_MENU_OPEN" == "true" ]; then
  this_json2="$(echo "$this_dump" | jq -r '.[] |
    select(.type == "PipeWire:Interface:Node") |
    .info.props["node.description"],
    .info.props["node.name"],
    .info.props["device.api"],
    (.info.params.Props[0].channelVolumes | (add / length)),
    .info.params.Props[0].mute,
    .info.props["factory.name"]
  ')"
  readarray -t this_array2 <<< $this_json2
  this_desc="${this_array2[0]}"
  this_name="${this_array2[1]}"
  this_driver="${this_array2[2]}"
  this_avgcv="${this_array2[3]}"
  this_mute="${this_array2[4]}"
  this_factory="${this_array2[5]}"

  if [ "$this_mute" == "false" ]; then
    if [ $this_avgcv == 0 ]; then
      this_db="-inf"
    elif [ $this_avgcv == 1 ]; then
      this_db="0.0"
    else
      this_db="$(awk -v vol="$this_avgcv" 'BEGIN { printf "%.1f", 20 * (log(vol) / log(10)) }')"
    fi
    vol_text="$this_avgcv ($this_db dB)"
  else
    vol_text="muted"
  fi

  echo "Selected Audio Output:|font=monospace size=$header_font iconName=audio-headphones-symbolic"
  echo "- Device Description: $this_desc|font=monospace size=$argos_font"
  echo "- Sink Name: $this_name|font=monospace size=$argos_font"
  echo "- Average Software Channel Volume: $vol_text|font=monospace size=$argos_font"
  if [ "$is_active" == "running" ]; then
    echo "---"
    echo "Hardware Sink Status:|font=monospace size=$header_font iconName=emblem-system-symbolic"
    echo "- Sink Audio Driver: $this_driver ($this_factory)|font=monospace size=$argos_font"
    echo "- Sink Audio Format: $this_format|font=monospace size=$argos_font"
    echo "- Sink Audio Sample Rate: $this_rate Hz|font=monospace size=$argos_font"
  fi
else
 echo "Loading stats...|size=$argos_font"
fi
