#!/bin/bash

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
echo "Deleting scripts"
rm -r /home/pi/scripts/klipper_backup_script
