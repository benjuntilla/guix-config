# -*- mode: sh -*-

export PNPM_HOME=~/.pnpm
export PATH=$PNPM_HOME:~/.bun/bin:~/.sst/bin:~/.config/emacs-doom/bin:~/.local/share/gem/ruby/2.0.0/bin:~/.config/rofi/bin:~/go/bin:~/.dotnet/tools:~/.cargo/bin:~/.local/bin:$PATH
export TERMCMD="wezterm start"
export TERMINAL="wezterm"
export EDITOR="nvim"
export PAGER="less -R"
export BROWSER="firefox"
export GDK_BACKEND="wayland"
export ALTERNATE_EDITOR=nvim
export SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS=0
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export XDG_SCREENSHOTS_DIR=~/Downloads
export XDG_DESKTOP_DIR=~/Downloads/Desktop
export XDG_DATA_DIRS=/var/lib/flatpak/exports/share:/home/ben/.local/share/flatpak/exports/share:$XDG_DATA_DIRS
export GOPATH=~/.local/share/go
export DELTA_FEATURES=side-by-side
export LEDGER_FILE=~/org/.hledger.journal

# https://wiki.archlinux.org/title/Unreal_Engine_4#Loading_times
export GLIBC_TUNABLES=glibc.rtld.dynamic_sort=2

# this is where the juicy secrets are...
source ~/.env.local

# aws-vault config
export AWS_VAULT_BACKEND="pass"
export AWS_VAULT_PASS_PREFIX="aws-vault/"

# fixes Python Poetry as per https://github.com/python-poetry/poetry/issues/3365#issuecomment-1720309294
export PYTHON_KEYRING_BACKEND=keyring.backends.null.Keyring

# fcitx input method
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export QT4_IM_MODULE=fcitx
export SDL_IM_MODULE=fcitx
export INPUT_METHOD=fcitx
export XMODIFIERS=@im=fcitx
export GLFW_IM_MODULE=ibus

# GPG on TTY stuff
export GPG_TTY=$(tty)
