source ~/.zplug/init.zsh

# Let zplug manage itself
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# Basic auto/tab complete:
fpath+=("$HOME/.local/share/zsh/site-functions")
autoload -U compinit && compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
_comp_options+=(globdots)		# Include hidden files.

# plugins and themes
zplug "Aloxaf/fzf-tab"
zplug "unixorn/fzf-zsh-plugin"
zplug "djui/alias-tips"
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "plugins/git", from:oh-my-zsh
zplug "plugins/gitignore", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh
zplug "plugins/sudo", from:oh-my-zsh
zplug "plugins/virtualenvwrapper", from:oh-my-zsh
zplug "plugins/systemd", from:oh-my-zsh
zplug "plugins/docker", from:oh-my-zsh
zplug "plugins/docker-compose", from:oh-my-zsh
zplug "mfaerevaag/wd", as:command, use:"wd.sh", hook-load:"wd() { . $ZPLUG_REPOS/mfaerevaag/wd/wd.sh }"
zplug "spaceship-prompt/spaceship-prompt", use:spaceship.zsh, from:github, as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

setopt autocd  # cd w/out typing cd
setopt AUTO_PUSHD  # Make cd push the old directory onto the directory stack.
setopt PUSHD_MINUS # exchange the meanings of '+' and '-'
setopt CDABLE_VARS # expand the expression (allows 'cd -2/tmp')

