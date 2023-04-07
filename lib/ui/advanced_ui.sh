#!/bin/bash

### Non functional. Was just for testing, but I might implement it fully in the future

advanced_ui() {
  GIT_BASE_URL_STATUS="${GIT_BASE_URL}"
  for (( i=${#GIT_BASE_URL}; i<29; i++ ))
  do
    GIT_BASE_URL_STATUS="${GIT_BASE_URL_STATUS} "
  done

  if ! [[ -z ${GITHUB_USER+x} ]]
  then
    NAMESPACE="${GITHUB_USER}"
  fi

  NAMESPACE_STATUS="${NAMESPACE}"
  for (( i=${#NAMESPACE}; i<29; i++ ))
  do
    NAMESPACE_STATUS="${NAMESPACE_STATUS} "
  done

  menu_header
  echo -e "${WHITE}|                     Advanced                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}       | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                  |                               |${NC}"
  echo -e "${WHITE}| 1) Git Base URL  | ${GIT_BASE_URL_STATUS} |${NC}"
  echo -e "${WHITE}| 2) Git Namespace | ${NAMESPACE_STATUS} |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu  |                               |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  advanced_info
  menu_footer
}

advanced_menu() {
  clear
  advanced_ui
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
        read -p "$(echo -e "${PURPLE}Enter the base URL of the Git instance you want to use: ${NC}")" GIT_BASE_URL
        success_msg "Set base URL to ${GIT_BASE_URL}"
        UNSAVED_CHANGES=1
        ;;
      2)
        read -p "$(echo -e "${PURPLE}Enter the namespace your repository is located in: ${NC}")" NAMESPACE
        success_msg "Set namespace to ${NAMESPACE}"
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
  advanced_menu
}
