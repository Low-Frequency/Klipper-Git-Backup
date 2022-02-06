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

echo "Removing log files"
rm -r /home/pi/backup_log
if command -v rclone
then
	echo "Removing cloud storage"
	/home/pi/scripts/klipper_backup_script/delete_remote.exp
	echo "Uninstalling rclone"
	sudo rm /home/pi/.config/rclone/rclone.conf
	sudo rm /usr/bin/rclone
	sudo rm /usr/local/share/man/man1/rclone.1
	echo "Uninstalling expect"
	sudo apt purge --auto-remove expect
fi
echo "Removing backup service"
sudo systemctl disable gitbackup.service
sudo rm /etc/systemd/system/gitbackup.service
echo "Removing custom commands"
sudo rm /usr/local/bin/backup
sudo rm /usr/local/bin/restore
sudo rm /usr/local/bin/uninstall_backup_utility
echo "Deleting scripts"
rm -r /home/pi/scripts/klipper_backup_script
