
#!/bin/bash
#script to do conversions from pdf to png, so that they may be imported into Xournal++.
#hurr durr inefficient programming time

cd "$1" #allows for user to pass in filepaths that contain the videos

#vars
formatDate=$(date +'%m-%d-%Y') #make the subfolder name unique by prefixing with formatDate
search="*.pdf" #file extensions we search for. Modify as needed

echo "Script starting, please wait..."
mkdir output_$formatDate #creates subfolder to house the converted videos and log file

shopt -s nocaseglob #begin ignore capitalization
for file in $search
do 
    #actual conversion
    pdftoppm "$file" "$file" -png 2>> output_$formatDate/log.log
done
mv *.png output_$formatDate
shopt -u nocaseglob #end ignore capitalization

echo "Script finished. Files can be found in output_$formatDate/."