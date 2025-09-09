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

- https://github.com/oddmario/NVIDIA-Fedora-Driver-Guide?tab=readme-ov-file#the-experience-on-wayland-is-not-the-smoothest-fix-wayland-issues (Github repo with details on enabling GSP)

- https://rpmfusion.org/Howto/NVIDIA (Fedora's howto for installing nvidia drivers via RPMFusion)

- https://www.reddit.com/r/Fedora/comments/1mbmhqk/comment/n7mm8t0/ (The only advice I found that actually told you how to force the proprietary drivers from RPMFusion on Fedora, thanks so much u/EnterTheDarkSide!)

## Enabling RTD3 (For Arch/EndeavourOS on GNOME Wayland)

1. Install the closed nvidia drivers (don't use the open ones, which are the default option).

2. Following the [Arch Wiki](https://wiki.archlinux.org/title/PRIME#NVIDIA) instructions, create the **udev** rule listed. Add all the rules listed (6 total).

3. Add the following to /etc/mkinitcpio.conf:

  - MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

  - FILES=(/etc/udev/rules.d/80-nvidia-pm.rules)

If these values already exist, just add the values in the parantheses to whatever is there currently.

4. Run ```sudo mkinitcpio -P``` to apply the above changes.

5. Create a file ```/etc/modprobe.d/nvidia-pm.conf``` with content ```options nvidia "NVreg_DynamicPowerManagement=0x02"``` .

6. Create a file ```/etc/modprobe.d/nvidia.conf``` with content ```options nvidia "NVreg_EnableGpuFirmware=0"``` .

7. Update GRUB to be sure.

8. If you want, install ```prime-run``` or ```switcherooctl``` to manually tell apps which GPU to use.

9. Reboot, use commands from the top to monitor your GPU. Look for D3cold when the GPU is not in use to ensure it worked.

10. If GNOME apps (calculator, clock) or electron apps (chromium, VSCode) activate the dGPU, then add ```GSK_RENDERER=ngl``` to ```/etc/environment```. Change the renderer for flatpaks as well using Flatseal. Once done, reboot again. (https://bbs.archlinux.org/viewtopic.php?id=284426)

## Enabling RTD3 (For Fedora, with GNOME Wayland)

1. Install the normal nvidia drivers (```akmod-nvidia, xorg-x11-drv-nvidia-cuda```) from RPMFusion (note, I did not need the rpmfusion-nonfree-nvidia-driver repo to be enabled).

2. Following the [Arch Wiki](https://wiki.archlinux.org/title/PRIME#NVIDIA) instructions, create the **udev** rule listed. Add all the rules listed (6 total).

3. Create a file ```/etc/modprobe.d/nvidia-pm.conf``` with content ```options nvidia "NVreg_DynamicPowerManagement=0x02"``` .

4. Create a file ```/etc/modprobe.d/nvidia.conf``` with content ```options nvidia "NVreg_EnableGpuFirmware=0"``` .

5. Update GRUB to be sure.

6. Reboot.

7. Upon reboot, run ```modinfo -l nvidia``` to check which version of the nvidia driver you have. If it is ```NVIDIA```, you are done! If it is ```Dual MIT/GPL```, you need to complete the following steps.

8. Run ```sudo sh -c 'echo "%_without_kmod_nvidia_detect 1" > /etc/rpm/macros.nvidia-kmod'```. This is a macro telling akmods to use the proprietary driver.

9. Run ```sudo akmods --rebuild``` to force rebuild with akmod.

10. Run ```sudo dracut --regenerate-all --force``` to regenerate the initramfs.

11. Run ```modinfo -l nvidia``` to check the version of the nvidia driver now. It should say ```NVIDIA```. 

12. If you want, install ```prime-run``` or ```switcherooctl``` to manually tell apps which GPU to use.

13. Reboot, use commands from the top to monitor your GPU. Look for D3cold when the GPU is not in use to ensure it worked.

14. If GNOME apps (calculator, clock) or electron apps (chromium, VSCode) activate the dGPU, then add ```GSK_RENDERER=ngl``` to ```/etc/environment```. Change the renderer for flatpaks as well using Flatseal. Once done, reboot again. (https://bbs.archlinux.org/viewtopic.php?id=284426)

## Chrome HW (on iGPU)

Now that nvidia drivers are working, chromium decides that it doesn't care about the iGPU and will instead force use the dGPU. To prevent that, follow the following:

1. Install VA-API stuff:

- https://wiki.archlinux.org/title/Hardware_video_acceleration (Arch)

- https://fedoraproject.org/wiki/Firefox_Hardware_acceleration (Fedora)

2. Add --enable-features=AcceleratedVideoDecodeLinuxGL to chrome flag conf
