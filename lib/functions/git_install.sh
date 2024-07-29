#!/bin/bash

install_git() {
  ### Install latest git from source

  ### Requirements for git install
  local requirements=(
    make
    libssl-dev
    libghc-zlib-dev
    libcurl4-gnutls-dev
    libexpat1-dev
    gettext
  )

  ### Get latest release
  local latest_version
  local version_number

  latest_version=$(curl -s https://github.com/git/git/tags | grep "/git/git/releases/tag" | grep -oE "v[0-9]\.[0-9]+\.[0-9]+(-rc[0-9])?" | uniq | head -1)
  version_number=${latest_version//v/}

  ### Check if git is installed
  if command -v git &>/dev/null; then
    ### Check the version
    if [[ $(git --version) == "git version ${version_number}" ]]; then
      success_msg "git already up to date"
      return 0
    else
      ### Uninstall git
      info_msg "Step 1/6: Removing existing installation"
      sudo apt-get remove git -y
      sudo apt-get autoremove -y
    fi
  fi

  ### Install dependencies
  info_msg "Step 2/6: Installing dependencies. ${#requirements[@]} required packets"
  sudo apt-get update
  for i in "${!requirements[@]}"; do
    info_msg "Installing packet $((i + 1))/${#requirements[@]}: ${requirements[${i}]}"
    sudo apt-get install "${requirements[${i}]}" -y
  done

  ### Download latest release
  info_msg "Step 3/6: Downloading latest release"
  sudo wget -qO /usr/src/git.tar.gz "https://github.com/git/git/archive/refs/tags/${latest_version}.tar.gz"
  ### Unpack the downloaded archive
  sudo tar -xf /usr/src/git.tar.gz -C "/usr/src"

  ### Compile and install git
  info_msg "Step 4/6: Installing git"
  sudo make -C "/usr/src/git-${version_number}" prefix=/usr/local all
  sudo make -C "/usr/src/git-${version_number}" prefix=/usr/local install

  ### Verify installation
  info_msg "Step 5/6: Verifying installation"
  if [[ $(git --version) == "git version ${version_number}" ]]; then
    success_msg "sucessfully installed git ${latest_version}"
    info_msg "Step 6/6: Removing source folder"
    ### Remove source code
    if sudo rm -rf /usr/src/git*; then
      success "Installation complete"
    else
      error_msg "Could not remove source folder! Please check /usr/src/ and remove all folders named git*"
    fi
  else
    error_msg "Error while installing git ${latest_version}!"
    if command -v git; then
      error_msg "Versions do not match!"
    else
      error_msg "git command not found!"
    fi
    return 1
  fi
  return 0
}
