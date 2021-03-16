#!/bin/bash

if [[ `lsb_release -is` == "Ubuntu" ]]; then
    # update repositories
    sudo apt update

    # python stuff
    # sudo apt install python-dev python-pip python3-dev python3-pip -y
    # sudo pip2 install --upgrade pip
    # sudo pip3 install --upgrade pip

    # install common utilities
    sudo apt install neovim ctags tmux htop build-essential xclip bc silversearcher-ag curl -y

elif [[ `lsb_release -is` == "Fedora" ]]; then
    # install common utilities
    sudo dnf install neovim ctags tmux htop xclip the_silver_searcher -y
fi
