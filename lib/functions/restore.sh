#!/bin/bash

restore() {
  ### The restoring part
  #!  Just checks if all parameters are present and copies the config

  local src="$1"
  local dst="$2"
  local clean_src

  ### Clean double slashes from source path
  clean_src="$(echo "${HOME}/kgb-data/backups/${src}/config/" | sed 's|//|/|g')"

  ### Check if restore destination was found
  if [[ -n ${src} ]] && [[ -n ${dst} ]]; then
    ### Copy config to existing printer_data directory
    log_msg "Restoring config from ${clean_src} to ${dst}"
    cp -r "${clean_src}/" "${dst}"
    return 0
  else
    return 1
  fi
}

get_dst() {
  ### Searches for the restore destination
  #!  Can't print messages here due to output being assigned to a variable

  local dir="$1"
  local restore_dst

  ### Check if same name exists in ${HOME}
  for dst in "${HOME}"/*/; do
    if echo "${dst}" | grep -q "${dir}"; then
      restore_dst="${dst}"
    fi
  done

  ### Return found destination
  echo "${restore_dst}"
}

local_restore() {
  ### Restores the config from the local repository
  #!  Always restores the latest backup

  local instance_id="$1"
  local dir_name
  local restore_dst
  local error=0

  ### Get instance name
  log_msg "Restoring ${CONFIG_FOLDER_LIST[${instance_id}]}"
  dir_name="$(echo "${CONFIG_FOLDER_LIST[${instance_id}]}" | sed -E 's|^.*/(.*_data)/?$|\1|')"

  ### Get restore destination
  restore_dst="$(get_dst "${dir_name}")"
  log_msg "Found restore destination ${restore_dst}"

  ### Restore
  if restore "${dir_name}" "${restore_dst}"; then
    log_msg "Restore complete"
  else
    log_msg "Could not find printer_data directory for ${CONFIG_FOLDER_LIST[${instance_id}]}"
    error=1
  fi

  ### Determine status
  if [[ ${error} -ne 0 ]]; then
    return 1
  else
    return 0
  fi
}

git_restore() {
  ### Restores the config from GitHub
  #!  Can restore backups from the past
  #!  Should be used for restoring to a new instance if it hasn't been restored during install

  local instance_id="$1"
  local input
  local dir_name
  local restore_dst
  local commit
  local re='^[0-9a-f]{40}$'
  local error=0

  ### Loop until user input is valid
  while true; do
    read -r -p "$(echo -e "${PURPLE}Please paste the commit you want to restore: ${NC}")" input
    ### Validate commit SHA
    if [[ ${input} =~ ${re} ]]; then
      log_msg "Setting commit SHA to ${input}"
      commit="${input}"
      break
    else
      ### Invalid commit SHA
      deny_action
    fi
    ### Reset input to avoid conflicts
    input=""
  done && input=""

  ### Get instance name
  log_msg "Restoring ${CONFIG_FOLDER_LIST[${instance_id}]}"
  dir_name="$(echo "${CONFIG_FOLDER_LIST[${instance_id}]}" | sed -E 's|^.*/(.*_data)/?$|\1|')"

  ### Switch to specified commit
  log_msg "Checking out commit: ${commit}"
  git -C "${HOME}/kgb-data/backups" checkout -b restore "${commit}"

  ### Get restore destination
  restore_dst="$(get_dst "${dir_name}")"

  ### Restore
  if restore "${dir_name}" "${restore_dst}"; then
    log_msg "Restore complete"
  else
    log_msg "Could not find printer_data directory for ${CONFIG_FOLDER_LIST[${instance_id}]}"
    error=1
  fi

  ### Switch back to latest commit
  log_msg "Resetting repo to latest state"
  git -C "${HOME}/kgb-data/backups" checkout "${GITHUB_BRANCH}"
  git -C "${HOME}/kgb-data/backups" branch -D restore

  if [[ ${error} -ne 0 ]]; then
    return 1
  else
    return 0
  fi
}

rm_config_bak() {
  ### Deletes the local config backup

  local input
  local clean_dir

  ### Loop until user input is valid
  while true; do
    ### Prompt for user input
    read -r -p "$(echo -e "${CYAN}Do you want to keep the local backup? ${NC}")" input
    case ${input} in
      y | Y)
        ### Keep local backup and continue
        clean_dir="$(echo "${CONFIG_FOLDER_LIST[${instance_id}]}/config_$(date +%F).bak" | sed 's|//|/|g')"
        log_msg "Old config folder is located at ${clean_dir}"
        break
        ;;
      n | N)
        ### Delete local backup
        log_msg "Deleting local backups"
        rm -rf "${CONFIG_FOLDER_LIST[${instance_id}]}/config_"*.bak
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""
}

