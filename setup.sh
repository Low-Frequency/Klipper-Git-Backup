#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
        less "$HOME/scripts/klipper_backup_script/manual"
        exit 1
elif [[ -n "$1" ]]
then
        echo "Try -h, or --help for the manual"
        exit 2
fi

echo "I strongly recommend you update your Raspberry Pi first"

## Update Pi
UPDATE="o"
while [[ "$UPDATE" != "y" && "$UPDATE" != "n" ]]
do
	read -p 'Do you want to update now? [y|n] ' UPDATE
	case $UPDATE in
		n)
			echo "The setup might fail"
			echo "Please run the uninstall script and update your Raspberry Pi if the setup fails"
			;;
		y)
			echo "Please update your system now and execute the setup again"
			echo "this is done with this command: sudo apt update && sudo apt upgrade"
			echo "After that you can just type this to execute the setup again: ./setup.sh"
			exit 3
			;;
		*)
			echo "Please provide a valid answer"
			;;
	esac
done

## Installing git
echo "Checking if git is installed"

if ! command -v git &> /dev/null
then
        echo "Git is not installed"
        echo "Installing git"
        sudo apt install git -y
else
        echo "Git already installed"
fi

echo ""

## Creating necessary directories
echo ""
echo "Checking for dierectories"

if [[ -d "$HOME/scripts" ]]
then
        echo "Scripts folder already exists"
else
        echo "Crating scripts folder"
        mkdir "$HOME/scripts"
fi

if [[ -d "$HOME/backup_log" ]]
then
        echo "Log folder already exists"
else
        echo "Creating log folder"
        mkdir "$HOME/backup_log"
fi

## Fetching backup script
echo "Downloading backup script"
if [[ ! -d "$HOME/scripts/klipper_backup_script" ]]
then
	git -C "$HOME/scripts" clone https://github.com/Low-Frequency/klipper_backup_script
else
	git pull origin main
fi

chmod +x "$HOME/scripts/klipper_backup_script/*.sh"

if [[ ! -d "$HOME/.config/klipper_backup_script" ]]
then
        mkdir -p "$HOME/.config/klipper_backup_script"
fi

mv "$HOME/scripts/klipper_backup_script/backup.cfg" "$HOME/.config/klipper_backup_script/"

## Adding config lines
echo ""
echo "Configuring the script"

## Log rotation config

echo ""
echo "Do you want to enable log rotation?"
echo "This can save space on your SD card"
echo "This is recommended, if you choose to backup to Google Drive"
echo ""

"$HOME/scripts/klipper_backup_script/log_rotation.sh"

## Choosing backup locations
echo ""
echo "Which backup locations do you want to enable?"
echo "Type y to enable a backup location"
echo "Type n to disable a backup location"
echo ""

G=9
C=9
while [[ "$G" != "y" && "$G" != "n" ]]
do
	read -p 'Do you want to enable GitHub as a backup location? [y|n] ' G
	case $G in
		n)
			echo "GitHub backup disabled"
			sed -i 's/^GIT=.*/GIT=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
			;;
		y)
			echo "GitHub backup enabled"
			echo "Configuring..."
			"$HOME/scripts/klipper_backup_script/git_repo.sh"
			echo ""
			;;
		*)
			echo "Please provide a valid answer"
			echo ""
			;;
	esac
done

echo ""

while [[ "$C" != "y" && "$C" != "n" ]]
do
        read -p 'Do you want to enable Google Drive backup? [y|n] ' C
        case $C in
                n)
                        echo "Google Drive backup disabled"
                        sed -i 's/^CLOUD=.*/CLOUD=0/g' "$HOME/.config/klipper_backup_script/backup.cfg"
                        ;;
                y)
                        echo "Google Drive backup enabled"
			chmod +x "$HOME/scripts/klipper_backup_script/drive.exp"
			chmod +x "$HOME/scripts/klipper_backup_script/delete_remote.exp"
			echo "Configuring..."
			"$HOME/scripts/klipper_backup_script/google_drive.sh"
			echo ""
                        ;;
                *)
                        echo "Please provide a valid answer"
                        echo ""
                        ;;
        esac
