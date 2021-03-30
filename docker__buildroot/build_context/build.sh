#!/bin/bash -e
DEFCONFIG=lothars__orangepi_one_defconfig
MY_HOME=/home/$(whoami)
BUILDROOT_DIR="${MY_HOME}/buildroot"
DL_DIR="${BUILDROOT_DIR}/dl"
OUTPUT_DIR="${BUILDROOT_DIR}/output"
SHARES=( ${DL_DIR} ${OUTPUT_DIR} )

## fix permissions (takes time)
for item in ${SHARES[*]}; do
    test -e ${item} && sudo chown $(whoami).$(whoami) -R ${item}
done

cd ${BUILDROOT_DIR}
make ${DEFCONFIG}
make -j8
