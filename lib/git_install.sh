#!/bin/bash

install_git() {
  REQUIRED_PACKETS=(make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext)
  LATEST_VERSION=$(curl -s https://github.com/git/git/tags | grep "/git/git/releases/tag" | grep -oE "v[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?" | uniq | head -1)
  VERSION_NUMBER=${LATEST_VERSION//v/}
  if command -v git > /dev/null
  then
    if [[ $(git --version) == "git version $VERSION_NUMBER" ]]
    then
      print_msg green "git already up to date"
      exit 0
    else
      print_msg cyan "Step 1/6: Removing existing installation"
      sudo apt-get remove git -y
      sudo apt-get autoremove -y
    fi
  fi
  print_msg cyan "Step 2/6: Installing dependencies. ${#REQUIRED_PACKETS[@]} required packets"
  sudo apt-get update
  for i in "${!REQUIRED_PACKETS[@]}"
  do
    print_msg purple "Installing packet $((i + 1))/${#REQUIRED_PACKETS[@]}: ${REQUIRED_PACKETS[$i]}"
    sudo apt install "${REQUIRED_PACKETS[$i]}" -y
  done
  print_msg cyan "Step 3/6: Downloading latest release"
  sudo wget -qO /usr/src/git.tar.gz "https://github.com/git/git/archive/refs/tags/$LATEST_VERSION.tar.gz"
  sudo tar -xf /usr/src/git.tar.gz -C "/usr/src"
  print_msg cyan "Step 4/6: Installing git"
  sudo make -C "/usr/src/git-$VERSION_NUMBER" prefix=/usr/local all
  sudo make -C "/usr/src/git-$VERSION_NUMBER" prefix=/usr/local install
  print_msg cyan "Step 5/6: Verifying installation"
  if [[ $(git --version) == "git version $VERSION_NUMBER" ]]
  then
    print_msg green "sucessfully installed git $LATEST_VERSION"
    print_msg cyan "Step 6/6: Removing source folder"
    if sudo rm -rf /usr/src/git*
    then
      print_msg green "Installation complete"
    else
      print_msg red "Could not remove source folder! Please check /usr/src/ and remove all folders named git*"
    fi
  else
    print_msg red "Error while installing git $LATEST_VERSION!"
    if command -v git
    then
      print_msg red "Versions do not match!"
    else
      print_msg red "git command not found!"
    fi
    exit 1
  fi
}
