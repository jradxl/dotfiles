#!/bin/bash

echo "Starting Initial Install..."

if [[ $(command -v swiftly) ]]; then
    ##All Set
    echo "Swiftly set up, continuing..."
else
    echo "Swiftly not found. Checking Installation..."
    if [[ -f $HOME/.local/share/swiftly/env.sh ]]; then
        echo "Swiftly installed but not sourced. Sourcing for this shell."
    else
        echo "Installing Swiftly. Will ask Questions..."
        curl -L https://swiftlang.github.io/swiftly/swiftly-install.sh | bash
    fi
    RERUNFLAG="TRUE"
    . $HOME/.local/share/swiftly/env.sh
    grep -qxF ". $HOME/.local/share/swiftly/env.sh" "$HOME/.bashrc"  || echo ". $HOME/.local/share/swiftly/env.sh" >> "$HOME/.bashrc"
    grep -qxF ". $HOME/.local/share/swiftly/env.sh" "$HOME/.profile" || echo ". $HOME/.local/share/swiftly/env.sh" >> "$HOME/.profile"
fi

if [[ -f "$HOME/.local/bin/swift"  ]]; then
    echo "Swift already installed"
else
    swiftly install latest
fi

if [[ "$RERUNFLAG" == "TRUE" ]]; then
    echo "You MUST restart this shell, and then re-run."
else
    echo "Swiftly and Swift installed"
    swiftly --version
    swift --version
fi

sudo apt-get -y install terminator git nmap net-tools curl wget iproute2 apt-utils age vim pipx rsync

if [[ $(command -v chezmoi ) ]]; then
    echo "Chezmoi already installed."
else
    echo "Installing Chezmoi to ~/.local/bin to use existing PATHs" 
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin   
fi

if [[ -d "$HOME/.local/share/chezmoi" ]]; then
    echo "Chezmoi Dotfiles repo already exists."
else
    echo "Getting existing Dofiles repo..."
    chezmoi init https://github.com/jradxl/dotfiles.git
fi

#Set up Github
git config --global user.email "jradxl@gmail.com"
git config --global user.email
git config --global user.name "John Radley"
git config --global user.name

echo "Install the Github Private Key and Y to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) exit;;
    esac
done

echo "Test Github access. May ask for passphrase."
if [[ $(ssh git@github.com) == 1 ]]; then
    echo "Github access failed."
    exit 1
fi

exit 0

CURENTDIR=$(pwd)
CHEZMOISRC=$(chezmoi source-path)
if [[ -f "$HOME/.github.configured" ]]; then
    echo "Github ready..."
    chezmoi cd
    git remote set-url origin git@github.com:jradxl/dotfiles.git
    git config --get remote.origin.url
    cd "$CURENTDIR"
    touch "$HOME/.github.configured"
else
    echo "Github Dotfiles Repo not ready"
    exit 1
fi



exit 0

curl -f https://zed.dev/install.sh | sh

##
#See: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
#See: dra https://github.com/devmatteini/dra
#This works to get filename:
# wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux | sed 's:.*/::'

## Bitwarden Secrets CLI
BWSPATH=$(wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux )
TESTPATH="https://github.com/bitwarden/sdk/releases/download/bws-v0.5.0/bws-x86_64-unknown-linux-gnu-0.5.0.zip"
FILENAME=echo "$BWSPATH" | sed 's:.*/::'

mkdir -p "$HOME/SecretsManager"
CURENTDIR=$(pwd)
cd "$HOME/SecretsManager"
#wget $(wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux )
wget $($BWSPATH)
unzip "$HOME/SecretsManager/$FILENAME"
mv bws "$HOME/.local/bin"
cd $CURENTDIR


exit 1

