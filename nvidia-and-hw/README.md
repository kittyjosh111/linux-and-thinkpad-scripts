# Enabling RTD3 for Nvidia on Linux

RTD3 did not work by default on my ThinkPad P16s with NVIDIA GPU. This meant increased heat and shortened battery life since the dGPU was always on. Using envycontrol supposedly fixed this issue, but I noticed that it still wouldn't work. The following are my attempts to get RTD3 working on that specific ThinkPad for both EndeavourOS and Fedora.

## Nice commands:

```watch cat /sys/class/drm/card*/device/power_state #power state of both iGPU and dGPU```

```watch cat /proc/driver/nvidia/gpus/0000\:03\:00.0/power #more granular info about rtd3```

Use those commands to monitor the GPU power status. If you can see D3cold on the first command, that means the GPU is powered down. The second command might have a different identifier based on your GPU (commonly, 0000\:03\:00.0 -> 0000\:01\:00.0)

## Good readings:

- https://wiki.archlinux.org/title/PRIME#PRIME_render_offload (Arch's notes on PRIME rendering)

- https://us.download.nvidia.com/XFree86/Linux-x86_64/550.54.14/README/dynamicpowermanagement.html (Nvidia's own documentation on RTD3, which allows for powering down the dGPU when not in use)

- https://bbs.archlinux.org/viewtopic.php?pid=2181317#p2181317 (Arch discussion about closed drivers)

- https://discussion.fedoraproject.org/t/kde-and-nvidia-drivers-causing-low-fps-lag-stuttering/125950 (Fedora discussion about GSP on the closed vs open drivers)

- https://discussion.fedoraproject.org/t/kde-and-nvidia-drivers-causing-low-fps-lag-stuttering/125950 (Github repo with details on enabling GSP)

- https://negativo17.org/nvidia-driver/#Proprietary_and_open_source_kernel_modules (Negativo17 notes about closed vs open drivers)

## Enabling RTD3 (For Arch/EndeavourOS on GNOME Wayland)

1. Install the closed nvidia drivers (don't use the open ones, which are the default option).

2. Following the [Arch Wiki](https://wiki.archlinux.org/title/PRIME#NVIDIA) instructions, create the **udev** rule listed. Add all the rules listed (6 total).

3. Add the following to /etc/mkinitcpio.conf:

  - MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

  - FILES=(/etc/udev/rules.d/80-nvidia-pm.rules)

If these values already exist, just add the values in the parantheses to whatever is there currently.

4. Run ```sudo mkinitcpio -P``` to apply the above changes.

5. Create a file ```/etc/modprobe.d/nvidia-pm.conf``` with content ```options nvidia "NVreg_DynamicPowerManagement=0x02"``` .

6. Create a file ```/etc/modprobe.d/nvidia.conf``` with content ```"NVreg_EnableGpuFirmware=0"``` .

7. Update GRUB to be sure.

8. If you want, install ```prime-run``` or ```switcherooctl``` to manually tell apps which GPU to use.

9. Reboot, use commands from the top to monitor your GPU. Look for D3cold when the GPU is not in use to ensure it worked.

10. If GNOME apps (calculator, clock) or electron apps (chromium, VSCode) activate the dGPU, then add ```GSK_RENDERER=ngl``` to ```/etc/environment```. Change the renderer for flatpaks as well using Flatseal. Once done, reboot again. (https://bbs.archlinux.org/viewtopic.php?id=284426)

## Enabling RTD3 (For Fedora, with GNOME Wayland)

1. Install the negativo17 drivers (https://negativo17.org/nvidia-driver/).

2. Install ```akmod-nvidia``` and related package. When installing the nvidia drivers from Negativo17, ensure that they are actually coming from the ```fedora-nvidia``` repo, NOT Fedora's own ```nonfree-nvidia``` and ```updates``` repos. If needed, disable those two Fedora repos.

3. Following the [Arch Wiki](https://wiki.archlinux.org/title/PRIME#NVIDIA) instructions, create the **udev** rule listed. Add all the rules listed (6 total).

4. Create a file ```/etc/modprobe.d/nvidia-pm.conf``` with content ```options nvidia "NVreg_DynamicPowerManagement=0x02"``` .

5. Create a file ```/etc/modprobe.d/nvidia.conf``` with content ```"NVreg_EnableGpuFirmware=0"``` .

6. Update GRUB to be sure.

7. Reboot.

8. Navigate to the [Proprietary and open source kernel modules](https://negativo17.org/nvidia-driver/#Proprietary_and_open_source_kernel_modules) section on Negativo17's website. Scroll down to the "akmods" section. Follow the instructions there. You'll most likely have installed the ```Dual MIT/GPL``` (open) version of the driver, so run the commands to switch to the closed drivers.

9. Before rebooting, run ```sudo dracut --regenerate-all --force``` .

10. If you want, install ```prime-run``` or ```switcherooctl``` to manually tell apps which GPU to use.

11. Reboot, use commands from the top to monitor your GPU. Look for D3cold when the GPU is not in use to ensure it worked.

12. If GNOME apps (calculator, clock) or electron apps (chromium, VSCode) activate the dGPU, then add ```GSK_RENDERER=ngl``` to ```/etc/environment```. Change the renderer for flatpaks as well using Flatseal. Once done, reboot again. (https://bbs.archlinux.org/viewtopic.php?id=284426)

## Chrome HW (on iGPU)

Now that nvidia drivers are working, chromium decides that it doesn't care about the iGPU and will instead force use the dGPU. To prevent that, follow the following:

1. Install VA-API stuff:

- https://wiki.archlinux.org/title/Hardware_video_acceleration (Arch)

- https://fedoraproject.org/wiki/Firefox_Hardware_acceleration (Fedora)

2. Add --enable-features=AcceleratedVideoDecodeLinuxGL to chrome flag conf
