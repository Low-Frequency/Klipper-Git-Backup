#!/bin/bash

log_rotation() {
  local DEL=$(( ( $(date '+%s') - $(date -d "${LOG_RETENTION} months ago" '+%s') ) / 86400 ))
	case $LOG_ROTATION in
		0)
			log_msg "Log rotation is disabled"
			;;
		1)
			log_msg "Deleting old logs"
			find "${HOME}/kgb-log" -mindepth 1 -mtime +$DEL -delete
			;;
		*)
			log_msg "No valid log rotation configuration"
			log_msg "Please check the config file!"
      exit 1
			;;
	esac
}

backup_config_folders() {
	local ERROR=0
  for FOLDER in "${CONFIG_FOLDER_LIST[@]}"
  do
    log_msg "Backing ${FOLDER} up to GitHub"
    log_msg "Adding changes to push"
    git -C "${FOLDER}" add . | tee -a "${HOME}/kgb-log/$(date +%F).log"
    log_msg "Committing to GitHub repository"
    git -C "${FOLDER}" commit -m "backup $(date +%F)" | tee -a "${HOME}/kgb-log/$(date +%F).log"
    log_msg "Pushing to GitHub repository"
    if git -C "${FOLDER}" push -u origin "${GITHUB_BRANCH}" | tee -a "${HOME}/kgb-log/$(date +%F).log"
		then
			log_msg "${FOLDER} backed up"
		else
			log_msg "${FOLDER} backup failed"
			ERROR=$(( ERROR + 1 ))
		fi
  done
	if [[ $ERROR -ne 0 ]]
	then
		return 1
	else
		return 0
	fi
}

backup() {
  case $GIT in
  	0)
  		log_msg "Backups are disabled"
      ;;
  	1)
  		if backup_config_folders
			then
				local ERROR=0
			else
				local ERROR=1
			fi
      ;;
  	*)
  		log_msg "No valid backup configuration"
  		log_msg "Please check the config file!"
  		exit 1
      ;;
  esac
  log_rotation
	if [[ $ERROR -ne 0 ]]
	then
		return 1
	else
		return 0
	fi
}
