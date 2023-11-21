# !/bin/bash -ex

VERSION="3.24.2"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Installing CMAKE ${VERSION} (Modify the script to install newer version)   <<<<<<<<<<<<<<<<<<<"

sudo apt-get install cmake > /dev/null

sudo update-alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 999

wget https://github.com/Kitware/CMake/releases/download/v${VERSION}/cmake-${VERSION}-linux-x86_64.tar.gz \
-O /tmp/cmake-${VERSION}-linux-x86_64.tar.gz


tar -xzf /tmp/cmake-${VERSION}-linux-x86_64.tar.gz -C /tmp/

sudo mv /tmp/cmake-${VERSION}-linux-x86_64 /opt/cmake-${VERSION}

sudo chown $(id -u):$(id -g) /opt/cmake-${VERSION}


sudo update-alternatives --install /usr/local/bin/cmake cmake /opt/cmake-${VERSION}/bin/cmake 324


echo "************************************************************"
echo "**************    Multiple version of cmake installation complete "
echo "**************    Call \"sudo update-alternatives --config cmake \" to switch between different version of gcc toolchains"
echo "************************************************************"

echo ">>>>>>>>>>>>>>>>>>>>>>>>>>     Done    <<<<<<<<<<<<<<<<<<<<< "
