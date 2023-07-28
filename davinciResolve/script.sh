#!/bin/bash
#script to do converstions for mov, mp4, or mkv to a mov file that davinci resolve (free) can read.
#hurr durr inefficient programming time

cd "$1" #allows for user to pass in filepaths that contain the videos

#vars
formatDate=$(date +'%m%d%Y-%H%M%S') #make the subfolder name unique by prefixing with formatDate
search="*.mp4 *.mov *.mkv *.insv" #file extensions we search for. Modify as needed
lsOut=$(ls $search)
args="$2"

echo "Script starting, please wait..."
mkdir output_$formatDate #creates subfolder to house the converted videos and log file

shopt -s nocaseglob #begin ignore capitalization
total=$(ls $search 2>/dev/null | wc -l) #total videos to process

echo "$total files were found for conversion."

i=0
for file in $lsOut
do
    let "i++"
    echo "Proccesing ($i/$total) files..."
    #actual conversion
    if [ -z "$args" ] #HEY! EDIT THIS TO USE FLAGS NEXT TIME!! :)
    then
        #My script (smaller files, but reduced quality)
        ffmpeg -y -i "$file" -vcodec mjpeg -acodec pcm_s16be -f mov "output_$formatDate/${file%.*}.mov" 2>> output_$formatDate/log.log
    else
        #ArchWiki's script (larger files)
        ffmpeg -y -i "$file" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le -f mov "output_$formatDate/${file%.*}.mov" 2>> output_$formatDate/log.log
done
shopt -u nocaseglob #end ignore capitalization

echo "Script finished. Files can be found in output_$formatDate/."
