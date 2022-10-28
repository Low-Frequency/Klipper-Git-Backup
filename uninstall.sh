#!/bin/bash

echo "Removing log files"
rm -r "$HOME/backup_log"
if command -v rclone
then
	echo "Removing cloud storage"
	"$HOME/scripts/klipper_backup_script/delete_remote.exp"
	echo "Uninstalling rclone"
	sudo rm "$HOME/.config/rclone/rclone.conf"
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
sudo rm /usr/local/bin/reconfigure_git
sudo rm /usr/local/bin/reconfigure_drive
sudo rm /usr/local/bin/uninstall_bak_util
sudo rm /usr/local/bin/update_bak_util
echo "Deleting config"
rm -r "$HOME/.config/klipper_backup_script"
echo "Deleting scripts"
rm -r "$HOME/scripts/klipper_backup_script"
