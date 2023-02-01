# X11flicker
Admittedly, Wayland is nice. However, certain apps don't think so, and are incompatible at the moment. For example, Barrier doesn't work. Zoom has to go through extra steps to share screen on Wayland. As such, it is necessary to run X11 sometimes. However, this X380 Yoga did not work well with X11, and had some screen flicker. This doesn't help with taking notes, so I did the following:

# install
1) Download the file.

2) Move the file to `/etc/X11/xorg.conf.d/`

3) Reboot

# reference
The options I used were taken from https://askubuntu.com/questions/1234026/screen-tearing-on-ubuntu-xorg-20-04-with-intel-graphics and https://askubuntu.com/questions/708855/intel-integrated-graphics-screen-tearing?rq=1. Animations seem a bit choppy, but hey, no screen flickering for me.

I use a i5-8350u, with 16GB RAM, and Intel HD Graphics 630.
