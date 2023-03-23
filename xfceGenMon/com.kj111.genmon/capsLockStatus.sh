#!/bin/bash
# This is a script to monitor if the caps lock is on or off. Think about GNOME extensions.The icon changes when the caps lock is activated or not.
# In genmon prefs, set period to 0 for instant icon changes.

#logic behind which icon to show depending on status of caps lock. sed is used to filter and search for the term caps in xset output.
if [ -z $(xset -q | grep Caps | sed -n 's/^.*Caps Lock:\s*\(\S*\).*$/\1/p' | grep "off") ]; then
  echo -e "<icon>caps-lock-on</icon>"
else
  echo -e "<icon>caps-lock-off</icon>"
fi

