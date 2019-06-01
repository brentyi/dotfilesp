#!/bin/bash

if [[ `lsb_release -rs` == "14.04" ]]; then # indigo
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    # sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 0xB01FA116
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install ros-indigo-desktop-full -y
    sudo rosdep init
    rosdep update

    echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
    echo "source /opt/ros/indigo/setup.zsh" >> ~/.zshrc

elif [[ `lsb_release -rs` == "16.04" ]]; then # kinetic
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install ros-kinetic-desktop-full -y
    sudo rosdep init
    rosdep update

    echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
    echo "source /opt/ros/kinetic/setup.zsh" >> ~/.zshrc

elif [[ `lsb_release -rs` == "18.04" ]]; then # melodic
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install ros-melodic-desktop-full -y
    sudo rosdep init
    rosdep update

    echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
    echo "source /opt/ros/melodic/setup.zsh" >> ~/.zshrc
fi
