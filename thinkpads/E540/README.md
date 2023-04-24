The Thinkpad E540 has an issue where the trackpad and trackpoint both stop working when the device wakes up from sleep. There were posts on forums and google saying to unload and reload the ps2mouse module, but this didn't work on Fedora. Thus I don't know if it would have worked at all.

What did work was unloading and reloading the rmi_smbus module. Thus it would be nice if we could run a script to unload and reload said module every time the computer wakes from sleep.

That sounds like the problem I encountered with the trackpoint keyboard scripts. Thus, let us use systemd to solve this issue. 

To install:

1) copy ```mouse-restart``` to /usr/local/bin. chmod +x it to make it executable.
2) copy ```mouse-restart.service``` to /etc/systemd/system/
3) run ```sudo systemctl daemon-reload```
4) run ```sudo systemctl enable --now mouse-restart.service```

