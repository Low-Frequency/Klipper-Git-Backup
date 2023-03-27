#!/bin/bash

uninstall() {
  print_msg purple "Removing log files"
  rm -r "$HOME/backup_log"
  print_msg purple "Removing backup service"
  sudo systemctl disable gitbackup.service
  sudo rm /etc/systemd/system/gitbackup.service
  print_msg purple "Removing custom commands"
  sudo rm /usr/local/bin/backup
  print_msg purple "Deleting config"
  rm -r "$HOME/.config/klipper_backup_script"
  print_msg purple "Deleting scripts"
  rm -r "$HOME/scripts/klipper_backup_script"
}
