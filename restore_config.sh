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

configfile="$HOME/.config/klipper_backup_script/backup.cfg"
configfile_secured="$HOME/.config/klipper_backup_script/sec_backup.cfg"

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

MODE=9
SOURCE=9

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
				echo "GitHub selected as backup source" | tee -a "$HOME/backup_log/$(date +%F).log"
				;;
			2)
				echo "Google Drive selected as backup source" | tee -a "$HOME/backup_log/$(date +%F).log"
				;;
			*)
				echo -e "${RED}Please select a valid source${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
				;;
		esac
	done
## Only Git configured
elif [ $GIT = 1 ]
then
	echo "GitHub selected as backup source" | tee -a "$HOME/backup_log/$(date +%F).log"
	SOURCE=1
## Only Google Drive configured
elif [ $CLOUD = 1 ]
then
	echo "Google Drive selected as backup source" | tee -a "$HOME/backup_log/$(date +%F).log"
	SOURCE=2
else
	echo -e "${RED}Restoring is not possible${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
	echo -e "${RED}Please make sure you have a valid config file${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
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
			echo "Restoring to existing installation" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		2)
			echo "Restoring to new installation" | tee -a "$HOME/backup_log/$(date +%F).log"
			;;
		*)
			echo -e "${RED}Please select a valid restoring method${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
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
	echo -e "${RED}Error while calculating which action to take${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
	echo "Aborting" | tee -a "$HOME/backup_log/$(date +%F).log"
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
	                echo "Restoring old configuration" | tee -a "$HOME/backup_log/$(date +%F).log"
	                git -C "$HOME/klipper_config" fetch --all | tee -a "$HOME/backup_log/$(date +%F).log"
	                git -C "$HOME/klipper_config" reset --hard origin/master | tee -a "$HOME/backup_log/$(date +%F).log"
	        else
	                echo -e "${RED}Restore canceled${NONE}"
	        fi
		;;
	2)
		## GitHub to new installation
		echo "Checking SSH key" | tee -a "$HOME/backup_log/$(date +%F).log"
	        if [[ -f "$HOME/.ssh/github_id_rsa" ]]
	        then
        	        if [[ -d "$HOME/klipper_config/.git" ]]
	                then
	                        echo -e "${RED}ERROR!${NONE} The klipper_config folder is already a git repository" | tee -a "$HOME/backup_log/$(date +%F).log"
	                        echo "Please use restore mode 1" | tee -a "$HOME/backup_log/$(date +%F).log"
	                else
	                        URL="https://github.com/$USER/$REPO"

	                        echo "Backing up the default klipper_config folder" | tee -a "$HOME/backup_log/$(date +%F).log"
	                        mv "$HOME/klipper_config /home/pi/klipper_config_bak"

	                        echo "Cloning the repo" | tee -a "$HOME/backup_log/$(date +%F).log"
	                        git -C "$HOME" clone "$URL" | tee -a "$HOME/backup_log/$(date +%F).log"
	                        mv "/home/pi/$REPO" "$HOME/klipper_config"

	                        read -p 'Do you want to keep the old folder? [y|n] ' DEL
	                        if [ "$DEL" = "n" ]
	                        then
	                                echo "Deleting backup" | tee -a "$HOME/backup_log/$(date +%F).log"
	                                rm -r "$HOME/klipper_config_bak"
	                        else
	                                echo "Old folder is located at $HOME/klipper_config_bak" | tee -a "$HOME/backup_log/$(date +%F).log"
	                        fi
	                fi
	        else
	                echo -e "${RED}ERROR!${NONE} Please set up a SSH key pair" | tee -a "$HOME/backup_log/$(date +%F).log"
	        fi
		;;
	3)
		## Google Drive to existing installation
		echo "Backing up existing files" | tee -a "$HOME/backup_log/$(date +%F).log"
		mkdir "$HOME/klipper_config_bak"
		mv "$HOME/klipper_config/*.cfg /home/pi/klipper_config_bak"
		mv "$HOME/klipper_config/*.conf /home/pi/klipper_config_bak"

		echo "Restoring backup" | tee -a "$HOME/backup_log/$(date +%F).log"
		rclone copy "$REMOTE":"$FOLDER" "$HOME/klipper_config_restore" --transfers=1 --log-file="$HOME/backup_log/$(date +%F).log" --log-level=INFO

		read -p 'Do you want to keep the old files? [y|n] ' DEL
		if [ "$DEL" = "n" ]
		then
			echo "Deleting backup" | tee -a "$HOME/backup_log/$(date +%F).log"
			rm -r "$HOME/klipper_config_bak"
		else
			echo "Old files are located at $HOME/klipper_config_bak" | tee -a "$HOME/backup_log/$(date +%F).log"
		fi
		;;
	4)
		## Google Drive to new installation
                echo "Backing up existing files" | tee -a "$HOME/backup_log/$(date +%F).log"
                mkdir "$HOME/klipper_config_bak"
                mv "$HOME/klipper_config/*.cfg /home/pi/klipper_config_bak"
                mv "$HOME/klipper_config/*.conf /home/pi/klipper_config_bak"

                echo "Restoring backup" | tee -a "$HOME/backup_log/$(date +%F).log"
                rclone copy "$REMOTE":"$FOLDER" "$HOME/klipper_config_restore" --transfers=1 --log-file="$HOME/backup_log/$(date +%F).log" --log-level=INFO

                read -p 'Do you want to keep the old files? [y|n] ' DEL
                if [ "$DEL" = "n" ]
                then
                        echo "Deleting backup" | tee -a "$HOME/backup_log/$(date +%F).log"
                        rm -r "$HOME/klipper_config_bak"
                else
                        echo "Old files are located at $HOME/klipper_config_bak" | tee -a "$HOME/backup_log/$(date +%F).log"
                fi
		;;
	*)
		## Wrong action chosen
		echo "${RED}Something went wrong while calculating the right restore action${NONE}" | tee -a "$HOME/backup_log/$(date +%F).log"
		;;
esac
