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

echo "Backing up the klipper config files to GitHub" | tee /home/pi/git_log/$(date +%F)
echo "Adding changes to push" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config add .
echo "Committing to GitHub repository" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config commit -m "backup $(date +%F)" | tee -a /home/pi/git_log/$(date +%F)
echo "Pushing" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/git_log/$(date +%F)
case $ROTATION in
        0)
		echo "Log rotation is disabled" | tee -a /home/pi/git_log/$(date +%F)
                ;;
        1)
                find /home/pi/git_log -mindepth 1 -mtime +$DEL -delete
                ;;
        *)
                echo "No valid log rotation configuration" | tee -a /home/pi/git_log/$(date +%F)
                ;;
esac
