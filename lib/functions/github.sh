#!/bin/bash

configure_git_user() {
  ### Configure GitHub user

  local input

  ### Changes to this will trigger unsaved changes
  #!  No input will not change the config
  read -r -p "$(echo -e "${PURPLE}Please enter your Git username: ${NC}")" input
  ### Check if user input differs from current config or no input was given
  if [[ ${GITHUB_USER} == "${input}" ]] || [[ -z ${input} ]]; then
    warning_msg "No changes were made"
    warning_msg "Username is set to ${GITHUB_USER}"
  else
    ### Set GitHub user to user input
    GITHUB_USER="${input}"
    success_msg "Username set to ${GITHUB_USER}"
    UNSAVED_CHANGES=1
  fi
  ### Reset input to prevent misconfiguration
  input=""
}

configure_mail_address() {
  ### Configure GitHub mail address

  local input

  ### Changes to this will trigger unsaved changes
  #!  No input will not change the config
  read -r -p "$(echo -e "${PURPLE}Please enter your mail address: ${NC}")" input
  ### Check if user input differs from current config or no input was given
  if [[ ${GITHUB_MAIL} == "${input}" ]] || [[ -z ${input} ]]; then
    warning_msg "No changes were made"
    warning_msg "Mail is set to ${GITHUB_MAIL}"
  else
    ### Set GitHub mail to user input
    GITHUB_MAIL="${input}"
    success_msg "Mail set to ${GITHUB_MAIL}"
    UNSAVED_CHANGES=1
  fi
  ### Reset input to prevent misconfiguration
  input=""
}

configure_default_branch() {
  ### Configure default branch

  local input

  ### Changes to this will trigger unsaved changes
  #!  No input will not change the config
  read -r -p "$(echo -e "${PURPLE}Please enter the default branch you want to use: ${NC}")" -i "main" -e input
  ### Check if user input differs from current config or no input was given
  if [[ ${GITHUB_BRANCH} == "${input}" ]] || [[ -z ${input} ]]; then
    warning_msg "No changes were made"
    ### Fallback to default if branch was not configured and no input was given
    GITHUB_BRANCH="${GITHUB_BRANCH:-main}"
    warning_msg "Default branch is set to ${GITHUB_BRANCH}"
  else
    ### Set default branch to user input
    GITHUB_BRANCH="${input}"
    success_msg "Default branch set to ${GITHUB_BRANCH}"
    UNSAVED_CHANGES=1
  fi
  ### Reset input to prevent misconfiguration
  input=""
}

config_repo() {
  ### Configure GitHub repo

  local input
  local re='^[a-zA-Z0-9-]+$'

  ### Loop until user input is valid
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${PURPLE}Enter the name of your backup repo: ${NC}")" -i "klipper-backups-by-kgb" -e input
    ### Validate user input
    if [[ -z ${input} ]] || [[ ${input} == "${GIT_REPO}" ]]; then
      info_msg "Not changing repo"
      info_msg "Repo remains ${GIT_REPO}"
      break
    else
      if [[ ${input} =~ ${re} ]]; then
        GIT_REPO="${input}"
        success_msg "Repo set to ${GIT_REPO}"
        break
      else
        deny_action
      fi
    fi
  done && input=""
}
