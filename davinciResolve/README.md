```
Usage: drfree -f [DIRECTORY] -s [OPTION]
This script allows converting videos into a format that DaVinci Resolve (free) can recognize on linux.

-h                    Prints a help message.
                        This is what you are reading right now.

-f [DIRECTORY]        Provide a DIRECTORY to the script. Defaults to where the script is run from.
                        ex: /home/user/Videos/subfolder

-s [OPTION]           Provide which conversion script to use. Defaults to low.
                        'low' creates smaller, lower-quality files, and 'high' creates larger, higher-quality files

-c [FORMAT]           Provide a comma-separated list of custom video formats to convert. Defaults to mp4, mov, and mkv
                        ex: insv,mkv,mp4
                        Note you need to redefine the default formats when defining custom ones.
                        Note there are no checks to whether ffmpeg can actually do the conversion.
```