# sway stuff
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# GPG on TTY stuff
export GPG_TTY=$(tty)

# GUIX stuff
source ~/.profile

GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"

GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"

# fcitx input method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT4_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export INPUT_METHOD=fcitx
export XMODIFIERS=@im=fcitx
export GLFW_IM_MODULE=ibus

# openai
export OPENAI_API_KEY=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

# fixes Python Poetry as per https://github.com/python-poetry/poetry/issues/3365#issuecomment-1720309294
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

