#!/bin/bash

wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.appimage -O nvim.appimage
sudo chmod +x nvim.appimage
sudo mv nvim.appimage /usr/bin/nvim
sudo apt-get install fuse libfuse2
