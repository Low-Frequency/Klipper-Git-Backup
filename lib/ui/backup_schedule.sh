#!/bin/bash

backup_schedule_ui() {
  ### Prints the backup schedule config menu
  #!  Set status color depending on config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### Local variables that are only used to display the status of the current config
  local status_scheduled_backups
  local schedule_status

  ### Determine if scheduled backups are enabled
  if [[ ${SCHEDULED_BACKUPS} -eq 0 ]]; then
    status_scheduled_backups="[${RED}\u2717${WHITE}] Disabled" ### Unicode cross mark
  else
    status_scheduled_backups="[${GREEN}\u2713${WHITE}] Enabled " ### Unicode check mark
  fi

  ### Determine correct length and wording for the schedule
  case ${TIME_UNIT} in
    h)
      ### Hourly schedule
      if [[ ${BACKUP_INTERVAL} -eq 1 ]]; then
        schedule_status="${BACKUP_INTERVAL} hour        "
      elif [[ ${BACKUP_INTERVAL} -lt 10 ]]; then
        schedule_status="${BACKUP_INTERVAL} hours       "
      else
        schedule_status="${BACKUP_INTERVAL} hours      "
      fi
      if [[ -z ${BACKUP_INTERVAL+x} ]]; then
        schedule_status="${RED}Invalid config${WHITE}"
      fi
      ;;
    d)
      ### Daily schedule
      if [[ ${BACKUP_INTERVAL} -eq 1 ]]; then
        schedule_status="${BACKUP_INTERVAL} day         "
      elif [[ ${BACKUP_INTERVAL} -lt 10 ]]; then
        schedule_status="${BACKUP_INTERVAL} days        "
      else
        schedule_status="${BACKUP_INTERVAL} days       "
      fi
      if [[ -z ${BACKUP_INTERVAL+x} ]]; then
        schedule_status="${RED}Invalid config${WHITE}"
      fi
      ;;
    m)
      ### Monthly schedule
      if [[ ${BACKUP_INTERVAL} -eq 1 ]]; then
        schedule_status="${BACKUP_INTERVAL} month       "
      elif [[ ${BACKUP_INTERVAL} -lt 10 ]]; then
        schedule_status="${BACKUP_INTERVAL} months      "
      else
        schedule_status="${BACKUP_INTERVAL} months     "
      fi
      if [[ -z ${BACKUP_INTERVAL+x} ]]; then
        schedule_status="${RED}Invalid config${WHITE}"
      fi
      ;;
    *)
      ### Broken config
      schedule_status="${RED}Invalid config${WHITE}"
      ;;
  esac

  ### Print default menu header
  menu_header

  ### Print backup schedule config menu
  echo -e "${WHITE}|          ${CYAN}Backup Schedule Configuration${WHITE}           |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Set Schedule         | ${schedule_status}         |${NC}"
  echo -e "${WHITE}| 2) Toggle Schedule      | ${status_scheduled_backups}           |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the menu footer
  menu_footer
}

show_timetable() {
  ### Info section about supported time intervals

  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  echo -e "${WHITE}|               ${BWHITE}Availabe time units${WHITE}                |${NC}"
  echo -e "${WHITE}| h: hours                                         |${NC}"
  echo -e "${WHITE}| d: days                                          |${NC}"
  echo -e "${WHITE}| m: months                                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

backup_schedule_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the backup schedule config menu
  backup_schedule_ui

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
        help_schedule
        ;;
      1)
        ### Print info section about supported time intervals
        show_timetable
        ### Configure backup schedule
        set_schedule
        UNSAVED_CHANGES=1
        ;;
      2)
        ### (De-)activate scheduled backups
        if [[ ${SCHEDULED_BACKUPS} -eq 0 ]]; then
          activate_module "scheduled backups"
          SCHEDULED_BACKUPS=1
        else
          deactivate_module "scheduled backups"
          SCHEDULED_BACKUPS=0
        fi
        UNSAVED_CHANGES=1
        ;;
      3)
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
  backup_schedule_menu
}
