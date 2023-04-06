#!/bin/bash

main_ui() {
  ### Set status color depending on config
  ### Disabled: Red
  ### Enabled, but not configured: Yellow
  ### Enabled and configured: Green

  ### GitHub status
  if [[ $GIT -ne 1 ]]
  then
    STATUS_COLOR_GIT="${RED}"
  else
    STATUS_COLOR_GIT="${GREEN}"
    if [[ ${#REPO_LIST[@]} -eq 0 ]]
    then
      STATUS_COLOR_GIT="${YELLOW}"
    elif [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]
    then
      STATUS_COLOR_GIT="${YELLOW}"
    fi
  fi

  ### Log Rotation status
  if [[ $LOG_ROTATION -ne 1 ]]
  then
    STATUS_COLOR_LOG="${RED}"
  else
    STATUS_COLOR_LOG="${GREEN}"
    if [[ -z ${LOG_RETENTION+x} ]]
    then
      STATUS_COLOR_LOG="${YELLOW}"
    fi
  fi

  ### Scheduled Backups status
  if [[ $SCHEDULED_BACKUPS -ne 1 ]]
  then
    STATUS_COLOR_SCHEDULE="${RED}"
  else
    STATUS_COLOR_SCHEDULE="${GREEN}"
    if [[ -z ${BACKUP_INTERVAL+x} ]]
    then
      STATUS_COLOR_SCHEDULE="${YELLOW}"
    elif [[ -z ${TIME_UNIT+x} ]]
    then
      STATUS_COLOR_SCHEDULE="${YELLOW}"
    fi
  fi

  if [[ ${#REPO_LIST[@]} -eq 0 ]]
  then
    BACKUP_COUNT="Backing up ${#REPO_LIST[@]} Folders   "
  elif [[ ${#REPO_LIST[@]} -eq 1 ]]
  then
    BACKUP_COUNT="Backing up ${#REPO_LIST[@]} Folder    "
  elif [[ $(( ${#REPO_LIST[@]} - 10 )) -lt 0 ]]
  then
    BACKUP_COUNT="Backing up ${#REPO_LIST[@]} Folders   "
  else
    BACKUP_COUNT="Backing up ${#REPO_LIST[@]} Folders  "
  fi

  menu_header
  echo -e "${WHITE}|                     ${CYAN}Main Menu${WHITE}                    |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}              | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Configure            | ${STATUS_COLOR_GIT}GitHub${WHITE}                 |${NC}"
  echo -e "${WHITE}| 2) Install              | ${STATUS_COLOR_LOG}Log Rotation${WHITE}           |${NC}"
  echo -e "${WHITE}| 3) Update               | ${STATUS_COLOR_SCHEDULE}Scheduled Backups${WHITE}      |${NC}"
  echo -e "${WHITE}| 4) Backup               |                        |${NC}"
  echo -e "${WHITE}| 5) Restore              |                        |${NC}"
  echo -e "${WHITE}| 6) Uninstall            | ${BACKUP_COUNT}|${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_info
  menu_footer
}

main_menu() {
  clear
  main_ui
  local ACTION
  while true
  do
    read -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" ACTION
    case $ACTION in
      q|Q)
        quit_installer
        ;;
      b|B)
        return
        ;;
      1)
        clear
        config_menu
        break
        ;;
      2)
        install_dialog
        break
        ;;
      3)
        update_dialog
        ;;
      4)
        backup_dialog
        ;;
      5)
        clear
        restore_menu
        break
        ;;
      6)
        uninstall_dialog
        ;;
      *)
        deny_action
        ;;
    esac
  done
  main_menu
}
