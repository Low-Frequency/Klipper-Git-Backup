#!/bin/bash

check_time() {
  if [[ -n $TIME_UNIT ]]
  then
  	case $TIME_UNIT in
  		m)
  			MULTIPLIER=60 ;;
  		h)
  			MULTIPLIER=3600 ;;
  		d)
  			MULTIPLIER=86400 ;;
  		*)
  			log_msg "[$(date '+%F %T')]: Misconfiguration in backup interval"
  			log_msg "[$(date '+%F %T')]: Please specify a valid timespan"
  			log_msg "[$(date '+%F %T')]: Available are s(econds), m(inutes), h(ours) and d(ays)"
  			log_msg "[$(date '+%F %T')]: Falling back to hourly backup"
  			MULTIPLIEER=3600 ;;
  	esac
  	PAUSE=$(($BACKUP_INTERVAL * $MULTIPLIER))
  fi
}

backup_config() {
	BREAK=0
  ROTATION=${ROTATION:-1}
  while [[ $BREAK -eq 0 ]]
  do
		case $GIT in
			0)
				log_msg "[$(date '+%F %T')]: Backups are disabled" ;;
			1)
				git_backup ;;
			*)
				log_msg "[$(date '+%F %T')]: No valid backup configuration"
				log_msg "[$(date '+%F %T')]: Please check the config file!"
				exit 1 ;;
		esac
		log_rotation
		if [[ $SCHEDULED_BACKUPS -eq 0 ]]
		then
			BREAK=1
		fi
		if [[ $BREAK -eq 1 ]]
		then
			break
		else
			sleep $PAUSE
		fi
	done
}

git_backup() {
  for folder in "${CONFIG_FOLDER_LIST[@]}"
  do
    log_msg "[$(date '+%F %T')]: Backing $folder up to GitHub"
    log_msg "[$(date '+%F %T')]: Adding changes to push"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" add . | tee -a "$HOME/backup_log/$(date +%F).log"
    log_msg "[$(date '+%F %T')]: Committing to GitHub repository"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" commit -m "backup $(date +%F)" | tee -a "$HOME/backup_log/$(date +%F).log"
    log_msg "[$(date '+%F %T')]: Pushing"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" push -u origin $BRANCH | tee -a "$HOME/backup_log/$(date +%F).log"
  done
}

log_rotation() {
  DEL=$((($(date '+%s') - $(date -d "$LOG_RETENTION months ago" '+%s')) / 86400))
	case $LOG_ROTATION in
		0)
			log_msg "[$(date '+%F %T')]: Log rotation is disabled" ;;
		1)
			log_msg "[$(date '+%F %T')]: Deleting old logs"
			find "$HOME/backup_log" -mindepth 1 -mtime +$DEL -delete ;;
		*)
			log_msg "[$(date '+%F %T')]: No valid log rotation configuration"
			log_msg "[$(date '+%F %T')]: Please check the config file!" ;;
	esac
}
