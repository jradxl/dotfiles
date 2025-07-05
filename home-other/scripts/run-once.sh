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

check-hatch() {
        echo "## HATCH..."
        if [[ $(command -v hatch ) ]]; then
            echo "Upgrading HATCH if needed (using install-hatch script)..."
            if [[ -f "$HOME/.local/share/chezmoi/home-other/scripts/install-hatch.sh" ]]; then
                echo "Calling script..."
                "$HOME/.local/share/chezmoi/home-other/scripts/install-hatch.sh"
            fi
        fi
}

check-micro() {
##https://github.com/zyedidia/micro/releases/download/v2.0.14/micro-2.0.14-linux64-static.tar.gz

        echo "## MICRO..."
        if [[ $(command -v micro ) ]]; then
            echo "Upgrading MICRO if needed (using install-micro script)..."
            if [[ -f "$HOME/.local/share/chezmoi/home-other/scripts/install-micro.sh" ]]; then
                echo "Calling script..."
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
            echo "GOLANG is not latest. Upgrading..."
            g i $(g lr | grep -v rc | tail -n 1)
        fi
     fi
}

check-direnv() {
    echo "## DIRENV"
    if [[ $(command -v direnv) ]]; then
        echo "DIRENV already installed, checking for upgrade..."
        current_direnv="$(direnv --version)"  
        where_direnv=$(which direnv)
        if [[ "$where_direnv" == "/usr/local/bin/direnv" ]]; then
            echo "DIRENV on path is correct."
        else
            if [[ "$where_direnv" != ""  ]]; then
                echo "DIRENV on path is: $where_direnv"
                echo "Please remove and then re-run this script."
                return
            fi
        fi
    else
        echo "DIRENV not found, installing..."
        current_direnv=""
    fi
    echo "CURRENT: $current_direnv"
    latest_direnv="$(lastversion https://github.com/direnv/direnv)"
    echo "LATEST: $latest_direnv"

    if [[ "$current_direnv" == "$latest_direnv" ]]; then
        echo "DIRENV already the latest version."
    else
        echo "Installing or Upgrading direnv..." 
        if [[ -x "$HOME/.local/share/chezmoi/home-other/scripts/install-direnv.sh" ]]; then
            "$HOME/.local/share/chezmoi/home-other/scripts/install-direnv.sh"
        else
	        echo "Pipx needs to be installed first. Run install_direnv.sh"
	        return
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

check-hishtory() {
    ## See also install-hishtory.sh
    echo "## HISHTORY"
    current_hishtory=""
    HISHTORY="UPGRADE"

    #path only added later, so can't use command or which
    if [[ -x "$HOME/.hishtory/hishtory" ]]; then
    #if [[ $(command -v hishtory) ]]; then
        echo "HISHTORY already installed, checking for upgrade..."
        current_hishtory="$("$HOME/.hishtory/hishtory" --version | awk '{print $3}')"
        echo "CURRENT: $current_hishtory"
    else
        echo "HISHTORY not found, installing..."
        HISHTORY="INSTALL"
    fi

    latest_hishtory="v$(lastversion https://github.com/ddworken/hishtory)"
    echo "LATEST: $latest_hishtory"

    if [[ "$current_hishtory" == "$latest_hishtory" ]]; then
        echo "HISHTORY already the latest version."
        return 0
    fi

    if [[ "$HISHTORY" == "INSTALL" ]]; then
        ## Scripted not suitable curl https://hishtory.dev/install.py | python3 -
        URL=https://github.com/ddworken/hishtory/releases/download/"$latest_hishtory"/hishtory-linux-amd64
        TEMP="$HOME/.hishtorytmp/"
        mkdir -p "$TEMP"
        wget --output-document="$TEMP/hishtory"  "$URL"
        if [[ -f "$TEMP/hishtory" ]]; then
            chmod +x "$TEMP/hishtory"
            "$TEMP"/hishtory install --offline --skip-config-modification
            rm -rf "$TEMP"
        else
            echo "Script ERROR: HISHTORY Not found"
        fi
    else
        "$HOME"/.hishtory/hishtory upgrade
    fi

    echo "Check HISHTORY has not added anything to .bashrc. PLEASE CHECK!"
    #sed -i '\|^# Hishtory Config:$|d'                          "$HOME/.bashrc"
    #sed -i '\|^source /home/jradley/.hishtory/config.sh$|d'    "$HOME/.bashrc"
    #sed -i '\|^export PATH="$PATH:/home/jradley/.hishtory"$|d' "$HOME/.bashrc"
    echo "Done"
    return 0
}

echo ""
echo "####### Executing the RUN-ONCE script..."

if [[ ! $(command -v pipx) ]]; then
    if [[ -x "$HOME/.local/share/chezmoi/home-other/scripts/install-pipx.sh" ]]; then
        "$HOME/.local/share/chezmoi/home-other/scripts/install-pipx.sh"
    else
	    echo "Pipx needs to be installed first. Run install_pipx.sh"
	    exit 1
    fi
else
    if [[ ! $(command -v lastversion) ]]; then
	    echo "lastversion needs to be installed."
	    sudo pipx install --global lastversion
	    exit 1
    fi
fi

cwd=$(pwd)

check-pnpm
check-nvm
check-rust
check-uv
check-hatch
check-micro
check-deno
check-gvm
check-direnv
check-flatpaks
check-hishtory

echo "####### RUN-ONCE script finished. #######"
echo ""
exit 0

