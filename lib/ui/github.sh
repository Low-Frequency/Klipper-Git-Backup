#!/bin/bash

github_ui() {
  ### Prints the GitHub config menu
  #!  Set status color depending on config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### Local variables that are only used to display the status of the current config
  local status_repo
  local status_user
  local status_mail
  local branch_status

  ### Set user status string
  if [[ -z ${GITHUB_USER+x} ]]; then
    status_user="[${RED}${CROSS}${WHITE}]"
  else
    status_user="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Set mail status string
  if [[ -z ${GITHUB_MAIL+x} ]]; then
    status_mail="[${RED}${CROSS}${WHITE}]"
  else
    status_mail="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Set branch status string to the correct length
  if [[ -z ${GITHUB_BRANCH} ]]; then
    branch_status="[${RED}${CROSS}${WHITE}]                   "
  else
    branch_status="${GITHUB_BRANCH}"
  fi
  for ((i = ${#GITHUB_BRANCH}; i < 22; i++)); do
    branch_status="${branch_status} "
  done

  ### Set repo status string
  if [[ -z ${GIT_REPO+x} ]]; then
    status_repo="[${RED}${CROSS}${WHITE}]"
  else
    status_repo="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Print default menu header
  menu_header

  ### Print the GitHub config menu
  echo -e "${WHITE}|                 ${CYAN}Git Configuration${WHITE}                |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) User                 | ${status_user}                    |${NC}"
  echo -e "${WHITE}| 2) Mail                 | ${status_mail}                    |${NC}"
  echo -e "${WHITE}| 3) Default Branch       | ${branch_status} |${NC}"
  echo -e "${WHITE}| 4) Repository           | ${status_repo}                    |${NC}"
  echo -e "${WHITE}| 5) Advanced             |                        |${NC}"
  echo -e "${WHITE}| 6) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the menu footer
  menu_footer
}

github_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the GitHub config menu
  github_ui

  ### Loop until the user input is valid
  while true; do
    ### Prompt the user to choose an action
    read -r -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" input

    ### Evaluate user input to execute the corresponding function
    case ${input} in
      q | Q)
        ### Exit
        quit_installer
        ;;
      b | B)
        ### Back to config menu
        return
        ;;
      h | H)
        help_github
        ;;
      1)
        ### Configure GitHub user
        configure_git_user
        ;;
      2)
        ### Configure GitHub mail address
        configure_mail_address
        ;;
      3)
        ### Configure default branch
        configure_default_branch
        ;;
      4)
        config_repo
        UNSAVED_CHANGES=1
        ;;
      5)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print the advanced git config menu
        advanced_menu
        ### Break out of the loop when advanced git config is finished
        #!  Will print the GitHub config  menu again
        break
        ;;
      6)
        ### Break out of the loop to reload the menu
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Loop back to itself
  github_menu
}
