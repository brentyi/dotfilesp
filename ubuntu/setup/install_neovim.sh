#!/bin/bash

wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage
sudo chmod +x nvim.appimage
sudo mv nvim.appimage /usr/bin/nvim
sudo apt-get install fuse libfuse2
