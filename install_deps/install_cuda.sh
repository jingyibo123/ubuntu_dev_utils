#!/bin/bash -e

wget https://developer.download.nvidia.com/compute/cuda/11.6.2/local_installers/cuda_11.6.2_510.47.03_linux.run -cO \
  /tmp/cuda_11.6.2_510.47.03_linux.run && \

sudo sh /tmp/cuda_11.6.2_510.47.03_linux.run --silent --toolkit 

echo "
export PATH=/usr/local/cuda/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:\$LD_LIBRARY_PATH" \
  | sudo tee /etc/bash.bashrc.d/cuda.sh
