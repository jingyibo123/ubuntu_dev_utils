#!/bin/bash -e

DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
INSTALL_DIR='/opt/miniconda3'

sudo mkdir -p $INSTALL_DIR && sudo chown $(id -u):$(id -g) $INSTALL_DIR

wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -cO /tmp/Miniconda3-latest-Linux-x86_64.sh && \
sh /tmp/Miniconda3-latest-Linux-x86_64.sh -bup ${INSTALL_DIR}

echo "
if [ -f '${INSTALL_DIR}/etc/profile.d/conda.sh' ]; then
    . '${INSTALL_DIR}/etc/profile.d/conda.sh'
else
    export PATH='${INSTALL_DIR}/bin:\$PATH'
fi" \
| sudo tee /etc/bash.bashrc.d/conda.sh

cp $DIR/../conf/.condarc ${INSTALL_DIR}
