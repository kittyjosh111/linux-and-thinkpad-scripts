# intro

Script to convert all video files within a folder into a format recognizable by the free version of DaVinci Resolve on linux.

The help message is found below:

```
Usage: drfree -f [DIRECTORY] -s [OPTION]
This script allows converting videos into a format that DaVinci Resolve (free) can recognize on linux.

-h                    Prints a help message.
                        This is what you are reading right now.

-f [DIRECTORY]        Required. Provide a DIRECTORY to the script. Any videos within the DIRECTORY will be considered for conversion.
                        ex: /home/user/Videos/subfolder

-s [OPTION]           Provide which conversion script to use. Defaults to low.
                        'low' creates smaller, lower-quality files, and 'high' creates larger, higher-quality files

-c [FORMAT]           Provide a comma-separated list of custom video formats to convert. Defaults to mp4, mov, and mkv
                        ex: insv,mkv,mp4
                        Note you need to redefine the default formats when defining custom ones.
                        Note there are no checks to whether ffmpeg can actually do the conversion.


```

Basically, you need to pass the directory of videos for ```drfree``` to work on. Then, it will create a new folder titled ```output_DATE_TIME```, which it will put converted videos into. Your pre-existing videos ARE NOT MODIFIED.

The 'low' option for the s flag will create a lower-quality output video that takes less space and is faster to convert. The 'high' option creates higher-quality ouputs that take more space and is slower, courtesy of the Arch Wiki.

By default, ```drfree``` looks for mp4, mov, and mkv files to convert. With the -c flag, you can specify custom video formats through a list separated by commas. Do note you will need to redefine mp4, mov, mkv if you specify custom formats. 

For example:

```drfree -f /home/user/Videos -s high -c mp4,mov,insv```

will convert all videos in format mp4, mov, or insv in the ~/Videos folder using the higher-quality options.