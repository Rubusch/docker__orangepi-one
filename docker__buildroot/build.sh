#!/bin/bash -e
export DEFCONFIG=lothars__orangepi_one_defconfig
cd buildroot
make ${DEFCONFIG}
make -j8
