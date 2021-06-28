#!/bin/bash -e
#
#

MY_USER=$(whoami)
DEFCONFIG="lothars__orangepi_one_defconfig"
MY_HOME="/home/${MY_USER}"
BUILDROOT_DIR="${MY_HOME}/buildroot"
DL_DIR="${BUILDROOT_DIR}/dl"
OUTPUT_DIR="${BUILDROOT_DIR}/output"
SSH_DIR="${MY_HOME}/.ssh"
SSH_KNOWN_HOSTS="${SSH_DIR}/known_hosts"
#BR_BRANCH="lothar/orangepi-devel"
BR_BRANCH="lothar/2020.11.x"


## permissions
for item in "${BUILDROOT_DIR}" "${MY_HOME}/.gitconfig" "${SSH_DIR}"; do
    test -e "${item}" || continue
    if [ ! "${MY_USER}" == "$( stat -c %U ${item} )" ]; then
        ## may take some time
        sudo chown ${MY_USER}:${MY_USER} -R ${item}
    fi
done


## ssh known_hosts
touch ${SSH_KNOWN_HOSTS}
for item in "github.com" "bitbucket.org"; do
    if [ "" == "$( grep ${item} -r ${SSH_KNOWN_HOSTS} )" ]; then
        ssh-keyscan ${item} >> "${SSH_KNOWN_HOSTS}"
    fi
done


## initial clone
if [[ "1" == "$(find ${YOCTO_DIR} | wc -l)" ]]; then
    cd ${MY_HOME}

    ## try it...
    git clone -j4 --depth=1 --branch ${BR_BRANCH} https://github.com/Rubusch/buildroot.git ${BUILDROOT_DIR}

    ## alternatively get official buildrooot
    ## NB: this will fail to build, since kconfig won't be able to build for cross device environments
    ## (the mounted 'dl' and 'output' folders - I [quick]fixed this in my repo)
    #git clone -j4 --depth=1 https://github.com/buildroot/buildroot.git ${BUILDROOT_DIR}
fi

## build
cd ${BUILDROOT_DIR}
make ${DEFCONFIG} || exit 1
make -j8 || exit 1
