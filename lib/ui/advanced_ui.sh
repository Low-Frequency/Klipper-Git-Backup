#!/bin/bash

### Non functional. Was just for testing, but I might implement it fully in the future

advanced_ui() {
  GIT_SERVER_STATUS="${GIT_SERVER}"
  for ((i = ${#GIT_SERVER}; i < 29; i++)); do
    GIT_SERVER_STATUS="${GIT_SERVER_STATUS} "
  done

  if [[ $GIT_SERVER == "github.com" ]]; then
    GIT_ORG=${GITHUB_USER}
  fi

  GIT_ORG_STATUS=${GIT_ORG}
  for ((i = ${#GIT_ORG}; i < 29; i++)); do
    GIT_ORG_STATUS="${GIT_ORG_STATUS} "
  done

  menu_header
  echo -e "${WHITE}|                     Advanced                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}       | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                  |                               |${NC}"
  echo -e "${WHITE}| 1) Git Server    | ${GIT_SERVER_STATUS} |${NC}"
  echo -e "${WHITE}| 2) Organisation  | ${STATUS_ORG} |${NC}"
  echo -e "${WHITE}| 3) Refresh Menu  |                               |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  advanced_info
  menu_footer
}

advanced_menu() {
  clear
  advanced_ui
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
      read -r -p "$(echo -e "${PURPLE}Please enter your Git Server (default: github.com): ${NC}")" GIT_SERVER
      GIT_SERVER=${GIT_SERVER:-github.com}
      success_msg "Server set to ${GIT_SERVER}"
      UNSAVED_CHANGES=1
      ;;
    2)
      read -r -p "$(echo -e "${PURPLE}Please enter your Git Organisation (for github enter your username): ${NC}")" GIT_ORG
      GIT_ORG=${GIT_ORG:-${GITHUB_USER}}
      success_msg "Organisation set to ${GIT_ORG}"
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
