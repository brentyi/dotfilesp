#!/bin/bash

# Create system-specific config
if [ ! -d "$HOME/dotfilesp/local" ]; then
    echo -n "Creating local directory... "
    cp -rf ~/dotfilesp/template ~/dotfilesp/local
    echo "DONE"
else
    echo "Local directory already exists"
fi

# Create symlinks to version-controlled dotfiles, and back up current ones
echo -n "Linking dotfiles... "
backup_dir=$HOME/dotfilesp/backup/$(date '+%Y_%m_%d__%H_%M_%S')/
mkdir -p $backup_dir
ln -sfb --suffix=.bak ~/dotfilesp/local/.[^.]* $HOME/
mv $HOME/.*.bak $backup_dir
echo "DONE"

# Link neovim config to standard vimrc location
echo -n "Linking nvim config... "
mkdir -p ~/.config/nvim
ln -sf ~/dotfilesp/common/init.lua ~/.config/nvim/init.lua
# echo "DONE"

# Install plugins
echo -n "Setting up plugins... "
nvim +PlugUpdate +qall
echo "DONE"
