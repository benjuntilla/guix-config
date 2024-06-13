# Ben's Guix Configuration
This is my entire system. Packages and configuration are managed in a
purely functional manner.

## Installation
This is a bit of an involved process; a convenient shell script should
streamline this process.

- Create initial installation of GUIX using [System Crafter's
  tutorial](https://systemcrafters.net/craft-your-system-with-guix/full-system-install/)
  - Stop before the "Saving your configuration" section
- Log into the new installation, and clone this repository
- Copy a system definition in `./systems` that you want to base your
  new system off of into `./systems/$SYSTEM_NAME.scm` (new
  definition), and open `/etc/config.scm` (old definition)
  - Doing this with a split neovim instance is helpful
  - Copy UUIDs within the `file-systems` value from the old
    definition to the new definition
  - Copy the `host-name` value from the old definition to the new
    definition
  - Copy the `users` value from the old definition to the new
    definition
- Copy the channels definition used for installation into your home with
```sh
mkdir -p ~/.config/guix; cp /etc/channels.scm ~/.config/guix
```
- Remove pins on channels by deleting all lines in
  `~/.config/guix/channels.scm` containing `(commit ...)`
- Update system with
```sh
guix pull
```
- Ensure you follow the subsequent instructions describing how to set
`GUIX_PROFILE` and source the profile, and then run
```sh
guix hash
```
- Configure system with 
```sh
sudo guix system reconfigure ./system/$SYSTEM_NAME.scm; guix home reconfigure ./home/home.scm
```
- Export installed packages on old machine into a manifest with
```sh
guix package --export-manifest > manifest.scm
```
- Then, install the packages using the manifest on your new machine with
```sh
guix package -m manifest.scm
```
- Reboot and enjoy 🎊
