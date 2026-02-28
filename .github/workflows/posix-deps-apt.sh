#!/bin/sh
apt-get update

echo "Running with Thomas' changes!"

INSTALL_RECOMMENDS=true

if [ "$INSTALL_RECOMMENDS" = "true" ]; then
    INSTALL_RECOMMENDS_FLAG=""
else
    INSTALL_RECOMMENDS_FLAG="--no-install-recommends"
fi

START=$(date +%s)
apt-get -yq $INSTALL_RECOMMENDS_FLAG install \
    build-essential \
    pkg-config \
    ccache \
    cmake \
    gdb \
    lcov \
    libb2-dev \
    libbz2-dev \
    libffi-dev \
    libgdbm-dev \
    libgdbm-compat-dev \
    liblzma-dev \
    libncurses5-dev \
    libreadline6-dev \
    libsqlite3-dev \
    libssl-dev \
    libzstd-dev \
    lzma \
    lzma-dev \
    strace \
    tk-dev \
    uuid-dev \
    xvfb \
    zlib1g-dev

# Workaround missing libmpdec-dev on ubuntu 24.04:
# https://launchpad.net/~ondrej/+archive/ubuntu/php
# https://deb.sury.org/
sudo add-apt-repository ppa:ondrej/php
apt-get update
apt-get -yq $INSTALL_RECOMMENDS_FLAG install libmpdec-dev
END=$(date +%s)
echo "posix-deps-apt.sh took $((END - START))s"
