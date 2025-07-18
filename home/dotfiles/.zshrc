# plugin management
source $HOME/.antidote/antidote.zsh
antidote load ${ZDOTDIR:-$HOME}/.zsh_plugins.txt

# configure history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

#
# aliases
#

alias python="python3"
alias e="emacsclient -t"
alias n="hx"
alias v="hx"

sway-get-tree () { swaymsg -t get_tree | jq -Cr "$1" | less -R }

# resume stuff
alias copy-resume="cat $HOME/src/resume/src/base.yaml | wl-copy"
resume() {
    cd $HOME/src/resume/src
    rendercv render "$1".yaml
    zathura $(ls -t rendercv_output/*.pdf | head -n 1) & rendercv render --watch "$1".yaml
}

# eza
alias l='eza -la'

# filetags
alias ft="filetags"
alias ftt="filetags --tags"
alias ftT="filetags --tags $(basename "$PWD") ./*"
alias ftr="filetags --remove"
alias fts="filetags --recursive --tagtrees --filebrowser qimgv"

# guix
alias gu="guix"
alias gui="guix install"
alias gur="guix remove"
alias gus="guix search"
alias guss="guix package -I"
alias dev-container="guix shell -C -F -N python-wrapper texlive openssl node poetry coreutils gcc-toolchain git -D ungoogled-chromium --share=/home/ben --preserve='^DISPLAY$' --preserve='^XAUTHORITY$' --preserve='^PATH$' --share=/etc/machine-id"
real () {
    realpath $(wh $1)
}

# flatpak
alias fp="flatpak"


# nmcli
alias nmc="nmcli"
alias nmccu="nmcli conn up"
alias nmccd="nmcli conn down"

# bluetooth
alias bl="bluetoothctl"

#
#
#

#
# bindings
#

# copilot
bindkey '^[|' zsh_gh_copilot_explain  # bind Alt+shift+\ to explain
bindkey '^[\' zsh_gh_copilot_suggest  # bind Alt+\ to suggest

# autosuggestions
bindkey '^ ' autosuggest-accept

#
#
#

# zoxide
eval "$(zoxide init zsh)"

