#!/bin/bash

MAIN_UI_CONTENT=(
  "Configure_GitHub"
  "Configure_Log_Rotation"
  "Configure_Backup_Schedule"
  "View_Config"
  "Save_Config"
  "Install"
  "Restore_Config"
  "Uninstall"
  "Clear_Screen"
)

main_ui() {
  clear
  ui_header "Klipper Backup Utility"
  ui_body "${MAIN_UI_CONTENT[@]}"
  ui_footer
}
