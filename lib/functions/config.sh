#!/bin/bash

write_line_to_config() {
  ### Writes a line to the config

  local line="$1"
  echo "${line}" >>"${HOME}/.config/kgb.cfg"
}

save_config() {
  ### Saves the current configuration to the config file

  ### Make sure the ´.config´ folder exists
  mkdir -p "${HOME}/.config"

  ### Remove the old config file
  #!  Is done since the ´write_line_to_config´ function only appends to a file
  if [[ -f "${HOME}/.config/kgb.cfg" ]]; then
    rm "${HOME}/.config/kgb.cfg"
  fi

  ### Set the default git organization if the user didn't do the advanced config
  if [[ ${GIT_SERVER} == "github.com" ]]; then
    GIT_ORG=${GITHUB_USER}
  fi

  ### Write the running config to the config file
  write_line_to_config "GIT=\"${GIT}\""
  write_line_to_config "GITHUB_USER=\"${GITHUB_USER}\""
  write_line_to_config "GIT_SERVER=\"${GIT_SERVER}\""
  write_line_to_config "GIT_ORG=\"${GIT_ORG}\""
  write_line_to_config "GITHUB_MAIL=\"${GITHUB_MAIL}\""
  write_line_to_config "GIT_REPO=\"${GIT_REPO}\""
  write_line_to_config "GITHUB_BRANCH=\"${GITHUB_BRANCH}\""
  write_line_to_config "CONFIG_FOLDER_LIST=(${CONFIG_FOLDER_LIST[*]})"
  write_line_to_config "LOG_ROTATION=\"${LOG_ROTATION}\""
  write_line_to_config "LOG_RETENTION=\"${LOG_RETENTION}\""
  write_line_to_config "SCHEDULED_BACKUPS=\"${SCHEDULED_BACKUPS}\""
  write_line_to_config "BACKUP_INTERVAL=\"${BACKUP_INTERVAL}\""
  write_line_to_config "TIME_UNIT=\"${TIME_UNIT}\""
  write_line_to_config "SPOOLMAN_DATA=\"${SPOOLMAN_DATA}\""

  ### Reset the unsaved changes tracker
  UNSAVED_CHANGES=0
}

show_config() {
  ### Shows the current config
  #!  Cases are only for formatting

  echo ""
  info_msg "### Current configuration ###"
  if [[ ${GIT} -eq 1 ]]; then
    success_msg "Backups are enabled"
    info_msg "GITHUB_USER: ${GITHUB_USER}"
    info_msg "GIT_SERVER: ${GIT_SERVER}"
    info_msg "GIT_ORG: ${GIT_ORG}"
    info_msg "GITHUB_MAIL: ${GITHUB_MAIL}"
    info_msg "GITHUB_BRANCH: ${GITHUB_BRANCH}"
    info_msg "GIT_REPO: ${GIT_REPO}"
    info_msg "Backed up directories:"
    for dir in "${CONFIG_FOLDER_LIST[@]}"; do
      info_msg "    ${dir}"
    done
    if [[ -n ${SPOOLMAN_DATA} ]]; then
      info_msg "    ${SPOOLMAN_DATA}"
    fi
  else
    error_msg "Backups are disabled"
  fi
  if [[ ${LOG_ROTATION} -eq 1 ]]; then
    success_msg "Log rotation is enabled"
    info_msg "LOG_RETENTION=${LOG_RETENTION}"
  else
    error_msg "Log rotation is disabled"
  fi
  if [[ ${SCHEDULED_BACKUPS} -eq 1 ]]; then
    success_msg "Scheduled Backups are enabled"
    info_msg "TIME_UNIT=${TIME_UNIT}"
    info_msg "BACKUP_INTERVAL=${BACKUP_INTERVAL}"
  else
    error_msg "Scheduled backups are disabled"
  fi
  echo ""
}
