export LANG=en_US.UTF-8
if [ -z "$HOME" ]; then
    export HOME=/home/brent
fi

# Clone antidote if necessary.
[[ -e ${ZDOTDIR:-~}/.antidote ]] ||
  git clone https://github.com/mattmc3/antidote.git ${ZDOTDIR:-~}/.antidote

# Source antidote.
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# Initialize antidote's dynamic mode, which changes `antidote bundle`
# from static mode.
source <(antidote init)

# Plugins. (dynamically loading them here is slower, but keeps our zshrc self-contained)
antidote bundle robbyrussell/oh-my-zsh
antidote bundle ohmyzsh/ohmyzsh path:plugins/git
antidote bundle ohmyzsh/ohmyzsh path:plugins/vi-mode
antidote bundle ohmyzsh/ohmyzsh path:plugins/history-substring-search
antidote bundle ohmyzsh/ohmyzsh path:plugins/history-substring-search
antidote bundle zsh-users/zsh-autosuggestions
antidote bundle brentyi/brent-zsh-theme

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
MODE_INDICATOR="%F{black}%K{white} <<< %k%f"
DISABLE_AUTO_TITLE="true"
export EDITOR='vim'

if [ -x "$(command -v nvim)" ]; then
    alias vim="nvim"
fi
alias tmux="tmux -2"
alias rosmaster="rosmasteruri"
alias s="source ~/.zshrc"
alias v="vim ~/.vimrc"
alias t="vim ~/.tmux.conf"
alias z="vim ~/.zshrc"
alias sudo="sudo "
alias :q="exit"
alias :e="vim"

tmux_renumber() {
    sessions=$(tmux ls | cut -f1 -d':')

    total=$(($(echo $sessions | wc -l) - 1))
    new=0
    while read -r old
    do
        tmux rename -t $old $new/$total
        ((new++))
    done <<< "$sessions"
}

bindkey -M viins '[[' vi-cmd-mode
bindkey -M viins ';;' vi-cmd-mode

setopt transientrprompt

if [ -n "$SSH_CONNECTION" ]; then
    echo "SSH CONNECTION"
elif [ "${TMUX+set}" ]; then
    echo "----------"
    tmux_renumber
else
    # open tmux by default
    tmux -2
    echo "Exiting... (ENTER to cancel)"
    read -t 0.2 || exit
fi

