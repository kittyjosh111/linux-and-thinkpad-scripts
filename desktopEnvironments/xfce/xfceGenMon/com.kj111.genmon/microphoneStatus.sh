#!/bin/bash
# This is a script to monitor if the microphone is on or off. Think about GNOME's microphone indicator or something. The icon changes when the microphone is on or off. To specify, on and off refer to if the microphone has been muted through software or not.
# In genmon prefs, set period to 0 for instant icon changes.

#genmon variable to add a clicking action
CLICK="amixer -D pulse set Capture toggle"
echo -e "<iconclick>$CLICK</iconclick>"

#logic behind which icon to show depending on output of amixer. Awk is used to filter and search for the term off in microphone settings.
if [ -z $(amixer | awk -F'Capture ' '{print $2}' | grep "off") ]; then
  echo -e "<icon>audio-input-microphone</icon>"
else
  echo -e "<icon>microphone-sensitivity-muted</icon>"
fi

