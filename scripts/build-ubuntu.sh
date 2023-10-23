#!/bin/bash

echo "[HSDIS-BUILDER] INFO - Checking out JDK code ..."
mkdir jdk
if [ "$JDK_DISTRIBUTION" = "openjdk" ]; then
  if [ "$JDK_VERSION" = "21" ]; then
    git clone https://github.com/openjdk/jdk jdk
    pushd jdk
    git checkout tags/jdk-${JDK_VERSION}-ga
    popd
  else
    echo "[HSDIS-BUILDER] ERROR - Invalid OpenJDK version: ${JDK_VERSION}"
    exit 1
  fi
elif [ "$JDK_DISTRIBUTION" = "corretto" ]; then
  if [ "$JDK_VERSION" = "21" ]; then
    git clone https://github.com/corretto/corretto-21 jdk
  else
    echo "[HSDIS-BUILDER] ERROR - Invalid Amazon Corretto JDK version: ${JDK_VERSION}"
    exit 1
  fi
else
  echo "[HSDIS-BUILDER] ERROR - Invalid JDK distribution: ${JDK_DISTRIBUTION}"
  exit 1
fi
echo "[HSDIS-BUILDER] INFO - Checked out JDK code"

echo "[HSDIS-BUILDER] INFO - Downloading binutils ..."
mkdir binutils
pushd binutils
BINUTILS_VERSION=2.38
wget https://ftp.gnu.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz -O binutils-${BINUTILS_VERSION}.tar.gz
tar -xzf binutils-${BINUTILS_VERSION}.tar.gz
BINUTILS_PATH="$(pwd)/binutils-${BINUTILS_VERSION}"
popd
echo "[HSDIS-BUILDER] INFO - Downloaded binutils"

echo "[HSDIS-BUILDER] INFO - Updating repositories ..."
sudo add-apt-repository universe
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt update
echo "[HSDIS-BUILDER] INFO - Updated repositories"

echo "[HSDIS-BUILDER] INFO - Installing dependencies ..."
sudo apt-get install build-essential
sudo apt-get install libasound2-dev
sudo apt-get install libcups2-dev
sudo apt-get install libfontconfig1-dev
sudo apt-get install libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev
echo "[HSDIS-BUILDER] INFO - Installed dependencies"

if [ "$JDK_DISTRIBUTION" = "openjdk" ]; then
  echo "[HSDIS-BUILDER] INFO - Installing Boot JDK ..."
  BOOT_JDK_VERSION=${JDK_VERSION}
  if [ "$JDK_VERSION" = "21" ]; then
    sudo apt-get install -y openjdk-${BOOT_JDK_VERSION}-jdk
  fi
  echo "[HSDIS-BUILDER] INFO - Installed Boot JDK"
fi

echo "[HSDIS-BUILDER] INFO - Building hsdis ..."
pushd "jdk"
bash configure --with-hsdis=binutils --with-binutils-src=${BINUTILS_PATH}
make build-hsdis
echo "HSDIS_BUILD_ARTIFACT_PATH=$(pwd)/build/linux-x86_64-server-release/support/hsdis/hsdis-amd64.so" >> $GITHUB_ENV
popd
echo "[HSDIS-BUILDER] INFO - Built hsdis"
