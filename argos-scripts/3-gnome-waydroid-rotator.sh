#!/bin/bash
# Link to Argos: https://github.com/p-e-w/argos

# The font sizes for the display in Argos' menu.
argos_font=11
header_font=13

# The text displayed in the top bar
top_bar_text="⟳"

######################################################################
## DO NOT MODIFY BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING ##
######################################################################

echo $top_bar_text
echo "---"
echo "Lock Rotation|iconName=rotation-allowed-symbolic size=$argos_font bash='touch /tmp/gnome-waydroid-rotator.lock' terminal=false"
echo "Unlock Rotation|iconName=rotation-allowed-symbolic size=$argos_font bash='rm /tmp/gnome-waydroid-rotator.lock' terminal=false"
echo "Restart Rotation|iconName=view-refresh-symbolic size=$argos_font bash='systemctl --user restart gnome-waydroid-rotator_user.service' terminal=false"
