#!/bin/bash

restore_config() {
  MODE="$1"
  case $MODE in
    existing)
      log_msg "Making a local backup of the current configuration"
      cp "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_bak_$(date +%F)"
      log_msg "Restoring ${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
      git -C "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" fetch --all | tee -a "$HOME/backup_log/$(date +%F).log"
      git -C "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" reset --hard origin/master | tee -a "$HOME/backup_log/$(date +%F).log"
      delete_local_backup ;;
    new)
      log_msg "Checking for an SSH key"
      if [[ -f "${HOME}/.ssh/github_id_rsa" ]]
      then
        log_msg "SSH key found"
        if [[ -d "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}/.git" ]]
        then
          log_msg "${CONFIG_FOLDER_LIST[$INSTANCE_ID]} is already a repository"
          log_msg "Please use a different restore method"
          return
        fi
        log_msg "Making a local backup of the current configuration"
        cp "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_bak_$(date +%F)"
        log_msg "Removing existing config"
        rm -r "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
        log_msg "Restoring ${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
        mkdir -p "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
        git clone "${REPO_LIST[$INSTANCE_ID]}" "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
      else
        log_msg "Please set up a SSH key pair!"
      fi
      delete_local_backup ;;
    *)
      print_msg red "Unexpected error while restoring" 
      print_msg none "Please open a GitHub issue and describe exactly what you did" ;;
  esac
}

delete_local_backup() {
  KEEP=$(get_input "Do you want to keep the local backup?")
  KEEP=${KEEP:-y}
  if [[ "$KEEP" == "y"]]
  then
    log_msg "Old config folder is located at ${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_bak_$(date +%F)"
  else
    log_msg "Deleting local backup"
    rm -r "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_bak_$(date +%F)"
  fi 
}
