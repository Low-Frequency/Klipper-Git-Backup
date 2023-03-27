#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

source "${HOME}/.config/klipper_backup_script/backup.cfg"
source "${SCRIPTPATH}/lib/backup_functions.sh"

check_time
backup_config