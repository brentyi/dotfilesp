# Dotfiles+other useful things
My collection of config files & setup scripts.

## Setup
Clone this repo to your home directory & run `./setup.sh`:
```
Usage: ./setup.sh [-d | -s | -r | -b]
        -d      dotfiles only: config files for zsh, bash, vim, tmux, & git
        -s      standard install: dotfiles + common tools
        -r      standard install + ros (indigo only)
        -b      embedded install (currently optimized for beaglebone, run as root)
```

## Structure
Dotfile linking is handled by `scripts/linker.sh`, which is set up to enable persistent system-specific configuration overrides without affecting working tree status or version control for shared settings (no messy merging!).

Linking goes something like this:

1. `scripts/linker.sh` is run from `setup.sh`
2. Current configuration files (if they exist) are moved to a timestamped directory in `~/dotfilesp/backup/`
3. A copy of `~/dotfilesp/template/` is made to `~/dotfilesp/local/`
 - these are mostly one-line config files that source the "real" settings stored in `~/dotfilesp/common/`
4. Symlinks are made to `~/dotfilesp/local/*` from the home directory

Explicitly local changes (usually workspace+environment stuff) can then be made in `~/dotfilesp/local`, while global ones are tracked in `~/dotfilesp/common`.

--
ROS macros for zsh ~~inspired by~~ stolen & repackaged from [Mike Chung's bash setup](http://github.com/mjyc/dotfiles).
