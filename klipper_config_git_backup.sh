#!/bin/bash

DATE=$(date +%F)
ROTATE=1
DEL=$((($(date '+%s') - $(date -d '6 months ago' '+%s')) / 86400))
COUNT=60

touch /home/pi/git_log/"$DATE"
echo "Backing up the klipper config files to GitHub" | tee /home/pi/git_log/"$DATE"
echo "Waiting for network" | tee -a /home/pi/git_log/"$DATE"
while [[ $COUNT -ne 0 ]]
do
        ping -c 1 8.8.8.8 > /dev/null
        rc=$?
        if [[ $rc -eq 0 ]]
        then
                (( COUNT = 1 ))
        else
                sleep 1
        fi
        (( COUNT = COUNT - 1 ))
done

if [[ $rc -eq 0 ]]
then
        echo "Adding changes to push" | tee -a /home/pi/git_log/"$DATE"
        git -C /home/pi/klipper_config add .
        echo "Committing to GitHub repository" | tee -a /home/pi/git_log/"$DATE"
        git -C /home/pi/klipper_config commit -m "backup $DATE" | tee -a /home/pi/git_log/"$DATE"
        echo "Pushing" | tee -a /home/pi/git_log/"$DATE"
        git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/git_log/"$DATE"
        if [[ "$ROTATE" -eq 1 ]]
        then
                find /home/pi/git_log -mindepth 1 -mtime +$DEL -delete
        fi
else
        echo "Network is down. Please make sure your WiFi works!" | tee -a /home/pi/git_log/"$DATE"
fi
