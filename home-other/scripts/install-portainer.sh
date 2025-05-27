#!/bin/bash

#PORTAINER ROOTFUL
#docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest

echo "Portainer: Starting Docker container..."
echo ""

ROOTFULL="-v /var/run/docker.sock:/var/run/docker.sock"
ROOTLESS="-v $XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock"

if [[ -f "$HOME/.docker-config" ]]; then
    echo ".docker-config found..."
    DOCKER_TYPE=$(cat "$HOME/.docker-config")
fi

if [[ -z "$DOCKER_TYPE" ]]; then
    echo "DOCKER_TYPE is blank, so enabling ROOTFULL..."
    DOCKER_TYPE2="rootfull"
else
    DOCKER_TYPE2="$DOCKER_TYPE"
    echo "Setting DOCKER_TYPE: <$DOCKER_TYPE2>"
fi

if [[ -z $XDG_RUNTIME_DIR ]]; then
    echo "The XDG_RUNTIME_DIR variable is empty. So cannot set ROOTLESS if required."
    DOCKER_TYPE2="rootfull"
fi

case $DOCKER_TYPE2 in
    "rootfull")
		#echo "rootfull..."
		#echo "DOCKER_HOST is: $DOCKER_HOST"
		DOCKER_SOCKET="$ROOTFULL"
		;;
    "rootless")
		#echo "Rootless..."
		#echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
		DOCKER_SOCKET="$ROOTLESS"
		;;
	*)
	    echo "Unknown setting in .docker-config"
	    exit 1
	;;
esac
    
echo "DOCKER_SOCKET set to: <$DOCKER_SOCKET>"

## XDG_RUNTIME_DIR=/run/user/1000
## DOCKER_HOST=unix:///run/user/1000/docker.sock

docker volume create portainer_data

echo "Starting..."
docker run -p 8000:8000 -p 9000:9000 -d \
    --name=portainer \
    --restart=always  \
    $DOCKER_SOCKET \
    -v portainer_data:/data \
    portainer/portainer-ee:latest

echo "Started."
exit 0

## -v ~/.local/share/docker/volumes:/var/lib/docker/volumes 

