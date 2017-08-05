#
# brent yi
#

echo '>>>>>>>>>>'

export LANG=en_US.UTF-8
if [ -z "$HOME" ]; then
    export HOME=/home/brent
fi

source $HOME/dotfilesp/thirdparty/antigen.zsh
antigen use oh-my-zsh
antigen bundle git
antigen bundle vi-mode
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle history-substring-search
antigen theme brentyi/brent-zsh-theme brent
antigen bundle brentyi/zsh-ros
antigen apply

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
MODE_INDICATOR="%F{black}%K{white} <<< %k%f"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
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
function u() {
    cd ~/dotfilesp
    if [[ -z $(git status -s) ]]; then
        echo "Updating dotfiles"
        echo "----------"
        git pull
        git submodule update --init --recursive
        vim +PluginInstall +qall
        rm -rf ~/.antigen
        # cleanup
        if [ -d "~/.oh-my-zsh" ]; then
          rm -rf ~/.oh-my-zsh
        fi
        source ~/.zshrc
    else
        echo "Unstaged changes in dotfiles directory; please commit or stash them"
    fi
    cd - > /dev/null
}

bindkey -M viins '[[' vi-cmd-mode
bindkey -M viins ';;' vi-cmd-mode

setopt transientrprompt

if [ -n "$SSH_CONNECTION" ]; then
    echo "SSH CONNECTION"
elif [ "${TMUX+set}" ]; then
    echo "----------"
else
    # open tmux by default
    tmux -2
    echo "Exiting... (ENTER to cancel)"
    read -t 0.2 || exit
fi

