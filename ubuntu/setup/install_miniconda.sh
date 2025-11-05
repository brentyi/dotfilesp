#!/bin/bash

if [ $# -eq 1 ]; then
    destination="$1"
else
    echo "Usage: $0 DESTINATION"
    exit 0
fi


if [[ `uname -m` == "aarch64" ]]; then # Miniforge
    echo "Installing Miniforge to: $destination"

    wget https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh -O ./install_conda.sh
    bash ./install_conda.sh -b -p $destination/miniforge

    echo "PATH=\$PATH:$destination/miniforge/bin" >> ~/.bashrc
    echo "PATH=\$PATH:$destination/miniforge/bin" >> ~/.zshrc
    rm ./install_conda.sh

elif [[ `uname -m` == "arm64" ]]; then
    echo "Installing Miniconda (OSX / arm64) to: $destination"

    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-MacOSX-arm64.sh -O ./install_conda.sh
    bash ./install_conda.sh -b -p $destination/miniconda

    echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.bashrc
    echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.zshrc
    rm ./install_conda.sh

else # Miniconda 64bit
    echo "Installing Miniconda to: $destination"

    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./install_conda.sh
    bash ./install_conda.sh -b -p $destination/miniconda

    echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.bashrc
    echo "PATH=\$PATH:$destination/miniconda/bin" >> ~/.zshrc
    rm ./install_conda.sh
fi
