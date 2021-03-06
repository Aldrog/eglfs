#!/bin/bash

set -e

source /usr/local/share/liri-travis/functions

# Install dependencies
travis_start "install_packages"
msg "Install packages..."
dnf install -y \
     mesa-libgbm-devel \
     libxkbcommon-devel \
     libinput-devel \
     systemd-devel \
     qt5-qtbase-static
travis_end "install_packages"

# Install artifacts
travis_start "artifacts"
msg "Install artifacts..."
for name in cmakeshared libliri qtudev; do
    /usr/local/bin/liri-download-artifacts $TRAVIS_BRANCH ${name}-artifacts.tar.gz
done
travis_end "artifacts"

# Configure
travis_start "configure"
msg "Setup CMake..."
mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DINSTALL_LIBDIR=/usr/lib64 \
    -DINSTALL_QMLDIR=/usr/lib64/qt5/qml \
    -DINSTALL_PLUGINSDIR=/usr/lib64/qt5/plugins
travis_end "configure"

# Build
travis_start "build"
msg "Build..."
make -j $(nproc)
travis_end "build"

# Install
travis_start "install"
msg "Install..."
make install
travis_end "install"

# Package
travis_start "package"
msg "Package..."
mkdir -p artifacts
tar czf artifacts/eglfs-artifacts.tar.gz -T install_manifest.txt
travis_end "package"
