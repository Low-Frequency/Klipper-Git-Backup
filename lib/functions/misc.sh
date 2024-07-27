#!/bin/bash

quit_installer() {
  ### Exits the installer
  #!  Has some safety built in to make sure the user doesn't accidentally discards config changes

  local input

  ### Check if there are unsaved config changes
  if [[ ${UNSAVED_CHANGES} -ne 0 ]]; then
    ### Loop until user input is valid
    while true; do
      warning_msg "You have config changes pending!"
      ### Prompt user for input
      read -r -p "$(echo -e "${CYAN}Save changes now? ${NC}")" -i "y" -e input
      ### Evaluate user input to choose an action
      case ${input} in
        y | Y)
          ### Save pending changes to config
          save_config

          ### Check the installation status
          #!  Exit the loop if it is installed
          #!  Skip to the next iteration if it isn't installed
          if check_install; then
            break
          else
            return 0
          fi
          ;;
        n | N)
          warning_msg "Your changes will be lost!"
          input=""
          ### Loop until user input is valid
          while true; do
            ### Prompt user for input
            read -r -p "$(echo -e "${CYAN}Continue? ${NC}")" -i "n" -e input
            case ${input} in
              y | Y)
                warning_msg "Discarding changes"

                ### Check the installation status
                #!  Exit the loop if it is installed
                #!  Skip to the next iteration if it isn't installed
                if check_install; then
                  break
                else
                  return 0
                fi
                ;;
              n | N)
                success_msg "Resuming"
                return 0
                ;;
              *)
                ### Invalid input
                deny_action
                ;;
            esac
          done
          break
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi

  ### Exit the installer
  success_msg "Exiting"
  exit 0
}

check_install() {
  ### Checks if the service has been installed

  local input

  ### Check if the service file exists
  #!  If not, warn the user that the installation process hasn't been completed
  if [[ ! -f /etc/systemd/system/kgb.service ]]; then
    ### Loop until user input is valid
    while true; do
      warning_msg "You haven't installed the script yet!"
      warning_msg "This will lead to errors if you want to use the script"

      ### Prompt the user for input
      read -r -p "$(echo -e "${CYAN}Continue anyway? ${NC}")" -i "n" -e input
      ### Evaluate user input to determine the return code
      case ${input} in
        y | Y)
          ### Skip installation
          return 0
          ;;
        n | N)
          ### Abort action to be able to install
          return 1
          ;;
        *)
          ### Invalid input
          deny_action
          ;;
      esac
    done && input=""
  fi
}
