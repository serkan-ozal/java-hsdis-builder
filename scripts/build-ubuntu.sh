#!/bin/bash

echo "Downloading binutils ..."
wget https://ftp.gnu.org/gnu/binutils/binutils-2.38.tar.gz -O binutils-2.38.tar.gz
echo "Downloaded binutils"

echo "Installing dependencies ..."
sudo apt-get install build-essential
sudo apt-get install libasound2-dev
sudo apt-get install libcups2-dev
sudo apt-get install libfontconfig1-dev
sudo apt-get install libx11-dev libxext-dev libxrender-dev libxrandr-dev libxtst-dev libxt-dev
echo "Installed dependencies"