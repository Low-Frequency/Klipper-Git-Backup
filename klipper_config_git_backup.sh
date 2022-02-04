#!/bin/bash

DEL=$((($(date '+%s') - $(date -d '6 months ago' '+%s')) / 86400))

touch /home/pi/git_log/$(date +%F)
echo "Backing up the klipper config files to GitHub" | tee /home/pi/git_log/$(date +%F)
echo "Adding changes to push" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config add .
echo "Committing to GitHub repository" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config commit -m "backup $(date +%F)" | tee -a /home/pi/git_log/$(date +%F)
echo "Pushing" | tee -a /home/pi/git_log/$(date +%F)
git -C /home/pi/klipper_config push -u origin master | tee -a /home/pi/git_log/$(date +%F)
find /home/pi/git_log -mindepth 1 -mtime +$DEL -delete
