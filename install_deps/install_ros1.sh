#!/bin/bash -ex

get_ros_version() {
    if ! command -v nvcc &>/dev/null; then
        echo "Error: nvcc not found. CUDA may not be installed." >&2
        exit 1
    fi

    local cuda_version=$(nvcc --version | grep "release" | awk '{print $NF}' | sed 's/V\([0-9]*\)\.\([0-9]*\)\..*/\1\2/')

    echo "$cuda_version"
}

. /etc/lsb-release > /dev/null && \
sudo echo "deb https://mirrors.tuna.atsinghua.edu.cn/ros/ubuntu/ ${DISTRIB_CODENAME} main" \
    > /etc/apt/sources.list.d/ros1-latest.list

sudo apt-key adv --keyserver-options http-proxy=127.0.0.1:3128 \
    --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

sudo mkdir -p /etc/ros/rosdep/sources.list.d && \
sudo curl https://raw.githubusercontent.com/ros/rosdistro/master/rosdep/sources.list.d/20-default.list

sudo apt update

sudo apt-get install -y --no-install-recommends ros-noetic-ros-core=1.5.0-1

export ROS_DISTRO=noetic

rosdep init

sudo apt install \
    build-essential \
    python3-rosdep \
    python3-rosinstall \
    python3-vcstools 

rosdep init
sudo rosdep init

sudo apt-get install -y --no-install-recommends ros-noetic-desktop

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Done    <<<<<<<<<<<<<<<<<<<" > /dev/null
