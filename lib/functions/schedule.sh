#!/bin/bash

init_schedule() {
  ### Initialize the timer schedule

  ### Check if the required config is set
  if [[ -z ${TIME_UNIT+x} ]]; then
    log_msg "Time unit is not set. Aborting!"
    exit 1
  else
    ### Check if scheduled backups are enabled
    if [[ ${SCHEDULED_BACKUPS} -eq 1 ]]; then
      ### Evaluate time unit and set the timer string accordingly
      case ${TIME_UNIT} in
        h)
          INTERVAL="OnCalendar=*-*-* 01/${BACKUP_INTERVAL}:00:00"
          PERSISTENT="true"
          ;;
        d)
          INTERVAL="OnCalendar=*-*-01/${BACKUP_INTERVAL} 00:00:00"
          PERSISTENT="true"
          ;;
        m)
          INTERVAL="OnCalendar=*-01/${BACKUP_INTERVAL}-* 00:00:00"
          PERSISTENT="true"
          ;;
        *)
          ### Invalid configuration
          log_msg "Misconfiguration in backup interval"
          log_msg "Please specify a valid timespan"
          log_msg "Available are h(ours), d(ays) and m(onths)"
          log_msg "Falling back to daily backup"
          INTERVAL="OnCalendar=*-*-*/${BACKUP_INTERVAL} 00:00:00"
          PERSISTENT="true"
          ;;
      esac
    else
      ### Default on disabled backup schedule
      #!  3 minutes past boot
      INTERVAL="OnBootSec=3min"
      PERSISTENT="false"
    fi
  fi
}

set_schedule() {
  ### Configure backup schedule

  local input
  local units

  ### Loop until user input is valid
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${CYAN}What time unit should the schedule comply to? ${NC}")" -i "d" -e input
    ### Validate user input
    case ${input} in
      h)
        TIME_UNIT="${input}"
        success_msg "Set time unit to hours"
        units="hours"
        break
        ;;
      d)
        TIME_UNIT="${input}"
        success_msg "Set time unit to days"
        units="days"
        break
        ;;
      m)
        TIME_UNIT="${input}"
        success_msg "Set time unit to months"
        units="months"
        break
        ;;
      *)
        deny_action
        ;;
    esac
    ### Reset input to avoid conflicts
    input=""
  done && input=""

  ### Loop until user input is valid
  while true; do
    ### Prompt user for input
    read -r -p "$(echo -e "${CYAN}How many ${units} between the backups? ${NC}")" -i "1" -e input

    ### Validate user input
    case ${input} in
      0)
        ### Invalid input, since 0 isn't an interval
        deny_action
        ;;
      [1-9]*)
        ### Set backup interval
        BACKUP_INTERVAL="${input}"
        success_msg "Backing up every ${BACKUP_INTERVAL} ${units}"
        break
        ;;
      *)
        ### Invalid input
        deny_action
        ;;
    esac
    ### Reset input to avoid conflicts
    input=""
  done
}
