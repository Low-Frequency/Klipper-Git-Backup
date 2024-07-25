#!/bin/bash

restore_ui() {
  ### Prints the restore menu

  local menu_entry=1

  ### Loop over all config folders
  for folder in "${CONFIG_FOLDER_LIST[@]}"; do
    ### Format config folder names
    #!  Don't print full paths if it is located in ${HOME}
    if [[ "${folder}" =~ ^"${HOME}"(/|$) ]]; then
      RESTORE_UI_CONTENT+=("~${folder#"${HOME}"}")
    else
      RESTORE_UI_CONTENT+=("${folder}")
    fi
  done

  ### Print default menu header
  menu_header

  ### Print restore menu
  echo -e "${WHITE}|                      Restore                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|               ${BWHITE}Available Instances${WHITE}                |${NC}"
  echo -e "${WHITE}|                                                  |${NC}"
  for folder in "${CONFIG_FOLDER_LIST[@]}"; do
    folder="${menu_entry}) ~${folder#"${HOME}"}"
    for ((i = ${#folder}; i < 48; i++)); do
      folder="${folder} "
    done
    echo -e "${WHITE}| ${folder} |${NC}"
    menu_entry=$((menu_entry + 1))
  done
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print the menu footer
  menu_footer
}

restore_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local action

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the restore menu
  restore_ui

  ### Loop until user input is valid
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${CYAN}Which instance do you want to restore? ${NC}")" action
    case ${action} in
      q | Q)
        ### Exit
        quit_installer
        ;;
      b | B)
        ### Return to main menu
        return
        ;;
      h | H)
        help_restore
        ;;
      [1-9]*)
        ### Calculate real index of array
        if [[ ${action} -le ${#CONFIG_FOLDER_LIST[@]} ]]; then
          ### Restore config
          restore_config "$((action - 1))"
          break
        else
          ### Invalid input
          deny_action
        fi
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && action=""

  ### Loop back to itself
  restore_menu
}
