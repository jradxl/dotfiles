#!/bin/bash

#git clone https://git.sr.ht/~sircmpwn/hare && cd hare

### HARE and HAREDOC ###

PWD=$(pwd)
CURRENT="NONE"

if [[ -f "$HOME/.hare/bin/hare" ]]; then
    echo "Found hare already installed"
    #CURRENT=$(hare -v)
    CURRENT=v$(hare version | awk '{print $2}' | head -c 6)
else
    echo "harec Not Found. Cloning or updating repository"
    if [[ -d "$HOME/Devel/sourcehut/hare/" ]]; then
        pushd "$PWD" > /dev/null
        cd "$HOME/Devel/sourcehut/hare/"
        git pull
        popd > /dev/null
        #Does not work! $(cd /home/jradley/Devel/sourcehut/harec/ && $(ls))
    else
        git clone https://git.sr.ht/~sircmpwn/hare "$HOME/Devel/sourcehut/hare"
    fi
fi

echo "Current is: $CURRENT"
if [[ -d "$HOME/Devel/sourcehut/hare/" ]]; then
    pushd "$PWD" > /dev/null
    cd "$HOME/Devel/sourcehut/harec/"
    BRANCHES=$(git branch -a | grep v | tail -n 1)
    IFS='/' read -ra BRANCH <<< "$BRANCHES"
    LATEST="${BRANCH[2]}"
    popd > /dev/null   
else
    exit 0
fi

echo "Latest is: $LATEST"

if [[ "$CURRENT" == "$LATEST" ]]; then
    echo "hare is already current"
else
    echo "hare needs an upgrade"
    if [[ -d "$HOME/Devel/sourcehut/hare/" ]]; then
        pushd "$PWD" > /dev/null
        cd "$HOME/Devel/sourcehut/hare/"
        if [[ -f config.mk ]]; then
            echo "Config File already exists"
        else
            echo "Coping config.mk file..."
            cp configs/linux.mk config.mk
            sed -i 's|PREFIX = /usr/local|PREFIX = $(HOME)/.hare|g' config.mk
        fi
        #make check
        make
        make install
        popd > /dev/null   
    else
        exit 0
    fi
fi

