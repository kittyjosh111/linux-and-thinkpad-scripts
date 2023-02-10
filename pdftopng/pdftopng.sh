
#!/bin/bash
#script to do conversions from pdf to png, so that they may be imported into Xournal++.
cd "$1"
mkdir bin
echo "Script starting, please wait..."
shopt -s nocaseglob
for file in *.pdf
do 
    pdftoppm "$file" "$file" -png
    mv "$file"-1.png bin/
done
shopt -u nocaseglob
echo "Script finished. Files can be found in bin/."
PWD=$(pwd)