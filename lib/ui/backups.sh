#!/bin/bash

backups_ui() {
  ### Prints the backup menu
  #!  Status colors are set based on the config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  local status_config_folders
  local status_schedule
  local status_backup

  ### Set config folder status string
  if [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]; then
    status_config_folders="[${RED}${CROSS}${WHITE}]"
  else
    status_config_folders="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Determine the status of scheduled backups
  #!  If scheduled backups are enabled and configured, status is okay
  #!  A warning state is determined if scheduled backups are enabled, but not configured
  if [[ ${SCHEDULED_BACKUPS} -ne 1 ]]; then
    status_schedule="[${RED}${CROSS}${WHITE}]"
  else
    status_schedule="[${GREEN}${CHECK}${WHITE}]"
    if [[ -z ${BACKUP_INTERVAL+x} ]]; then
      status_schedule="[${YELLOW}${EXCLM}${WHITE}]"
    elif [[ -z ${TIME_UNIT+x} ]]; then
      status_schedule="[${YELLOW}${EXCLM}${WHITE}]"
    fi
  fi

  ### Set backup status string
  if [[ ${GIT} -ne 1 ]]; then
    status_backup="[${RED}${CROSS}${WHITE}]" ### Unicode cross mark
  else
    status_backup="[${GREEN}${CHECK}${WHITE}]" ### Unicode check mark
  fi

  ### Print the default menu header
  menu_header

  ### Print the main menu
  echo -e "${WHITE}|                ${CYAN}Backup configuration${WHITE}              |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Config Folders       | ${status_config_folders}                    |${NC}"
  echo -e "${WHITE}| 2) Scheduled Backups    | ${status_schedule}                    |${NC}"
  echo -e "${WHITE}| 3) Toggle Backup        | ${status_backup}                    |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the info section of the menu
  menu_info

  ### Print the menu footer
  menu_footer
}

backups_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the backups config menu
  backups_ui

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
        # help_backups
        help_backups
        ;;
      1)
        ### Configure printer_data folders
        config_folders
        ;;
      2)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print backup schedule config menu
        backup_schedule_menu
        ### Break out of the loop when backup scheldule config menu is exited
        #!  Will print the backup config menu again
        break
        ;;
      3)
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
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Loop back to itself
  backups_menu
}
