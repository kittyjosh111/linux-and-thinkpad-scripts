#!/bin/bash
#In genmon prefs, set period to 0 for instant icon changes.

if [ -z $(amixer | awk -F'Capture ' '{print $2}' | grep "off") ]; then
  echo -e "<icon>audio-input-microphone</icon>"
else
  echo -e "<icon>microphone-sensitivity-muted</icon>"
fi
