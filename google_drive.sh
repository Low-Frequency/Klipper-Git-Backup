#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
        less /home/pi/scripts/klipper_backup_script/manual
        exit 1
elif [[ -n "$1" ]]
then
        echo "Try -h, or --help for the manual"
        exit 2
fi

## Regex for string checking
SPACE=" |'"
SLASH="\/"

## Installing dependencies
echo "Installing rclone"
curl https://rclone.org/install.sh | sudo bash

echo ""
echo "Installing expect"
sudo apt install expect

echo ""
echo "Setting up a remote location for your backup"

## Set up remote location
REMNAME="google drive"
while [[ $REMNAME =~ $SPACE || $REMNAME =~ $SLASH ]]
do
	read -p 'Please name your remote storage (no spaces, or / allowed): ' REMNAME
done

## Adding config lines
sed -i "s/REMOTE=none/REMOTE=$REMNAME/g" /home/pi/.config/klipper_backup_script/backup.cfg

## Specifying backup folder
DIR="some directory"
echo ""
while [[ $DIR =~ $SPACE || $DIR =~ $SLASH ]]
do
	read -p 'Please specify a folder to backup into (no spaces, or / allowed): ' DIR
done

## Adding config lines
sed -i "s/FOLDER=none/FOLDER=\"$DIR\"/g" /home/pi/.config/klipper_backup_script/backup.cfg

## Configuring rclone
/home/pi/scripts/klipper_backup_script/drive.exp "$REMNAME"

## Activating Google Drive backup
sed -i 's/CLOUD=0/CLOUD=1/g' /home/pi/.config/klipper_backup_script/backup.cfg

echo "Google Drive backup has been configured and activated"
