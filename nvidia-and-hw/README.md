## Nice commands:

watch cat /sys/class/drm/card*/device/power_state #power state of both iGPU and dGPU

watch cat /proc/driver/nvidia/gpus/0000\:03\:00.0/power #more granular info about rtd3

## Enabling RTD3 (Tested on GNOME Wayland, EndeavourOS)

1. Use the closed nvidia drivers

2. https://wiki.archlinux.org/title/PRIME#PRIME_render_offload, https://us.download.nvidia.com/XFree86/Linux-x86_64/550.54.14/README/dynamicpowermanagement.html, https://bbs.archlinux.org/viewtopic.php?pid=2181317#p2181317

2b. manually create the files (dont use aur package, and add all stuff to the udev rule)

2c. Add the following to /etc/mkinitcpio.conf:

  - MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

  - FILES=(/etc/udev/rules.d/80-nvidia-pm.rules)

2d. sudo mkinitcpio -P

2e. options nvidia "NVreg_DynamicPowerManagement=0x02" for /etc/modprobe.d/nvidia-pm.conf

2f. options nvidia "NVreg_EnableGpuFirmware=0" for /etc/modprobe.d/nvidia.conf

2g. Update grub to be sure

2h. If you want, install prime-run, switcherooctl

2h. Reboot, use commands from top to monitor. Look for D3cold

2i. If GNOME apps (calculator, clock) use dGPU, then add GSK_RENDERER=ngl to /etc/environment. then reboot again (https://bbs.archlinux.org/viewtopic.php?id=284426)

## Chrome HW (iGPU)

1. Install VA-API stuff: https://wiki.archlinux.org/title/Hardware_video_acceleration

2. Add --enable-features=AcceleratedVideoDecodeLinuxGL to chrome flag conf
