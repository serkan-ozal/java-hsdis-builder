#!/bin/bash

echo "[HSDIS-BUILDER] INFO - Checking out JDK code ..."
mkdir jdk
if [ "$JDK_NAME" = "OpenJDK" ]; then
  if [ "$JDK_VERSION" = "21" ]; then
    git clone https://github.com/openjdk/jdk jdk
    pushd jdk
    git checkout tags/jdk-${JDK_VERSION}-ga
    popd
  else
    echo "[HSDIS-BUILDER] ERROR - Invalid OpenJDK version: ${JDK_VERSION}"
    exit 1
  fi
elif [ "$JDK_NAME" = "Amazon Corretto" ]; then
  if [ "$JDK_VERSION" = "21" ]; then
    git clone https://github.com/corretto/corretto-21 jdk
  else
    echo "[HSDIS-BUILDER] ERROR - Invalid Amazon Corretto JDK version: ${JDK_VERSION}"
    exit 1
  fi
else
  echo "[HSDIS-BUILDER] ERROR - Invalid JDK name: ${JDK_NAME}"
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
if [ "$JDK_NAME" = "OpenJDK" ]; then
  sudo add-apt-repository ppa:openjdk-r/ppa
elif [ "$JDK_NAME" = "Amazon Corretto" ]; then
  wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add -
  sudo add-apt-repository "deb https://apt.corretto.aws stable main"
fi
sudo apt update
echo "[HSDIS-BUILDER] INFO - Updated repositories"

echo "[HSDIS-BUILDER] INFO - Installing dependencies ..."
sudo apt-get install build-essential
sudo apt-get install libasound2-dev
sudo apt-get install libcups2-dev
sudo apt-get install libfontconfig1-dev
sudo apt-get install libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev
echo "[HSDIS-BUILDER] INFO - Installed dependencies"

echo "[HSDIS-BUILDER] INFO - Installing Boot JDK ..."
if [ "$JDK_NAME" = "OpenJDK" ]; then
  BOOT_JDK_VERSION=${JDK_VERSION}
  if [ "$JDK_VERSION" = "21" ]; then
    sudo apt-get install -y openjdk-${BOOT_JDK_VERSION}-jdk
  fi
elif [ "$JDK_NAME" = "Amazon Corretto" ]; then
  BOOT_JDK_VERSION=${JDK_VERSION}
  if [ "$JDK_VERSION" = "21" ]; then
    sudo apt-get install -y java-${BOOT_JDK_VERSION}-amazon-corretto-jdk
  fi
fi
echo "[HSDIS-BUILDER] INFO - Installed Boot JDK"

echo "[HSDIS-BUILDER] INFO - Building hsdis ..."
pushd "jdk"
bash configure --with-hsdis=binutils --with-binutils-src=${BINUTILS_PATH}
make build-hsdis
echo "HSDIS_BUILD_ARTIFACT_PATH=$(pwd)/build/linux-x86_64-server-release/support/hsdis/hsdis-amd64.so" >> $GITHUB_ENV
popd
echo "[HSDIS-BUILDER] INFO - Built hsdis"
