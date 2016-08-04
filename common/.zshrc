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
export UPDATE_ZSH_DAYS=30

ZSH_THEME="sunaku"
plugins=(git vi-mode vundle history-substring-search)

HYPHEN_INSENSITIVE="true"
COMPLETION_WAITING_DOTS="true"
DISABLE_UNTRACKED_FILES_DIRTY="false"
HIST_STAMPS="yyyy-mm-dd"
ZSH_CUSTOM=$ZSH/custom
MODE_INDICATOR="%F{black}%K{white} VI %k%f"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"
source $ZSH/oh-my-zsh.sh
export EDITOR='vim'

alias tmux="tmux -2"
alias vim="nvim"
alias rosmaster="rosmasteruri"
alias s="source ~/.zshrc"

function ssh_indicator() {
    if [ -n "$SSH_CONNECTION" ]; then
        echo "%K{cyan} $USER@$HOST %k"
    fi
}
function ros_info() {
    if [ -n "$ROS_MASTER_URI" ] && [ "$ROS_MASTER_URI" != "http://$ROS_IP:11311" ]; then
        echo "%K{red} $ROS_MASTER_URI %k"
    fi
}
function rosmasteruri() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: $0 [master_ip] [interface]";
        return 2
    fi

    unset ROS_HOSTNAME;
    export ROS_MASTER_URI=http://"$1":11311;
    export ROS_IP=`getip $2`

    echo unset ROS_HOSTNAME;
    echo ROS_MASTER_URI=$ROS_MASTER_URI
    echo ROS_IP=$ROS_IP

}
function getip() {
    if [ "$#" -ne 1 ]; then
        echo "Usage: $0 [interface]";
        return 2
    fi

    if [[ "$OSTYPE" =~ ^darwin ]]; then
        echo `ipconfig getifaddr "$1"`
    else
        echo `ifconfig "$1" | awk '/inet/ { print $2 } ' | sed -e s/addr://`
    fi
}
RPROMPT=$RPROMPT'$(ssh_indicator)$(ros_info)'
