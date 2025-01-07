#!/bin/bash

sudo apt-get install libz-dev libssl-dev libffi-dev libyaml-dev

if [[ -d "$HOME/.rbenv" ]]; then
    echo "RBENV already installed"
else
    echo "Installing RBENV from github"
    git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
    git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv"/plugins/ruby-build
fi

if [[ $(grep -s "rbenv init" "$HOME/.bashrc" ) ]]; then
    echo "RBENV already configured in .bashrc"
else
    echo "RBENV will be configured in .bashrc"
    #Equiv to "$HOME/.rbenv/bin/rbenv init"
    #Quoted "EOF" to avoid expansion
    cat << "EOF" >> $HOME/test123.txt 
# Added by script install-ruby.sh
eval "$($HOME/.rbenv/bin/rbenv init - --no-rehash bash)"
export RBENV_ROOT="$HOME/.rbenv"
git -C "$HOME/.rbenv"/plugins/ruby-build pull
EOF
fi

echo "Attempting to upgrade RBENV plugin, ruby-build..."
git -C "$HOME/.rbenv"/plugins/ruby-build pull

if [[ $(ruby --version) ]]; then
    echo "RUBY version: $(ruby --version) already installed."
else
    echo "Compiling RUBY 3.4.1 ..."
    rbenv global 3.4.1
fi

