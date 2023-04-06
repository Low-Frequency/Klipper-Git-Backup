#!/bin/bash

config_ui() {
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

    ### Config status
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]
  then
    STATUS_UNSAVED_CHANGES="[${RED}\u2717${WHITE}]"        ### Unicode cross mark
  else
    STATUS_UNSAVED_CHANGES="[${GREEN}\u2713${WHITE}]"      ### Unicode check mark
  fi

  menu_header
  echo -e "${WHITE}|                   ${CYAN}Configuration${WHITE}                  |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}              | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) GitHub               | ${STATUS_COLOR_GIT}GitHub${WHITE}                 |${NC}"
  echo -e "${WHITE}| 2) Log Rotation         | ${STATUS_COLOR_LOG}Log Rotation${WHITE}           |${NC}"
  echo -e "${WHITE}| 3) Scheduled Backups    | ${STATUS_COLOR_SCHEDULE}Scheduled Backups${WHITE}      |${NC}"
  echo -e "${WHITE}| 4) Save Config          | ${STATUS_UNSAVED_CHANGES}                    |${NC}"
  echo -e "${WHITE}| 5) Advanced             |                        |${NC}"
  echo -e "${WHITE}| 6) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_info
  menu_footer
}

config_menu() {
  clear
  config_ui
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
        github_menu
        break
        ;;
      2)
        clear
        log_rotation_menu
        break
        ;;
      3)
        clear
        backup_schedule_menu
        break
        ;;
      4)
        success_msg "Saving config"
        save_config
        break
        ;;
      5)
        # clear
        # advanced_menu
        # break
        echo -e "${PURPLE}Sorry, not implemented yet${NC}"
        ;;
      6)
        break
        ;;
      *)
        deny_action
        ;;
    esac
  done
  config_menu
}