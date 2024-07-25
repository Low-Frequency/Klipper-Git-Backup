#!/bin/bash

advanced_ui() {
  ### Prints the advanced git config menu

  local git_server_Status
  local git_org_status

  ### Set git server string to correct length
  git_server_status="${GIT_SERVER}"
  for ((i = ${#GIT_SERVER}; i < 29; i++)); do
    git_server_status="${git_server_status} "
  done

  ### Default GitHub org
  if [[ ${GIT_SERVER} == "github.com" ]]; then
    GIT_ORG=${GITHUB_USER}
  fi

  ### Ser git org string to correct length
  git_org_status=${GIT_ORG}
  for ((i = ${#GIT_ORG}; i < 29; i++)); do
    git_org_status="${git_org_status} "
  done

  ### Print default menu header
  menu_header

  ### Print advanced git config menu
  echo -e "${WHITE}|                     Advanced                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}       | ${BWHITE}Status${WHITE}                        |${NC}"
  echo -e "${WHITE}|                  |                               |${NC}"
  echo -e "${WHITE}| 1) Git Server    | ${git_server_status} |${NC}"
  echo -e "${WHITE}| 2) Organisation  | ${git_org_status} |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu  |                               |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print info section for the advanced git config
  advanced_info

  ### Print the menu footer
  menu_footer
}

advanced_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the advanced git config menu
  advanced_ui

  ### Loop until user input is valid
  while true; do
    ### Prompt the user to choose an action
    read -r -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" action

    ### Evaluate user input to execute the corresponding function
    case ${action} in
      q | Q)
        ### Exit
        quit_installer
        ;;
      b | B)
        ### Back to GitHub config menu
        return
        ;;
      h | H)
        help_advanced
        ;;
      1)
        ### Configure the git server
        configure_git_server
        ;;
      2)
        ### Configure the git org
        configure_git_org
        ;;
      3)
        ### Break out of the loop to reload the menu
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && action=""

  ### Loop back to itself
  advanced_menu
}