done

echo ""

## Configuring backup intervals
"$HOME/scripts/klipper_backup_script/scheduled_backups.sh"

## Enabling automatic backups
sed -i "s/^User=.*/User=$USER/g" "$HOME/scripts/klipper_backup_script/gitbackup.service"
sed -i "s|ExecStart=.*|ExecStart=$HOME\/scripts\/klipper_backup_script\/klipper_config_git_backup.sh|g" "$HOME/scripts/klipper_backup_script/gitbackup.service"
echo ""
echo "Setting up the service"
sudo mv "$HOME/scripts/klipper_backup_script/gitbackup.service" /etc/systemd/system/gitbackup.service
sudo chown root:root /etc/systemd/system/gitbackup.service
sudo systemctl enable gitbackup.service
sudo systemctl start gitbackup.service

echo ""

## Testing GitHub connection
if [ "$G" = "y" ]
then
	echo "Testing SSH connention"
	ssh -T git@github.com
	echo ""
fi

## Backing up/restoring
NOW="o"
BAK="o"
while [[ "$NOW" != "y" && "$NOW" != "n" ]]
do
	read -p 'Do you want to restore a backup, or do a backup now? [y|n] ' NOW
	case $NOW in
		y)
			echo "b: backup"
			echo "r: restore"
			while [[ "$BAK" != "b" && "$BAK" != "r" ]]
			do
				read -p 'Do you want to restore a backup, or do a backup? [b|r] ' BAK
				case $BAK in
					b)
						ACT=1
						;;
					r)
						ACT=2
						;;
					*)
						echo "Please choose a valid action"
						;;
				esac
			done
			;;
		n)
			echo "Backing up is recommended"
			echo "Don't forget to do that later"
			;;
		*)
			echo "Please choose avalid action"
			;;
	esac
done

configfile="$HOME/.config/klipper_backup_script/backup.cfg"
configfile_secured="$HOME/.config/klipper_backup_script/sec_backup.cfg"

sed -i "s/^BREAK=.*/BREAK=0/g" "$HOME/.config/klipper_backup_script/backup.cfg"

## Check if the file contains malicious code
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"
then
        echo "Config file is unclean, cleaning it..." >&2
        ## Filter the original to a new file
        egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
        configfile="$configfile_secured"
fi

## Importing the config
source "$configfile"

case $ACT in
	1)
		if [[ $INTERVAL = 1 ]]
		then
			echo "You need to reboot to enable the backups"
			echo "Backups will be done automatically then"
		elif [[ $INTERVAL = 0 ]]
		then
			echo "Backing up your config to the specified locations"
			"$HOME/scripts/klipper_backup_script/klipper_config_git_backup.sh"
		else
			echo "Something went wrong while configuring the script"
			echo "Please check the config"
		fi
		;;
	2)
		echo "Restoring backup"
		"$HOME/scripts/klipper_backup_script/restore_config.sh"
		;;
	*)
		echo "No backup/restore action chosen"
		;;
esac

sudo ln -s "$HOME/scripts/klipper_backup_script/klipper_config_git_backup.sh" /usr/local/bin/backup
sudo ln -s "$HOME/scripts/klipper_backup_script/restore_config.sh" /usr/local/bin/restore
sudo ln -s "$HOME/scripts/klipper_backup_script/uninstall.sh" /usr/local/bin/uninstall_bak_util
sudo ln -s "$HOME/scripts/klipper_backup_script/update.sh" /usr/local/bin/update_bak_util
sudo ln -s "$HOME/scripts/klipper_backup_script/git_repo.sh" /usr/local/bin/reconfigure_git
sudo ln -s "$HOME/scripts/klipper_backup_script/google_drive.sh" /usr/local/bin/reconfigure_drive

## Deleting now unecessary setup script
rm "$HOME/setup.sh"
