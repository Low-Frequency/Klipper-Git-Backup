#!/bin/bash

backup_dialog() {
  if [[ $UNSAVED_CHANGES -ne 0 ]]; then
    while true; do
      warning_msg "You have config changes pending!"
      warning_msg "Not saving will cause the pending changes to be lost!"
      read -r -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
      case $SAVE_CHANGES in
      y | Y)
        save_config
        break
        ;;
      n | N)
        error_msg "Not saving"
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
  if "${SCRIPTPATH}/backup.sh"; then
    success_msg "Backup succeeded"
  else
    error_msg "Backup failed! Please check the log"
  fi
}

update_dialog() {
  info_msg "Updating..."
  git reset --hard
  if ! git -C "${SCRIPTPATH}" pull | grep -q "up to date"; then
    info_msg "KGB has to be restarted"
    chmod +x "${SCRIPTPATH}"/*.sh
    quit_installer
  fi
}

install_dialog() {
  if [[ $UNSAVED_CHANGES -ne 0 ]]; then
    warning_msg "You have config changes pending!"
    show_config
    while true; do
      read -r -p "$(echo -e "${CYAN}Install with current config? ${NC}")" INSTALL
      case $INSTALL in
      y | Y)
        info_msg "Saving config"
        save_config
        break
        ;;
      n | N)
        while true; do
          read -r -p "$(echo -e "${CYAN}Ignore config changes and cancel install? ${NC}")" IGNORE
          case $IGNORE in
          y | Y)
            success_msg "Ignoring config changes"
            break
            ;;
          n | N)
            error_msg "Install was cancelled"
            return 1
            ;;
          *)
            deny_action
            ;;
          esac
        done
        break
        ;;
      *)
        deny_action
        ;;
      esac
    done
  fi
  if setup_ssh; then
    install
  else
    error_msg "SSH setup failed"
  fi
}

uninstall_dialog() {
  read -r -p "$(echo -e "${CYAN}Do you really want to uninstall KGB? ${NC}")" UNINSTALL
  case $UNINSTALL in
  n | N)
    success_msg "Cancelled uninstall"
    ;;
  y | Y)
    success_msg "Uninstalling..."
    info_msg "Removing log files"
    rm -r "$HOME/kgb-log"
    info_msg "Removing backup service"
    sudo systemctl disable kgb.service
    sudo rm /etc/systemd/system/kgb.service
    info_msg "Removing backup schedule"
    sudo systemctl disable kgb.timer
    sudo rm /etc/systemd/system/kgb.timer
    info_msg "Deleting config"
    rm -r "$HOME/.config/kgb.cfg"
    info_msg "Deleting scripts"
    rm -r "${SCRIPTPATH}"
    exit 0
    ;;
  *)
    deny_action
    ;;
  esac
}
