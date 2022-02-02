#!/bin/bash

DATE=$(date +%F)
DEL=$((($(date '+%s') - $(date -d '6 months ago' '+%s')) / 86400))

sleep 15
touch /home/pi/git_log/"$DATE"
echo "Adding SSH key to agent" | tee -a /home/pi/git_log/"$DATE"
eval "$(ssh-agent -s)" | tee -a /home/pi/git_log/"$DATE"
ssh-add /home/pi/.ssh/github_id_rsa | tee -a /home/pi/git_log/"$DATE"
echo "Adding changes to push" | tee -a /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config add .
echo "Committing to GitHub repository" | tee -a /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config commit -m "backup $DATE" | tee -a /home/pi/git_log/"$DATE"
echo "Pushing" | tee -a /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/git_log/"$DATE"
find /home/pi/git_log -mindepth 1 -mtime +$DEL -delete
