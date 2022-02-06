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

echo "I strongly advise you update your Raspberry Pi first"

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
			echo "Updateing now"
			sudo apt update && sudo apt update
			;;
		*)
			echo "Please provide a valid answer"
			;;
	esac
done

read -p 'Do you want to update now? [y|n] ' UPDATE

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

## Fetching backup script
echo "Cloning backup script"
git -C /home/pi/scripts clone https://github.com/Low-Frequency/klipper_backup_script
chmod +x /home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
chmod +x /home/pi/scripts/klipper_backup_script/restore_config.sh
chmod +x /home/pi/scripts/klipper_backup_script/uninstall.sh
chmod +x /home/pi/scripts/klipper_backup_script/git_repo.sh
chmod +x /home/pi/scripts/klipper_backup_script/google_drive.sh

## Adding config lines
echo ""
echo "Configuring the script"

## Log rotation config

echo ""
echo "Do you want to enable log rotation?"
echo "This can save space on your SD card"
echo "This is recommended, if you choose to backup to Google Drive"
echo ""

ROT="o"
while [[ "$ROT" != "y" && "$ROT" != "n" ]]
do
	read -p 'Enable log rotation? [y|n] ' ROT

	case $ROT in
		n)
			sed -i 's/ROTATION=1/ROTATION=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
			echo "Log rotation disabled"
			break
			;;
		y)
                        echo "Log rotation enabled"
			break
                        ;;
		*)
			echo "Please provide a valid configuration"
			echo ""
			;;
	esac
done

echo "##" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo "## Time in months to keep the logs" >> /home/pi/scripts/klipper_backup_script/backup.cfg
echo ""

if [[ "$ROT" = "y" ]]
then
	read -p "How long should the logs be kept (in months) " KEEP
	sed -i "s/RETENTION=6/RETENTION=$KEEP/g" /home/pi/scripts/klipper_backup_script/backup.cfg
fi

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
			sed -i 's/GIT=1/GIT=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
			;;
		y)
			echo "GitHub backup enabled"
			;;
		*)
			echo "Please provide a valid configuration"
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
                        sed -i 's/CLOUD=1/CLOUD=0/g' /home/pi/scripts/klipper_backup_script/backup.cfg
                        ;;
                y)
                        echo "Google Drive backup enabled"
			chmod +x /home/pi/scripts/klipper_backup_script/drive.exp
			chmod +x /home/pi/scripts/klipper_backup_script/delete_remote.exp
                        ;;
                *)
                        echo "Please provide a valid configuration"
                        echo ""
                        ;;
        esac
done

## Creating necessary directories
echo ""
echo "Checking for dierectories"

if [[ -d /home/pi/scripts ]]
then
        echo "Scripts folder already exists"
else
        echo "Crating scripts folder"
        mkdir /home/pi/scripts
fi

if [[ -d /home/pi/backup_log ]]
then
        echo "Log folder already exists"
else
        echo "Creating log folder"
        mkdir /home/pi/backup_log
fi

## GitHub setup
if [ "$G" = "y" ]
then
	/home/pi/scripts/klipper_backup_script/git_repo.sh
fi

echo ""

## Google Drive setup
if [ "$C" = "y" ]
then
	/home/pi/scripts/klipper_backup_script/google_drive.sh
fi

## Enabling automatic backups
echo ""
echo "Setting up the service"
sudo mv /home/pi/scripts/klipper_backup_script/gitbackup.service /etc/systemd/system/gitbackup.service
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

case $ACT in
	1)
		echo "Pushing the first backup to your specified backup location(s)"
		/home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh
		;;
	2)
		echo "Restoring backup"
		/home/pi/scripts/klipper_backup_script/restore_config.sh
		;;
	*)
		echo "Error while backing up/restoring"
		;;
esac

## Deleting now unecessary setup script
rm /home/pi/setup.sh
