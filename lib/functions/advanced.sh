#!/bin/bash

configure_git_server() {
  ### Sets the git server to user input

  local input
  local re='^([a-z0-9-]+.?)+.[a-z]+$'

  ### Set to configured value
  #!  Fallback to github.com if not configured
  GIT_SERVER=${GIT_SERVER:-github.com}

  ### Prompt the user for input
  read -r -p "$(echo -e "${PURPLE}Please enter your git server: ${NC}")" -i "github.com" -e input
  ### Validate the user input to be a somewhat valid FQDN
  #!  Can only contain alphanumeric characters and dashes
  #!  Sections have to be separated by a dot
  #!  Last section has to be only word characters
  #!  Matches some invalid FQDNs, but didn't want to overcomplicate it
  if [[ ${GIT_SERVER} == "${input}" ]]; then
    info_msg "Git server alredy set to ${GIT_SERVER}"
    info_msg "No changes were made"
  elif [[ ${input} =~ ${re} ]]; then
    GIT_SERVER=${input}
    success_msg "Server set to ${GIT_SERVER}"
    UNSAVED_CHANGES=1
  else
    ### Invalid input
    deny_action
  fi
  ### Reset input to avoid conflicts
  input=""
}

configure_git_org() {
  ### Configures the git org

  local input

  ### Promt the user for input
  read -r -p "$(echo -e "${PURPLE}Please enter your git organisation (leave empty for GitHub): ${NC}")" input
  ### Validate the input to only contain alpanumeric characters, dashes and slashes
  #!  Might be wrong, but I have no experience with git orgs, so I just hope this works
  if [[ -n ${input} ]]; then
    ### Default value in case no value is given
    GIT_ORG=${input}
    success_msg "Organisation set to ${GIT_ORG}"
    UNSAVED_CHANGES=1
  else
    ### Default to git user
    GIT_ORG=${GITHUB_USER}
    success_msg "Organisation set to ${GIT_ORG}"
    UNSAVED_CHANGES=1
  fi
  ### Reset input to avoid conflicts
  input=""
}
