#!/bin/bash
# This is a script to monitor a thinkpad running fedora
# Link to Argos: https://github.com/p-e-w/argos

###############
## Variables ##
###############

# The font sizes for the display in Argos' menu.
argos_font=12

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

thinkvantage
echo "---"
if [ "$ARGOS_MENU_OPEN" == "true" ]; then
  echo "$(thinkvantage -v) | font=monospace size=$argos_font"
fi
