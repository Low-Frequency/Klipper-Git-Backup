#!/bin/bash

rm -r /home/pi/git_log
sudo systemctl disable gitbackup.service
sudo rm /etc/systemd/system/gitbackup.service
rm -r /home/pi/scripts/klipper_backup_script
