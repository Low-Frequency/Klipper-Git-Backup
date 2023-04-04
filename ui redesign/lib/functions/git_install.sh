#!/bin/bash

install_git() {
  REQUIRED_PACKETS=(make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext)
  LATEST_VERSION=$(curl -s https://github.com/git/git/tags | grep "/git/git/releases/tag" | grep -oE "v[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?" | uniq | head -1)
  VERSION_NUMBER=${LATEST_VERSION//v/}
  if command -v git > /dev/null
  then
    if [[ $(git --version) == "git version ${VERSION_NUMBER}" ]]
    then
      success_msg "git already up to date"
      return 0
    else
      info_msg "Step 1/6: Removing existing installation"
      sudo apt-get remove git -y
      sudo apt-get autoremove -y
    fi
  fi
  info_msg "Step 2/6: Installing dependencies. ${#REQUIRED_PACKETS[@]} required packets"
  sudo apt-get update
  for i in "${!REQUIRED_PACKETS[@]}"
  do
    info_msg "Installing packet $(( i + 1 ))/${#REQUIRED_PACKETS[@]}: ${REQUIRED_PACKETS[$i]}"
    sudo apt-get install "${REQUIRED_PACKETS[$i]}" -y
  done
  info_msg "Step 3/6: Downloading latest release"
  sudo wget -qO /usr/src/git.tar.gz "https://github.com/git/git/archive/refs/tags/${LATEST_VERSION}.tar.gz"
  sudo tar -xf /usr/src/git.tar.gz -C "/usr/src"
  info_msg "Step 4/6: Installing git"
  sudo make -C "/usr/src/git-${VERSION_NUMBER}" prefix=/usr/local all
  sudo make -C "/usr/src/git-${VERSION_NUMBER}" prefix=/usr/local install
  info_msg "Step 5/6: Verifying installation"
  if [[ $(git --version) == "git version ${VERSION_NUMBER}" ]]
  then
    success_msg "sucessfully installed git ${LATEST_VERSION}"
    info_msg "Step 6/6: Removing source folder"
    if sudo rm -rf /usr/src/git*
    then
      success "Installation complete"
    else
      error_msg "Could not remove source folder! Please check /usr/src/ and remove all folders named git*"
    fi
  else
    error_msg "Error while installing git ${LATEST_VERSION}!"
    if command -v git
    then
      error_msg "Versions do not match!"
    else
      error_msg "git command not found!"
    fi
    return 1
  fi
  return 0
}
