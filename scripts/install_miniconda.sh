#!/bin/bash

wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ./miniconda.sh
bash ./miniconda.sh -b -p ~/miniconda
rm ./miniconda.sh

echo "PATH=\$PATH:\$HOME/miniconda/bin" >> ~/.bashrc
echo "PATH=\$PATH:\$HOME/miniconda/bin" >> ~/.zshrc
