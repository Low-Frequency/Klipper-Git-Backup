#!/bin/bash

advanced_ui(){
  echo -e  "${PURPLE}Sorry, not implemented yet \u2639${NC}"
  info_msg "Press b to go back"
}

advanced_menu(){
  clear
  advanced_ui
  local ACTION
  while true
  do
    read -p "$(echo -e "${CYAN}##### Choose action: ${NC}")" ACTION
    case $ACTION in
      q|Q)
        quit_installer
        ;;
      b|B)
        return
        ;;
      *)
        deny_action
        ;;
    esac
  done
  advanced_menu
}
