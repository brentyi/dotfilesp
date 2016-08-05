#
# brent yi
#

echo '>>>>>>>>>>'
if [ -n "$SSH_CONNECTION" ]; then
    echo 'SSH CONNECTION'
elif [ "${TMUX+set}" ]; then
    echo '----------'
else
    # open tmux by default
    tmux -2
    exit
fi

#

export LANG=en_US.UTF-8

export HOME=/home/brent
export ZSH=$HOME/.oh-my-zsh
export ZSH_CUSTOM=$HOME/dotfilesp/common/zsh_custom
export UPDATE_ZSH_DAYS=30

ZSH_THEME="brent"
plugins=(ros git vi-mode vundle history-substring-search)

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
MODE_INDICATOR="%F{black}%K{white} VI %k%f"

unset RPROMPT

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
export EDITOR='vim'

alias tmux="tmux -2"
alias vim="nvim"
alias rosmaster="rosmasteruri"
alias s="source ~/.zshrc"
alias v="vim ~/.vimrc"
alias t="vim ~/.tmux.conf"
alias z="vim ~/.zshrc"

source $ZSH/oh-my-zsh.sh
