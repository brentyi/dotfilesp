#!/bin/bash

# set up zsh
if [[ `lsb_release -is` == "Ubuntu" ]]; then
    sudo apt-get install zsh -y
elif [[ `lsb_release -is` == "Fedora" ]]; then
    sudo dnf install zsh -y
fi
chsh -s /bin/zsh
