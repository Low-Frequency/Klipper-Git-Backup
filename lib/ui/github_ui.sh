#!/bin/bash

github_ui() {
  ### Set status color depending on config
  ### Disabled: Red
  ### Enabled, but not configured: Yellow
  ### Enabled and configured: Green

  ### Backup status
  if [[ $GIT -ne 1 ]]
  then
    STATUS_BACKUP="[${RED}\u2717${WHITE}] Disabled"      ### Unicode cross mark
  else
    STATUS_BACKUP="[${GREEN}\u2713${WHITE}] Enabled "    ### Unicode check mark
  fi

  ### Repo status
  if [[ ${#REPO_LIST[@]} -eq 0 ]]
  then
    STATUS_REPO="[${RED}\u2717${WHITE}]"        ### Unicode cross mark
  else
    STATUS_REPO="[${GREEN}\u2713${WHITE}]"      ### Unicode check mark
  fi

  ### Config folder status
  if [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]
  then
    STATUS_CONFIG="[${RED}\u2717${WHITE}]"      ### Unicode cross mark
  else
    STATUS_CONFIG="[${GREEN}\u2713${WHITE}]"    ### Unicode check mark
  fi

  if [[ -z ${GITHUB_USER+x} ]]
  then
    STATUS_USER="[${RED}\u2717${WHITE}]"      ### Unicode cross mark
  else
    STATUS_USER="[${GREEN}\u2713${WHITE}]"    ### Unicode check mark
  fi
  
    if [[ -z ${GIT_SERVER+x} ]]
  then
    STATUS_SERVER="[${RED}\u2717${WHITE}]"      ### Unicode cross mark
  else
    STATUS_SERVER="[${GREEN}\u2713${WHITE}]"    ### Unicode check mark
  fi

	if [[ -z ${GIT_ORG+x} ]]
		then
    STATUS_ORG="[${RED}\u2717${WHITE}]"      ### Unicode cross mark
  else
    STATUS_ORG="[${GREEN}\u2713${WHITE}]"    ### Unicode check mark
  fi
  if [[ -z ${GITHUB_MAIL+x} ]]
  then
    STATUS_MAIL="[${RED}\u2717${WHITE}]"      ### Unicode cross mark
  else
    STATUS_MAIL="[${GREEN}\u2713${WHITE}]"    ### Unicode check mark
  fi

  BRANCH_LEN=${#GITHUB_BRANCH}
  BRANCH_STATUS="${GITHUB_BRANCH}"
  for (( i=$BRANCH_LEN; i<22; i++ ))
  do
    BRANCH_STATUS="${BRANCH_STATUS} "
  done

  menu_header
  echo -e "${WHITE}|               ${CYAN}GitHub Configuration${WHITE}               |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BOLD}Actions${WHITE}              | ${BOLD}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) User                 | ${STATUS_USER}                    |${NC}"
  echo -e "${WHITE}| 2) Git Server           | ${STATUS_SERVER}                    |${NC}"
  echo -e "${WHITE}| 3) Organisation         | ${STATUS_ORG}                    |${NC}"
  echo -e "${WHITE}| 4) Mail                 | ${STATUS_MAIL}                    |${NC}"
  echo -e "${WHITE}| 5) Default Branch       | ${BRANCH_STATUS} |${NC}"
  echo -e "${WHITE}| 6) Repositories         | ${STATUS_REPO}                    |${NC}"
  echo -e "${WHITE}| 7) Config Folders       | ${STATUS_CONFIG}                    |${NC}"
  echo -e "${WHITE}| 8) Toggle Backup        | ${STATUS_BACKUP}           |${NC}"
  echo -e "${WHITE}| 9) Refresh Menu         |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_footer
}

github_menu() {
  clear
  github_ui
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
        read -p "$(echo -e "${PURPLE}Please enter your Git username: ${NC}")" GITHUB_USER
        success_msg "Username set to ${GITHUB_USER}"
        UNSAVED_CHANGES=1
        ;;
	  2)
        read -p "$(echo -e "${PURPLE}Please enter your Git Server (default: github.com): ${NC}")" GIT_SERVER
        success_msg "Server set to ${GIT_SERVER}"
		GIT_SERVER=${GIT_SERVER:-github.com}
        UNSAVED_CHANGES=1
        ;;
      3)
        read -p "$(echo -e "${PURPLE}Please enter your Git Organisation (for github enter your username): ${NC}")" GIT_ORG
        success_msg "Organisation set to ${GIT_ORG}"
		GIT_ORG=${GIT_ORG:-${GITHUB_USER}}
        UNSAVED_CHANGES=1
        ;;
      4)
        read -p "$(echo -e "${PURPLE}Please enter your mail address: ${NC}")" GITHUB_MAIL
        success_msg "Mail set to ${GITHUB_MAIL}"
        UNSAVED_CHANGES=1
        ;;
      5)
        read -p "$(echo -e "${PURPLE}Please enter the default branch you want to use: ${NC}")" GITHUB_BRANCH
        success_msg "Default branch set to ${GITHUB_BRANCH}"
        GITHUB_BRANCH=${GITHUB_BRANCH:-main}
        UNSAVED_CHANGES=1
        ;;
      6)
        config_repo
        UNSAVED_CHANGES=1
        ;;
      7)
        config_folders
        UNSAVED_CHANGES=1
        ;;
      8)
        if [[ $GIT -eq 0 ]]
        then
          activate_module "backups"
          GIT=1
        else
          deactivate_module "backups"
          GIT=0
        fi
        UNSAVED_CHANGES=1
        ;;
      9)
        break
        ;;
      *)
        deny_action
        ;;
    esac
  done
  github_menu
}
