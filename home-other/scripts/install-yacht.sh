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

docker volume create yacht_data 

docker run -d -p 8001:8000 \
      --name=yacht \
      --restart=always  \
       -v $XDG_RUNTIME_DIR/docker.sock:/var/run/docker.sock \
       -v yacht_data:/config \
       selfhostedpro/yacht    

exit 0

