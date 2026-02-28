#!/bin/sh
apt-get update

echo "Running with Thomas' changes!"

START=$(date +%s)

ADDITIONAL_OPTIM="false"
if [ "$ADDITIONAL_OPTIM" = "true" ]; then
    INITRAMFS_CONF="/etc/initramfs-tools/update-initramfs.conf"
    DPKG_TRIGGERS="/var/lib/dpkg/triggers/File"

    if [ -e $INITRAMFS_CONF ]; then
        sudo sed -i 's/yes/no/g' $INITRAMFS_CONF
    fi
    echo 'set man-db/auto-update false' | sudo debconf-communicate >/dev/null
    sudo dpkg-reconfigure man-db

    if [ -e $DPKG_TRIGGERS ]; then
        sudo sed '/fontconfig/d' -i $DPKG_TRIGGERS
        sudo sed '/install-info/d' -i $DPKG_TRIGGERS
        sudo sed '/mime/d' -i $DPKG_TRIGGERS
        sudo sed '/hicolor-icon-theme/d' -i $DPKG_TRIGGERS
    fi

    echo "force-unsafe-io" | sudo tee -a /etc/dpkg/dpkg.cfg.d/force-unsafe-io

    if [ -e /usr/bin/eatmydata ]; then
        echo "eatmydata available"
        echo -e '#!/bin/sh\nexec eatmydata /usr/bin/dpkg $@' | sudo tee /usr/local/bin/dpkg && sudo chmod +x /usr/local/bin/dpkg
        echo -e '#!/bin/sh\nexec eatmydata /usr/bin/apt $@' | sudo tee /usr/local/bin/apt && sudo chmod +x /usr/local/bin/apt
        echo -e '#!/bin/sh\nexec eatmydata /usr/bin/apt-get $@' | sudo tee /usr/local/bin/apt-get && sudo chmod +x /usr/local/bin/apt-get
    fi
fi

INSTALL_RECOMMENDS=true

if [ "$INSTALL_RECOMMENDS" = "true" ]; then
    INSTALL_RECOMMENDS_FLAG=""
else
    INSTALL_RECOMMENDS_FLAG="--no-install-recommends"
fi

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
