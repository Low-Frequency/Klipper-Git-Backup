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
  echo -e "${WHITE}| 2) Mail                 | ${STATUS_MAIL}                    |${NC}"
  echo -e "${WHITE}| 3) Default Branch       | ${BRANCH_STATUS} |${NC}"
  echo -e "${WHITE}| 4) Repositories         | ${STATUS_REPO}                    |${NC}"
  echo -e "${WHITE}| 5) Config Folders       | ${STATUS_CONFIG}                    |${NC}"
  echo -e "${WHITE}| 6) Toggle Backup        | ${STATUS_BACKUP}           |${NC}"
  echo -e "${WHITE}| 7) Refresh Menu         |                        |${NC}"
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
        read -p "$(echo -e "${PURPLE}Please enter your GitHub username: ${NC}")" GITHUB_USER
        success_msg "Username set to ${GITHUB_USER}"
        UNSAVED_CHANGES=1
        ;;
      2)
        read -p "$(echo -e "${PURPLE}Please enter your mail address: ${NC}")" GITHUB_MAIL
        success_msg "Mail set to ${GITHUB_MAIL}"
        UNSAVED_CHANGES=1
        ;;
      3)
        read -p "$(echo -e "${PURPLE}Please enter the default branch you want to use: ${NC}")" GITHUB_BRANCH
        success_msg "Default branch set to ${GITHUB_BRANCH}"
        UNSAVED_CHANGES=1
        ;;
      4)
        if [[ ${#REPO_LIST[@]} -ne 0 ]]
        then
          REPO_COUNT="${#REPO_LIST[@]}"
        elif [[ ${#CONFIG_FOLDER_LIST[@]} -ne 0 ]]
        then
          REPO_COUNT="${#CONFIG_FOLDER_LIST[@]}"
        fi
        if [[ $REPO_COUNT -eq 0 ]]
        then
          read -p "$(echo -e "${PURPLE}How may instances should be backed up? ${NC}")" REPO_COUNT
        fi
        success_msg "Instance count has been set to ${REPO_COUNT}"
        for (( i=1; i<=$REPO_COUNT; i++ ))
        do
          read -p "$(echo -e "${PURPLE}Enter the name of repo #${i}: ${NC}")" REPO
          REPO_LIST+=("${REPO}")
          success_msg "${REPO} has been added to the list"
          REPO=""
        done
        UNSAVED_CHANGES=1
        ;;
      5)
        if [[ ${#REPO_LIST[@]} -ne 0 ]]
        then
          CONFIG_COUNT="${#REPO_LIST[@]}"
        elif [[ ${#CONFIG_FOLDER_LIST[@]} -ne 0 ]]
        then
          CONFIG_COUNT="${#CONFIG_FOLDER_LIST[@]}"
        fi
        if [[ $CONFIG_COUNT -eq 0 ]]
        then
          read -p "$(echo -e "${PURPLE}How may instances should be backed up? ${NC}")" REPO_COUNT
        fi
        success_msg "Instance count has been set to ${REPO_COUNT}"
        for (( i=1; i<=$CONFIG_COUNT; i++ ))
        do
          read -p "$(echo -e "${PURPLE}Enter the path of config folder #${i}: ${NC}")" CONFIG
          if ! echo "$CONFIG" | grep -q "^${HOME}"
          then
            if echo "$CONFIG" | grep -q "^~"
            then
              CONFIG=${CONFIG/\~/$HOME}
            else
              warning_msg "Relative path detected. Assuming relative to ${HOME}"
              CONFIG="${HOME}/${CONFIG}"
            fi
          fi
          CONFIG_FOLDER_LIST+=("${CONFIG}")
          success_msg "${CONFIG} has been added to the list"
          CONFIG=""
        done
        UNSAVED_CHANGES=1
        ;;
      6)
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
      7)
        break
        ;;
      *)
        deny_action
        ;;
    esac
  done
  github_menu
}
