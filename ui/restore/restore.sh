#!/bin/bash

restore_ui() {
  for FOLDER in "${CONFIG_FOLDER_LIST[@]}"
  do
    if [[ "$FOLDER" =~ ^"$HOME"(/|$) ]]
    then
      RESTORE_UI_CONTENT+=("~${FOLDER#$HOME}")
    else
      RESTORE_UI_CONTENT+=("${FOLDER}")
    fi
  done
  clear
  ui_header "Klipper Config Restore"
  ui_title "The following instaces can be restored"
  ui_divider normal
  ui_body "${RESTORE_UI_CONTENT[@]}"
  ui_footer
}

restore_actions() {
  while true
  do
    ACTION=$(echo $(get_input "Which instance should be restored?:") | tr '[:upper:]' '[:lower:]')
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      *)
        if [[ -z ${CONFIG_FOLDER_LIST[${ACTION}]+x} ]]
        then
          print_msg red "Invalid input!"
        else
          print_msg none "Selected ${CONFIG_FOLDER_LIST[${ACTION}]}"
          RESTORE=$(get_input "Do you want to restore the selected instance?")
          RESTORE=${RESTORE:-n}
          if check_no "${RESTORE}"
          then
            print_msg red "Cancelling restore"
          else
            INSTANCE_ID="${ACTION}"
            mode_ui
            mode_actions
            break
          fi
        fi ;;
    esac
  done
}
