#!/bin/bash

# This is a lighter version of linker.sh.

# Append source file to target file only if content isn't already present
append_if_missing() {
    local source_file="$1"
    local target_file="$2"

    if ! grep -qF "$(cat "$source_file")" "$target_file" 2>/dev/null; then
        echo "Appending $source_file to $target_file"
        cat "$source_file" >> "$target_file"
    else
        echo "Content from $source_file already exists in $target_file, skipping"
    fi
}

mkdir -p ~/.config/nvim
ln -sf $HOME/dotfilesp/common/init.lua ~/.config/nvim/init.lua

append_if_missing ~/dotfilesp/template/.zshrc ~/.zshrc
append_if_missing ~/dotfilesp/template/.tmux.conf ~/.tmux.conf
append_if_missing ~/dotfilesp/template/.gitconfig ~/.gitconfig
