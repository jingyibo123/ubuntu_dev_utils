#! /bin/bash -ex


sudo apt update && sudo apt install -y tmux

cp ../conf/.tmux.conf ~
