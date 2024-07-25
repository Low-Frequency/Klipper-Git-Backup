#!/bin/bash

add_gh_key() {
  ### Attempt adding the key 3 times
  #!  Basically a remainder of debugging, but better safe than sorry

  info_msg "Attempting to add the key to your GitHub account"

  for i in {1..3}; do
    info_msg "Attempt ${i}/3"
    ### Add the key
    if ! gh ssh-key add "${HOME}/.ssh/github_id_ed25519.pub" -t "KGB SSH key" --type authentication; then
      ### If failes, wait 2 seconds
      sleep 2
    else
      ### Success
      return 0
    fi
    ### On failed 3rd attempt logout and return error
    if [[ ${i} -eq 3 ]]; then
      error_msg "Could not add the key to your GitHub account!"
      error_msg "Please add the key manually"
      info_msg "Logging out of your GitHub account"
      gh auth logout --user "${GITHUB_USER}"
      return 1
    fi
  done
}

setup_ssh() {
  ### Setu GitHub SSH connection

  local input

  info_msg "Setting up SSH"

  ### Make sure ´.ssh´ directory exists and has the correct permissions
  mkdir -p "${HOME}/.ssh"
  chmod 700 "${HOME}/.ssh"

  ### Install gh-cli
  info_msg "Checking if GitHub CLI has to be installed"
  if setup_gh_cli; then
    ### Setup GitHub repo
    setup_gh_repo
  else
    if [[ ${GIT_SERVER} != "github.com" ]]; then
      info_msg "Advanced installation detected"
      info_msg "Continuing setup..."
    else
      info_msg "Logging out of your GitHub account"
      gh auth logout --user "${GITHUB_USER}"
      return 1
    fi
  fi

  ### Check for an existing SSH key pair
  if [[ -f "${HOME}/.ssh/github_id_ed25519" ]]; then
    success_msg "SSH Key found"

    ### Loop until user input is valid
    while true; do
      ### Prompt user for input
      read -r -p "$(echo -e "${CYAN}Did you already add this key to your Git account? ${NC}")" -i "n" -e input

      ### Evaluate the user input to determine the correct actions
      case ${input} in
        n | N)
          ### Add the SSH key to GitHub
          if ! add_gh_key; then
            return 1
          fi
          break
          ;;
        y | Y)
          ### Key already added
          #!  Nothing to do
          success_msg "Continuing setup"
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  else
    ### No key pair found
    #!  Generate a new one
    info_msg "Generating new SSH key pair"

    ### Check for required config
    if [[ -z ${GITHUB_MAIL+x} ]]; then
      error_msg "Please configure your mail address first"
      info_msg "Logging out of your GitHub account"
      gh auth logout --user "${GITHUB_USER}"
      return 1
    else
      ### Generate the key pair
      ssh-keygen -t ed25519 -C "${GITHUB_MAIL}" -f "${HOME}/.ssh/github_id_ed25519" -q -N ""
      ### Add it to ´.ssh/config´ and set the correct permissions
      echo "IdentityFile ${HOME}/.ssh/github_id_ed25519" >>"${HOME}/.ssh/config"
      chmod 600 "${HOME}/.ssh/config"

      ### Add the SSH key to GitHub
      if ! add_gh_key; then
        return 1
      fi
    fi
  fi
  info_msg "Logging out of your GitHub account"
  gh auth logout --user "${GITHUB_USER}"
  return 0
}
