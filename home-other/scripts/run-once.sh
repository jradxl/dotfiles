#!/bin/bash
###################
# Run Once per day by .bashrc
# Can be run as standalone script
###################

get-github-latest () {
    git ls-remote --tags --sort=v:refname $1 | grep -v "rc" | grep -v "{}"  | grep -v "release" | tail -n 1 | tr -d '[:space:]' |  rev | cut -d/ -f1 | rev
}

check-pnpm() {
    echo "## PNPM..."
    if [[ $(command -v pnpm) ]]; then
        echo "Updating PNPM..."
        pnpm self-update
    fi
}

check-rust() {
    echo "## RUSTUP..."
    if [[ $(command -v rustup) ]]; then
        echo "Updating RUST..."
        rustup upgrade
    fi
}

check-nvm() {
    echo "## NVM..."
    NVM_DIR="$HOME/.nvm"
    if [[ -d "$NVM_DIR" ]]; then
        echo "Updating NVM if needed..."
        ##This is a fussy installer. .nvm dir needs to pre exist.
        ##Assumed to be already installed, hence check for upgrade.
        if [[ -s "$NVM_DIR/nvm.sh" ]]; then
            # This loads nvm
            source "$NVM_DIR/nvm.sh"  
        fi 
        NVM_LATEST=$(get-github-latest https://github.com/nvm-sh/nvm)
        echo "Latest NVM Version: $NVM_LATEST"
        NVM_CURRENT=$(nvm --version)
        echo "Installed NVM version: $NVM_CURRENT"
        echo "Latest Node Version: $(get-github-latest https://github.com/nodejs/node)"
        if [[ "$NVM_LATEST" == "v$NVM_CURRENT" ]]; then
            echo "No upgrade of NVM needed"
        else
            echo "Upgrading NVM"
            wget -qO- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_LATEST/install.sh" | bash
            echo "Upgrading NPM"
            nvm install --latest-npm
        fi
     fi
}

check-uv() {
        echo "## UV..."
        if [[ $(command -v uv ) ]]; then
            echo "Updating UV if needed."
            uv self update
        fi
}

check-micro() {
        echo "## MICRO..."
        if [[ $(command -v micro ) ]]; then
            echo "Upgrading MICRO if needed (using install-micro script)..."
            if [[ -f "$HOME/.local/share/chezmoi/home-other/scripts/install-micro.sh" ]]; then
                echo "Upgrading MICRO. May require SUDO password."
                "$HOME/.local/share/chezmoi/home-other/scripts/install-micro.sh"
            fi
        fi
}

check-deno() {
        echo "## DENO..."
        if [[ $(command -v deno ) ]]; then
            echo "Upgrading DENO, if necessary..."
            ##${str:0:1} == "1"
            if [[ -f "$HOME"/.deno-version ]]; then
                DENOVER=$(cat "$HOME"/.deno-version)
                if [[ ${DENOVER:0:1} == "1" ]]; then
            		echo "Deno Version $DENOVER requested"
                    deno upgrade $(cat "$HOME"/.deno-version)
                 else
                    echo "Deno latest requested"
                    deno upgrade
                fi
            fi
        fi
}

#https://github.com/voidint/g

check-gvm() {
    echo "## GVM (as g)..."
    if [[ $(command -v g) ]]; then
        echo "Upgrading GVM (as g) if necessary"

        G_CURRENT=$(g --version | grep "g version" | awk '{print $3}')
        echo "G Current Version: $G_CURRENT"

        G_LATEST=$(get-github-latest https://github.com/voidint/g)
        G_LATEST=${G_LATEST:1:6}
        echo "G Latest Version: $G_LATEST"

        if [[ $G_CURRENT == $G_LATEST ]]; then
            echo "G Voidint's GVM is latest version."
        else
            echo "G Voidint's GVM needs updating."
            curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
        fi

        GO_LATEST=$(curl -s https://go.dev/VERSION?m=text | head -n 1)
        GO_LATEST=${GO_LATEST:2:6}
        echo "Latest version of GOLANG: $GO_LATEST"

        GO_CURRENT=$(go version)
        GO_CURRENT=${GO_CURRENT:13:6}
        echo "Curent version of GOLANG: $GO_CURRENT"

        if [[ $GO_LATEST == $GO_CURRENT ]]; then
            echo "GOLANG is latest version."
        else
            echo "GOLANG is not latest. Consider using G to upgrade."
        fi
     fi
}

check-direnv() {
    echo "## DIRENV"
    if [[ $(command -v direnv) ]]; then
        DIRENV_LATEST=$(get-github-latest https://github.com/direnv/direnv )
        DIRENV_LATEST=${DIRENV_LATEST:1:6}
        DIRENV_CURRENT=$(direnv version)
        echo "DIRENV latest is: $DIRENV_LATEST"
        echo "DIRENV current is $DIRENV_CURRENT"
        if [[ $DIRENV_LATEST == $DIRENV_CURRENT ]]; then
            echo "DIRENV is latest version."
        else
            echo "DIRENV is not latest, upgrading."
            #curl -sfL https://direnv.net/install.sh | bash
        fi
    fi
}

check-flatpaks() {
    echo "## FLATPAKS"
    if [[ $(command -v flatpak) ]]; then
        #Lets not need SUDO in User login
        #echo "Updating system flatpaks if any"
        #sudo flatpak update --system -y
        echo "Updating user flatpaks if any"
        flatpak update --user -y
    fi
}

echo ""
echo "####### Executing the RUN-ONCE script..."

check-pnpm
check-nvm
check-rust
check-uv
check-micro
check-deno
check-gvm
check-direnv
check-flatpaks

echo "####### RUN-ONCE script finished. #######"
echo ""
exit 0
