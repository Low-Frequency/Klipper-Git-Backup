#!/bin/bash

SPACE=" |'"

echo "Installing rclone"
curl https://rclone.org/install.sh | sudo bash

echo ""
echo "Installing expect"
sudo apt install expect -y

echo ""
echo "Setting up a remote location for your backup"

REMNAME="google drive"
while [[ $REMNAME =~ $SPACE ]]
do
	read -p 'Please name your remote storage (no spaces allowed): ' REMNAME
done

echo "##" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## File paths for cloud backup" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "REMOTE=$REMNAME" >> /home/pi/scripts/klipper_backup_script/backup.cfg

DIR="some directory"
echo ""
while [[ $DIR =~ $SPACE ]]
do
	read -p 'Please specify a folder to backup into (no spaces allowed): ' DIR
done

echo "FOLDER=\"$DIR\"" >> /home/pi/scripts/klipper_backup_script/backup.cfg
/home/pi/scripts/klipper_backup_script/drive.exp "$REMNAME"