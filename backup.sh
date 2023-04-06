#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

source "${SCRIPTPATH}/lib/functions/general_functions.sh"
source "${SCRIPTPATH}/lib/functions/github_functions.sh"

if [[ -f "${HOME}/.config/klipper_backup_script/backup.cfg" ]]
then
  source "${HOME}/.config/klipper_backup_script/backup.cfg"
else
  log_msg "No config file found!"
  exit 1
fi

init_schedule
backup

exit 0
