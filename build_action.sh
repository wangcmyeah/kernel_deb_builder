#!/usr/bin/env bash

VERSION=$(grep 'Kernel Configuration' < config | awk '{print $3}')
# VERSION='6.0-rc7'


# add deb-src to sources.list
sed -i "/deb-src/s/# //g" /etc/apt/sources.list

# install dep
sudo apt update
sudo apt install -y wget
sudo apt build-dep -y linux

# change dir to workplace
cd "${GITHUB_WORKSPACE}" || exit

# download kernel source
wget http://www.kernel.org/pub/linux/kernel/v5.x/linux-"$VERSION".tar.xz
tar -xf linux-"$VERSION".tar.xz

# Just for 6.X
#wget https://git.kernel.org/torvalds/t/linux-6.0-rc7.tar.gz
#tar -zxvf linux-6.0-rc7.tar.gz

cd linux-"$VERSION" || exit

# copy config file
cp ../config .config

# disable DEBUG_INFO to speedup build
scripts/config --disable DEBUG_INFO

# apply patches
# shellcheck source=src/util.sh
source ../patch.d/*.sh

# build deb packages
CPU_CORES=$(($(grep -c processor < /proc/cpuinfo)*2))
make deb-pkg -j"$CPU_CORES"

# move deb packages to artifact dir
cd ..
mkdir "artifact"
mv ./*.deb artifact/
