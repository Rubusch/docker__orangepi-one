#!/bin/bash -e
export DEFCONFIG=lothars__orangepi_one_defconfig
export MY_HOME=/home/$(whoami)

sudo chown $(whoami):$(whoami) -R ${MY_HOME}/buildroot/dl
sudo chown $(whoami):$(whoami) -R ${MY_HOME}/buildroot/output

cd ${MY_HOME}/buildroot
make ${DEFCONFIG}
make -j8
