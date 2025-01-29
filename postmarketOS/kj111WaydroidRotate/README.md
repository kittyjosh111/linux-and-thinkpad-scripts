# background

Turns out that if you kept waydroid in its default dimensions, rotating the screen absolutely screws up the waydroid window. For example, lets say that I have a 1920x1060 window on a 1920x1080 screen. Rotating the screen ends up with the waydroid window only showing half the content on the upper half of the screen. However, you can use commands to manually rotate the android device in waydroid. This combined with a non-rotating linux WM allows you to use the full estate of waydroid when rotating the device.

To set up, set your device to the orientation you want to lock the rotation at. Then lock rotation. Then run monitor-sensor and note down what the device reports for now. Set that to the variable ```device_landscape_normal```.

Then, set the following values. Use their names as hints for how to rotate your device

- device_left_portrait

- device_right_portrait

- device_landscape_flipped

Then, run the script.
