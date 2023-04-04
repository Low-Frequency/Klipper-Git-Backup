#!/bin/bash

LOG_ROTATION_UI_CONTENT=(
  "Retention_Time"
  "Enable_Log_Rotation"
  "Disable_Log_Rotation"
  "Clear_Screen"
)

log_rotation_ui() {
  clear
  ui_script_title "KGB" "Klipper Git Backup"
  ui_header "Log Rotation Setup"
  ui_body "${LOG_ROTATION_UI_CONTENT[@]}"
  ui_footer
}

log_rotation_actions() {
  while true
  do
    ACTION=$(echo $(get_input "Choose an action:") | tr '[:upper:]' '[:lower:]')
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      1)
        print_msg purple "The default logfile retention time is 3 months"
        print_msg cyan "The current logfile retention time is ${LOG_RETENTION} months"
        LOG_RETENTION=$(get_input "Press enter to use the default, or provide a different value:")
        LOG_RETENTION=${LOG_RETENTION:-3} ;;
      2)
        print_msg green "Log rotation enabled"
        LOG_ROTATION=1 ;;
      3)
        print_msg red "Log rotation disabled"
        LOG_ROTATION=0 ;;
      4)
        log_rotation_ui ;;
      *)
        ;;
    esac
  done
}