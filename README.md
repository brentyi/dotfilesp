# Dotfiles+other useful things

A collection of config files & setup scripts.

## Setup

Install scripts rely on `apt`. After cloning to `$HOME/dotfilesp`:

```
Usage: ./setup.sh [-c] [-z] [-d] [-r] [-g] [-b] [-m] [-y] [-n] [-v] [-N] [-l] [-j] [-p]
        -c      common utilities: neovim, ctags, tmux, htop, xclip, ag, ...
        -z      zsh
        -d      dotfiles
        -r      ROS
        -g      Google Chrome
        -b      Beaglebone libraries
        -m      Miniconda (or Miniforge)
        -y      Yarn (+nodejs)
        -n      NPM (+nodejs)
        -v      Vim (from PPA)
        -N      Neovim (unstable, from PPA)
        -l      golang (1.17.1)
        -j      Jekyll + Ruby
        -p      Pipewire (replaces pulseaudio, from PPA)
```

## Symlink structure

Manual installation of dotfiles is possible by copying from
[./common/](./common/). Alternatively, the `-d` flag runs `setup/linker.sh`,
which establishes a symlink-based structure with an explicit local/global split.

Linking goes something like this:

1. `setup/linker.sh` is run from `setup.sh`
2. Current configuration files (if they exist) are moved to a timestamped
   directory in `~/dotfilesp/backup/`
3. A copy of `~/dotfilesp/template/` is made to `~/dotfilesp/local/`
   - These are mostly one-line config files that source the "real" settings
     stored in `~/dotfilesp/common/`
4. Symlinks are made to `~/dotfilesp/local/*` from the home directory

Explicitly local changes (usually workspace+environment stuff) can then be made
in `~/dotfilesp/local`, while global ones are tracked in `~/dotfilesp/common`.
