#!/bin/bash

VERSION="v1.0.0"
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
UNSAVED_CHANGES=0

### Load all functions
for script in "${SCRIPTPATH}/lib/"*.sh
do
  source "${script}"
done
for script in "${SCRIPTPATH}/lib/ui/"*.sh
do
  source "${script}"
done

### Load config
### If config doesn't exist set defaults
if [[ -f "${HOME}/.config/kgb.cfg" ]]
then
  source "${HOME}/.config/kgb.cfg"
else
  GITHUB_BRANCH="main"
  GIT=1
  LOG_ROTATION=1
  LOG_RETENTION=3
  SCHEDULED_BACKUPS=0
  TIME_UNIT=d
  BACKUP_INTERVAL=7
fi

main_menu
