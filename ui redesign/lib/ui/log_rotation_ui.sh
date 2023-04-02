#!/bin/bash

log_rotation_ui() {
  ### Set status color depending on config
  ### Disabled: Red
  ### Enabled, but not configured: Yellow
  ### Enabled and configured: Green

  ### Log Rotation status
  if [[ ${LOG_ROTATION} -eq 0 ]]
  then
    STATUS_LOG_ROTATION="[${RED}\u2717${WHITE}]"        ### Unicode cross mark
  else
    STATUS_LOG_ROTATION="[${GREEN}\u2713${WHITE}]"      ### Unicode check mark
  fi

  ### Setting menu entry depending on length of number
  if [[ $LOG_RETENTION -eq 1 ]]
  then
    RETENTION_STATUS="${LOG_RETENTION} month     "
  elif [[ $(( LOG_RETENTION - 10 )) -lt 0 ]]
  then
    RETENTION_STATUS="${LOG_RETENTION} months    "
  elif [[ $(( LOG_RETENTION - 10 )) -ge 0 ]]
  then
    RETENTION_STATUS="${LOG_RETENTION} months   "
  fi

  menu_header
  echo -e "${WHITE}|            ${CYAN}Log Rotation Configuration${WHITE}            |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}              | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Set Retention Time   | Retention: ${RETENTION_STATUS}|${NC}"
  echo -e "${WHITE}| 2) Toggle Log Rotation  | ${STATUS_LOG_ROTATION}                    |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_footer
}

log_rotation_menu() {
  clear
  log_rotation_ui
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
        read -p "$(echo -e "${PURPLE}How many months should the logs be kept? ${NC}")" LOG_RETENTION
        if [[ $LOG_RETENTION -eq 1 ]]
        then
          success_msg "Set log retention to ${LOG_RETENTION} month"
        else
          success_msg "Set log retention to ${LOG_RETENTION} months"
        fi
        UNSAVED_CHANGES=1
        ;;
      2)
        if [[ $LOG_ROTATION -eq 0 ]]
        then
          activate_module "log rotation"
          LOG_ROTATION=1
        else
          deactivate_module "log rotation"
          LOG_ROTATION=0
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
  log_rotation_menu
}
