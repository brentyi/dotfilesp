#!/bin/bash

# Installs Yarn (and nodejs if needed)
wget -q -O /dev/stdout https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install yarn -y

echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.bashrc
echo "PATH=\"\$PATH:`yarn global bin`\"" >> ~/.zshrc
