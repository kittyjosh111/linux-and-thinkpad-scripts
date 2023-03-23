#!/bin/bash
# This is a script to turn on and off the media stream playing.
# RELIES ON PLAYERCTL. Install it from your favorite package manager.
# In genmon prefs, set period to 0 for instant icon changes.

#show only if theres actual media playing
if [ `playerctl status` != Stopped ]; then

  CLICK="playerctl play-pause"
  echo -e "<iconclick>$CLICK</iconclick>"

  #logic behind which icon to show depending on if audio is playing or not. If media is indeed playing, display the pause icon. If not, display the play icon.
  if [ -z $(playerctl status | grep "Playing") ]; then
    echo -e "<icon>media-playback-playing</icon>"
  else
    echo -e "<icon>media-playback-paused</icon>"
  fi
else
echo ""  
fi
