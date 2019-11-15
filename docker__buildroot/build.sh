#!/bin/bash -e
export DEFCONFIG=lothars__orangepi_one_defconfig
cd buildroot
make ${DEFCONFIG}
make -j8
## not possible to mount the folder directly as 'output' inside the container
## buildroot's make then fails right in the beginning with:
##
##   *** Error during update of the configuration.
##

## obtain build artifacts
sudo chown $(whoami):$(whoami) -R ~/output
cp -arfL ~/buildroot/output/* ~/output/
