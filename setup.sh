#!/bin/bash

usage() {
    echo "Usage: $0 [-c] [-z] [-d] [-r] [-b]"
    echo -e "\t-c\tcommon utilities: vim, tmux, htop, python"
    echo -e "\t-z\tzsh"
    echo -e "\t-d\tdotfiles"
    echo -e "\t-r\tROS"
    echo -e "\t-b\tBeaglebone libraries"
}

valid=0
install_dotfiles=0
install_common=0
install_ros=0
install_beaglebone=0
install_zsh=0

while getopts czdrb flag; do
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
    b)
      valid=1
      install_beaglebone=1
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
if [[ $install_beaglebone = 1 ]]; then
    echo -e "\n---------"
    echo "Beaglebone-specific installations"
    echo "---------"
    bash scripts/install_beaglebone.sh
fi

echo ""

exit 0
