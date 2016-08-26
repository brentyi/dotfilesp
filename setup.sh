#!/bin/bash

usage() {
    echo "Usage: $0 [-d | -s | -r | -b]"
    echo -e "\t-d\tdotfiles only"
    echo -e "\t-s\tstandard install: common utilities + dotfiles"
    echo -e "\t-r\tstandard install w/ ros"
    echo -e "\t-b\tbeaglebone-specific install (run as root)"
}

valid=0
install_dotfiles=0
install_basic=0
install_ros=0
install_beaglebone=0

while getopts dsrb flag; do
  case $flag in
    d)
      valid=1
      install_dotfiles=1
      ;;
    s)
      valid=1
      install_dotfiles=1
      install_basic=1
      ;;
    r)
      valid=1
      install_dotfiles=1
      install_basic=1
      install_ros=1
      ;;
    b)
      valid=1
      install_dotfiles=1
      install_basic=1
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

if [[ $install_basic = 1 ]]; then
    echo -e "\n---------"
    echo "Installing basic utilities"
    echo "---------"
    bash scripts/install_basic.sh
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
