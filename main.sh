#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
GITHUB_BRANCH="main"
GIT=1
LOG_ROTATION=1
LOG_RETENTION=3
SCHEDULED_BACKUPS=0
GIT_VERSION=$(git --version | cut -b 13- | sed -e 's/\.//g')

source "${SCRIPTPATH}/lib/install_functions.sh"
source "${SCRIPTPATH}/lib/general_functions.sh"
source "${SCRIPTPATH}/lib/backup_functions.sh"
source "${SCRIPTPATH}/lib/restore_functions.sh"
source "${SCRIPTPATH}/lib/colors.sh"
source "${SCRIPTPATH}/lib/service.sh"
source "${SCRIPTPATH}/lib/uninstall.sh"
source "${SCRIPTPATH}/lib/git_install.sh"
source "${SCRIPTPATH}/ui/ui.sh"
source "${SCRIPTPATH}/ui/install/github.sh"
source "${SCRIPTPATH}/ui/install/log_rotation.sh"
source "${SCRIPTPATH}/ui/install/main_menu.sh"
source "${SCRIPTPATH}/ui/install/schedule.sh"
source "${SCRIPTPATH}/ui/restore/mode.sh"
source "${SCRIPTPATH}/ui/restore/restore.sh"

if [[ -f "${HOME}/.config/klipper_backup_script/backup.cfg" ]]
then
  source "${HOME}/.config/klipper_backup_script/backup.cfg"
fi

while true
do
  main_ui
  ACTION=$(echo $(get_input "Choose an action:") | tr '[:upper:]' '[:lower:]')
  case $ACTION in
    c)
      end_script ;;
    b)
      break ;;
    1)
      github_ui 
      github_actions ;;
    2)
      log_rotation_ui
      log_rotation_actions ;;
    3)
      backup_schedule_ui
      backup_schedule_actions ;;
    4)
      get_config ;;
    5)
      save_config ;;
    6)
      install ;;
    7)
      restore_ui
      restore_actions ;;
    8)
      uninstall ;;
    9)
      main_ui ;;
    *)
      end_script ;;
  esac
done
