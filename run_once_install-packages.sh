#!/usr/bin/env bash

# exist checks if a command exist in shell
exist() {
    command -v "$1" >/dev/null 2>&1
}

# log writes message to stdout with a timestamp in blue
log() {
    printf "\033[33;34m [%s] %s\n" "$(date)" "$1"
}

if [ -n "$CODESPACES" ]; then
    log "Exit. Skip run_once_install for codespaces."
    exit
fi

log "Running run_once_install-packages.sh once..."

now=$(date +"%Y-%m-%d-%H%M%S")
mkdir -p $HOME/.czm-tests
touch "$HOME/.czm-tests/czm-wrote-this-$now"

log "Done. Please restart the shell."

