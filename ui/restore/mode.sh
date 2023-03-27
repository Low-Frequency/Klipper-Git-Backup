#!/bin/bash

MODE_UI_CONTENT=(
  "Existing_installation"
  "New_installation"
)

mode_ui() {
  clear
  ui_header "Klipper Config Restore"
  ui_body "${MODE_UI_CONTENT[@]}"
  ui_footer
}

mode_actions() {
  while true
  do
    ACTION=$(get_input "Do you want to restore to a new or an existing installation?")
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      1)
        restore_config existing ;;
      2)
        restore_config new ;;
      *)
        print_msg red "Not a valid input" ;;
    esac
  done
}