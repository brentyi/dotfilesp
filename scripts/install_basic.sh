# update repositories
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update

# install common utilities
sudo apt-get install neovim tmux htop build-essential -y

# set up zsh
sudo apt-get install zsh
sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

# python stuff
sudo apt-get install python-dev python-pip python3-dev python3-pip -y
