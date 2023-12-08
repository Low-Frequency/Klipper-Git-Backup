#!/bin/bash

VERSION="v1.2.0"
SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)"
UNSAVED_CHANGES=0

### Load all functions
# shellcheck source=lib/functions/colors.sh
# shellcheck source=lib/functions/dialog.sh
# shellcheck source=lib/functions/general_functions.sh
# shellcheck source=lib/functions/git_install.sh
# shellcheck source=lib/functions/github_functions.sh
# shellcheck source=lib/functions/install_functions.sh
# shellcheck source=lib/functions/menu_functions.sh
# shellcheck source=lib/functions/restore_functions.sh
# shellcheck source=lib/functions/service_files.sh
for FN_SCRIPT in "${SCRIPTPATH}/lib/functions/"*.sh; do
  source "${FN_SCRIPT}"
done
# shellcheck source=lib/ui/advanced_ui.sh
# shellcheck source=lib/ui/backup_schedule.sh
# shellcheck source=lib/ui/config_ui.sh
# shellcheck source=lib/ui/github_ui.sh
# shellcheck source=lib/ui/log_rotation.sh
# shellcheck source=lib/ui/main_ui.sh
# shellcheck source=lib/ui/menu_elements.sh
# shellcheck source=lib/ui/restore_ui.sh
for UI_SCRIPT in "${SCRIPTPATH}/lib/ui/"*.sh; do
  source "${UI_SCRIPT}"
done

### Load config
### If config doesn't exist set defaults
# shellcheck source=sample_backup.cfg
if [[ -f "${HOME}/.config/kgb.cfg" ]]; then
  source "${HOME}/.config/kgb.cfg"
else
  GIT=1
  GITHUB_BRANCH="main"
  GIT_SERVER="github.com"
  LOG_ROTATION=1
  LOG_RETENTION=3
  SCHEDULED_BACKUPS=0
  TIME_UNIT=d
  BACKUP_INTERVAL=7
fi

main_menu
