# GUIX stuff
source ~/.profile

GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"

GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"

# Auto-start sway on log-in
[ "$(tty)" = "/dev/tty1" ] && ~/.local/bin/sway-wrapper
