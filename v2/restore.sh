#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"

source "${SCRIPTPATH}/lib/colors.sh"
source "${SCRIPTPATH}/lib/restore_functions.sh"
source "${SCRIPTPATH}/lib/backup_functions.sh"
source "${HOME}/.config/klipper_backup_script/backup.cfg"

