#!/bin/bash

### FUCTIONS
function import_config {
  CONFIG_FILE="$HOME/.config/klipper_backup_script/backup.cfg"
  CONFIG_FILE_SECURE="$HOME/.config/klipper_backup_script/sec_backup.cfg"

  sed -i "s/^BREAK=.*/BREAK=0/g" "$HOME/.config/klipper_backup_script/backup.cfg"

  ### Check if the file contains malicious code
  if egrep -q -v '^#|^[^ ]*=[^;]*' "$CONFIG_FILE"
  then
  	echo "Warning! Config file is unclean, cleaning it..." | tee -a "$HOME/backup_log/$(date +%F).log"
  	### Filter the original to a new file
  	egrep '^#|^[^ ]*=[^;&]*'  "$CONFIG_FILE" > "$CONFIG_FILE_SECURE"
  	CONFIG_FILE="$CONFIG_FILE_SECURE"
  fi

  source "$CONFIG_FILE"
}

function time_check {
  if [[ -n $UNIT ]]
  then
  	case $UNIT in
  		s)
  			MULTIPLIER=1
  			;;
  		m)
  			MULTIPLIER=60
  			;;
  		h)
  			MULTIPLIER=3600
  			;;
  		d)
  			MULTIPLIER=86400
  			;;
  		*)
  			echo "[$(date '+%F %T')]: Misconfiguration in backup interval" | tee -a "$HOME/backup_log/$(date +%F).log"
  			echo "[$(date '+%F %T')]: Please specify a valid timespan" | tee -a "$HOME/backup_log/$(date +%F).log"
  			echo "[$(date '+%F %T')]: Available are s(econds), m(inutes), h(ours) and d(ays)" | tee -a "$HOME/backup_log/$(date +%F).log"
  			echo "[$(date '+%F %T')]: Falling back to hourly backup" | tee -a "$HOME/backup_log/$(date +%F).log"
  			MULTIPLIEER=3600
  			;;
  	esac

  	## Calulating the intervals
  	PAUSE=$(($TIME * $MULTIPLIER))
  fi
}

function log_rotation {
  DEL=$((($(date '+%s') - $(date -d "$RETENTION months ago" '+%s')) / 86400))

	case $ROTATION in
		0)
			echo "[$(date '+%F %T')]: Log rotation is disabled" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		1)
			echo "[$(date '+%F %T')]: Deleting old logs" | tee -a "$HOME/backup_log/$(date +%F).log"
			find "$HOME/backup_log" -mindepth 1 -mtime +$DEL -delete
			;;
		*)
			echo "[$(date '+%F %T')]: No valid log rotation configuration" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Please check the config file!" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
	esac
}

function git_backup {
  for folder in ${GITHUB_CONFIG_FOLDER_LIST[@]}
  do
    echo "[$(date '+%F %T')]: Backing $folder up to GitHub" | tee -a "$HOME/backup_log/$(date +%F).log"
    echo "[$(date '+%F %T')]: Adding changes to push" | tee -a "$HOME/backup_log/$(date +%F).log"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" add . | tee -a "$HOME/backup_log/$(date +%F).log"
    echo "[$(date '+%F %T')]: Committing to GitHub repository" | tee -a "$HOME/backup_log/$(date +%F).log"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" commit -m "backup $(date +%F)" | tee -a "$HOME/backup_log/$(date +%F).log"
    echo "[$(date '+%F %T')]: Pushing" | tee -a "$HOME/backup_log/$(date +%F).log"
    git -C "$HOME/$folder$LOCAL_FOLDER_APPEND" push -u origin $BRANCH | tee -a "$HOME/backup_log/$(date +%F).log"
  done
}

function google_backup {
  for i in ${!DRIVE_CONFIG_FOLDER_LIST[@]}
  do
    echo "[$(date '+%F %T')]: Backing up ${DRIVE_CONFIG_FOLDER_LIST[$i]} to Cloud storage provider" | tee -a "$HOME/backup_log/$(date +%F).log"
	  rclone copy "$HOME/${DRIVE_CONFIG_FOLDER_LIST[$i]}$LOCAL_FOLDER_APPEND" "$REMOTE":"${DRIVE_REMOTE_FOLDER_LIST[$i]}" --exclude "/.git/**" --transfers=1 --log-file="$HOME/backup_log/gdrive_${CONFIG_FOLDER_LIST[$i]}_backup_$(date +%F).log" --log-level=INFO
  done
}

function backup {
  BACKUP=$((10*$CLOUD + $GIT))
  CLOUD=${CLOUD:-0}
  GIT=${GIT:-0}
  ROTATION=${ROTATION:-1}

  while [[ $BREAK = 0 ]]
  do
  	case $BACKUP in
  		0)
  			echo "[$(date '+%F %T')]: No backups configured" | tee -a "$HOME/backup_log/$(date +%F).log"
  			;;
  		1)
        git_backup
  			;;
  		10)
  			google_backup
  			;;
  		11)
        git_backup
        google_backup
  	    ;;
  		*)
  			echo "[$(date '+%F %T')]: No valid backup configuration" | tee -a "$HOME/backup_log/$(date +%F).log"
  			echo "[$(date '+%F %T')]: Please check the config file!" | tee -a "$HOME/backup_log/$(date +%F).log"
        exit 1
  			;;
  	esac

    log_rotation

  	if [[ $INTERVAL = 0 ]]
  	then
  		sed -i 's/BREAK=0/BREAK=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
  	fi

  	import_config

  	if [[ $BREAK = 1 ]]
  	then
  		break
  	else
  		sleep $PAUSE
  	fi
  done
}

### BACKUP SCRIPT
import_config
time_check
backup
