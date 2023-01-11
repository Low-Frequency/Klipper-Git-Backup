#!/bin/bash

### Print text to shell
print_step() {
  STEP=$1
  echo ""
  echo -e "${CYAN}### $STEP ${NONE}"
  echo ""
}

error_msg() {
  MSG=$1
  echo -e "${RED} $MSG ${NONE}"
}

success_msg() {
  MSG=$1
  echo -e "${GREEN} $MSG ${NONE}"
}

NONE='\033[0m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RED='\033[0;31m'

### Get latest version number from the releases
LATEST_VERSION=$(curl https://github.com/git/git/tags | grep "/git/git/releases/tag" | grep -oE "v[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?" | uniq | head -1)
VERSION=$(echo $LATEST_VERSION | sed -e 's/v//')

### Uninstalling git
if command -v git
then
  print_step "Removing existing installation"
  sudo apt-get remove git -y
  sudo apt-get autoremove -y
fi

### Install dependencies to compile git
print_step "Installing dependencies"
sudo apt-get update
sudo apt install make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext -y

### Downloading the source code
print_step "Downloading latest release"
sudo wget -O /usr/src/git.tar.gz "https://github.com/git/git/archive/refs/tags/$LATEST_VERSION.tar.gz"
sudo tar -xf /usr/src/git.tar.gz -C "/usr/src"

### Compiling and installing
print_step "Installing git"
sudo make -C "/usr/src/git-$VERSION" prefix=/usr/local all
sudo make -C "/usr/src/git-$VERSION" prefix=/usr/local install

### Verifying the version
print_step "Verifying installation"
INSTALLED=$(git --version | grep -oE "[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?")

if [[ "$INSTALLED" == "$VERSION" ]]
then
  success_msg "Successfully installed git $LATEST_VERSION"
  print_step "Removing source folder"
  sudo sudo rm -rf /usr/src/git*
  if [[ $? -eq 0 ]]
  then
    success_msg "Installation complete"
  else
    error_msg "Could not remove source folder! Please check /usr/src/ and remove all folders named git*"
  fi
else
  error_msg "Error while installing git $LATEST_VERSION!"
  if command -v git
  then
    error_msg "Versions do not match!"
  else
    error_msg "git command not found!"
  fi
  exit 1
fi