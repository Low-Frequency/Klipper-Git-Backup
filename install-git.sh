#!/bin/bash

### Function to print text to shell
print_msg() {
  TYPE=$1
  MSG=$2
  case $TYPE in
    info)
      echo -e "${PURPLE} $MSG ${NONE}"
      ;;
    success)
      echo -e "${GREEN} $MSG ${NONE}"
      ;;
    error)
      echo -e "${RED} $MSG ${NONE}"
      ;;
    step)
      echo -e "\n${CYAN}### $MSG ###${NONE}\n"
      ;;
  esac
}

cmd() {
  
}

NONE='\033[0m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
GREEN='\033[0;32m'
RED='\033[0;31m'
REQUIRED_PACKETS=(make libssl-dev libghc-zlib-dev libcurl4-gnutls-dev libexpat1-dev gettext)

### Get latest version number from the releases
LATEST_VERSION=$(curl -s https://github.com/git/git/tags | grep "/git/git/releases/tag" | grep -oE "v[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?" | uniq | head -1)
VERSION_NUMBER=${LATEST_VERSION//v/}

### Uninstalling git
if command -v git > /dev/null
then
  if [[ $(git --version) == "git version $VERSION_NUMBER" ]]
  then
    print_msg success "git already up to date"
    exit 0
  else
    print_msg step "Step 1/6: Removing existing installation"
    sudo apt-get remove git -y
    sudo apt-get autoremove -y
  fi
fi

### Install dependencies to compile git
print_msg step "Step 2/6: Installing dependencies. ${#REQUIRED_PACKETS[@]} required packets"
sudo apt-get update
for i in "${!REQUIRED_PACKETS[@]}"
do
  print_msg info "Installing packet $((i + 1))/${#REQUIRED_PACKETS[@]}: ${REQUIRED_PACKETS[$i]}"
  sudo apt install "${REQUIRED_PACKETS[$i]}" -y
done

### Downloading the source code
print_msg step "Step 3/6: Downloading latest release"
sudo wget -qO /usr/src/git.tar.gz "https://github.com/git/git/archive/refs/tags/$LATEST_VERSION.tar.gz"
sudo tar -xf /usr/src/git.tar.gz -C "/usr/src"

### Compiling and installing
print_msg step "Step 4/6: Installing git"
sudo make -C "/usr/src/git-$VERSION_NUMBER" prefix=/usr/local all
sudo make -C "/usr/src/git-$VERSION_NUMBER" prefix=/usr/local install

### Verifying the version
print_msg step "Step 5/6: Verifying installation"

if [[ $(git --version) == "git version $VERSION_NUMBER" ]]
then
  print_msg success "Successfully installed git $LATEST_VERSION"
  print_msg step "Step 6/6: Removing source folder"
  if sudo rm -rf /usr/src/git*
  then
    print_msg success "Installation complete"
  else
    print_msg error "Could not remove source folder! Please check /usr/src/ and remove all folders named git*"
  fi
else
  print_msg error "Error while installing git $LATEST_VERSION!"
  if command -v git
  then
    print_msg error "Versions do not match!"
  else
    print_msg error "git command not found!"
  fi
  exit 1
fi