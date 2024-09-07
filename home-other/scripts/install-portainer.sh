#!/bin/bash

#PORTAINER ROOTFUL
#docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ee:latest

if [[ -z $XDG_RUNTIME_DIR ]]; then
    echo "The XDG_RUNTIME_DIR variable is empty. Exiting..."
    exit 1
fi

echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
echo "DOCKER_HOST: $DOCKER_HOST"

## XDG_RUNTIME_DIR=/run/user/1000
## DOCKER_HOST=unix:///run/user/1000/docker.sock

docker run -p 8000:8000 -p 9000:9000 -d \
    --name=portainer \
    --restart=always  \
    -v $XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock \
    -v ~/.local/share/docker/volumes:/var/lib/docker/volumes  \
    -v portainer_data:/data \
    portainer/portainer-ee:latest

exit 0

