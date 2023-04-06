#!/bin/bash

git_ssh_url() {
  local REPO_NAME
  REPO_NAME="$1"
  if [[ -z ${GITHUB_USER+x} ]]
  then
    error_msg "GitHub username is undefined!"
    info_msg "Please configure username first"
    return 1
  else
    echo "git@github.com:${GITHUB_USER}/${REPO_NAME}.git"
    return 0
  fi
}

git_https_url() {
  local REPO_NAME
  REPO_NAME="$1"
  if [[ -z ${GITHUB_USER+x} ]]
  then
    error_msg "GitHub username is undefined!"
    info_msg "Please configure username first"
    return 1
  else
    echo "https://github.com/${GITHUB_USER}/${REPO_NAME}"
    return 0
  fi
}

init_schedule() {
  if [[ -z ${TIME_UNIT+x} ]]
  then
    log_msg "Something went wrong during schedule initialization"
    exit 1
  else
  	case $TIME_UNIT in
  		h)
  			MULTIPLIER=3600
        ;;
  		d)
  			MULTIPLIER=86400
        ;;
      m)
  			MULTIPLIER=2592000
        ;;
  		*)
  			log_msg "Misconfiguration in backup interval"
  			log_msg "Please specify a valid timespan"
  			log_msg "Available are h(ours), d(ays) and m(onths)"
  			log_msg "Falling back to daily backup"
  			MULTIPLIEER=86400
        ;;
  	esac
  	PAUSE=$(( BACKUP_INTERVAL * MULTIPLIER ))
  fi
}

log_rotation() {
  DEL=$(( ( $(date '+%s') - $(date -d "${LOG_RETENTION} months ago" '+%s') ) / 86400 ))
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
  for FOLDER in "${CONFIG_FOLDER_LIST[@]}"
  do
    log_msg "Backing ${FOLDER} up to GitHub"
    log_msg "Adding changes to push"
    git -C "${FOLDER}" add . | tee -a "${HOME}/kgb-log/$(date +%F).log"
    log_msg "Committing to GitHub repository"
    git -C "${FOLDER}" commit -m "backup $(date +%F)" | tee -a "${HOME}/kgb-log/$(date +%F).log"
    log_msg "Pushing to GitHub repository"
    git -C "${FOLDER}" push -u origin "${BRANCH}" | tee -a "${HOME}/kgb-log/$(date +%F).log"
  done
}

backup() {
  while true
  do
  	case $GIT in
  		0)
  			log_msg "Backups are disabled"
        ;;
  		1)
  			backup_config_folders
        ;;
  		*)
  			log_msg "No valid backup configuration"
  			log_msg "Please check the config file!"
  			exit 1
        ;;
  	esac
  	log_rotation
  	if [[ $SCHEDULED_BACKUPS -eq 0 ]]
  	then
  		break
  	else
  		sleep $PAUSE
  	fi
  done
}
