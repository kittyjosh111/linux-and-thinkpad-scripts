# background

On pmOS 24.12, I have an issue where the device fails to lock before suspending. You can fix this by inserting a hook to run a script before suspending. This is supported by elogind.

To use, move the folder ```system-sleep``` to /etc/elogind/
