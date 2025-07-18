# GUIX stuff
source ~/.profile

GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"

GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"

# Auto-start WM on log-in
[ "$(tty)" = "/dev/tty1" ] && niri

# nix
source /run/current-system/profile/etc/profile.d/nix.sh
