so while not a thinkpad, i have used a duet 3 (N4020 cpu, 4 GB RAM)...

It needed this to work with a stylus with xournalpp (place in /etc/udev/hwdb.d/):

```
#ELAN Stylus Override
evdev:input:b0018v04F3p2BD6*
 KEYBOARD_KEY_d0045=btn_stylus
 KEYBOARD_KEY_d0044=btn_stylus
```

And this for libwacom tablet file:

```
[Device]
Name=Elan 2BD6
ModelName=
DeviceMatch=i2c|04f3|2bd6
Class=ISDV4
IntegratedIn=Display;System
#Styli=@generic-with-eraser
Styli=@generic-no-eraser

[Features]
Stylus=true
Touch=true
```

Now for the locking via power button, install acpid, then create a (/etc/acpi/events/powerconf):

```
event=button/power.*
actuib=/etc/acpi/actions/lock.sh
```

and the actual action (/etc/acpi/actions/lock.sh):

```
loginctl lock-sessions
```
