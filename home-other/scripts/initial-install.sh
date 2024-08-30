#!/bin/bash

echo "Starting Initial Install..."

echo "Checking for Curl. May ask for superuser access."
if [[ $(command -v curl) ]]; then
    echo "Curl is present, continuing..."
else
    echo "Curl is NOT present, installing..."
    sudo apt-get -y install curl
fi

sudo systemctl daemon-reload

sudo apt-get -y install terminator git nmap net-tools curl wget iproute2 apt-utils age vim pipx rsync bison
sudo apt-get -y install liblz4-dev libssl-dev libzstd-dev libxxhash-dev libacl1-dev


### CHEZMOI ###
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

### End Chezmoi ###


if [[ $(command -v rye) ]]; then
    echo "Rye already installed"
else
    echo "Installing Rye"
    curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes"  bash
    rye --version
    echo "3.11" > "$HOME/.python-version"
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

if [[ -d  "$HOME/.g" ]]; then
    echo "Golang Version manager G is already installed."
else
    echo "Installing the Golang Version manager G."
    curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
    UNWANTEDLINE="[ -s "${HOME}/.g/env" ] && \. "${HOME}/.g/env"  # g shell setup"
    sed -i '/g shell setup/d'  "$HOME/.bashrc"
fi
. "$HOME/.g/env"
g --version
GOLATEST=$(g lsr | grep -v rc | grep -v beta | tail -n 1 | sed 's/^[[:space:]]*//g')
echo "Latest Go Version: <$GOLATEST>"
echo "Installing Latest Golang..."
g install "$GOLATEST"
go version
exit 0

exit 0





#GVM appears to need a working Go to install others
#if [[ -d "$HOME/.gvm" ]]; then
#    echo "GVM version manager already installed"
#else
#    echo "Installing GVM version manager"
#    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
#fi
#. "$HOME/.gvm/scripts/gvm"
#gvm version


exit 0

if [[ $(command -v code) ]]; then
    echo "VSCode is already installed"
else
    ##Installing VSCode
    echo "Installing VSCode"
    sudo apt-get -y install wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    sudo apt-get update
    sudo apt-get -y install code
fi
code --version

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
