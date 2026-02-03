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
echo "Quick Controls:|size=$header_font"
echo "Lock Rotation|iconName=rotation-locked-symbolic size=$argos_font bash='touch /tmp/gwr/lock' terminal=false"
echo "Automatic Rotation|iconName=rotation-allowed-symbolic size=$argos_font bash='rm /tmp/gwr/lock' terminal=false"
echo "---"
echo "Manual Rotation:|size=$header_font"
echo "Normal Orientation|iconName=orientation-landscape-symbolic size=$argos_font bash='touch /tmp/gwr/lock && echo normal | tee /tmp/gwr/manual' terminal=false"
echo "Right-Up Orientation|iconName=orientation-portrait-right-symbolic size=$argos_font bash='touch /tmp/gwr/lock && echo right-up | tee /tmp/gwr/manual' terminal=false"
echo "Left-Up Orientation|iconName=orientation-portrait-left-symbolic size=$argos_font bash='touch /tmp/gwr/lock && echo left-up | tee /tmp/gwr/manual' terminal=false"
echo "Bottom-Up Orientation|iconName=orientation-landscape-inverse-symbolic size=$argos_font bash='touch /tmp/gwr/lock && echo bottom-up | tee /tmp/gwr/manual' terminal=false"
echo "Automatic Orientation|iconName=rotation-allowed-symbolic size=$argos_font bash='rm /tmp/gwr/lock' terminal=false"
echo "---"
echo "Restart Service|iconName=view-refresh-symbolic size=$argos_font bash='systemctl --user restart gnome-waydroid-rotator_user.service' terminal=false"
