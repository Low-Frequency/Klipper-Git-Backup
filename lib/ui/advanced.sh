#!/bin/bash

advanced_ui() {
  ### Prints the advanced git config menu

  ### Print default menu header
  menu_header

  ### Print advanced git config menu
  echo -e "${WHITE}|                     Advanced                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|    ${BWHITE}Actions${WHITE}       | ${BWHITE}Status${WHITE}                        |${NC}"
  echo -e "${WHITE}|                  |                               |${NC}"
  echo -e "${WHITE}| 1) Git Server    |                               |${NC}"
  echo -e "${WHITE}| 2) Organisation  |                               |${NC}"
  echo -e "${WHITE}+--------------------------------------------------+${NC}"

  ### Print info section for the advanced git config
  advanced_info

  ### Print the menu footer
  menu_footer
}

advanced_menu() {
  ### Loop for navigation

  ### Local variable to determine the action to take
  #!  Gets its value from user input
  local input

  ### Clear the screen to always print the menu at the same spot
  clear

  ### Print the advanced git config menu
  advanced_ui

  ### Loop until user input is valid
  while true; do
    ### Prompt the user to choose an action
    read -r -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" input

    ### Evaluate user input to execute the corresponding function
    case ${input} in
      q | Q)
        ### Exit
        quit_installer
        ;;
      b | B)
        ### Back to GitHub config menu
        return
        ;;
      h | H)
        help_advanced
        ;;
      1)
        ### Configure the git server
        configure_git_server
        ;;
      2)
        ### Configure the git org
        configure_git_org
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
  done && input=""

  ### Loop back to itself
  advanced_menu
}
