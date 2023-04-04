#!/bin/bash

backup_dialog() {
  if [[ $UNSAVED_CHANGES -eq 1 ]]
  then
    warning_msg "You have config changes pending!"
    read -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
    case $SAVE_CHANGES in
      y|Y)
        save_config
        ;;
      n|N)
        error_msg "Not saving"
        ;;
      *)
        deny_action
        break
        ;;
    esac
  fi
  if [[ $SCHEDULED_BACKUPS -eq 1 ]]
  then
    warning_msg "You have scheduled backups enabled!"
    info_msg "This action will turn off scheduled backups temporarily"
    info_msg "This causes all your pending changes to be saved"
    read -p "$(echo -e "${CYAN}Save changes now? ${NC}")" SAVE_CHANGES
    case $SAVE_CHANGES in
      y|Y)
        SCHEDULED_BACKUPS=0
        REVERT_SCHEDULE=1
        save_config
        ;;
      n|N)
        error_msg "Aborting"
        break
        ;;
      *)
        deny_action
        break
        ;;
    esac
  fi
  if "${SCRIPTPATH}/backup.sh"
  then
    success_msg "Backup succeeded"
  else
    error_msg "Backup failed! Please check the log"
  fi
  if [[ $REVERT_SCHEDULE -eq 1 ]]
  then
    SCHEDULED_BACKUPS=1
    REVERT_SCHEDULE=0
    save_config
  fi
}

update_dialog() {
  info_msg "Updating..."
  git -C "${SCRIPTPATH}" pull
}

install_dialog() {
  if [[ $UNSAVED_CHANGES -ne 0 ]]
  then
    warning_msg "You have config changes pending!"
    get_config
    while true
    do
      read -p "$(echo -e "${CYAN}Install with current config? ${NC}")" INSTALL
      case $INSTALL in
        y|Y)
          info_msg "Saving config"
          save_config
          break
          ;;
        n|N)
          while true
          do
            read -p "$(echo -e "${CYAN}Ignore config changes? ${NC}")" IGNORE
            case $IGNORE in
              y|Y)
                success_msg "Ignoring config changes"
                break
                ;;
              n|N)
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
          ;
      esac
    done
  fi
  if setup_ssh
  then
    install
  else
    error_msg "SSH setup failed"
  fi
}

uninstall_dialog() {
  read -p "$(echo -e "${CYAN}Do you really want to uninstall KGB? ${NC}")" UNINSTALL
  case $UNINSTALL in
    n|N)
      success_msg "Cancelled uninstall"
      ;;
    y|Y)
      success_msg "Uninstalling..."
      info_msg "Removing log files"
      rm -r "$HOME/kgb-log"
      info_msg "Removing backup service"
      sudo systemctl disable kgb.service
      sudo rm /etc/systemd/system/kgb.service
      info_msg "Removing custom command"
      sudo rm /usr/local/bin/kgb
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
  fi
}