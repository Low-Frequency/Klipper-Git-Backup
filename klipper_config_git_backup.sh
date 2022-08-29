#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
        less "$HOME/scripts/klipper_backup_script/manual"
        exit 1
elif [[ -n "$1" ]]
then
        echo "Try -h, or --help for the manual"
        exit 2
fi

PAUSE=1

configfile="$HOME/.config/klipper_backup_script/backup.cfg"
configfile_secured="$HOME/.config/klipper_backup_script/sec_backup.cfg"

sed -i "s/^BREAK=.*/BREAK=0/g" "$HOME/.config/klipper_backup_script/backup.cfg"

## Check if the file contains malicious code
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"
then
        echo "Config file is unclean, cleaning it..." >&2
        ## Filter the original to a new file
        egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
        configfile="$configfile_secured"
fi

## Importing the config
source "$configfile"

## Checking time unit
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

## Calculating days to keep the logs
DEL=$((($(date '+%s') - $(date -d "$RETENTION months ago" '+%s')) / 86400))

if [[ -z $CLOUD ]]
then
	CLOUD=0
fi

if [[ -z $GIT ]]
then
	GIT=0
fi

## Calculating which backups should be done
BACKUP=$((10*$CLOUD + $GIT))

## Backing up
while [[ $BREAK = 0 ]]
do
	case $BACKUP in
		0)
			## None specified
			echo "[$(date '+%F %T')]: No backups configured" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Exiting" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		1)
			## GitHub
			echo "[$(date '+%F %T')]: Backing up to GitHub" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Adding changes to push" | tee -a "$HOME/backup_log/$(date +%F).log"
			git -C "$HOME/klipper_config" add .
			echo "[$(date '+%F %T')]: Committing to GitHub repository" | tee -a "$HOME/backup_log/$(date +%F).log"
			git -C "$HOME/klipper_config" commit -m "backup $(date +%F)" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Pushing" | tee -a "$HOME/backup_log/$(date +%F).log"
			git -C "$HOME/klipper_config" push -u origin $BRANCH | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		10)
			## Google Drive
			echo "[$(date '+%F %T')]: Backing up to Cloud storage provider" | tee -a "$HOME/backup_log/$(date +%F).log"
			rclone copy "$HOME/klipper_config" "$REMOTE":"$FOLDER" --exclude "/.git/**" --transfers=1 --log-file="$HOME/backup_log/$(date +%F).log" --log-level=INFO
			;;
		11)
			## GitHub and Google Drive
			echo "[$(date '+%F %T')]: Backing up to GitHub" | tee -a "$HOME/backup_log/$(date +%F).log"
	                echo "[$(date '+%F %T')]: Adding changes to push" | tee -a "$HOME/backup_log/$(date +%F).log"
	                git -C "$HOME/klipper_config" add .
	                echo "[$(date '+%F %T')]: Committing to GitHub repository" | tee -a "$HOME/backup_log/$(date +%F).log"
	                git -C "$HOME/klipper_config" commit -m "backup $(date +%F)" | tee -a "$HOME/backup_log/$(date +%F).log"
	                echo "[$(date '+%F %T')]: Pushing" | tee -a "$HOME/backup_log/$(date +%F).log"
	                git -C "$HOME/klipper_config" push -u origin $BRANCH | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Backing up to Cloud storage provider" | tee -a "$HOME/backup_log/$(date +%F).log"
	                rclone copy "$HOME/klipper_config" "$REMOTE":"$FOLDER" --exclude "/.git/**" --transfers=1 --log-file="$HOME/backup_log/$(date +%F).log" --log-level=INFO
	                ;;
		*)
			## Config error
			echo "[$(date '+%F %T')]: No valid backup configuration" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Please check the config file!" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
	esac

	if [[ -z $ROTATION ]]
	then
		ROTATION=1
	fi

	## Log rotation
	case $ROTATION in
		0)
			## No action taken
			echo "[$(date '+%F %T')]: Log rotation is disabled" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		1)
			## Delete old logs
			echo "[$(date '+%F %T')]: Deleting old logs" | tee -a "$HOME/backup_log/$(date +%F).log"
			find "$HOME/backup_log" -mindepth 1 -mtime +$DEL -delete
			;;
		*)
			## Config error
			echo "[$(date '+%F %T')]: No valid log rotation configuration" | tee -a "$HOME/backup_log/$(date +%F).log"
			echo "[$(date '+%F %T')]: Please check the config file!" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
	esac

	if [[ $INTERVAL = 0 ]]
	then
		sed -i 's/BREAK=0/BREAK=1/g' "$HOME/.config/klipper_backup_script/backup.cfg"
	fi
	source "$configfile"
	if [[ $BREAK = 1 ]]
	then
		break
	else
		sleep $PAUSE
	fi
done
