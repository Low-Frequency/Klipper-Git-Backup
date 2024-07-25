#!/bin/bash

log_rotation_ui() {
  ### Prints the log rotation config menu
  #!  Set status color depending on config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### TODO: Log rotation via config in /etc/logrotate.d

  ### Local variables that are only used to display the status of the current config
  local status_log_rotation
  local retention_status

  ### Determine if log rotation is enabled
  if [[ ${LOG_ROTATION} -eq 0 ]]; then
    status_log_rotation="[${RED}\u2717${WHITE}] Disabled" ### Unicode cross mark
  else
    status_log_rotation="[${GREEN}\u2713${WHITE}] Enabled " ### Unicode check mark
  fi

  ### Determine log retention string
  #!  The cases are basically only for the correct wording and spacing
  if [[ ${LOG_RETENTION} -eq 1 ]]; then
    retention_status="${LOG_RETENTION} month     "
  elif [[ $((LOG_RETENTION - 10)) -lt 0 ]]; then
    retention_status="${LOG_RETENTION} months    "
  elif [[ $((LOG_RETENTION - 10)) -ge 0 ]]; then
    retention_status="${LOG_RETENTION} months   "
  fi

  ### Print default menu header
  menu_header

  ### Print log rotation config menu
  echo -e "${WHITE}|            ${CYAN}Log Rotation Configuration${WHITE}            |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Set Retention Time   | Retention: ${retention_status}|${NC}"
  echo -e "${WHITE}| 2) Toggle Log Rotation  | ${status_log_rotation}           |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the menu footer
  menu_footer
}

log_rotation_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the log rotation config menu
  log_rotation_ui

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
        ### Back to config menu
        return
        ;;
      h | H)
        help_rotation
        ;;
      1)
        ### Configure log retention
        configure_log_retention
        ;;
      2)
        ### (De-)activate log rotation
        if [[ ${LOG_ROTATION} -eq 0 ]]; then
          activate_module "log rotation"
          LOG_ROTATION=1
        else
          deactivate_module "log rotation"
          LOG_ROTATION=0
        fi
        UNSAVED_CHANGES=1
        ;;
      3)
        ### Break out of loop to reload the menu
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && action=""

  ### Loop back to itself
  log_rotation_menu
}
