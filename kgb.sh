#!/bin/bash

VERSION="v1.1.0"
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
UNSAVED_CHANGES=0

### Load all functions
for FN_SCRIPT in "${SCRIPTPATH}/lib/functions/"*.sh
do
  source "${FN_SCRIPT}"
done
for UI_SCRIPT in "${SCRIPTPATH}/lib/ui/"*.sh
do
  source "${UI_SCRIPT}"
done

### Load config
### If config doesn't exist set defaults
if [[ -f "${HOME}/.config/kgb.cfg" ]]
then
  source "${HOME}/.config/kgb.cfg"
else
  GIT=1
  GITHUB_BRANCH="main"
  GIT_SERVER="github.com"
  GIT_ORG=${GITHUB_USER}
  LOG_ROTATION=1
  LOG_RETENTION=3
  SCHEDULED_BACKUPS=0
  TIME_UNIT=d
  BACKUP_INTERVAL=7
fi

main_menu
