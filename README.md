# Ben's Guix Configuration
This is my entire system. Packages and configuration are managed in a purely functional manner. 

## Installation
This is a bit of an involved process; a convenient shell script should streamline this process.
- Create initial installation of GUIX using [System Crafter's tutorial](https://systemcrafters.net/craft-your-system-with-guix/full-system-install/)
  - Stop before the "Saving your configuration" section
- Log into the new installation, and clone this repository
- Open `./system/system.scm` (new definition) and `/etc/config.scm` (old definition)
  - Doing this with a split `neovim` instance is helpful
  - Copy UUIDs within the `file-systems` value from the old definition to the new definition
  - Copy `host-name` value from the old definition to the new definition
  - If necessary, copy `users` value from the old definition to the new definition
- Copy over channels file with `mkdir -p ~/.config/guix; cp /etc/channels.scm ~/.config/guix`
  - Edit `~/.config/guix/channels.scm` to remove all lines containing `(commit ...)`
- Update system with `guix pull`
  - Ensure you follow the instructions describing how to set `GUIX_PROFILE`, source the profile, and run `guix hash`
- Configure system with `sudo guix system reconfigure ./system/system.scm; guix home reconfigure ./home/home.scm`
- Install all your old packages by creating a manifest on your old machine with `guix package --export-manifest > manifest.scm`, transferring it to your new machine, and using it with `guix package -m manifest.scm`
- Reboot and enjoy 🎊
