#!/bin/bash -ex



curl -s https://syncthing.net/release-key.txt | sudo apt-key add -

echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

sudo apt-get install apt-transport-https

sudo apt-get update && sudo apt-get install syncthing


