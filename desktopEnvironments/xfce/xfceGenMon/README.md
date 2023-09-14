# intro

Why does the XFCE microphone thing look so bad? Why isn't there an indicator for caps lock or num lock anymore?

The directory presented here is meant to house various genmon scripts I wrote to replace features from other DEs that i found useful and not in XFCE. For example, there is a genmon script to basically monitor for whether a microphone is on or off. I missed this feature from GNOME but the builtin panel indicator for XFCE looks terrible. Thus using genmon, we can jank up our own version.

Keep this script somewhere genmon can read. For example, move the directory into your ~/.config/ folder and make genmon read from that. Set genmon peiod to a lower number for a faster icon refresh rate.

If you are on GNOME, you can actually use these scripts with the gnome extension "Executor", which provides similar functionality. You can just copy paste the contents of the script into executor.
