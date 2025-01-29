# background

Some years ago, I bought a Lenovo Chromebook Duet 10.1 (google-kukui) to use for classes. My model has 4GB of RAM, and is the light blue variant found at Best Buy. What made this an interesting device to me personally was:

- Operating System: Though built in the form of a tablet, having ChromeOS loaded on the Duet meant that I had access to a "desktop" class operating system with window management, cursor input, and a sensible file system. My main gripes with mobile-first operating systems such as iPadOS or Android were that they seemed to be missing many features from a "normal" operating system (for example, the filesystem organization found on iPadOS and iOS is just garbage, and until only recently iPadOS did not have a sensible way to display multiple apps at once). I still argue that ChromeOS is actually a well-made operating system, and this was one of the main reasons I considered the Duet for classwork. Plus, it ran Linux and Android apps OOTB, which is more than Windows can say (RIP WSA).

- Portability: Being only 10 inches diagonally, this device is still the most compact device I use. This really helps when shoving the Duet into a backpack to carry around, thus less load when walking between classes or moving between floors of my dorm to check in on students.

- Built in keyboard: Having a detatchable keyboard already included is a major plus for using the Duet as more than just a media consumption device. Need to write a document? Need to code? That keyboard is surprisingly nice to type on, and doesn't have an extreme price tag attached to it (unlike having to buy a separate iPad keyboard).

However, I also had some nitpicks about this particular Duet:

- Sluggishness: The processor included is pretty low-end. That paired with the 4GB of RAM meant that even after a few tabs open, the built-in Chrome browser would begin lagging and stuttering. It got worse when enabling the Google Play Store, and many Android apps would just take up too many resources.

- Operating System: One major gripe I have with ChromeOS is how much it relies on the internet. I understand that reliance on PWAs or other web-services is what allows chromebooks to be functional despite having low-end hardware, but it's incoveniently effectively having your device bricked if its not constantly near a router. I tried to work around this via linux applications, and though they function offline, certain things with ChromeOS' linux compatibility make it less-than-ideal to use (no OSK on linux apps, incompatibilities with display renderers, etc.)

As such, I quickly wondered if it was possible to just replace ChromeOS with linux. Since I was already primarily using only Linux and Android apps for their ability to function offline, couldn't that be solved by running a Linux distro with Waydroid installed?

And that's how I learned about PostmarketOS.

This directory contains various tweaks, frustrations, and QOL changes I've implemented while running pmOS on my google-kukui (google-krane specifically). As a general overview, here's been some highlights during my experience running this OS on the Duet:

1) Battery life: Lower than ChromeOS' battery life, but still pretty good. This is due to the ARM processor inside, so the Duet can still maintain longer runtimes than the other x86_64 devices I employ.

2) Audio: Multiple versions of pmOS have had issues with audio on this board. That seems to be a known issue, as detailed on the pmOS page for google-kukui. One of the more serious issues was the Duet's tendency to randomly wake up from suspend making a very loud and high pitched whine, which though impressive considering the size of the device, also managed to stop one my lectures due to everyone thinking that a fire alarm had sounded. Thankfully, this issue has seemingly decreased in frequency since release 24.06, and I personally haven't had the shriek happen since then. Also one more note, it seems the speakers/microphone only get detected when using pulseaudio. Using PipeWire led to the creation of a Dummy Output in my sound settings which failed to play any sound.

3) Rotation: Thankfully, the rotation sensor works on this device. However, the orientation seems to be incorrect, and by default the display rotation is offset by 90 degrees. Refer to the pmOS google-krane page to fix.

4) Suspension: This has been a huge issue for me. Oftentimes, pmOS would fail to suspend, or get stuck in a loop when waking from suspend. This seems to have been solved somewhat in 24.12, but I still sometimes have to deal with it failing to wake up at all after a long sleep. Additionally, it seems that on GNOME, the device fails to lock before suspending, so additional elogind confs might be needed.

---

Overall, I'd say the Duet isn't a bad device. If you're ok with chromeOS, its actually a nice and cheap tablet with almost the full ChromeOS feature set, all stuck into a 10 inch screen. Battery runtime is good, the screen is relatively sharp, and the keyboard is as expected of Lenovo. The fact that pure linux can run on it is the cherry on top for me. Even though there's some issues, you can often find workarounds or experience the real joy of troubleshooting and discovering your own solutions.
