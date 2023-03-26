#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
GITHUB_BRANCH="main"
GIT=1
LOG_ROTATION=1
LOG_RETENTION=3
SCHEDULED_BACKUPS=0
GIT_VERSION=$(git --version | cut -b 13- | sed -e 's/\.//g')

source "${SCRIPTPATH}/lib/functions.sh"
source "${SCRIPTPATH}/lib/ui.sh"
source "${SCRIPTPATH}/lib/colors.sh"
source "${SCRIPTPATH}/ui/github.sh"
source "${SCRIPTPATH}/ui/log_rotation.sh"
source "${SCRIPTPATH}/ui/main.sh"
source "${SCRIPTPATH}/ui/schedule.sh"

if [[ -f "$HOME/.config/klipper_backup_script/backup.cfg" ]]
then
  source "$HOME/.config/klipper_backup_script/backup.cfg"
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
      main_ui ;;
    *)
      end_script ;;
  esac
done
