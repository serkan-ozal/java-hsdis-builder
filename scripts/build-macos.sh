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

if [ "$JDK_DISTRIBUTION" = "openjdk" ]; then
  echo "[HSDIS-BUILDER] INFO - Installing Boot JDK ..."
  BOOT_JDK_VERSION=${JDK_VERSION}
  if [ "$JDK_VERSION" = "21" ]; then
    brew install openjdk@${BOOT_JDK_VERSION}
    JAVA_HOME=/usr/local/Cellar/openjdk/${BOOT_JDK_VERSION}
  fi
  echo "[HSDIS-BUILDER] INFO - Installed Boot JDK"
fi

echo "[HSDIS-BUILDER] INFO - Building hsdis ..."
pushd "jdk"
brew install autoconf
bash configure --with-hsdis=binutils --with-binutils-src=${BINUTILS_PATH}
make build-hsdis
CPU_ARCH=$(uname -m)
if [ "$CPU_ARCH" = "arm64" ]; then
  echo "HSDIS_BUILD_ARTIFACT_PATH=$(pwd)/build/macosx-aarch64-server-release/support/hsdis/hsdis-aarch64.dylib" >> $GITHUB_ENV
else
  echo "HSDIS_BUILD_ARTIFACT_PATH=$(pwd)/build/macosx-x86_64-server-release/support/hsdis/hsdis-amd64.dylib" >> $GITHUB_ENV
fi
popd
echo "[HSDIS-BUILDER] INFO - Built hsdis"
