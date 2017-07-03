#!/bin/bash

# update repositories
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update

# python stuff
sudo apt-get install python-dev python-pip python3-dev python3-pip -y
sudo pip2 install --upgrade pip
sudo pip3 install --upgrade pip

# install common utilities
sudo apt-get install tmux htop build-essential xclip -y
sudo apt-get install neovim -y
sudo pip2 install neovim
sudo pip3 install neovim

# set up zsh
sudo apt-get install zsh -y
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh
