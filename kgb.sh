#!/bin/bash

### Variable info:
#!  Variables in CAPS are used across multiple files, for example config values
#!  Lowercase variables are usually local to a function

VERSION="2.0.0"
### Get path where script is located and save it to a variable
#!  Using this variable will ensure that full paths are used
#!  when files are referenced

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)"

### Initialize variable that tracks changes to the config
UNSAVED_CHANGES=0

### Load all functions
#!  Shellcheck directives to make linting not fail on ´source´ commands
#!  All files ending in ´.sh´ from ´lib/functions´ and ´lib/ui´ will be loaded
# shellcheck source=lib/functions/advanced.sh
# shellcheck source=lib/functions/backup.sh
# shellcheck source=lib/functions/colors.sh
# shellcheck source=lib/functions/config.sh
# shellcheck source=lib/functions/dialogs.sh
# shellcheck source=lib/functions/general.sh
# shellcheck source=lib/functions/git_install.sh
# shellcheck source=lib/functions/github.sh
# shellcheck source=lib/functions/help.sh
# shellcheck source=lib/functions/install_deps.sh
# shellcheck source=lib/functions/install.sh
# shellcheck source=lib/functions/log_rotation.sh
# shellcheck source=lib/functions/migrate.sh
# shellcheck source=lib/functions/misc.sh
# shellcheck source=lib/functions/restore.sh
# shellcheck source=lib/functions/schedule.sh
# shellcheck source=lib/functions/service_files.sh
# shellcheck source=lib/functions/ssh.sh
# shellcheck source=lib/functions/uninstall.sh
for function_script in "${SCRIPTPATH}/lib/functions/"*.sh; do
  source "${function_script}"
done
# shellcheck source=lib/ui/advanced.sh
# shellcheck source=lib/ui/backup_schedule.sh
# shellcheck source=lib/ui/config.sh
# shellcheck source=lib/ui/github.sh
# shellcheck source=lib/ui/log_rotation.sh
# shellcheck source=lib/ui/main.sh
# shellcheck source=lib/ui/menu_elements.sh
# shellcheck source=lib/ui/restore.sh
for ui_script in "${SCRIPTPATH}/lib/ui/"*.sh; do
  source "${ui_script}"
done

### Load config
#!  If config doesn't exist, defaults will be set
# shellcheck source=sample_backup.cfg
if [[ -f "${HOME}/.config/kgb.cfg" ]]; then
  source "${HOME}/.config/kgb.cfg"
else
  GIT=1
  GITHUB_BRANCH="main"
  GIT_SERVER="github.com"
  GIT_REPO="klipper-backups-by-kgb"
  LOG_ROTATION=1
  LOG_RETENTION=3
  SCHEDULED_BACKUPS=0
  TIME_UNIT=d
  BACKUP_INTERVAL=7
fi

### Open main menu
main_menu
