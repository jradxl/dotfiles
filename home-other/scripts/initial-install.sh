#!/bin/bash

echo "Starting Initial Install of CHEZMOI...."

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

echo "Checking for Curl. May ask for superuser access."
if [[ $(command -v curl) ]]; then
    echo "Curl is present, continuing..."
else
    echo "Curl is NOT present, installing..."
    sudo apt-get -y install curl
fi

sudo systemctl daemon-reload

## Don't add Pipx, Borg and Borgmatic from Ubuntu repositories
sudo apt-get -y install apt-file trash-cli build-essential micro jq apt-transport-https pluma caja terminator keychain git nmap net-tools curl wget iproute2 apt-utils age vim rsync bison qemu-guest-agent spice-vdagent openssh-server

sudo apt-get -y install liblz4-dev libssl-dev libzstd-dev libxxhash-dev libacl1-dev

#For MOJO
sudo apt-get -y install javascript-common libjs-jquery libjs-sphinxdoc libjs-underscore libncurses-dev python3-dev python3-pip python3-setuptools python3-wheel

## Xrdp Easy Intstaller
mkdir -p "$HOME/scripts"
if [[ ! -f  "$HOME"/scripts/xrdp-installer-1.5.2.zip ]]; then
    echo "Downloading the xrdp easy installer Version 1.5.2"
    (cd "$HOME"/scripts && wget https://c-nergy.be/downloads/xRDP/xrdp-installer-1.5.2.zip)
    if [[ -f $HOME/scripts/xrdp-installer-1.5.2.sh ]]; then
        chmod +x "$HOME"/scripts/xrdp-installer-1.5.2.sh
        echo "Xrdp Easy Installer Version 1.5.2 available"
    fi
else
    echo "Xrdp Easy Installer already present"
fi
## Xrdp Easy Intstaller

### CHEZMOI ###
if [[ $(command -v chezmoi ) ]]; then
    echo "Chezmoi already installed."
else
    echo "Installing Chezmoi to ~/.local/bin to use existing PATHs" 
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin   
fi

##Add to current shell
export PATH="$HOME/.local/bin:$PATH"
echo "$PATH"

if [[ -d "$HOME/.local/share/chezmoi" ]]; then
    echo "Chezmoi Dotfiles repo already exists."
else
    echo "Getting existing Dofiles repo..."
    chezmoi init https://github.com/jradxl/dotfiles.git
fi

chezmoi --version

echo "Applying Chezmoi updates to the underlying files"
echo "CAREFUL: Do you want to force the application of Chezmoi updates?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
			echo "Appling Chezmod updates..."
			chezmoi apply --force
			break
			;;
        No )
			echo "Chezmod updates not applied..."
			break
			;;
    esac
done
echo "Finished Chezmoi updating..."

#Set up Github
git config --global user.email "jradxl@gmail.com"
git config --global user.email
git config --global user.name "John Radley"
git config --global user.name

if [[ -f "$HOME/.github.configured" ]]; then
    echo "Github Private Key setup OK"
else
    echo "Github Private Key NOT setup."
    echo "Install the Github Private Key and Y to continue?"
    select yn in "Yes" "No"; do
        case $yn in
            Yes ) break;;
            No ) exit;;
        esac
    done
    touch "$HOME/.github.configured"
fi

echo "Test Github access. May ask for passphrase."
if [[ $(ssh git@github.com) == 1 ]]; then
    echo "Github access failed. Please fix and re-run this script."
    exit 1
fi

if [[ ! -f "$HOME/.chezmoi-pac" ]]; then
    echo "Update .chezmoi-pac when convenient."
    echo 'export CHEZMOI_GITHUB_ACCESS_TOKEN=""' > "$HOME/.chezmoi-pac"
fi

CURENTDIR=$(pwd)

CHEZMOISRC1=$(chezmoi source-path) #This includes home if configured

#Method to get the base dir for Chezmoi
CHEZMOISRC2=$(chezmoi dump-config | grep sourceDir | sed 's/[^,:]*://g' | sed 's/,//g' | sed 's/^[[:space:]]*//g' | sed 's/\"//g')

if [[ -f "$HOME/.github.configured" ]]; then
    echo "Github ready... Attempting to change Chezmoi repo to git access"
    #NOT USED as opens new shell:  chezmoi cd
    cd "$CHEZMOISRC2"
    echo "Chezmoi Repo Path: <$(pwd)>"
    git remote set-url origin git@github.com:jradxl/dotfiles.git
    #echo "GIT1: <$?>"
    git config --get remote.origin.url
    #echo "GIT2: <$?>"
    cd "$CURENTDIR"
fi

sudo systemctl daemon-reload

### End Chezmoi ###
exit 0

