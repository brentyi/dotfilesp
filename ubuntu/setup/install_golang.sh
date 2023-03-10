#!/bin/bash

cd /tmp
wget https://golang.org/dl/go1.17.1.linux-amd64.tar.gz
sudo tar -xvf go1.17.1.linux-amd64.tar.gz
sudo mv go /usr/local
cd -

echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export GOPATH=\$HOME/go" >> ~/.bashrc
echo "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.bashrc

echo "export GOROOT=/usr/local/go" >> ~/.zshrc
echo "export GOPATH=\$HOME/go" >> ~/.zshrc
echo "export PATH=\$GOPATH/bin:\$GOROOT/bin:\$PATH" >> ~/.zshrc
