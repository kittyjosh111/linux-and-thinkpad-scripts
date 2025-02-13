# install

- Find and edit your gamemode.ini file (for example, in /usr/share/gamemode). In the custom section, pasted the contents of ```gamemode.ini```.

# background and reasoning

Gamemode provides a good way to run programs such as DaVinci Resolve with more performance. Look at [their page](https://github.com/FeralInteractive/gamemode) for more info. However, to make it work with our powerpm and turbo-load stuff, we need to:

- When gamemode is active, disable turbo-load functionality, set turbo boost on.

- When gamemode is inactive, enable turbo-load functionality, let it adjust turbo boost.