#!/bin/bash
# This is a script to display info on the media currently playing. Inspired by the Media Controls extension found for GNOME. 
# RELIES ON PLAYERCTL. Install it from your favorite package manager.
# In genmon prefs, set period to 0 for instant icon changes.

##--CONFIG--##
# Change these values to your liking
length="50" # This is how many characters will be displayed. Useful for when the title of a youtube video spans the entire panel and you need to control it. Change to an obscenely high number if you don't want to limit it.
separator="|" # This is a separator character placed between various metadata strings. For example: Artist | Title. Change to your liking.

#######################################################################

#logic behind getting the artist and title of the media being played
#First, get artist. Then get the media title
#Then see how long it is with the separator character
#Take only the first $length characters. If its over, add the ...
#Also, the script only checks for titles if there is anything playing. Otherwise it is blank.

if [ `playerctl status` != Stopped ]; then
  metadata=$(echo -e $(playerctl metadata artist) $separator $(playerctl metadata title)) #This pulls metadata using the playerctl command.
  metaLength=${#metadata} #This counts how many characters make up the entire phrase
  if [ $metaLength -gt $length ]; then #Checking if the metadata var is longer than our defined length in the config
    formatted=$(echo -e $metadata | cut -c 1-$length) #This shortens the output from playerctl in the event that the metadata is longer than the defined length
    echo -e $formatted  ". . . " #This adds on the "..." to it the overall output
  else
    echo -e $metadata " " #This adds a space to the end to provide padding with other panel elements. Remove whitespace if so desired
  fi
else
  echo ""
fi

#######################################################################
