#!/bin/bash -e

# From https://docs.docker.com/engine/install/ubuntu/ 

install_deps() (
  sudo apt-get update 

  sudo apt-get install -y \
     ca-certificates \
     curl \
     gnupg \
     lsb-release
)

# https://docs.docker.com/engine/install/linux-postinstall/
grant_nonroot_access() (
  sudo groupadd docker
  sudo usermod -aG docker $USER
  newgrp docker
)

install_deps

curl -fsSL https://get.docker.com -o get-docker.sh
# sudo sh get-docker.sh
rm get-docker.sh

grant_nonroot_access

sudo systemctl enable docker.service
sudo systemctl enable containerd.service

