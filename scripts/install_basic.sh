# update repositories
sudo add-apt-repository ppa:neovim-ppa/unstable -y
sudo apt-get update

# install common utilities
sudo apt-get install neovim tmux htop build-essential -y

# set up zsh
sudo apt-get install zsh
git clone git://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
chsh -s /bin/zsh

# python stuff
sudo apt-get install python-dev python-pip python3-dev python3-pip -y
