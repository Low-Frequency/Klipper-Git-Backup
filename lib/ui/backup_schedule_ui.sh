#!/bin/bash

backup_schedule_ui() {
  ### Set status color depending on config
  ### Disabled: Red
  ### Enabled, but not configured: Yellow
  ### Enabled and configured: Green

  ### Log Rotation status
  if [[ ${SCHEDULED_BACKUPS} -eq 0 ]]; then
    STATUS_SCHEDULED_BACKUPS="[${RED}\u2717${WHITE}] Disabled" ### Unicode cross mark
  else
    STATUS_SCHEDULED_BACKUPS="[${GREEN}\u2713${WHITE}] Enabled " ### Unicode check mark
  fi

  ### Setting menu entry depending on schedule
  case $TIME_UNIT in
  h)
    if [[ $BACKUP_INTERVAL -eq 1 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} hour        "
    elif [[ $BACKUP_INTERVAL -lt 10 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} hours       "
    else
      SCHEDULE_STATUS="${BACKUP_INTERVAL} hours      "
    fi
    if [[ -z ${BACKUP_INTERVAL+x} ]]; then
      SCHEDULE_STATUS="${RED}Invalid config${WHITE}"
    fi
    ;;
  d)
    if [[ $BACKUP_INTERVAL -eq 1 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} day         "
    elif [[ $BACKUP_INTERVAL -lt 10 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} days        "
    else
      SCHEDULE_STATUS="${BACKUP_INTERVAL} days       "
    fi
    if [[ -z ${BACKUP_INTERVAL+x} ]]; then
      SCHEDULE_STATUS="${RED}Invalid config${WHITE}"
    fi
    ;;
  m)
    if [[ $BACKUP_INTERVAL -eq 1 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} month       "
    elif [[ $BACKUP_INTERVAL -lt 10 ]]; then
      SCHEDULE_STATUS="${BACKUP_INTERVAL} months      "
    else
      SCHEDULE_STATUS="${BACKUP_INTERVAL} months     "
    fi
    if [[ -z ${BACKUP_INTERVAL+x} ]]; then
      SCHEDULE_STATUS="${RED}Invalid config${WHITE}"
    fi
    ;;
  *)
    SCHEDULE_STATUS="${RED}Invalid config${WHITE}"
    ;;
  esac

  menu_header
  echo -e "${WHITE}|          ${CYAN}Backup Schedule Configuration${WHITE}           |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}              | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Set Schedule         | ${SCHEDULE_STATUS}         |${NC}"
  echo -e "${WHITE}| 2) Toggle Schedule      | ${STATUS_SCHEDULED_BACKUPS}           |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_footer
}

show_timetable() {
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  echo -e "${WHITE}|               ${BOLD}Availabe time units${WHITE}                |${NC}"
  echo -e "${WHITE}| h: hours                                         |${NC}"
  echo -e "${WHITE}| d: days                                          |${NC}"
  echo -e "${WHITE}| m: months                                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
}

backup_schedule_menu() {
  clear
  backup_schedule_ui
  local ACTION
  while true; do
    read -r -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" ACTION
    case $ACTION in
    q | Q)
      quit_installer
      ;;
    b | B)
      return
      ;;
    1)
      show_timetable
      set_schedule
      UNSAVED_CHANGES=1
      ;;
    2)
      if [[ $SCHEDULED_BACKUPS -eq 0 ]]; then
        activate_module "scheduled backups"
        SCHEDULED_BACKUPS=1
      else
        deactivate_module "scheduled backups"
        SCHEDULED_BACKUPS=0
      fi
      UNSAVED_CHANGES=1
      ;;
    3)
      break
      ;;
    *)
      deny_action
      ;;
    esac
  done
  backup_schedule_menu
}
