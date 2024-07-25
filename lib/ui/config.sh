#!/bin/bash

config_ui() {
  ### Prints the config menu
  #!  Set status color depending on config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### Local variables that are only used to display the status of the current config
  #!  Variables with the prefix ´status_color´ are dynamic references to a color defined in ´lib/functions/colors.sh´
  local status_color_git
  local status_color_log
  local status_color_schedule
  local status_unsaved_changes

  ### Determine the status of GitHub backups
  #!  If GitHub backups are enabled and configured, status is okay
  #!  A warning state is determined if GitHub backups are enabled, but not configured
  if [[ ${GIT} -ne 1 ]]; then
    status_color_git="${RED}"
  else
    status_color_git="${GREEN}"
    if [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]; then
      status_color_git="${YELLOW}"
    elif [[ -z ${GIT_REPO+x} ]]; then
      status_color_git="${YELLOW}"
    fi
  fi

  ### Determine the status of the log rotation
  #!  If log rotation is enabled and configured, status is okay
  #!  A warning state is determined if log rotation is enabled, but not configured
  if [[ ${LOG_ROTATION} -ne 1 ]]; then
    status_color_log="${RED}"
  else
    status_color_log="${GREEN}"
    if [[ -z ${LOG_RETENTION+x} ]]; then
      status_color_log="${YELLOW}"
    fi
  fi

  ### Determine the status of scheduled backups
  #!  If scheduled backups are enabled and configured, status is okay
  #!  A warning state is determined if scheduled backups are enabled, but not configured
  if [[ ${SCHEDULED_BACKUPS} -ne 1 ]]; then
    status_color_schedule="${RED}"
  else
    status_color_schedule="${GREEN}"
    if [[ -z ${BACKUP_INTERVAL+x} ]]; then
      status_color_schedule="${YELLOW}"
    elif [[ -z ${TIME_UNIT+x} ]]; then
      status_color_schedule="${YELLOW}"
    fi
  fi

  ### Determine if there are unsaved changes to the config
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]; then
    status_unsaved_changes="[${RED}\u2717${WHITE}]" ### Unicode cross mark
  else
    status_unsaved_changes="[${GREEN}\u2713${WHITE}]" ### Unicode check mark
  fi

  ### Print the default menu header
  menu_header

  ### Print the config menu
  echo -e "${WHITE}|                   ${CYAN}Configuration${WHITE}                  |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Git                  | ${status_color_git}Git${WHITE}                    |${NC}"
  echo -e "${WHITE}| 2) Log Rotation         | ${status_color_log}Log Rotation${WHITE}           |${NC}"
  echo -e "${WHITE}| 3) Scheduled Backups    | ${status_color_schedule}Scheduled Backups${WHITE}      |${NC}"
  echo -e "${WHITE}| 4) Save Config          | ${status_unsaved_changes}                    |${NC}"
  echo -e "${WHITE}| 5) Show Config          |                        |${NC}"
  echo -e "${WHITE}| 6) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the info section of the menu
  menu_info

  ### Print the menu footer
  menu_footer
}

config_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the config menu
  config_ui

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
        ### Back to main menu
        return
        ;;
      h | H)
        help_config
        ;;
      1)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print the GitHub config menu
        github_menu
        ### Break out of the loop when GitHub config menu is exited
        #!  Will print the config menu again
        break
        ;;
      2)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print log rotation config menu
        log_rotation_menu
        ### Break out of the loop when log rotation config menu is exited
        #!  Will print the config menu again
        break
        ;;
      3)
        ### Clear the screen to always print the menu at the same spot
        clear
        ### Print backup schedule config menu
        backup_schedule_menu
        ### Break out of the loop when backup scheldule config menu is exited
        #!  Will print the config menu again
        break
        ;;
      4)
        success_msg "Saving config"
        ### Save the current config
        save_config
        ### Break out of the loop when config hs been saved
        #!  Will print the config menu again
        break
        ;;
      5)
        ### Show the current config including changes that were made in the current session
        show_config
        read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
        ### Break out of the loop when config has been printed
        #!  Will print the config menu again
        break
        ;;
      6)
        ### Break loop to reload the menu
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && action=""

  ### Loop back to itself
  config_menu
}
