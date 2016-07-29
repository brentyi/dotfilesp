#!/bin/bash
#
# beaglebone setup script for embedded linux development
#
# installs:
#### stable kernel version
#### pin multiplexing tools
#### python&c++ libraries for interfacing with hardware
#
# this should be run as root
#

if [ $EUID != 0 ]; then
    echo "Beaglebone install must be run as root"
    exit 2
fi

ntpdate -su time.nist.gov

apt-get update
apt-get install linux-image-3.8.13-bone79
apt-get install libpcre3-dev cmake python-dev python-setuptools python-pip python-smbus swig -y

## user-friendly pinmux configuration
cd /opt/source
git clone https://github.com/cdsteinkuehler/beaglebone-universal-io
cd beaglebone-universal-io
cp config-pin /usr/bin/
chmod +x /usr/bin/config-pin

## install mraa from intel devkit
cd /opt/source
git clone https://github.com/intel-iot-devkit/mraa.git
mkdir mraa/build && cd $_
cmake .. -DCMAKE_BUILD_TYPE=DEBUG -DBUILDARCH=arm -DBUILDSWIGNODE=OFF
make
make install

cd /opt/source
echo "/usr/local/lib/arm-linux-gnueabihf/" >> /etc/ld.so.conf
ldconfig
echo "export PYTHONPATH=$PYTHONPATH:$(dirname $(find /usr/local -name mraa.py))" >> ~/.bashrc
cp mraa/build/examples/mraa-gpio /usr/bin/
chmod +x /usr/bin/mraa-gpio

## adafruit's beaglebone io library is super nice for prototyping
pip install Adafruit_BBIO

## ros-base
echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list
apt-get update
wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -O - | apt-key add -
apt-get install ros-indigo-ros-base ros-indigo-rosbridge-server python-rosdep -y
rosdep init
rosdep update

echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc
echo "source /opt/ros/indigo/setup.zsh" >> ~/.zshrc
