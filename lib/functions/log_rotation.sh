#!/bin/bash

configure_log_retention() {
  ### Configure log retention

  local input
  local re='^[0-9]+$'

  read -r -p "$(echo -e "${PURPLE}How many months should the logs be kept? ${NC}")" input
  ### Validate the input to only be numerical values
  if [[ ${input} =~ ^[0-9]+$ ]]; then
    LOG_RETENTION="${input}"
    ### Determine correct wording
    if [[ ${LOG_RETENTION} -eq 1 ]]; then
      success_msg "Set log retention to ${LOG_RETENTION} month"
    else
      success_msg "Set log retention to ${LOG_RETENTION} months"
    fi
    UNSAVED_CHANGES=1
    ### Reset input
    input=""
  else
    ### Invalid input
    deny_action
  fi
}

log_rotation() {
  ### Delete obsolete logs

  local del=$((($(date '+%s') - $(date -d "${LOG_RETENTION} months ago" '+%s')) / 86400))

  ### Evaluate log rotation config
  case ${LOG_ROTATION} in
    0)
      log_msg "Log rotation is disabled"
      ;;
    1)
      log_msg "Deleting old logs"
      ### Find all files that can be deleted
      find "${HOME}/kgb-data/log" -mindepth 1 -mtime +"${del}" -delete
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}
