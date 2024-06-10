# install:

- Install ```evtest``` and ```inotify-tools``` with your package manager.

- Move ```kj111lidswitch``` to /usr/local/bin. Give it executable perms.

- Move ```kj111lidswitch.service``` to /etc/systemd/system/. Enable and start it with systemctl command.

# why?

When you enable fingerprint authentication on linux, it turns out that fprintd will not stop itself when the lid closes. So on most laptops such as the T series ThinkPads, you end up having no physical way to press the fingerprint sensor when the lid is closed (say you use a dock), unless you drill a hole through the lid.

We can manually enable or disable fingerprint auth by unmasking or masking the systemctl fprintd service, respectively.

People on the internet have suggested using acpid to automate the above fixes. However, it doesn't work on Fedora, and I have no clue why. I can create files in /tmp just fine on response to lid open or close, but cannot execute systemctl commands.

Thus, we turn to our old frenemy, libinput. This script attempts to work around the fingerprint issue by using the Lid Switch event provided from libinput. We use evtest to monitor the status of the lid, where value 1 is closed, and value 0 is open. Write this to a /tmp/ file and we can use inotify to run commands every time the log changes. When the lid is closed, we mask fprintd, and when it is open, we unmask.

Couple this with systemd, and we can run this script on startup / automatically.
