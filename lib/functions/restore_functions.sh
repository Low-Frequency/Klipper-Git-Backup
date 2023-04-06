#!/bin/bash

restore_config() {
  INSTANCE_ID="$1"
  local ACTION
  log_msg "Started backup of ${CONFIG_FOLDER_LIST[$INSTANCE_ID]}"
  log_msg "Making a local backup of the current configuration"
  cp "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_$(date +%F).bak"
  log_msg "Restoring config"
  git -C "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" fetch --all | tee -a "$HOME/kgb-log/$(date +%F).log"
  git -C "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}" reset --hard origin/master | tee -a "$HOME/kgb-log/$(date +%F).log"
  while true
  do
    read -p "$(echo -e "${CYAN}Do you want to keep the local backup? ${NC}")" ACTION
    case $ACTION in
      y|Y)
        log_msg "Old config folder is located at ${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_$(date +%F).bak"
        break
        ;;
      n|N)
        log_msg "Deleting local backup"
        rm -r "${CONFIG_FOLDER_LIST[$INSTANCE_ID]}_$(date +%F).bak"
        break
        ;;
      *)
        deny_action
        ;;
    esac
  done
}
