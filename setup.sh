#!/bin/bash

set -eEuo pipefail

# https://wiki.lineageos.org/devices/sunfish/build/#install-the-build-packages
apt-get -qq update && \
    apt-get install -y bc \
    bison \
    build-essential \
    ccache \
    curl \
    flex \
    g++-multilib \
    gcc-multilib \
    git \
    git-lfs \
    gnupg \
    gperf \
    imagemagick \
    lib32readline-dev \
    lib32z1-dev \
    libelf-dev \
    liblz4-tool \
    libsdl1.2-dev \
    libssl-dev \
    libxml2 \
    libxml2-utils \
    lzop \
    pngcrush \
    rsync \
    schedtool \
    squashfs-tools \
    xsltproc \
    zip \
    zlib1g-dev \
    python-is-python3 \
    wget \
    lib32ncurses5-dev \
    libncurses5 \
    libncurses5-dev \

     
source ./env.sh

ccache -M 50G
ccache -o compression=true

# https://wiki.lineageos.org/devices/sunfish/build/#create-the-directories
mkdir -p $SRC_DIR $CCACHE_DIR $ZIP_DIR $LMANIFEST_DIR $KEYS_DIR $LOGS_DIR

$INIT_DIR/setup-keys.sh

# https://wiki.lineageos.org/devices/sunfish/build/#install-the-repo-command
curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
      chmod a+x /usr/local/bin/repo

# https://wiki.lineageos.org/devices/sunfish/build/#configure-git
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
git config --global trailer.changeid.key "Change-Id"
git lfs install

$INIT_DIR/checkout-and-patch.sh

$INIT_DIR/build-and-sign.sh
