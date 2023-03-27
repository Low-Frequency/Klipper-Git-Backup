#!/bin/bash

BACKUP_SCHEDULE_UI_CONTENT=(
  "Set_Schedule"
  "Enable_Scheduled_Backups"
  "Disable_Scheduled_Backups"
  "Clear_Screen"
)

SCHEDULE_UI_CONTENT=(
  "Days"
  "Hours"
  "Minutes"
)

backup_schedule_ui() {
  clear
  ui_header "Backup Schedule"
  ui_body "${BACKUP_SCHEDULE_UI_CONTENT[@]}"
  ui_footer
}

schedule_ui() {
  clear
  ui_header "Schedule Setup"
  ui_body "${SCHEDULE_UI_CONTENT[@]}"
  ui_footer
}

backup_schedule_actions() {
  while true
  do
    ACTION=$(echo $(get_input "Choose an action:") | tr '[:upper:]' '[:lower:]')
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      1)
        schedule_ui
        schedule_actions ;;
      2)
        print_msg green "Scheduled backups enabled"
        SCHEDULED_BACKUPS=1 ;;
      3)
        print_msg red "Scheduled backups disabled"
        SCHEDULED_BACKUPS=0 ;;
      4)
        backup_schedule_ui ;;
      *)
        ;;
    esac
  done
}

schedule_actions() {
  while true
  do
    ACTION=$(echo $(get_input "Choose an action:") | tr '[:upper:]' '[:lower:]')
    case $ACTION in
      c)
        end_script ;;
      b)
        break ;;
      1)
        TIME_UNIT="d"
        BACKUP_INTERVAL=$(get_input "Backup every x days") ;;
      2)
        TIME_UNIT="h"
        BACKUP_INTERVAL=$(get_input "Backup every x hours") ;;
      3)
        TIME_UNIT="m"
        BACKUP_INTERVAL=$(get_input "Backup every x minutes") ;;
      *)
        ;;
    esac
  done
}
