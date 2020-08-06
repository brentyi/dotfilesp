#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-z] [-d] [-r] [-g] [-b] [-m] [-y] [-v] [-l]"
    echo -e "\t-c\tcommon utilities: vim, tmux, htop, python"
    echo -e "\t-z\tzsh"
    echo -e "\t-d\tdotfiles"
    echo -e "\t-r\tROS"
    echo -e "\t-g\tGoogle Chrome"
    echo -e "\t-b\tBeaglebone libraries"
    echo -e "\t-m\tMiniconda"
    echo -e "\t-y\tYarn (+nodejs)"
    echo -e "\t-v\tVim (from PPA)"
    echo -e "\t-l\tgolang (1.14.6)"
}

valid=0
install_dotfiles=0
install_common=0
install_ros=0
install_chrome=0
install_beaglebone=0
install_zsh=0
install_miniconda=0
install_vim_ppa=0
install_golang=0

while getopts czdrgbmyv flag; do
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
    v)
      valid=1
      install_vim_ppa=1
      ;;
    v)
      valid=1
      install_golang=1
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
    bash scripts/install_common.sh
fi

if [[ $install_zsh = 1 ]]; then
    echo -e "\n---------"
    echo "Installing ZSH"
    echo "---------"
    bash scripts/install_zsh.sh
fi

if [[ $install_dotfiles = 1 ]]; then
    echo -e "\n---------"
    echo "Linking dotfiles"
    echo "---------"
    bash scripts/linker.sh
fi

if [[ $install_ros = 1 ]]; then
    echo -e "\n---------"
    echo "Installing ROS"
    echo "---------"
    bash scripts/install_ros_desktop.sh
fi

if [[ $install_chrome = 1 ]]; then
    echo -e "\n---------"
    echo "Installing Chrome"
    echo "---------"
    bash scripts/install_chrome.sh
fi

if [[ $install_beaglebone = 1 ]]; then
    echo -e "\n---------"
    echo "Beaglebone-specific installations"
    echo "---------"
    bash scripts/install_beaglebone.sh
fi

if [[ $install_miniconda = 1 ]]; then
    echo -e "\n---------"
    echo "Miniconda"
    echo "---------"
    bash scripts/install_miniconda.sh $HOME
fi

if [[ $install_yarn = 1 ]]; then
    echo -e "\n---------"
    echo "Yarn"
    echo "---------"
    bash scripts/install_yarn.sh
fi

if [[ $install_vim_ppa = 1 ]]; then
    echo -e "\n---------"
    echo "Vim (from PPA)"
    echo "---------"
    bash scripts/install_vim_ppa.sh
fi

if [[ $install_golang = 1 ]]; then
    echo -e "\n---------"
    echo "Golang"
    echo "---------"
    bash scripts/install_golang.sh
fi

echo ""

exit 0
