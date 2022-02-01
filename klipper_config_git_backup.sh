#!/bin/bash

DATE=$(date +%F)

sleep 30
touch /home/pi/git_log/"$DATE"
echo "Adding SSH key to agent" >> /home/pi/git_log/"$DATE"
eval "$(ssh-agent -s)" >> /home/pi/git_log/"$DATE"
ssh-add /home/pi/.ssh/github_id_rsa >> /home/pi/git_log/"$DATE"
echo "Adding changes to push" >> /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config add .
echo "Committing to GitHub repository" >> /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config commit -m "backup $DATE" >> /home/pi/git_log/"$D$
echo "Pushing" >> /home/pi/git_log/"$DATE"
git -C /home/pi/klipper_config push -u origin master >> /home/pi/git_log/"$DATE"
