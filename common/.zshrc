#
# brent yi
#

export LANG=en_US.UTF-8

echo '>>>>>>>>>>'

export HOME=/home/brent
export ZSH=$HOME/.oh-my-zsh
export UPDATE_ZSH_DAYS=30

ZSH_THEME="sunaku"
plugins=(git vi-mode vundle history-substring-search)

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM=$ZSH/custom
MODE_INDICATOR="%K{magenta} %k%F{white}%K{black}    VI %k%f"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
source $ZSH/oh-my-zsh.sh
export EDITOR='vim'

alias tmux="tmux -2"
alias vim="nvim"

if [[ -n $SSH_CONNECTION ]]; then
    echo 'SSH CONNECTION'
elif [ "${TMUX+set}" ]; then
    echo '----------'
else
    tmux
    exit
fi
