#!/bin/bash

sudo apt-key del 421C365BD9FF1F717815A3895523BAEEB01FA116
wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | sudo apt-key add -
