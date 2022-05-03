#!/bin/bash -e

# From https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html

distribution=$(. /etc/os-release;echo $ID$VERSION_ID) && \
      curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - && \
      curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get updatec && sudo apt-get install -y nvidia-docker2

sudo systemctl restart docker

sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
