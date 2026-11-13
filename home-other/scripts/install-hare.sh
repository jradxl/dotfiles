#!/bin/bash

##git clone https://git.sr.ht/~sircmpwn/harec && cd harecc

PWD=$(pwd)
CURRENT="NONE"

$(dpkg-query -W -f'${db:Status-Abbrev}\n' scdoc 2>/dev/null | grep -q '^.i $')
RET=$?
if [[ "$RET" == "0" ]]; then
    echo "SCDOC is already installed"
else
    echo 'Installing SCDOC'
    sudo apt install -y scdoc
fi

$(dpkg-query -W -f'${db:Status-Abbrev}\n' qbe 2>/dev/null | grep -q '^.i $')
RET=$?
if [[ "$RET" == "0" ]]; then
    echo "QBE is already installed"
else
    echo 'Installing QBE'
    sudo apt install -y qbe
fi

if [[ -f "/usr/local/bin/harec" ]]; then
    echo "Found harec already installed"
    #CURRENT=$(harec -v)
    CURRENT=v$(harec -v | awk '{print $2}' | head -c 6)
else
    echo "harec Not Found. Cloning or updating repository"
    if [[ -d "$HOME/Devel/sourcehut/harec/" ]]; then
        pushd "$PWD" > /dev/null
        cd "$HOME/Devel/sourcehut/harec/"
        git pull
        popd > /dev/null
        #Does not work! $(cd /home/jradley/Devel/sourcehut/harec/ && $(ls))
    else
        git clone https://git.sr.ht/~sircmpwn/harec "$HOME/Devel/sourcehut/harec"
    fi
fi

echo "Current is: $CURRENT"
if [[ -d "$HOME/Devel/sourcehut/harec/" ]]; then
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
    echo "harec is aleady current"
else
    echo "harec needs an upgrade"
    if [[ -d "$HOME/Devel/sourcehut/harec/" ]]; then
        pushd "$PWD" > /dev/null
        cd "$HOME/Devel/sourcehut/harec/"
        if [[ -f config.mk ]]; then
            echo "Config File already exists"
        else
            echo "Coping config.mk file..."
            cp configs/linux.mk config.mk
        fi
        make check
        #make
        sudo make install
        popd > /dev/null   
    else
        exit 0
    fi
fi

exit 0

