#!/bin/bash

if [ $# -eq 1 ]; then
    destination="$1"
else
    echo "Usage: $0 DESTINATION"
    exit 0
fi

echo "Installing Miniconda to: $destination"

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
bash ./miniconda.sh -b -p $destination/miniconda
rm ./miniconda.sh

echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.bashrc
echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.zshrc