spoolman_git_restore() {
  ### Restore spoolman database to specific commit

  local input
  local commit
  local re='^[0-9a-f]{40}$'
  local error=0

  ### Loop until user input is valid
  while true; do
    read -r -p "$(echo -e "${PURPLE}Please paste the commit you want to restore: ${NC}")" input
    ### Validate commit SHA
    if [[ ${input} =~ ${re} ]]; then
      log_msg "Setting commit SHA to ${input}"
      commit="${input}"
      break
    else
      ### Invalid commit SHA
      deny_action
    fi
    ### Reset input to avoid conflicts
    input=""
  done

  ### Switch to specified commit
  log_msg "Checking out commit: ${commit}"
  git -C "${HOME}/kgb-data/backups" checkout -b restore "${commit}"

  ### Restore
  if [[ -f ${HOME}/kgb-data/backups/spoolman/spoolman.db ]]; then
    cp "${HOME}/kgb-data/backups/spoolman/spoolman.db" "${SPOOLMAN_DATA}/spoolman.db"
    log_msg "Spoolman database has been restored"
  else
    log_msg "No Spoolman backup in specified commit found"
    error=1
  fi

  ### Switch back to latest commit
  log_msg "Resetting repo to latest state"
  git -C "${HOME}/kgb-data/backups" checkout "${GITHUB_BRANCH}"
  git -C "${HOME}/kgb-data/backups" branch -D restore

  if [[ ${error} -ne 0 ]]; then
    return 1
  else
    return 0
  fi
}

rm_spoolman_bak() {
  ### Remove local spoolman safety backup

  local input

  ### Loop until user input is valid
  while true; do
    read -r -p "$(echo -e "${PURPLE}Do you want to keep the local backup? ${NC}")" input
    ### Validate user input
    case ${input} in
      y | Y)
        ### Keep local backup and continue
        log_msg "Old Spoolman data is located at ${SPOOLMAN_DATA}_$(date +%F).bak"
        break
        ;;
      n | N)
        ### Delete local backup
        log_msg "Deleting local backup"
        rm -rf "${SPOOLMAN_DATA}_"*.bak
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done
}

restore_spoolman() {
  ### Restores the spoolman database

  local input
  local error=0

  ### Safety backup
  log_msg "Making local backup of ${SPOOLMAN_DATA}"
  cp -r "${SPOOLMAN_DATA}" "${SPOOLMAN_DATA}_$(date +%F).bak"

  info_msg "Do you want to restore from the local backup, or from GitHub?"
  ### Loop until user input is valid
  while true; do
    read -r -p "$(echo -e "${PURPLE}Please input either 'local' or 'git': ${NC}")" -i "local" -e input
    ### Validate user input
    case ${input} in
      local)
        ### Copy database back to original destination
        if [[ -f ${HOME}/kgb-data/backups/spoolman/spoolman.db ]]; then
          cp "${HOME}/kgb-data/backups/spoolman/spoolman.db" "${SPOOLMAN_DATA}/spoolman.db"
          log_msg "Spoolman database has been restored"
        else
          log_msg "No Spoolman backup found in local repository"
          error=1
        fi
        break
        ;;
      git)
        ### Switch to specified commit and restore database
        if ! spoolman_git_restore; then
          error=1
        fi
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Remove safety backup
  rm_spoolman_bak

  ### Determine status
  if [[ ${error} -ne 0 ]]; then
    error_msg "Could not restore backup"
  else
    success_msg "Backup was restored"
  fi

  ### Continue
  read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
}

restore_config() {
  ### Restore a config backup

  local instance_id="$1"
  local input
  local error=0

  ### Creating a local backup for safety
  log_msg "Making local backup of ${CONFIG_FOLDER_LIST[${instance_id}]}"
  cp -r "${CONFIG_FOLDER_LIST[${instance_id}]}/config" "${CONFIG_FOLDER_LIST[${instance_id}]}/config_$(date +%F).bak"

  ### Loop until user input is valid
  info_msg "Do you want to restore from the local backup, or from GitHub?"
  while true; do
    read -r -p "$(echo -e "${PURPLE}Please input either 'local' or 'git': ${NC}")" -i "local" -e input
    ### Evaluate user input
    case ${input} in
      local)
        if ! local_restore "${instance_id}"; then
          error=1
        fi
        break
        ;;
      git)
        if ! git_restore "${instance_id}"; then
          error=1
        fi
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Remove local config backup
  rm_config_bak

  ### Determine status
  if [[ ${error} -ne 0 ]]; then
    error_msg "Could not restore backup"
  else
    success_msg "Backup was restored"
  fi

  read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" CONTINUE
}
