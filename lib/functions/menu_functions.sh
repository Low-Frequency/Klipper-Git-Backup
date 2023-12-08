#!/bin/bash

quit_installer() {
  if [[ $UNSAVED_CHANGES -ne 0 ]]; then
    while true; do
      warning_msg "You have config changes pending!"
      read -r -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
      case $SAVE_CHANGES in
      y | Y)
        save_config
        UNSAVED_CHANGES=0
        check_install
        if [[ $SKIP_INSTALL -eq 1 ]]; then
          break
        else
          continue
        fi
        ;;
      n | N)
        warning_msg "Your changes will be lost!"
        while true; do
          read -r -p "$(echo -e "${CYAN}Continue? ${NC}")" LOOSE_CHANGES
          case $LOOSE_CHANGES in
          y | Y)
            warning_msg "Discarding changes"
            check_install
            if [[ $SKIP_INSTALL -eq 1 ]]; then
              break
            else
              continue
            fi
            ;;
          n | N)
            success_msg "Resuming"
            return 0
            ;;
          *)
            deny_action
            ;;
          esac
        done
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
  success_msg "Exiting"
  exit 0
}

check_install() {
  # shellcheck disable=SC2153
  if [[ $INSTALLED -eq 0 ]]; then
    while true; do
      warning_msg "You haven't installed the script yet!"
      warning_msg "This will lead to errors if you want to use the script"
      read -r -p "$(echo -e "${CYAN}Continue anyway? ${NC}")" INSTALLER
      case $INSTALLER in
      y | Y)
        SKIP_INSTALL=1
        break
        ;;
      n | N)
        SKIP_INSTALL=0
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
}

config_repo() {
  if [[ ${#REPO_LIST[@]} -ne 0 ]]; then
    REPO_COUNT="${#REPO_LIST[@]}"
  elif [[ ${#CONFIG_FOLDER_LIST[@]} -ne 0 ]]; then
    REPO_COUNT="${#CONFIG_FOLDER_LIST[@]}"
  fi
  if [[ $REPO_COUNT -eq 0 ]]; then
    while true; do
      read -r -p "$(echo -e "${PURPLE}How many instances should be backed up? ${NC}")" REPO_COUNT
      case $REPO_COUNT in
      [0-9]*)
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
  success_msg "Instance count has been set to ${REPO_COUNT}"
  for ((i = 1; i <= REPO_COUNT; i++)); do
    read -r -p "$(echo -e "${PURPLE}Enter the name of repo #${i}: ${NC}")" REPO
    REPO_LIST+=("${REPO}")
    success_msg "${REPO} has been added to the list"
    REPO=""
  done
}

config_folders() {
  if [[ ${#REPO_LIST[@]} -ne 0 ]]; then
    CONFIG_COUNT="${#REPO_LIST[@]}"
  elif [[ ${#CONFIG_FOLDER_LIST[@]} -ne 0 ]]; then
    CONFIG_COUNT="${#CONFIG_FOLDER_LIST[@]}"
  fi
  if [[ $CONFIG_COUNT -eq 0 ]]; then
    while true; do
      read -r -p "$(echo -e "${PURPLE}How many instances should be backed up? ${NC}")" REPO_COUNT
      case $REPO_COUNT in
      [0-9]*)
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
  success_msg "Instance count has been set to ${REPO_COUNT}"
  for ((i = 1; i <= CONFIG_COUNT; i++)); do
    read -r -p "$(echo -e "${PURPLE}Enter the path of config folder #${i}: ${NC}")" CONFIG
    if ! echo "$CONFIG" | grep -q "^${HOME}"; then
      if echo "$CONFIG" | grep -q "^~"; then
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
}

set_schedule() {
  while true; do
    read -r -p "$(echo -e "${CYAN}What time unit should the schedule comply to? ${NC}")" TIME_UNIT
    case $TIME_UNIT in
    h)
      success_msg "Set time unit to hours"
      UNITS="hours"
      break
      ;;
    d)
      success_msg "Set time unit to days"
      UNITS="days"
      break
      ;;
    m)
      success_msg "Set time unit to months"
      UNITS="months"
      break
      ;;
    *)
      deny_action
      ;;
    esac
  done
  while true; do
    read -r -p "$(echo -e "${CYAN}How many ${UNITS} between the backups? ${NC}")" BACKUP_INTERVAL
    case $BACKUP_INTERVAL in
    [0-9]*)
      success_msg "Backing up every ${BACKUP_INTERVAL} ${UNITS}"
      break
      ;;
    *)
      deny_action
      ;;
    esac
  done
}
