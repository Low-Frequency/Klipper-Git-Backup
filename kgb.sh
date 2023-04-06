#!/bin/bash

VERSION="v1.0.0"
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit; pwd -P )"
UNSAVED_CHANGES=0

### Load all functions
for SCRIPT in "${SCRIPTPATH}/lib/functions/"*.sh
do
  source "${SCRIPT}"
done
for SCRIPT in "${SCRIPTPATH}/lib/ui/"*.sh
do
  source "${SCRIPT}"
done

### Load config
### If config doesn't exist set defaults
if [[ -f "${HOME}/.config/kgb.cfg" ]]
then
  source "${HOME}/.config/kgb.cfg"
else
  GIT=1
  GITHUB_BRANCH="main"
  LOG_ROTATION=1
  LOG_RETENTION=3
  SCHEDULED_BACKUPS=0
  TIME_UNIT=d
  BACKUP_INTERVAL=7
  GIT_BASE_URL=github.com
fi

main_menu
