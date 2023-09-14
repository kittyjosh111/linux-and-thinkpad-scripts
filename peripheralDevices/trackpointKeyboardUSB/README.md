# trackpointKeyboardUSB
I am very inaccurate at using a trackpoint. Thus, I need to lower the sensitivity of the trackpoint to achieve manageable accuracy. For the builtin trackpoint, you can use this script: https://askubuntu.com/questions/37824/what-is-the-best-way-to-configure-a-thinkpads-trackpoint. Originally, I repurposed this answer to also apply to my external trackpoint keyboard, with steps documented in my other repo: https://github.com/kittyjosh111/udev-trackpoint-keyboard

Yet it seems that it didn't work all the time, and having to search for the id each time the keybaord was plugged in became impractical. Thus, I turned to systemd.

# install
1) Download the files. Edit `trackpoint.service` to add you username to the field with `User=`. For example, `User=fedora`

2) Move `trackpoint` into `/usr/local/bin/` give it executable permission using `sudo chmod +x trackpoint`

3) Move both `trackpoint.service` and `trackpoint-restart.service` into `/etc/systemd/system/`

4) Enable both by doing:

```sudo systemctl enable trackpoint.service && sudo systemctl start trackpoint.service```

```sudo systemctl enable trackpoint-restart.service && sudo systemctl start trackpoint-restart.service```

This installs the systemd files and the script it runs.

# explanation

There are three parts to this solution:
1) Script to decrease trackpoint sensitivity, placed into `/usr/local/bin`
2) Activation of said script using systemd (`trackpoint.service`)
3) Activation of above systemd service upon waking from suspend (`trackpoint-restart.service`)

The files I used are above. The two ```*.service``` files are to be placed in `/etc/systemd/system/`. Enable and start them normally with the usual `sudo systemctl enable ...` and `sudo systemctl start ...`.

`trackpoint.service` invokes the script in `/usr/local/bin/` This waits 10 seconds in case you are just logging in, then lists out xinput devices and attempts to find one called "ThinkPad Compact USB Keyboard with TrackPoint". Since there are multiple results, it attempts to decrease acceleration on all returned results. Some will fail as they are not pointing devices, but one should work and the trackpoint will have decreased sensitivity. 

If you need to edit the name that the script searches for, try editing `trackpoint` and changing the term in quotation marks.

```trackpoint-restart.service``` runs on waking from suspend and literally just restarts the aforementioned ```trackpoint.service```.