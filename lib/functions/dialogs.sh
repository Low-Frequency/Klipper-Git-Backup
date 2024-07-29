#!/bin/bash

backup_dialog() {
  ### Trigger a backup

  local input

  ### Check for pending changes
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]; then
    ### Loop until user input is valid
    while true; do
      warning_msg "You have config changes pending!"
      warning_msg "Not saving will cause the pending changes to be lost!"
      ### Prompt the user for input
      read -r -p "$(echo -e "${CYAN}Save changes now? ${NC}")" -i "y" -e input
      case ${input} in
        y | Y)
          ### Save config and start backup
          save_config
          break
          ;;
        n | N)
          ### Discard changes and start backup
          error_msg "Not saving"
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi

  ### Execute backup script
  if "${SCRIPTPATH}/backup.sh"; then
    success_msg "Backup succeeded"
  else
    error_msg "Backup failed! Please check the log"
  fi
}

update_dialog() {
  ### Update KGB

  ### Compare versions
  if [[ ${VERSION} == "${LATEST_RELEASE}" ]]; then
    info_msg "Already up to date. Nothing to do"
  else
    info_msg "Updating..."
    ### Reset the KGB repo in case user has made any local changes
    git -C "${SCRIPTPATH}" reset --hard
    ### Pull the latest version
    if ! git -C "${SCRIPTPATH}" pull | grep -q "up to date"; then
      ### KGB was updated. Terminating
      info_msg "KGB has to be restarted"
      chmod +x "${SCRIPTPATH}"/*.sh
      return 1
    fi
  ### KGB was up to date
  return 0
}

install_dialog() {
  ### Starts the installation process

  local input

  ### Check if all settings have been saved
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]; then
    warning_msg "You have config changes pending!"
    show_config
    ### Loop until user input is valid
    while true; do
      ### Prompt user for input
      read -r -p "$(echo -e "${CYAN}Install with current config? ${NC}")" -i "y" -e input

      ### Evaluate user input
      case ${input} in
        y | Y)
          ### Save changes
          info_msg "Saving config"
          save_config
          break
          ;;
        n | N)
          ### Confirmation prompt
          input=""
          while true; do
            read -r -p "$(echo -e "${CYAN}Cancel install? ${NC}")" -i "n" -e input
            case ${input} in
              y | Y)
                ### Cancel installation
                return 1
                ;;
              n | N)
                ### Return to previous prompt
                break
                ;;
              *)
                ### Invalid input
                deny_action
                ;;
            esac
          done && input=""
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi
  return 0
}

uninstall_dialog() {
  ### Uninstall the script

  local input
  local gh_ssh_id

  ### Loop until user input is valid
  while true; do
    ### Prompt for user input
    read -r -p "$(echo -e "${CYAN}Do you really want to uninstall KGB? ${NC}")" -i "n" -e input
    ### Evaluate user input to choose the right actions
    case ${input} in
      n | N)
        ### Cancel install
        return 1
        ;;
      y | Y)
        ### Uninstall script
        #!  *Insert sad pepe meme*
        if uninstall; then
          return 0
        else
          return 1
        fi
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && action=""
}
