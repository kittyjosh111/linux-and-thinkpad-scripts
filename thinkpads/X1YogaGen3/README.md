# Reference Link: https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_3)

1. Install kernel module acpi_call. For Fedora, go here: https://github.com/MiMillieuh/acpi_call-fedora

2a. Load the kernel module. ```sudo modprobe acpi_call```

2b. To make it persistent: ```echo 'acpi_call' | sudo tee /etc/modules-load.d/acpi_call.conf```

3. Create the systemd service from here: https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Yoga_(Gen_3)

4. Enable said systemd service
