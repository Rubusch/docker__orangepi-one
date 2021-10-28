#!/bin/sh -e
MY_USER="${USER}"
MY_HOME="/home/${MY_USER}"
BUILDROOT_DIR="${MY_HOME}/buildroot"
DL_DIR="${BUILDROOT_DIR}/dl"
OUTPUT_DIR="${BUILDROOT_DIR}/output"
SSH_DIR="${MY_HOME}/.ssh"
SSH_KNOWN_HOSTS="${SSH_DIR}/known_hosts"
#BR_BRANCH="lothar/orangepi-devel"
BR_BRANCH="lothar/2020.11.x"
DEFCONFIG="lothars__orangepi_one_defconfig"

## prepare
00_defenv.sh "${BUILDROOT_DIR}" "${MY_HOME}/.gitconfig" "${CONFIGS_DIR}"

## initial clone
FIRST="$(ls -A "${BUILDROOT_DIR}")" || true
if [ -z "${FIRST}" ]; then
    cd "${MY_HOME}"

    ## try it...
    git clone -j4 --depth=1 --branch "${BR_BRANCH}" https://github.com/Rubusch/buildroot.git "${BUILDROOT_DIR}"

    ## alternatively get official buildrooot
    ## NB: this will fail to build, since kconfig won't be able to build for cross device environments
    ## (the mounted 'dl' and 'output' folders - I [quick]fixed this in my repo)
    #git clone -j4 --depth=1 https://github.com/buildroot/buildroot.git ${BUILDROOT_DIR}
fi

## build
cd "${BUILDROOT_DIR}"
make "${DEFCONFIG}" || exit 1
make -j "$(nproc)" || exit 1

echo "READY."
