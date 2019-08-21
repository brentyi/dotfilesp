#!/bin/bash

# update repositories
sudo apt-get update

# python stuff
sudo apt-get install python-dev python-pip python3-dev python3-pip -y
sudo pip2 install --upgrade pip
sudo pip3 install --upgrade pip

# install common utilities
sudo apt-get install vim ctags tmux htop build-essential xclip bc -y
