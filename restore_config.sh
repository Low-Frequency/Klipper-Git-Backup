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

configfile='/home/pi/scripts/klipper_backup_script/backup.cfg'
configfile_secured='/home/pi/scripts/klipper_backup_script/sec_backup.cfg'

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

## Setting error text colors
YELLOW='\033[0;33m'
RED='\033[0;31m'
NONE='\033[0m'

## Choosing backup source
if [[ $GIT = 1 && $CLOUD = 1 ]]
then
	echo "From which source should the backup be restored?"
	echo "1: GitHub"
	echo "2: Google Drive"
	while [[ $SOURCE != 1 && $SOURCE != 2 ]]
	do
		read -p 'Backup source: ' SOURCE
		case $SOURCE in
			1)
				echo "GitHub selected as backup source"
				;;
			2)
				echo "Google Drive selected as backup source"
				;;
			*)
				echo -e "${RED}Please select a valid source${NONE}"
				;;
		esac
	done
## Only Git configured
elif [ $GIT = 1 ]
then
	echo "GitHub selected as backup source"
## Only Google Drive configured
elif [ $CLOUD = 1 ]
then
	echo "Google Drive selected as backup source"
else
	echo -e "${RED}Restoring is not possible${NONE}"
	echo -e "${RED}Please make sure you have a valid config file${NONE}"
	exit 1
fi

## Choosing restore mode
echo "Which restoring mode do you want?"
echo "1: Restore an old config to an existing installation"
echo "2: Restore a config to a new installation"

while [[ $MODE != 1 && $MODE != 2 ]]
do
	read -p 'Please enter the restore mode [1|2] ' MODE
	case $MODE in
		1)
			echo "Restoring to existing installation"
			;;
		2)
			echo "Restoring to new installation"
			;;
		*)
			echo -e "${RED}Please select a valid restoring method${NONE}"
			;;
	esac
done

## Setting actions to take
if [[ $SOURCE = 1 && $MODE = 1 ]]
then
	## GitHub to existing installation
	ACTION=1
elif [[ $SOURCE = 1 && $MODE = 2 ]]
then
	## GitHub to new installation
	ACTION=2
elif [[ $SOURCE = 2 && $MODE = 1 ]]
then
	## Google Drive to existing installation
	ACTION=3
elif [[ $SOURCE = 2 && $MODE = 2 ]]
then
	## Google Drive to new installation
	ACTION=4
else
	## Input error
	echo -e "${RED}Error while calculating which action to take${NONE}"
	echo "Aborting"
	exit 2
fi

## Restoring
case $ACTION in
	1)
		## GitHub to existing installation
		echo -e "${YELLOW}WARNING!${NONE} This will delete your current configuration!"
	        read -p 'Continue? [y|n] ' CONTINUE
	        if [ "$CONTINUE" = "y" ]
	        then
	                echo "Restoring old configuration"
	                git -C /home/pi/klipper_config fetch --all
	                git -C /home/pi/klipper_config reset --hard origin/master
	        else
	                echo -e "${RED}Restore canceled${NONE}"
	        fi
		;;
	2)
		## GitHub to new installation
		echo "Checking SSH key"
	        if [[ -f /home/pi/.ssh/github_id_rsa ]]
	        then
        	        if [[ -d /home/pi/klipper_config/.git ]]
	                then
	                        echo -e "${RED}ERROR!${NONE} The klipper_config folder is already a git repository"
	                        echo "Please use restore mode 1"
	                else
	                        URL="https://github.com/$USER/$REPO"

	                        echo "Backing up the default klipper_config folder"
	                        mv /home/pi/klipper_config /home/pi/klipper_config_bak

	                        echo "Cloning the repo"
	                        git -C /home/pi clone "$URL"
	                        mv "/home/pi/$REPO" /home/pi/klipper_config

	                        read -p 'Do you want to keep the old folder? [y|n] ' DEL
	                        if [ "$DEL" = "n" ]
	                        then
	                                echo "Deleting backup"
	                                rm -r /home/pi/klipper_config_bak
	                        else
	                                echo "Old folder is located at /home/pi/klipper_config_bak"
	                        fi
	                fi
	        else
	                echo -e "${RED}ERROR!${NONE} Please set up a SSH key pair"
	        fi
		;;
	3)
		## Google Drive to existing installation
		echo "Backing up existing files"
		mkdir /home/pi/klipper_config_bak
		mv /home/pi/klipper_config/*.cfg /home/pi/klipper_config_bak
		mv /home/pi/klipper_config/*.conf /home/pi/klipper_config_bak

		echo "Restoring backup"
		rclone copy "$REMOTE":"$FOLDER" /home/pi/klipper_config_restore --transfers=1

		read -p 'Do you want to keep the old files? [y|n] ' DEL
		if [ "$DEL" = "n" ]
		then
			echo "Deleting backup"
			rm -r /home/pi/klipper_config_bak
		else
			echo "Old files are located at /home/pi/klipper_config_bak"
		fi
		;;
	4)
		## Google Drive to new installation
                echo "Backing up existing files"
                mkdir /home/pi/klipper_config_bak
                mv /home/pi/klipper_config/*.cfg /home/pi/klipper_config_bak
                mv /home/pi/klipper_config/*.conf /home/pi/klipper_config_bak

                echo "Restoring backup"
                rclone copy "$REMOTE":"$FOLDER" /home/pi/klipper_config_restore --transfers=1

                read -p 'Do you want to keep the old files? [y|n] ' DEL
                if [ "$DEL" = "n" ]
                then
                        echo "Deleting backup"
                        rm -r /home/pi/klipper_config_bak
                else
                        echo "Old files are located at /home/pi/klipper_config_bak"
                fi
		;;
	*)
		## Wrong action chosen
		echo "${RED}Something went wrong while calculating the right restore action${NONE}"
		;;
esac
