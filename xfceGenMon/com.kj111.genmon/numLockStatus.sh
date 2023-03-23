#!/bin/bash
# This is a script to monitor if the num lock is on or off. Think about GNOME extensions.The icon changes when the num lock is activated or not.
# In genmon prefs, set period to 0 for instant icon changes.

#logic behind which icon to show depending on status of num lock. sed is used to filter and search for the term num in xset output.
if [ -z $(xset -q | grep Caps | sed -n 's/^.*Num Lock:\s*\(\S*\).*$/\1/p' | grep "off") ]; then
  echo -e "<icon>num-lock-on</icon>"
else
  echo -e "<icon>num-lock-off</icon>"
fi

