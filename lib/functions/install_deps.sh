#!/bin/bash

loading_wheel() {
  ### Fun loading wheel

  ### Endless loop
  while true; do
    ### Print specified character each 0.1 second
    #!  Overwites the line every time
    # shellcheck disable=SC1003
    for char in '|' '/' '-' '\'; do
      echo -en "\r   ${WHITE}[${PURPLE}${INFO}${WHITE}]${NC} $1 ${char}"
      sleep 0.1
    done
  done
}

setup_gh_cli() {
  ### Installs gh-cli
  #!  Is used to manage GitHub repos and SSH keys

  local input
  local wheel_pid

  ### Check if git server is github.com
  #!  If it is not set, default to github.com
  if [[ ${GIT_SERVER:-github.com} == "github.com" ]]; then
    ### Check if GitHub CLI already is installed
    if ! command -v gh &>/dev/null; then
      ### Check requirement for install
      if ! command -v wget &>/dev/null; then
        ### Install ´wget´
        #!  Start loading wheel as background task
        loading_wheel "Installing dependencies" &
        ### Get PID of loading wheel
        wheel_pid=$!
        ### Silently install wget
        sudo apt-get update &>/dev/null
        apt-get install wget -y &>/dev/null
        ### Kill loading wheel
        kill "${wheel_pid}"
        ### Overwrite last loading wheel line
        echo -e "\r   ${WHITE}[${PURPLE}${INFO}${WHITE}] Installing dependecies ${GREEN}done${NC}"
      fi
      ### Start loading wheel as background task
      loading_wheel "Installing GitHub CLI" &
      ### Get PID of loading wheel
      wheel_pid=$!
      ### Get GitHub CLI Keyring
      wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
      sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
      ### Configure necessary repo
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
      ### Silently install GitHub CLI
      sudo apt-get update &>/dev/null
      sudo apt-get install gh -y &>/dev/null
      ### Kill loading wheel
      kill "${wheel_pid}"
      ### Overwrite last loading wheel line
      echo -e "\r   ${WHITE}[${PURPLE}${INFO}${WHITE}] Installing GitHub CLI ${GREEN}done${NC}"
    fi
    info_msg "Attempting login to your GitHub Account"
    ### Check if access token is present
    if [[ ! -f ${HOME}/.secrets/gh-token ]]; then
      error_msg "GitHub Token could not be found!"
      error_msg "Please create a fine-grained access token according to the instructions in README.md and place it in ${HOME}/.secrets/gh-token"
      input=""
      return 1
    fi
    ### Try to log in to GitHub account
    if gh auth login -p ssh --with-token <"${HOME}/.secrets/gh-token"; then
      success_msg "Successfully logged in to GitHub"
      return 0
    else
      ### Something went wrong
      #!  Can't be determined what exactly, so print suggestions to troubleshoot
      error_msg "Could not log in to GitHub!"
      error_msg "It could be that the permissions on your token (or the token file) are wrong"
      input=""
      return 1
    fi
  else
    ### Non standard git server
    #!  Can't use GitHub CLI
    warning_msg "Git server is not set to github.com"
    warning_msg "It is in your obligation to make sure all requirements are met"
    input=""
    return 1
  fi
}

setup_gh_repo() {
  ### Creates a new GitHub repo

  info_msg "Checking if the specified repo already exists"
  if gh repo list "${GITHUB_USER}" | grep -q "${GIT_REPO}"; then
    info_msg "GitHub repo already exists"
  else
    info_msg "Repo not found"
    info_msg "Creating the repo"
    gh repo create "${GIT_REPO}" --private -d "Klipper backups powered by KGB"
  fi
}
