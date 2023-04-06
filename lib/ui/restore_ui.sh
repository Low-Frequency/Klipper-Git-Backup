#!/bin/bash

restore_ui() {
  MENU_ENTRY=1

  for FOLDER in "${CONFIG_FOLDER_LIST[@]}"
  do
    if [[ "$FOLDER" =~ ^"$HOME"(/|$) ]]
    then
      RESTORE_UI_CONTENT+=("~${FOLDER#$HOME}")
    else
      RESTORE_UI_CONTENT+=("${FOLDER}")
    fi
  done

  menu_header
  echo -e "${WHITE}|                      Restore                     |${NC}"
  echo -e "${WHITE}+==================================================+${NC}"
  echo -e "${WHITE}|               ${BOLD}Available Instances${WHITE}                |${NC}"
  echo -e "${WHITE}|                                                  |${NC}"
  for FOLDER in "${CONFIG_FOLDER_LIST[@]}"
  do
    FOLDER="${MENU_ENTRY}) ~${FOLDER#$HOME}"
    for (( i=${#FOLDER} ; i<48; i++ ))
    do
      FOLDER="${FOLDER} "
    done
    echo -e "${WHITE}| ${FOLDER} |${NC}"
    MENU_ENTRY=$(( MENU_ENTRY + 1 ))
  done
  echo -e "${WHITE}+--------------------------------------------------+${NC}"
  menu_info
  menu_footer
}

restore_menu() {
  clear
  restore_ui
  local ACTION
  while true
  do
    read -p "$(echo -e "${CYAN}Which instance do you want to restore? ${NC}")" ACTION
    case $ACTION in
      q|Q)
        quit_installer
        ;;
      b|B)
        break
        ;;
      [0-9]*)
        if [[ $ACTION -le 0 ]]
        then
          deny_action
        elif [[ $ACTION -le ${#CONFIG_FOLDER_LIST} ]]
        then
          restore_config "${ACTION}"
          break
        else
          deny_action
        fi
        ;;
      *)
        deny_action
        ;;
    esac
  done
  restore_menu
}
