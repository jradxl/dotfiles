#!/bin/bash

echo "Starting Initial Install..."

echo "Checking for Curl. May ask for superuser access."
if [[ $(command -v curl) ]]; then
    echo "Curl is present, continuing..."
else
    echo "Curl is NOT present, installing..."
    sudo apt-get -y install curl
fi

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
sudo apt-get -y install liblz4-dev libssl-dev libzstd-dev libxxhash-dev libacl1-dev

#Borg is installed as root user uisng pipx. Therefore must be run as root
#for the venv to work
if [[ $(sudo -u root /root/.local/bin/borg --version) ]]; then
    echo "Borg backup is present"
else
    echo "Installling Borg backup using pipx"
    sudo pipx install borgbackup
fi
sudo -u root /root/.local/bin/borg --version

#Borgmatic is installed as root user uisng pipx. Therefore must be run as root
#for the venv to work
if [[ $(sudo -u root /root/.local/bin/borgmatic --version) ]]; then
    echo "Borgmatic is present"
else
    echo "Installling Borgmatic using pipx"
    sudo pipx install borgmatic
fi
sudo -u root /root/.local/bin/borgmatic --version


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
CHEZMOISRC2=$(chezmoi dump-config | grep sourceDir | sed 's/[^,:]*://g' | sed 's/,//g' | sed 's/^[[:space:]]*//g' | sed 's/\"//g')

if [[ -f "$HOME/.github.configured" ]]; then
    echo "Github ready... Attempting to change Chezmoi repo to git access"
    #NOT USED as opens new shell chezmoi cd
    cd "$CHEZMOISRC2"
    echo "Chezmoi Repo Path: <$(pwd)>"
    git remote set-url origin git@github.com:jradxl/dotfiles.git
    #echo "GIT1: <$?>"
    git config --get remote.origin.url
    #echo "GIT2: <$?>"
    cd "$CURENTDIR"
fi

if [[ $(command -v rye) ]]; then
    echo "Rye already installed"
else
    echo "Installing Rye"
    curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes"  bash
    rye --version
    echo "3.11" > .python-version
    rye fetch
    mkdir -p ~/.local/share/bash-completion/completions
    rye self completion > ~/.local/share/bash-completion/completions/rye.bash
fi

if [[ -d "$HOME/.nvm" ]]; then
    echo "NVM already installed"
else
    echo "Installing NVM"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi
. "$HOME/.nvm/nvm.sh"
nvm --version

if [[ $(command -v node) ]]; then
    echo "NODE already installed"
else
    echo "Installing NODEjs"
    nvm install node
fi
node --version

exit 0

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
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

