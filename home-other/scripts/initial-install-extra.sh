#!/bin/bash

echo "Starting Initial Install..."

pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

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

### CHEZMOI ###
if [[ $(command -v chezmoi ) ]]; then
    echo "Good, Chezmoi is already installed."
else
    echo "Chezmoi needs to be installed first. Run ./initial-install.sh" 
    exit 1
fi

### RUST ###
if [[ -d "$HOME/.cargo" ]]; then
    echo "Rust Toolchain already installed."
else
    echo "Installing Rust Toolchain"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi
##. "$HOME/.cargo/env"
#export PATH="$HOME/.cargo/bin:$PATH"
pathmunge "$HOME/.cargo/bin"

### End RUST ###


### RYE for Python ###

if [[ $(command -v rye) ]]; then
    echo "Rye already installed"
else
    echo "Installing Rye..."
    curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes"  bash
    .  "$HOME/.rye/env"
    rye --version
    echo "3.11" > "$HOME/.python-version"
    rye fetch
    mkdir -p ~/.local/share/bash-completion/completions
    rye self completion > ~/.local/share/bash-completion/completions/rye.bash
fi
## RYE End ###

## UV Start ##

if [[ $(command -v uv) ]]; then
    echo "UV already installed"
else
    echo "Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi
uv --version

## UV End ##

### NVM and NODE ###
#This is a fussy installer. .nvm dir needs to pre exist.
export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

NVM_LATEST=$(get-github-latest https://github.com/nvm-sh/nvm.git)
echo "Latest available NVM: $NVM_LATEST"

if [[ -f "$NVM_DIR/nvm.sh" ]]; then
    echo "NVM already installed"
else
    echo "Installing NVM"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_LATEST/install.sh | bash
fi

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

nvm --version

if [[ $(command -v node) ]]; then
    echo "NODE already installed"
else
    echo "Installing NODEjs"
    nvm install node
fi
node --version
### End NVM and NODE ###




### ZED editor ###
if [[ -f "$HOME/.local/bin/zed" ]]; then
    echo "Zed Editor already installed"
else
    echo "Installing Zed editor"
    curl -f https://zed.dev/install.sh | sh
fi
### End Zed ###

## BITWARDEN Secrets ###
#See: https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
#See: dra https://github.com/devmatteini/dra
#This works to get filename:
# wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux | sed 's:.*/::'

## Bitwarden Secrets CLI
if [[ $(command -v bws) ]]; then
    echo "Bitwarden Secrets Manager is already installed"
else
    echo "Installing Bitwarden Secrets Manager "
    BWSPATH=$(wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux )
    TESTPATH="https://github.com/bitwarden/sdk/releases/download/bws-v0.5.0/bws-x86_64-unknown-linux-gnu-0.5.0.zip"
    FILENAME=$(echo "$BWSPATH" | sed 's:.*/::')

    mkdir -p "$HOME/SecretsManager"
    CURENTDIR=$(pwd)
    cd "$HOME/SecretsManager"
    #wget $(wget -q -O - https://api.github.com/repos/bitwarden/sdk/releases/latest  |  jq -r '.assets[] | select(.name | contains ("zip")) | .browser_download_url' | grep x86_64-unknown-linux )
    wget $BWSPATH
    unzip "$HOME/SecretsManager/$FILENAME"
    mv bws "$HOME/.local/bin"
    cd $CURENTDIR
    rm -rf "$HOME/SecretsManager"
fi
bws --version

### GOLANG Version Manager G, which seems easiest to use ###
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
### End GOLAND ###

#GVM appears to need a working Go to install others
#if [[ -d "$HOME/.gvm" ]]; then
#    echo "GVM version manager already installed"
#else
#    echo "Installing GVM version manager"
#    bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
#fi
#. "$HOME/.gvm/scripts/gvm"
#gvm version

### VSCODE ###
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
### End VSCODE ###

### Swift and Swiftly ###
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

exit 0

if [[ "$RERUNFLAG" == "TRUE" ]]; then
    echo "You MUST restart this shell, and then re-run."
else
    echo "Swiftly and Swift installed"
    swiftly --version
    swift --version
fi
### END Swift and Swiftly ###

exit 0

