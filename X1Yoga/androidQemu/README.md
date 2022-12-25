# androidQEMU
Getting to run android apps through QEMU on a linux device is cool for when you want to run a mobile app and not have to deal with Waydroid or Anbox. Also, having a touchscreen makes the experience so much better and a better mimic of having an android tablet. Sure you can install androidx86 natively or use chromeOS, but I still want to run linux and use all the software available for that.

The problem is that virtual machines are slow. It's even worse running virtual machines on an i5-6300u with a very old graphics card. Thankfully QEMU exists and can support some degree of 3D acceleration. This plus scrcpy allows for touchscreen input for gestures like zooming, etc.

Thanks to https://ivonblog.com/en-us/posts/android-x86-virgl-libhoudini/ for the instructions that allowed a qemu vm with actual 3D acceleration.

# install
0) Read this link https://ivonblog.com/en-us/posts/android-x86-virgl-libhoudini/. I will summarize the steps below.

1) Install virtual machine manager and qemu.

2) Download androidx86 9.0 iso from their website and create a qcow file for qemu.  

3) Manual Install, android-x86-9.0. Choose ram and cpu options.

4) Customize before install.

5) Overview > Q35 / UEFI x64 OVMF_CODE

6) IDE Disk > VirtIO

7) NIC > VirtIO

8) Display Spice > None / OpenGL

9) Video QXL > Virtio / 3D Acceleration

10) Change device holding the iso to SATA

11) Begin Installtion

12) GPT Yes

13) Create a 512M EFI partition

14) Use the rest of the space for android

15) Format android to ext4

16) Install Grub

17) Yes to format EFI

18) Install /system as read-write

19) Complete setup and enable native bridge if needed.

20) Install adb and scrcpy, connect to IP address under vmm's nic options

# change resolution

1) Boot into android

2) Open terminal or adb shell

3) su

4) mount /dev/block/vda1 /mnt

5) vi efi/boot/android.cfg (or wherever android.cfg is)

6) scroll down to where it says "add_entry "$live". This should be under "#Create main menu"

7) add "video=1920x1080" after quiet. Change dimensions to your needs.