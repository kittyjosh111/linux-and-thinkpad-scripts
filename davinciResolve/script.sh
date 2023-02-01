#!/bin/bash
#script to do converstions for mov, mp4, or mkv to a mov file that davinci resolve (free) can read.
cd "$1"
mkdir bin
echo "Script starting, please wait..."
shopt -s nocaseglob
for file in *.mp4 *.mov *.mkv
do 
    ffmpeg -y -i "$file" -vcodec mjpeg -q:v 2 -acodec pcm_s16be -q:a 0 -f mov "bin/${file%.*}.mov" 2> bin/log.log
done
shopt -u nocaseglob
echo "Script finished. Files can be found in bin/."