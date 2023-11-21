#!/bin/bash -ex

VERSIONS=("8")
# 5, 6, 7, 8, 9, 10, 11

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Installing GCC $VERSIONS (Modify the script to enable more)   <<<<<<<<<<<<<<<<<<<"

# sudo apt-get install -y software-properties-common > /dev/null

# TODO does not work due to SSL certificate, see BLOG
# sudo add-apt-repository ppa:ubuntu-toolchain-r/test



for V in ${VERSIONS[@]};
do

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Installing gcc-$V and g++-$V   <<<<<<<<<<<<<<<<<<<"
sudo apt-get install -y gcc-$V g++-$V > /dev/null

sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-$V "${V}0" \
--slave /usr/bin/g++ g++ /usr/bin/g++-$V \
--slave /usr/bin/gcov gcov /usr/bin/gcov-$V \
--slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-$V \
--slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-$V

done

echo "************************************************************"
echo "**************    Multiple version of gcc/g++ installation complete "
echo "**************    Call \"sudo update-alternatives --config gcc \" to switch between different version of gcc toolchains"
echo "************************************************************"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Done    <<<<<<<<<<<<<<<<<<<<< "
