#!/bin/bash
# This is a script to display info on the media currently playing. Inspired by the Media Controls extension found for GNOME. 
# RELIES ON PLAYERCTL. Install it from your favorite package manager.
# In genmon prefs, set period to 0 for instant icon changes.

##--CONFIG--##
# Change these values to your liking
length="50" # This is how many characters will be displayed. Useful for when the title of a youtube video spans the entire panel and you need to control it. Leave blank (remove number but keep the quotations) if you want it to be limitless.
separator="|" # This is a separator character placed between various metadata strings. For example: Artist | Title. Change to your liking.

#######################################################################

#genmon variable to add a clicking action
#CLICK="playerctl play-pause"
#echo -e "<textclick>$CLICK</textclick>"

#logic behind getting the artist and title of the media being played
if [ `playerctl status` != Stopped ]; then
  metadata=$(echo -e $(playerctl metadata artist) $separator $(playerctl metadata title)) #This pulls metadata using the playerctl command.
  formatted=$(echo -e $metadata | cut -c 1-$length) #This shortens the output from playerctl 
    if [ -z "$length" ]; then
      echo -e $formatted
    else
      echo -e $formatted  ". . . " # This adds on the "..." to it the overall output
    fi
else
  echo ""
fi

#######################################################################
