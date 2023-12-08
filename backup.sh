#!/bin/bash

SCRIPTPATH="$(
  cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit
  pwd -P
)"

# shellcheck source=lib/functions/general_functions.sh
source "${SCRIPTPATH}/lib/functions/general_functions.sh"
# shellcheck source=lib/functions/github_functions.sh
source "${SCRIPTPATH}/lib/functions/github_functions.sh"

if [[ -f "${HOME}/.config/kgb.cfg" ]]; then
  # shellcheck source=sample_backup.cfg
  source "${HOME}/.config/kgb.cfg"
else
  log_msg "No config file found!"
  exit 1
fi

if backup; then
  exit 0
else
  exit 1
fi
