#!/bin/bash

uninstall() {
  ### Uninstall script
  #!  *Insert sad pepe meme*

  local input
  local wheel_pid

  success_msg "Uninstalling..."
  info_msg "Removing local data"

  ### Remove all logs and backups
  rm -rf "${HOME}/kgb-data"

  ### Stop, disable and remove the service
  info_msg "Removing backup service"
  sudo systemctl disable kgb.service
  sudo rm /etc/systemd/system/kgb.service

  ### Stop, disable and remove the timer
  info_msg "Removing backup schedule"
  sudo systemctl disable kgb.timer
  sudo rm /etc/systemd/system/kgb.timer

  ### Remove the config
  info_msg "Deleting config"
  rm -f "${HOME}/.config/kgb.cfg"

  ### Remove GitHub configuration
  if [[ ${GIT_SERVER:-github.com} == "github.com" ]]; then
    info_msg "Deleting SSH key from GitHub"
    ### Login to account
    gh auth login -p ssh --with-token <"${HOME}/.secrets/gh-token"
    ### Get ID of used SSH key
    gh_ssh_id=$(gh ssh-key list | grep "KGB SSH key" | sed 's|\t|\n|g' | grep -E "^[0-9]+$")
    ### Delete the key from GitHub account
    gh ssh-key delete "${gh_ssh_id}" --yes
    ### Remove key from system
    rm -rf "${HOME}/.ssh/github_id_ed25519" "${HOME}/.ssh/github_id_ed25519.pub"
    ### Remove access token from system
    rm -f "${HOME}/.secrets/gh-token"
    ### Delete repo
    while true; do
      read -r -p "$(echo -e "${PURPLE}Do you want to delete the repository on GitHub? ${NC}")" -i "n" -e input
      case ${input} in
        n | N)
          info_msg "Please delete the repository manually"
          break
          ;;
        y | Y)
          gh repo delete "${GIT_REPO}" --yes
          break
          ;;
        *)
          deny_action
          ;;
      esac
    done && input=""
    ### Logout
    gh auth logout "${GITHUB_USER}"
  fi

  ### Uninstall github-cli
  loading_wheel "Uninstalling GitHub CLI" &
  wheel_pid=$!
  ### Silently uninstall GitHub CLI
  sudo apt-get remove gh -y &>/dev/null
  sudo apt-get autoremove &>/dev/null
  ### Remove github-cli repo
  sudo rm -f /etc/apt/keyrings/githubcli-archive-keyring.gpg
  sudo rm -f /etc/apt/sources.list.d/github-cli.list
  kill "${wheel_pid}"
  echo -e "\r   ${WHITE}[${PURPLE}${INFO}${WHITE}] Uninstalling GitHub CLI ${GREEN}done${NC}"

  ### Remove github-cli config
  rm -rf "${HOME}/.config/gh"

  ### Remove KGB scripts
  info_msg "Deleting scripts"
  rm -rf "${SCRIPTPATH}"

  info_msg "Please delete the access key from your GitHub Account"

  return 0
}
