### X1 Yoga Gen 3 Quirks

The X1 Yoga Gen 3 is a convertible PC from the X1 Line and features 8th generation Intel processors. This makes it compatible with Windows 11 due to the 4C/8T nature of the 8th gen chips, while also being suitable for notetaking and other touchscreen-focused tasks. The model I have has an i5-8350u, 1080p screen, and is silver. However, this device has some quirks.

**Reference Link: https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_3)**

#### Issues waking from Linux Suspend

1. Install kernel module acpi_call. For Fedora, go here: https://github.com/MiMillieuh/acpi_call-fedora

2a. Load the kernel module. ```sudo modprobe acpi_call```

2b. To make it persistent: ```echo 'acpi_call' | sudo tee /etc/modules-load.d/acpi_call.conf```

3. Create the systemd service from here: https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_3)

4. Enable said systemd service

#### Fans don't turn on until 80 C

1. Install thinkfan

2. Set up thinkfan


