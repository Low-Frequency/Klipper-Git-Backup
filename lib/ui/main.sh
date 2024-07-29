#!/bin/bash

main_ui() {
  ### Prints the main menu
  #!  Status colors are set based on the config
  #!  Disabled: Red
  #!  Enabled, but not configured: Yellow
  #!  Enabled and configured: Green

  ### Local variables that are only used to display the status of the current config
  local backup_count
  local migrate_status
  local update_status
  local install_status

  ### Check if service has been installed
  if [[ -f /etc/systemd/system/kgb.service ]]; then
    install_status="[${GREEN}${CHECK}${WHITE}]"
  else
    install_status="[${RED}${CROSS}${WHITE}]"
  fi

  ### Complare latest release with current version
  if [[ ${VERSION} != "${LATEST_RELEASE}" ]]; then
    update_status="[${YELLOW}${EXCLM}${WHITE}]"
  else
    update_status="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Count the amount of repositories that are managed
  #!  Conditionals are only for correct spacing and wording in the menu
  if [[ ${#CONFIG_FOLDER_LIST[@]} -eq 0 ]]; then
    backup_count="Backing up ${#CONFIG_FOLDER_LIST[@]} Folders   "
  elif [[ ${#CONFIG_FOLDER_LIST[@]} -eq 1 ]]; then
    backup_count="Backing up ${#CONFIG_FOLDER_LIST[@]} Folder    "
  elif [[ $((${#CONFIG_FOLDER_LIST[@]} - 10)) -lt 0 ]]; then
    backup_count="Backing up ${#CONFIG_FOLDER_LIST[@]} Folders   "
  else
    backup_count="Backing up ${#CONFIG_FOLDER_LIST[@]} Folders  "
  fi

  if [[ ${#REPO_LIST[@]} -ne 0 ]]; then
    migrate_status="[${RED}${CROSS}${WHITE}]"
  else
    migrate_status="[${GREEN}${CHECK}${WHITE}]"
  fi

  ### Print the default menu header
  menu_header

  ### Print the main menu
  echo -e "${WHITE}|                     ${CYAN}Main Menu${WHITE}                    |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}              | ${BWHITE}Status${WHITE}                 |${NC}"
  echo -e "${WHITE}|                         |                        |${NC}"
  echo -e "${WHITE}| 1) Configure            |                        |${NC}"
  echo -e "${WHITE}| 2) Install              | ${install_status}                    |${NC}"
  echo -e "${WHITE}| 3) Update               | ${update_status}                    |${NC}"
  echo -e "${WHITE}| 4) Backup               | ${backup_count}|${NC}"
  echo -e "${WHITE}| 5) Restore              |                        |${NC}"
  echo -e "${WHITE}| 6) Migrate to v2        | ${migrate_status}                    |${NC}"
  echo -e "${WHITE}| 7) Uninstall            |                        |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the info section of the menu
  menu_info

  ### Print the menu footer
  menu_footer
}

main_menu() {
  ### Main menu loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local input
  local prompt

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the main menu
  main_ui

  ### Loop until user input is valid
  while true; do
    ### Hint user towards config migration
    if [[ ${VERSION} != "${LATEST_RELEASE}" ]]; then
      prompt=3
    elif [[ ${#GIT_REPO} -eq 0 ]]; then
      prompt=6
    fi
    ### Prompt the user to choose an action
    read -r -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" -i "${prompt}" -e input

    ### Evaluate user input to execute the corresponding function
    case ${input} in
      q | Q)
        ### Exit
        quit_installer
        ;;
      b | B)
        ### Exit
        #!  Main menu is the entrypint, so going back exits
        quit_installer
        ;;
      h | H)
        help_main
        ;;
      1)
        ### Clear the screen to prepare for a new menu
        clear
        ### Print config menu
        config_menu
        ### Break out of the loop when config menu is exited
        #!  Will print the main menu again
        break
        ;;
      2)
        ### Start the install dialog
        #!  Returns 1 if installation is cancelled
        #!  On returning 0, SSH setup is attempted
        if install_dialog; then
          ### Setup SSH. On success: install the script
          if setup_ssh; then
            #### Install the script
            install
          else
            error_msg "SSH setup failed"
            read -r -p "Continue 1" action
            input=""
          fi
        else
          error_msg "Install was cancelled"
          read -r -p "Continue 2" action
          input=""
        fi
        ### Break out of the loop when install dialog is finished
        #!  Will print the main menu again
        break
        ;;
      3)
        ### Start updating KGB
        #!  Updater returns 0 if KGB has to be restarted
        #!  Otherwise reload the menu
        if ! update_dialog; then
          quit_installer
        else
          clear
          break
        fi
        ;;
      4)
        ### Trigger a backup
        backup_dialog
        ;;
      5)
        ### Clear the screen to prepare for a new menu
        clear
        ### Print the restore menu
        restore_menu
        ### Break out of the loop when restore menu is exited
        #!  Will print the main menu again
        break
        ;;
      6)
        ### Migrate to version 2
        migrate_config
        read -r -p "$(echo -e "${CYAN}Press enter to continue ${NC}")" input
        input=""
        break
        ;;
      7)
        ### Start the uninstall dialog
        if uninstall_dialog; then
          success_msg "Successfully uninstalled"
          success_msg "Happy printing and hope you don't loose your config"
          exit 0
        else
          success_msg "Cancelled uninstall"
        fi
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Loop back to itself
  main_menu
}
