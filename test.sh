#!/bin/bash

USER="I do work"
sed -i "s/USER=/USER=$USER/g" /home/pi/scripts/klipper_backup_script/sample_config/backup.cfg
cat /home/pi/scripts/klipper_backup_script/sample_config/backup.cfg
