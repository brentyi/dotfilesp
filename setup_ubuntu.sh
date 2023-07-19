#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-z] [-d] [-r] [-g] [-b] [-m] [-y] [-n] [-v] [-N] [-l] [-j] [-p]"
    echo -e "\t-c\tcommon utilities: neovim, ctags, tmux, htop, xclip, ag, ..."
    echo -e "\t-z\tzsh"
    echo -e "\t-d\tdotfiles"
    echo -e "\t-r\tROS"
    echo -e "\t-g\tGoogle Chrome"
    echo -e "\t-b\tBeaglebone libraries"
    echo -e "\t-m\tMiniconda (or Miniforge)"
    echo -e "\t-y\tYarn (+nodejs)"
    echo -e "\t-n\tNPM (+nodejs)"
    echo -e "\t-v\tVim (from PPA)"
    echo -e "\t-N\tNeovim"
    echo -e "\t-l\tgolang (1.17.1)"
    echo -e "\t-j\tJekyll + Ruby"
    echo -e "\t-p\tPipewire (replaces pulseaudio, from PPA)"
}

valid=0
install_dotfiles=0
install_common=0
install_ros=0
install_chrome=0
install_beaglebone=0
install_zsh=0
install_miniconda=0
install_yarn=0
install_npm=0
install_vim_ppa=0
install_neovim_unstable=0
install_golang=0
install_jekyll=0
install_pipewire=0

while getopts czdrgbmynvNljp flag; do
  case $flag in
    c)
      valid=1
      install_common=1
      ;;
    z)
      valid=1
      install_zsh=1
    ;;
    d)
      valid=1
      install_dotfiles=1
      ;;
    r)
      valid=1
      install_ros=1
      ;;
    g)
      valid=1
      install_chrome=1
      ;;
    b)
      valid=1
      install_beaglebone=1
      ;;
    m)
      valid=1
      install_miniconda=1
      ;;
    y)
      valid=1
      install_yarn=1
      ;;
    n)
      valid=1
      install_npm=1
      ;;
    v)
      valid=1
      install_vim_ppa=1
      ;;
    N)
      valid=1
      install_neovim=1
      ;;
    l)
      valid=1
      install_golang=1
      ;;
    j)
      valid=1
      install_jekyll=1
      ;;
    p)
      valid=1
      install_pipewire=1
      ;;
    ?)
      valid=0
      ;;
  esac
done
shift $(( OPTIND - 1 ));

if [[ $valid = 0 ]]; then
    usage
    exit 2
fi

sudo -v

if [[ $install_common = 1 ]]; then
    echo -e "\n---------"
    echo "Installing common utilities"
    echo "---------"
    bash ubuntu/setup/install_common.sh
fi

if [[ $install_zsh = 1 ]]; then
    echo -e "\n---------"
    echo "Installing ZSH"
    echo "---------"
    bash ubuntu/setup/install_zsh.sh
fi

if [[ $install_dotfiles = 1 ]]; then
    echo -e "\n---------"
    echo "Linking dotfiles"
    echo "---------"
    bash ubuntu/setup/linker.sh
fi

if [[ $install_ros = 1 ]]; then
    echo -e "\n---------"
    echo "Installing ROS"
    echo "---------"
    bash ubuntu/setup/install_ros_desktop.sh
fi

if [[ $install_chrome = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Chrome"
    echo "---------"
    bash ubuntu/setup/install_chrome.sh
fi

if [[ $install_beaglebone = 1 ]]; then
    echo -e "\n---------"
    echo "Beaglebone-specific installations"
    echo "---------"
    bash ubuntu/setup/install_beaglebone.sh
fi

if [[ $install_miniconda = 1 ]]; then
    echo -e "\n---------"
    echo "Miniconda"
    echo "---------"
    bash ubuntu/setup/install_miniconda.sh $HOME
fi

if [[ $install_yarn = 1 ]]; then
    echo -e "\n---------"
    echo "Yarn"
    echo "---------"
    bash ubuntu/setup/install_yarn.sh
fi

if [[ $install_npm = 1 ]]; then
    echo -e "\n---------"
    echo "NPM"
    echo "---------"
    bash ubuntu/setup/install_npm.sh
fi

if [[ $install_vim_ppa = 1 ]]; then
    echo -e "\n---------"
    echo "Vim (from PPA)"
    echo "---------"
    bash ubuntu/setup/install_vim_ppa.sh
fi

if [[ $install_neovim = 1 ]]; then
    echo -e "\n---------"
    echo "Neovim"
    echo "---------"
    bash ubuntu/setup/install_neovim.sh
fi

if [[ $install_golang = 1 ]]; then
    echo -e "\n---------"
    echo "Golang"
    echo "---------"
    bash ubuntu/setup/install_golang.sh
fi

if [[ $install_jekyll = 1 ]]; then
    echo -e "\n---------"
    echo "Jekyll"
    echo "---------"
    bash ubuntu/setup/install_jekyll.sh
fi

if [[ $install_pipewire = 1 ]]; then
    echo -e "\n---------"
    echo "Pipewire"
    echo "---------"
    bash ubuntu/setup/install_pipewire.sh
fi

echo ""

exit 0
