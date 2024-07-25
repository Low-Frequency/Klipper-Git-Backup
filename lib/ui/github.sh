#!/bin/bash

github_ui() {
  ### Prints the GitHub config menu
  #!  Set status color depending on config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### Local variables that are only used to display the status of the current config
  local status_backup
  local status_repo
  local status_config
  local status_user
  local status_mail
  local branch_status

  ### Set backup status string
  if [[ ${GIT} -ne 1 ]]; then
    status_backup="[${RED}\u2717${WHITE}] Disabled" ### Unicode cross mark
  else
    status_backup="[${GREEN}\u2713${WHITE}] Enabled " ### Unicode check mark
  fi

  ### Set repo status string
  if [[ -z ${GIT_REPO+x} ]]; then
    status_repo="[${RED}\u2717${WHITE}]" ### Unicode cross mark
  else
    status_repo="[${GREEN}\u2713${WHITE}]" ### Unicode check mark
  fi

  ### Set config folder status string
  if [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]; then
    status_config="[${RED}\u2717${WHITE}]" ### Unicode cross mark
  else
    status_config="[${GREEN}\u2713${WHITE}]" ### Unicode check mark
  fi

  ### Set user status string
  if [[ -z ${GITHUB_USER+x} ]]; then
    status_user="[${RED}\u2717${WHITE}]" ### Unicode cross mark
  else
    status_user="[${GREEN}\u2713${WHITE}]" ### Unicode check mark
  fi

  ### Set mail status string
  if [[ -z ${GITHUB_MAIL+x} ]]; then
    status_mail="[${RED}\u2717${WHITE}]" ### Unicode cross mark
  else
    status_mail="[${GREEN}\u2713${WHITE}]" ### Unicode check mark
  fi

  ### Set branch status string to the correct length
  if [[ -z ${GITHUB_BRANCH} ]]; then
    branch_status="[${RED}\u2717${WHITE}]"
  else
    branch_status="${GITHUB_BRANCH}"
  fi
  for ((i = ${#GITHUB_BRANCH}; i < 22; i++)); do
    branch_status="${branch_status} "
  done

  ### Print defaulr menu header
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
  echo -e "${WHITE}| 5) Config Folders       | ${status_config}                    |${NC}"
  echo -e "${WHITE}| 6) Toggle Backup        | ${status_backup}           |${NC}"
  echo -e "${WHITE}| 7) Advanced             |                        |${NC}"
  echo -e "${WHITE}| 8) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the menu footer
  menu_footer
}

github_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the GitHub config menu
  github_ui

  ### Loop until the user input is valid
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
        config_folders
        UNSAVED_CHANGES=1
        ;;
      6)
        ### (De-)activate backups
        if [[ ${GIT} -eq 0 ]]; then
          activate_module "backups"
          GIT=1
        else
          deactivate_module "backups"
          GIT=0
        fi
        UNSAVED_CHANGES=1
        break
        ;;
      7)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print the advanced git config menu
        advanced_menu
        ### Break out of the loop when advanced git config is finished
        #!  Will print the GitHub config  menu again
        break
        ;;
      8)
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
  github_menu
}