# Disable compfix message
ZSH_DISABLE_COMPFIX="true"

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# emacs vterm integration
vterm_printf(){
    if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi

vterm_prompt_end() {
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

# start tmux on every shell login
# (https://wiki.archlinux.org/title/Tmux)
# if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ]; then
#     tmux attach || tmux >/dev/null 2>&1
# fi

#
# aliases
# 

alias python="python3"
alias e="$EDITOR"
alias f="fzf-tmux"
alias se="doasedit"
alias n="nvim"
alias v="vim"
alias t="trash"
alias ta='tail -f "$(ls -Art | tail -n 1)"'
alias lsg="ls -lHa | grep"
alias d="diff-sync-conflict"
alias r=". ranger"
alias f2="fail2ban-client"
alias m="man"
alias wg="wget"
alias fixmyaudio="scu-restart pipewire{,-pulse}.{socket,service}"
alias sl="sl -e"
alias to="tomb"
alias ns="nsxiv"
alias wh="which"
alias pnpm="corepack pnpm"
alias pn="corepack pnpm"
alias yarn="corepack yarn"

alias -g Y="| ydiff"
alias -g Ys="| ydiff -s"
alias -g C="| code-oss -"
alias -g L="| less"
alias -g LR="| less -R"
alias -g H="| head"
alias -g A="| as-tree"
alias -g N="EDITOR=nvim"
alias -g H="EDITOR=helix"

setmp3artfromurl () { mid3v2 -p <(curl "$1") $2 }
ydiff-sync-conflict () { diff-sync-conflict -u "$1" | ydiff -s }
sway-get-tree () { swaymsg -t get_tree | jq -Cr "$1" | less -R }

# beet
alias be="beet"
alias bi="beet imp"
alias big="beet imp --group-albums"
alias bil="beet imp -Lt"
alias brm="beet rm -ad"

# chezmoi
alias c="chezmoi"
alias ca="chezmoi apply"
alias cs="chezmoi status"
alias ce="chezmoi edit --apply"
alias cdi="chezmoi diff"
alias cg="chezmoi git"
alias cgs="chezmoi git status"
alias cgd="chezmoi git diff"
alias cga="chezmoi git add"
alias cgc="chezmoi git commit --"
alias cgp="chezmoi git push"
cfz () {
  fzf_command=("fzf")
  if [ -n "$1" ]; then
    fzf_command=($fzf_command "--query=$1" "-1")
  fi

  file_path=$(chezmoi managed --include=files | ${fzf_command[@]})
  if [ -z "$file_path" ]; then
    >&2 echo "No file selected"
  else
	print -s "chezmoi edit --apply \"~/$file_path\""
	chezmoi edit --apply "~/$file_path"
  fi
}

# pass
alias pg="pass git"
alias pge="pass generate"
alias po="pass otp"
alias pe="pass edit"
alias pa="pass"

# lsd
alias l='ls'

# bat & bat-integrated cmds
alias b="bat"
alias -g B="| bat"
alias mb="batman"
alias grb="batgrep"
alias fzfb="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
hb () { "$@" --help 2>&1 | bat --plain  --language=help }
fdb () { fd "$1" -X bat }
tb () { tail -f $1 | bat --paging=never -l log }

# filetags
alias ft="filetags"
alias ftt="filetags --tags"
alias ftT="filetags --tags $(basename "$PWD") ./*"
alias ftr="filetags --remove"
alias fts="filetags --recursive --tagtrees --filebrowser qimgv"

# ytdl
alias yd="yt-dlp -o '%(title)s.%(ext)s'"
alias yda="yt-dlp --embed-metadata -f ba -x --audio-quality 0 -o '%(title)s.%(ext)s' --audio-format mp3"
alias ydap="yt-dlp --embed-metadata -f ba -x --audio-quality 0 -o '%(playlist)s/%(playlist_index)s %(title)s.%(ext)s' --audio-format mp3"

# spotdl
alias sd="spotdl"

# curl
alias co="curl -O"
alias coj="curl -OJ"
alias cf="xargs -n 1 curl -O <"  # curl from list of urls in file

# systemctl
alias sc="systemctl"
alias scu="systemctl --user"

# wd
alias wda="wd add"

# helix
alias he="helix"

# wget
wo () { wget "$1" -O "$2" }
wp () { wget "$1" -P "$2" }

lfcd () {
    tmp="$(mktemp)"
    fid="$(mktemp)"
    lf -command '$printf $id > '"$fid"'' -last-dir-path="$tmp" "$@"
    id="$(cat "$fid")"
    archivemount_dir="/tmp/__lf_archivemount_$id"
    if [ -f "$archivemount_dir" ]; then
        cat "$archivemount_dir" | \
            while read -r line; do
                sudo umount "$line"
                rmdir "$line"
            done
        rm -f "$archivemount_dir"
    fi
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        if [ -d "$dir" ]; then
            if [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
            fi
        fi
    fi
}

# LaTeX
alias lm="latexmk -pvc -pdf -synctex=1"

# instaloader
alias il="instaloader --fast-update --stories --highlights --igtv --dirname-pattern=instaloader profile"

# gopass
alias gop="gopass"

# lazydocker
alias lzs="lazydocker"

# gallery-dl
alias gdl="gallery-dl"

# wl-clipboard
alias wlc="wl-copy"
alias wlp="wl-paste"

# paru
alias pa="paru"
par () {
    paru -Qq | fzf -q "$1" -m --preview 'paru -Qi {1}' | xargs -ro paru -Rns
}
pai () {
    paru -Slq | fzf -q "$1" -m --preview 'paru -Si {1}'| xargs -ro paru -S
}

# GNU core
# fkill() {
#     local pid
#     if [ "$UID" != "0" ]; then
#         pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
#     else
#         pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
#     fi  
# 
#     if [ "x$pid" != "x" ]
#     then
#         echo $pid | xargs kill -${1:-9}
#     fi  
# }

alias kg9="killall -g -9"

# networking
alias port="sudo netstat -lntup | grep"

# guix
alias gu="guix"
alias gui="guix install"
alias gur="guix remove"
alias gus="guix search"
alias guss="guix package -I"

# flatpak
alias fp="flatpak"

alias we="~/node_modules/web-ext/bin/web-ext.js"

# npm
alias nrb="npm run build"
alias nrd="npm run dev"

# nmcli
alias nmc="nmcli"
alias nmccu="nmcli conn up"
alias nmccd="nmcli conn down"

# git
alias gsync="git pull --rebase && git push"
alias gcm="git commit -m"

# herd
alias he="herd"
alias hes="herd start"
alias hep="herd stop"

# aliases
alias ag="alias | grep"

# rclone
alias pcloud="rclone mount pcloud: ~/pcloud"

#
# bindings
#
bindkey -v

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# file explorer
bindkey -s '^o' 'lfcd\n'

# editing
# autoload edit-command-line
# zle -N edit-command-line
# bindkey -e '^x^e' edit-command-line

# autosuggestions
bindkey '^ ' autosuggest-accept

# zoxide
eval "$(zoxide init zsh)"

# art
FORTUNE=$(DAIKICHI_FORTUNE_PATH=$HOME/.local/share/fortunes fortune)
cbonsai -p -m "$FORTUNE"
# cbonsai -p -m "hello."
