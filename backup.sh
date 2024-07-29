#!/bin/bash

### Get path where script is located and save it to a variable
#!  Using this variable will ensure that full paths are used
#!  when files are referenced
SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)"

### Load required functions
#!  Shellcheck directives to make linting not fail on ´source´ commands
# shellcheck source=lib/functions/general.sh
source "${SCRIPTPATH}/lib/functions/general.sh"
# shellcheck source=lib/functions/backup.sh
source "${SCRIPTPATH}/lib/functions/backup.sh"
# shellcheck source=lib/functions/log_rotation.sh
source "${SCRIPTPATH}/lib/functions/log_rotation.sh"

### Check for existing config file and load it
if [[ -f "${HOME}/.config/kgb.cfg" ]]; then
  # shellcheck source=kgb.cfg.example
  source "${HOME}/.config/kgb.cfg"
else
  log_msg "No config file found!"
  exit 1
fi

### Execute backup
if backup; then
  exit 0
else
  exit 1
fi
