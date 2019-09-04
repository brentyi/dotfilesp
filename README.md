# Dotfiles+other useful things
A collection of config files & setup scripts

## Setup
Cloned to `$HOME/dotfilesp`:
```
Usage: ./setup.sh [-c] [-z] [-d] [-r] [-g] [-b]
        -c      common utilities: vim, tmux, htop, python
        -z      zsh
        -d      dotfiles
        -r      ROS (Indigo/Kinetic)
        -g      Google Chrome
        -b      Beaglebone libraries
        -m      Miniconda
```

## Structure
Dotfile linking is handled by `scripts/linker.sh`, which is set up to enable persistent system-specific configuration overrides without affecting working tree status for shared settings (no messy merging!).

Linking goes something like this:

1. `scripts/linker.sh` is run from `setup.sh`
2. Current configuration files (if they exist) are moved to a timestamped directory in `~/dotfilesp/backup/`
3. A copy of `~/dotfilesp/template/` is made to `~/dotfilesp/local/`
    - these are mostly one-line config files that source the "real" settings stored in `~/dotfilesp/common/`
4. Symlinks are made to `~/dotfilesp/local/*` from the home directory

Explicitly local changes (usually workspace+environment stuff) can then be made in `~/dotfilesp/local`, while global ones are tracked in `~/dotfilesp/common`.
