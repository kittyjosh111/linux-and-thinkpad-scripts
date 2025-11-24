so while not a thinkpad, i have used a duet 3 (N4020 cpu, 4 GB RAM)...

It needed this to work with a stylus with xournalpp (place in /etc/udev/hwdb.d/):

```
#ELAN Stylus Override
evdev:input:b0018v04F3p2BD6*
 KEYBOARD_KEY_d0045=btn_stylus
 KEYBOARD_KEY_d0044=btn_stylus
```
