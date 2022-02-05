#!/bin/bash

configfile='/home/pi/scripts/klipper_backup_script/backup.cfg'
configfile_secured='/home/pi/scripts/klipper_backup_script/sec_backup.cfg'

# check if the file contains malicious code
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"
then
        echo "Config file is unclean, cleaning it..." >&2
        # filter the original to a new file
        egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
        configfile="$configfile_secured"
fi

# importing the config
source "$configfile"

DEL=$((($(date '+%s') - $(date -d "$RETENTION months ago" '+%s')) / 86400))

BACKUP=$((10*$CLOUD + $GIT))

case $BACKUP in
	0)
		echo "No backups configured"
		echo "Exiting"
		;;
	1)
		echo "Backing up to GitHub" | tee /home/pi/backup_log/$(date +%F).log
		echo "Adding changes to push" | tee -a /home/pi/backup_log/$(date +%F).log
		git -C /home/pi/klipper_config add .
		echo "Committing to GitHub repository" | tee -a /home/pi/backup_log/$(date +%F).log
		git -C /home/pi/klipper_config commit -m "backup $(date +%F)" | tee -a /home/pi/backup_log/$(date +%F).log
		echo "Pushing" | tee -a /home/pi/backup_log/$(date +%F).log
		git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/backup_log/$(date +%F).log
		;;
	10)
		echo "Backing up to Cloud storage provider" | tee /home/pi/backup_log/$(date +%F).log
		rclone sync /home/pi/klipper_config "$REMOTE":"$FOLDER" --exclude "/.git/**" --transfers=1 --log-file=/home/pi/backup_log/"$(date +%F)".log --log-level=INFO
		;;
	11)
		echo "Backing up to GitHub" | tee /home/pi/backup_log/$(date +%F).log
                echo "Adding changes to push" | tee -a /home/pi/backup_log/$(date +%F).log
                git -C /home/pi/klipper_config add .
                echo "Committing to GitHub repository" | tee -a /home/pi/backup_log/$(date +%F).log
                git -C /home/pi/klipper_config commit -m "backup $(date +%F)" | tee -a /home/pi/backup_log/$(date +%F).log
                echo "Pushing" | tee -a /home/pi/backup_log/$(date +%F).log
                git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/backup_log/$(date +%F).log
		echo "Backing up to Cloud storage provider" | tee /home/pi/backup_log/$(date +%F).log
                rclone sync /home/pi/klipper_config "$REMOTE":"$FOLDER" --exclude "/.git/**" --transfers=1 --log-file=/home/pi/backup_log/"$(date +%F)".log --log-level=INFO
                ;;
	*)
		echo "No valid backup configuration" | tee -a /home/pi/backup_log/$(date +%F).log
		echo "Please check the config file!" | tee -a /home/pi/backup_log/$(date +%F).log
		;;
esac

case $ROTATION in
	0)
		echo "Log rotation is disabled" | tee -a /home/pi/backup_log/$(date +%F).log
		;;
	1)
		find /home/pi/backup_log -mindepth 1 -mtime +$DEL -delete
		;;
	*)
		echo "No valid log rotation configuration" | tee -a /home/pi/backup_log/$(date +%F).log
		echo "Please check the config file!" | tee -a /home/pi/backup_log/$(date +%F).log
		;;
esac
